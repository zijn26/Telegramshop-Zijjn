import random
import logging
import datetime
from decimal import Decimal
from typing import Optional, Tuple
from sqlalchemy import select

from bot.database.main import Database
from bot.database.models.main import User, Operations
from bot.database.models.gacha import GachaSettings, GachaItem, GachaUserWin
from bot.database.methods.read import check_user_cached, invalidate_user_cache

logger = logging.getLogger(__name__)


async def get_gacha_settings() -> GachaSettings:
    """Retrieve global GachaSettings instance (creates default if missing)."""
    async with Database().session() as session:
        settings = (await session.scalars(select(GachaSettings))).first()
        if not settings:
            settings = GachaSettings(
                spin_price=Decimal("10000.00"),
                is_active=True,
                title="🎰 Vòng Quay Gacha May Mắn",
                description="Thử vận may ngay hôm nay với nhiều phần quà hấp dẫn!"
            )
            session.add(settings)
            await session.flush()
            await session.refresh(settings)
        return settings


async def get_active_gacha_items() -> list[GachaItem]:
    """Retrieve all active items in the Gacha pool."""
    async with Database().session() as session:
        items = (await session.scalars(
            select(GachaItem)
            .where(GachaItem.is_active == True)
            .where((GachaItem.stock_quantity == -1) | (GachaItem.stock_quantity > 0))
            .order_by(GachaItem.drop_rate.desc(), GachaItem.id)
        )).all()
        return list(items)


async def spin_gacha_for_user(user_id: int) -> Tuple[bool, str, Optional[GachaItem], str]:
    """
    Execute a Gacha spin for user:
    - Check system active status & user balance.
    - Deduct spin price.
    - Select prize based on weighted random probabilities.
    - Apply reward & record win history.
    """
    async with Database().session() as session:
        settings = (await session.scalars(select(GachaSettings))).first()
        if not settings or not settings.is_active:
            return False, "❌ Hệ thống Gacha hiện đang bảo trì. Vui lòng quay lại sau!", None, ""

        user = (await session.scalars(select(User).where(User.telegram_id == user_id))).first()
        if not user:
            return False, "❌ Không tìm thấy thông tin tài khoản!", None, ""

        spin_price = Decimal(str(settings.spin_price))
        if Decimal(str(user.balance)) < spin_price:
            return False, f"❌ Số dư không đủ! Mỗi lượt quay cần <b>{spin_price:,.0f} VND</b>, số dư hiện tại của bạn là <b>{Decimal(str(user.balance)):,.0f} VND</b>.", None, ""

        # Fetch active items pool
        items = (await session.scalars(
            select(GachaItem)
            .where(GachaItem.is_active == True)
            .where((GachaItem.stock_quantity == -1) | (GachaItem.stock_quantity > 0))
        )).all()
        items = list(items)

        if not items:
            return False, "❌ Hiện chưa có vật phẩm nào trong kho Gacha!", None, ""

        # Deduct balance
        user.balance = Decimal(str(user.balance)) - spin_price
        session.add(Operations(
            user_id=user_id,
            operation_value=-int(spin_price),
            operation_time=datetime.datetime.now(datetime.timezone.utc)
        ))

        # Select item by drop_rate weights
        weights = [float(item.drop_rate) for item in items]
        selected_item = random.choices(items, weights=weights, k=1)[0]

        # Re-fetch item attached to current session
        item_db = await session.get(GachaItem, selected_item.id)

        # Decrement stock if finite
        if item_db.stock_quantity > 0:
            item_db.stock_quantity -= 1

        reward_detail = ""
        # Process reward type
        if item_db.item_type == "balance_reward":
            try:
                reward_amt = Decimal(item_db.reward_value or "0")
                user.balance = Decimal(str(user.balance)) + reward_amt
                session.add(Operations(
                    user_id=user_id,
                    operation_value=int(reward_amt),
                    operation_time=datetime.datetime.now(datetime.timezone.utc)
                ))
                reward_detail = f"Đã cộng {reward_amt:,.0f} VND vào tài khoản!"
            except Exception as e:
                logger.error("Error applying balance_reward in gacha: %s", e)
                reward_detail = item_db.reward_value or ""
        elif item_db.item_type == "promo_code":
            reward_detail = f"Mã giảm giá: {item_db.reward_value}"
        elif item_db.item_type == "text_gift":
            reward_detail = item_db.reward_value or item_db.description or "Phần thưởng đặc biệt"
        elif item_db.item_type == "no_prize":
            reward_detail = "Chúc bạn may mắn lần sau!"

        # Record win
        win_record = GachaUserWin(
            user_id=user_id,
            gacha_item_id=item_db.id,
            item_name=item_db.name,
            reward_details=reward_detail,
        )
        session.add(win_record)
        await session.commit()

        await invalidate_user_cache(user_id)

        return True, "Success", item_db, reward_detail


async def get_user_gacha_wins(user_id: int, limit: int = 20) -> list[GachaUserWin]:
    """Retrieve user win history ordered by newest first."""
    async with Database().session() as session:
        wins = (await session.scalars(
            select(GachaUserWin)
            .where(GachaUserWin.user_id == user_id)
            .order_by(GachaUserWin.won_at.desc())
            .limit(limit)
        )).all()
        return list(wins)
