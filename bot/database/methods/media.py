import logging
import datetime
from typing import Optional, Tuple
from sqlalchemy import select, func

from bot.database.main import Database
from bot.database.models.media import MediaVault

logger = logging.getLogger(__name__)


async def record_media_vault(
    file_id: str,
    media_type: str,
    file_unique_id: Optional[str] = None,
    file_name: Optional[str] = None,
    file_size: Optional[int] = None,
    caption: Optional[str] = None,
    uploader_user_id: Optional[int] = None,
) -> MediaVault:
    """Record incoming Telegram file_id into MediaVault database table (avoids duplicates)."""
    async with Database().session() as session:
        existing = (await session.scalars(select(MediaVault).where(MediaVault.file_id == file_id))).first()
        if existing:
            return existing

        media = MediaVault(
            file_id=file_id,
            file_unique_id=file_unique_id,
            media_type=media_type,
            file_name=file_name,
            file_size=file_size,
            caption=caption,
            uploader_user_id=uploader_user_id,
            created_at=datetime.datetime.now(datetime.timezone.utc),
        )
        session.add(media)
        await session.commit()
        await session.refresh(media)
        logger.info("Recorded media file_id [%s] type=%s to MediaVault", file_id[:15], media_type)
        return media


async def get_media_vault_list(
    media_type: Optional[str] = None,
    search: Optional[str] = None,
    page: int = 1,
    per_page: int = 12,
) -> Tuple[list[MediaVault], int, int]:
    """Retrieve paginated MediaVault records with filtering and total page count."""
    async with Database().session() as session:
        query = select(MediaVault)

        if media_type and media_type != "all":
            if media_type in ("sticker", "emoji"):
                query = query.where(MediaVault.media_type.in_(["sticker", "emoji"]))
            else:
                query = query.where(MediaVault.media_type == media_type)

        if search and search.strip():
            term = f"%{search.strip()}%"
            query = query.where(
                (MediaVault.file_name.ilike(term)) |
                (MediaVault.caption.ilike(term)) |
                (MediaVault.file_id.ilike(term))
            )

        count_query = select(func.count()).select_from(query.subquery())
        total_items = (await session.scalar(count_query)) or 0
        total_pages = max(1, (total_items + per_page - 1) // per_page)

        if page > total_pages:
            page = total_pages
        if page < 1:
            page = 1

        offset = (page - 1) * per_page
        items = (await session.scalars(
            query.order_by(MediaVault.created_at.desc()).offset(offset).limit(per_page)
        )).all()

        return list(items), total_items, total_pages


async def verify_and_clean_stale_media(bot) -> Tuple[int, int]:
    """
    Check all file_id records in MediaVault against Telegram API (bot.get_file).
    If Telegram returns a bad request error indicating the file no longer exists,
    delete the stale record from MediaVault database table.
    Returns (total_checked, total_deleted).
    """
    if not bot:
        return 0, 0

    from aiogram.exceptions import TelegramBadRequest, TelegramAPIError

    total_checked = 0
    total_deleted = 0

    async with Database().session() as session:
        items = (await session.scalars(select(MediaVault))).all()
        for item in items:
            total_checked += 1
            is_valid = True
            try:
                await bot.get_file(item.file_id)
            except TelegramBadRequest as e:
                logger.warning("Stale file_id detected for MediaVault ID #%s [%s]: %s", item.id, item.file_id[:15], e)
                is_valid = False
            except TelegramAPIError as e:
                logger.warning("Telegram API error checking file_id #%s: %s", item.id, e)
            except Exception as e:
                logger.error("Unexpected error validating file_id #%s: %s", item.id, e)

            if not is_valid:
                await session.delete(item)
                total_deleted += 1

        if total_deleted > 0:
            await session.commit()
            logger.info("Cleaned up %d stale MediaVault records out of %d checked.", total_deleted, total_checked)

    return total_checked, total_deleted


import json
from bot.database.models.media import MediaCaptureSettings


async def get_media_capture_settings() -> MediaCaptureSettings:
    """Retrieve or initialize single-row MediaCaptureSettings."""
    async with Database().session() as session:
        settings = (await session.scalars(select(MediaCaptureSettings))).first()
        if not settings:
            settings = MediaCaptureSettings(mode="allow_all", allowed_user_ids="[]")
            session.add(settings)
            await session.commit()
            await session.refresh(settings)
        return settings


async def is_user_allowed_to_capture_media(user_id: Optional[int]) -> bool:
    """Check if given uploader_user_id is allowed to record media file_id into MediaVault."""
    async with Database().session() as session:
        settings = (await session.scalars(select(MediaCaptureSettings))).first()
        if not settings:
            return True

        mode = settings.mode or "allow_all"
        if mode == "block_all":
            return False
        if mode == "allow_all":
            return True
        if mode == "allow_selected":
            if not user_id:
                return False
            allowed_list = []
            if settings.allowed_user_ids:
                try:
                    allowed_list = json.loads(settings.allowed_user_ids)
                    if not isinstance(allowed_list, list):
                        allowed_list = []
                except Exception:
                    allowed_list = []
            return user_id in allowed_list or str(user_id) in [str(u) for u in allowed_list]

    return True
