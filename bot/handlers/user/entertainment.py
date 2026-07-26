import logging
from aiogram import Router, F
from aiogram.types import CallbackQuery, InputMediaPhoto, InputMediaVideo, InputMediaAnimation, URLInputFile
from aiogram.fsm.context import FSMContext
from aiogram.exceptions import TelegramBadRequest

from bot.database.methods.media import (
    get_roll_media_item,
    get_random_roll_media_index,
    update_media_vault_converted_file_id,
)
from bot.keyboards.inline import ngam_xinh_menu_keyboard, roll_media_keyboard
from bot.misc.button_registry import register_system_button, get_system_button_text

_STICKER_TO_PHOTO_CACHE: dict[str, str] = {}

logger = logging.getLogger(__name__)

router = Router(name="entertainment")


@register_system_button(
    key="ngam_xinh",
    name="🌸 Ngắm xinh (Media Roll)",
    help_text="Văn bản hiển thị khi khách chọn menu Ngắm xinh trong Khu giải trí."
)
@router.callback_query(F.data == "ngam_xinh_main")
async def ngam_xinh_main_handler(call: CallbackQuery, state: FSMContext):
    """
    Sub-menu for 'Ngắm xinh' (Ngắm Video & Ngắm Ảnh/Emoji).
    """
    await state.clear()
    custom_text = await get_system_button_text("ngam_xinh")
    default_text = (
        "<b>🌸 Khu Vực Ngắm Xinh</b>\n\n"
        "Chào mừng bạn đến với góc thư giãn! Hãy chọn loại nội dung bạn muốn xem bên dưới:"
    )
    text = custom_text or default_text
    markup = ngam_xinh_menu_keyboard()

    if call.message.text is not None:
        try:
            await call.message.edit_text(text, reply_markup=markup, parse_mode="HTML")
        except TelegramBadRequest:
            await call.message.answer(text, reply_markup=markup, parse_mode="HTML")
    else:
        try:
            await call.message.delete()
        except Exception:
            pass
        await call.message.answer(text, reply_markup=markup, parse_mode="HTML")


@router.callback_query(F.data.startswith("roll_media_rand:"))
async def roll_media_rand_handler(call: CallbackQuery, state: FSMContext):
    """
    Pick a random index and route to show_roll_media.
    """
    category = call.data.split(":")[1]
    rand_idx = await get_random_roll_media_index(category)
    await show_roll_media(call, category, rand_idx)


@router.callback_query(F.data.startswith("roll_media:"))
async def roll_media_handler(call: CallbackQuery, state: FSMContext):
    """
    Display media at specified index (category: video vs photo).
    """
    parts = call.data.split(":")
    category = parts[1]
    try:
        index = int(parts[2])
    except (IndexError, ValueError):
        index = 0

    await show_roll_media(call, category, index)


async def show_roll_media(call: CallbackQuery, category: str, index: int):
    """
    Helper function to send/edit media item for roll_media.
    """
    item, total_count = await get_roll_media_item(category, index)

    if total_count == 0:
        cat_title = "video" if category == "video" else "ảnh/emoji"
        await call.answer(f"Kho media hiện chưa có {cat_title} nào! Admin cần gửi hoặc tải {cat_title} lên hệ thống.", show_alert=True)
        return

    if index < 0:
        await call.answer("Đây là media đầu tiên rồi fen!", show_alert=True)
        return

    if index >= total_count:
        cat_title = "video" if category == "video" else "ảnh/emoji"
        await call.answer(f"Hết {cat_title} rồi fen ơi! 🎬", show_alert=True)
        return

    await call.answer()

    markup = roll_media_keyboard(category, index, total_count)
    caption_text = f"<b>🌸 Ngắm Xinh [{index + 1}/{total_count}]</b>"
    if item.caption:
        caption_text += f"\n<i>{item.caption}</i>"

    # Attempt to edit or send media cleanly
    try:
        if item.media_type == "video":
            media = InputMediaVideo(media=item.file_id, caption=caption_text, parse_mode="HTML")
            try:
                await call.message.edit_media(media=media, reply_markup=markup)
            except Exception:
                try:
                    await call.message.delete()
                except Exception:
                    pass
                await call.message.answer_video(video=item.file_id, caption=caption_text, reply_markup=markup, parse_mode="HTML")

        elif item.media_type == "animation":
            media = InputMediaAnimation(media=item.file_id, caption=caption_text, parse_mode="HTML")
            try:
                await call.message.edit_media(media=media, reply_markup=markup)
            except Exception:
                try:
                    await call.message.delete()
                except Exception:
                    pass
                await call.message.answer_animation(animation=item.file_id, caption=caption_text, reply_markup=markup, parse_mode="HTML")

        elif item.media_type in ("sticker", "emoji"):
            # Check permanent converted_file_id in DB or in-memory cache for INSTANT zero-lag edit_media
            cached_photo_id = item.converted_file_id or _STICKER_TO_PHOTO_CACHE.get(item.file_id)
            if cached_photo_id:
                media = InputMediaPhoto(media=cached_photo_id, caption=caption_text, parse_mode="HTML")
                try:
                    await call.message.edit_media(media=media, reply_markup=markup)
                    return
                except Exception:
                    pass

            # First-time conversion: fetch file_url and send photo to extract native photo file_id
            photo_source = item.file_id
            try:
                file_info = await call.bot.get_file(item.file_id)
                if file_info and file_info.file_path:
                    file_url = f"https://api.telegram.org/file/bot{call.bot.token}/{file_info.file_path}"
                    photo_source = URLInputFile(file_url, filename="emoji.png")
            except Exception as fe:
                logger.warning("Could not get_file for sticker %s: %s", item.file_id[:15], fe)

            try:
                await call.message.delete()
            except Exception:
                pass

            try:
                sent_msg = await call.message.answer_photo(photo=photo_source, caption=caption_text, reply_markup=markup, parse_mode="HTML")
                if sent_msg and sent_msg.photo:
                    conv_id = sent_msg.photo[-1].file_id
                    _STICKER_TO_PHOTO_CACHE[item.file_id] = conv_id
                    await update_media_vault_converted_file_id(item.id, conv_id)
            except Exception:
                await call.message.answer_document(document=item.file_id, caption=caption_text, reply_markup=markup, parse_mode="HTML")

        else:  # photo / default
            media = InputMediaPhoto(media=item.file_id, caption=caption_text, parse_mode="HTML")
            try:
                await call.message.edit_media(media=media, reply_markup=markup)
            except Exception:
                try:
                    await call.message.delete()
                except Exception:
                    pass
                try:
                    await call.message.answer_photo(photo=item.file_id, caption=caption_text, reply_markup=markup, parse_mode="HTML")
                except Exception:
                    await call.message.answer_document(document=item.file_id, caption=caption_text, reply_markup=markup, parse_mode="HTML")

    except Exception as e:
        logger.error("Error rendering roll_media #%s: %s", index, e)
        try:
            await call.message.answer_photo(photo=item.file_id, caption=caption_text, reply_markup=markup, parse_mode="HTML")
        except Exception as e2:
            logger.error("Fallback answer failed: %s", e2)
            await call.message.answer(f"{caption_text}\n(Không thể hiển thị media: {item.file_id[:15]}...)", reply_markup=markup, parse_mode="HTML")
