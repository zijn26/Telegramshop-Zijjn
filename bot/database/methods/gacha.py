import json
import random
import logging
import datetime
from decimal import Decimal
from typing import Optional, Tuple
from sqlalchemy import select

from bot.database.main import Database
from bot.database.models.main import User, Operations, Goods, ItemValues, BoughtGoods, PromoCodes
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
    """Retrieve active items included in current GachaSettings wheel pool."""
    async with Database().session() as session:
        settings = (await session.scalars(select(GachaSettings))).first()
        selected_ids = None
        if settings and settings.selected_item_ids:
            try:
                selected_ids = json.loads(settings.selected_item_ids)
                if not isinstance(selected_ids, list):
                    selected_ids = None
            except Exception:
                selected_ids = None

        query = select(GachaItem).where(GachaItem.is_active == True).where(
            (GachaItem.stock_quantity == -1) | (GachaItem.stock_quantity > 0)
        )

        if selected_ids is not None:
            if not selected_ids:
                return []
            query = query.where(GachaItem.id.in_(selected_ids))

        items = (await session.scalars(query.order_by(GachaItem.drop_rate.desc(), GachaItem.id))).all()
        return list(items)


from decimal import Decimal, InvalidOperation

def _parse_decimal(val_str: Optional[str], default: Decimal = Decimal("10")) -> Decimal:
    if not val_str:
        return default
    clean = "".join([c for c in str(val_str) if c.isdigit() or c == "."])
    if not clean:
        return default
    try:
        return Decimal(clean)
    except (InvalidOperation, TypeError, ValueError):
        return default


async def spin_gacha_for_user(user_id: int) -> Tuple[bool, str, Optional[GachaItem], str]:
    """
    Execute a Gacha spin for user with real backend logic:
    - Checks balance >= spin_price.
    - Deducts spin price and logs operation.
    - Performs weighted random selection.
    - Executes real reward fulfillment:
      * balance_reward: Adds money directly to user balance & logs topup operation.
      * promo_code: Generates unique 1-use PromoCodes in database.
      * goods_item: Takes real digital product item value from ItemValues & creates BoughtGoods for user.
      * text_gift: Delivers gift text.
      * no_prize: Better luck next time.
    - Records win log.
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

        # Determine active pool
        selected_ids = None
        if settings.selected_item_ids:
            try:
                selected_ids = json.loads(settings.selected_item_ids)
                if not isinstance(selected_ids, list):
                    selected_ids = None
            except Exception:
                selected_ids = None

        query = select(GachaItem).where(GachaItem.is_active == True).where(
            (GachaItem.stock_quantity == -1) | (GachaItem.stock_quantity > 0)
        )
        if selected_ids is not None:
            if not selected_ids:
                return False, "❌ Hiện chưa có phần thưởng nào được chọn trong vòng quay Gacha!", None, ""
            query = query.where(GachaItem.id.in_(selected_ids))

        items = (await session.scalars(query)).all()
        items = list(items)

        if not items:
            return False, "❌ Hiện chưa có vật phẩm nào khả dụng trong kho Gacha!", None, ""

        # Deduct balance
        user.balance = Decimal(str(user.balance)) - spin_price
        now_dt = datetime.datetime.now(datetime.timezone.utc)
        session.add(Operations(
            user_id=user_id,
            operation_value=-int(spin_price),
            operation_time=now_dt
        ))

        # Weighted selection
        weights = [float(item.drop_rate) for item in items]
        selected_item = random.choices(items, weights=weights, k=1)[0]
        item_db = await session.get(GachaItem, selected_item.id)

        # Decrement stock if finite
        if item_db.stock_quantity > 0:
            item_db.stock_quantity -= 1

        reward_detail = ""

        # --- REAL BACKEND REWARD FULFILLMENT ---
        if item_db.item_type == "balance_reward":
            try:
                reward_amt = _parse_decimal(item_db.reward_value, default=Decimal("10000"))
                user.balance = Decimal(str(user.balance)) + reward_amt
                session.add(Operations(
                    user_id=user_id,
                    operation_value=int(reward_amt),
                    operation_time=now_dt
                ))
                reward_detail = f"Đã cộng {reward_amt:,.0f} VND vào số dư tài khoản!"
            except Exception as e:
                logger.error("Error applying balance_reward: %s", e)
                reward_detail = item_db.reward_value or "Cộng số dư"

        elif item_db.item_type == "promo_code":
            try:
                disc_val = _parse_decimal(item_db.reward_value, default=Decimal("10"))
                code_str = f"GACHA-{random.randint(100000, 999999)}"
                promo = PromoCodes(
                    code=code_str,
                    discount_type="percent",
                    discount_value=disc_val,
                    scope="global",
                    max_uses=1,
                    is_active=True,
                    expires_at=now_dt + datetime.timedelta(days=7),
                )
                session.add(promo)
                reward_detail = f"Mã giảm giá 1 lần dùng: <code>{code_str}</code> (Giảm {disc_val}% đơn tiếp theo)"
            except Exception as e:
                logger.error("Error creating promo_code reward: %s", e)
                reward_detail = f"Mã giảm giá {item_db.reward_value}%"

        elif item_db.item_type == "goods_item":
            goods = None
            if item_db.goods_id:
                goods = await session.get(Goods, item_db.goods_id)

            if goods:
                item_val = (await session.scalars(
                    select(ItemValues).where(ItemValues.item_id == goods.id)
                )).first()

                if item_val:
                    val_str = item_val.value or "Sản phẩm KTS"
                    file_path = item_val.file_path
                    file_name = item_val.file_name
                    delivery_type = item_val.delivery_type or "text"

                    if not item_val.is_infinity:
                        if item_val.quantity > 1:
                            item_val.quantity -= 1
                        else:
                            await session.delete(item_val)

                    unique_id = int(now_dt.timestamp() * 1000) + random.randint(100, 999)
                    bought = BoughtGoods(
                        item_name=goods.name,
                        value=val_str,
                        price=Decimal("0.00"),
                        buyer_id=user_id,
                        bought_datetime=now_dt,
                        unique_id=unique_id,
                        delivery_type=delivery_type,
                        file_path=file_path,
                        file_name=file_name,
                    )
                    session.add(bought)
                    reward_detail = f"Sản phẩm: <b>{goods.name}</b>\nNội dung quà: <code>{val_str}</code>"
                else:
                    reward_detail = f"Sản phẩm: <b>{goods.name}</b> (Kho sản phẩm đang hết hàng, vui lòng liên hệ admin nhận quà!)"
            else:
                reward_detail = item_db.reward_value or "Phần thưởng sản phẩm"

        elif item_db.item_type == "text_gift":
            reward_detail = item_db.reward_value or item_db.description or "Phần thưởng quà tặng"
        elif item_db.item_type == "no_prize":
            reward_detail = "Chúc bạn may mắn lần sau! Đừng nản lòng nhé."

        # Record win log
        win_record = GachaUserWin(
            user_id=user_id,
            gacha_item_id=item_db.id,
            item_name=item_db.name,
            reward_details=reward_detail,
            won_at=now_dt,
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
