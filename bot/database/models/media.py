import datetime
from typing import Optional
from sqlalchemy import BigInteger, DateTime, Integer, String, Text
from sqlalchemy.orm import Mapped, mapped_column
from bot.database.main import Database


class MediaVault(Database.BASE):
    """Registry of Telegram media files (photo, video, doc, etc.) and their Telegram file_ids."""
    __tablename__ = "media_vault"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    file_id: Mapped[str] = mapped_column(Text, nullable=False, index=True)
    file_unique_id: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    media_type: Mapped[str] = mapped_column(String(50), default="photo", nullable=False, index=True)  # photo, video, document, animation, audio, voice
    file_name: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    file_size: Mapped[Optional[int]] = mapped_column(BigInteger, nullable=True)
    caption: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    uploader_user_id: Mapped[Optional[int]] = mapped_column(BigInteger, nullable=True, index=True)
    created_at: Mapped[datetime.datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.datetime.now(datetime.timezone.utc),
        nullable=False
    )

    def __str__(self):
        return f"[{self.media_type.upper()}] {self.file_name or self.file_id[:15]}"


class MediaCaptureSettings(Database.BASE):
    """Configuration for who can record media into MediaVault."""
    __tablename__ = "media_capture_settings"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    mode: Mapped[str] = mapped_column(String(50), default="allow_all", nullable=False)  # allow_all, allow_selected, block_all
    allowed_user_ids: Mapped[Optional[str]] = mapped_column(Text, nullable=True)  # JSON list string of integer User IDs
