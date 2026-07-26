from aiogram import Router, F
from aiogram.types import Message
from bot.database.methods.media import record_media_vault, is_user_allowed_to_capture_media

router = Router(name="media_capture")


@router.message(F.photo | F.video | F.document | F.animation | F.audio | F.voice | F.sticker)
async def capture_telegram_media(message: Message):
    """Intercept media messages sent to the bot and auto-record their Telegram file_id into MediaVault."""
    uploader_id = message.from_user.id if message.from_user else None
    
    # Check access control settings before saving
    if not await is_user_allowed_to_capture_media(uploader_id):
        return

    caption = message.caption

    if message.photo:
        photo = message.photo[-1]
        await record_media_vault(
            file_id=photo.file_id,
            file_unique_id=photo.file_unique_id,
            media_type="photo",
            file_size=photo.file_size,
            caption=caption,
            uploader_user_id=uploader_id,
        )
    elif message.video:
        video = message.video
        await record_media_vault(
            file_id=video.file_id,
            file_unique_id=video.file_unique_id,
            media_type="video",
            file_name=video.file_name,
            file_size=video.file_size,
            caption=caption,
            uploader_user_id=uploader_id,
        )
    elif message.document:
        doc = message.document
        await record_media_vault(
            file_id=doc.file_id,
            file_unique_id=doc.file_unique_id,
            media_type="document",
            file_name=doc.file_name,
            file_size=doc.file_size,
            caption=caption,
            uploader_user_id=uploader_id,
        )
    elif message.animation:
        anim = message.animation
        await record_media_vault(
            file_id=anim.file_id,
            file_unique_id=anim.file_unique_id,
            media_type="animation",
            file_name=anim.file_name,
            file_size=anim.file_size,
            caption=caption,
            uploader_user_id=uploader_id,
        )
    elif message.audio:
        audio = message.audio
        await record_media_vault(
            file_id=audio.file_id,
            file_unique_id=audio.file_unique_id,
            media_type="audio",
            file_name=audio.file_name,
            file_size=audio.file_size,
            caption=caption,
            uploader_user_id=uploader_id,
        )
    elif message.voice:
        voice = message.voice
        await record_media_vault(
            file_id=voice.file_id,
            file_unique_id=voice.file_unique_id,
            media_type="voice",
            file_size=voice.file_size,
            caption=caption,
            uploader_user_id=uploader_id,
        )
    elif message.sticker:
        stk = message.sticker
        m_type = "emoji" if stk.custom_emoji_id else "sticker"
        emoji_str = stk.emoji or ""
        name_str = f"Sticker/Emoji {emoji_str} ({stk.set_name or 'Custom'})".strip()
        cap_str = caption or f"Emoji: {emoji_str} | Custom ID: {stk.custom_emoji_id or 'None'}"

        converted_photo_id = None
        try:
            from aiogram.types import URLInputFile
            file_info = await message.bot.get_file(stk.file_id)
            if file_info and file_info.file_path:
                file_url = f"https://api.telegram.org/file/bot{message.bot.token}/{file_info.file_path}"
                photo_input = URLInputFile(file_url, filename="emoji.png")
                tmp_msg = await message.answer_photo(photo=photo_input)
                if tmp_msg and tmp_msg.photo:
                    converted_photo_id = tmp_msg.photo[-1].file_id
                    try:
                        await tmp_msg.delete()
                    except Exception:
                        pass
        except Exception:
            pass

        await record_media_vault(
            file_id=stk.file_id,
            converted_file_id=converted_photo_id,
            file_unique_id=stk.file_unique_id,
            media_type=m_type,
            file_name=name_str,
            file_size=stk.file_size,
            caption=cap_str,
            uploader_user_id=uploader_id,
        )
