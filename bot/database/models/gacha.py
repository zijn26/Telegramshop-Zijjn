import datetime
from decimal import Decimal
from typing import Optional
from sqlalchemy import (
    BigInteger, Boolean, DateTime, ForeignKey, Integer,
    Numeric, String, Text
)
from sqlalchemy.orm import Mapped, mapped_column, relationship
from bot.database.main import Database


class GachaSettings(Database.BASE):
    """Global configuration for the Gacha system."""
    __tablename__ = "gacha_settings"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    spin_price: Mapped[Decimal] = mapped_column(Numeric(12, 2), default=Decimal("10000.00"), nullable=False)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    title: Mapped[str] = mapped_column(String(255), default="🎰 Vòng Quay Gacha May Mắn", nullable=False)
    description: Mapped[Optional[str]] = mapped_column(Text, nullable=True)


class GachaItem(Database.BASE):
    """Pool of items / prizes in the Gacha system."""
    __tablename__ = "gacha_items"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    description: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    item_type: Mapped[str] = mapped_column(
        String(50), default="text_gift", nullable=False
    )  # text_gift, balance_reward, promo_code, no_prize
    reward_value: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    drop_rate: Mapped[float] = mapped_column(Numeric(6, 2), default=10.0, nullable=False)  # Weight / Probability %
    stock_quantity: Mapped[int] = mapped_column(Integer, default=-1, nullable=False)  # -1 = unlimited
    image_url: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)

    wins: Mapped[list["GachaUserWin"]] = relationship("GachaUserWin", back_populates="item", cascade="all, delete-orphan")

    def __str__(self):
        return f"{self.name} ({self.drop_rate}%)"


class GachaUserWin(Database.BASE):
    """Log of items won by users from Gacha spins."""
    __tablename__ = "gacha_user_wins"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    user_id: Mapped[int] = mapped_column(BigInteger, ForeignKey("users.telegram_id", ondelete="CASCADE"), nullable=False)
    gacha_item_id: Mapped[Optional[int]] = mapped_column(Integer, ForeignKey("gacha_items.id", ondelete="SET NULL"), nullable=True)
    item_name: Mapped[str] = mapped_column(String(255), nullable=False)
    reward_details: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    won_at: Mapped[datetime.datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.datetime.now(datetime.timezone.utc),
        nullable=False
    )

    item: Mapped[Optional["GachaItem"]] = relationship("GachaItem", back_populates="wins")

    def __str__(self):
        return f"User {self.user_id} - {self.item_name}"
