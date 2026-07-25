import logging
from aiogram import Router, F
from aiogram.types import CallbackQuery, InputMediaPhoto, InputMediaVideo, InputMediaAnimation
from aiogram.fsm.context import FSMContext
from aiogram.exceptions import TelegramBadRequest

from bot.database.methods.media import get_roll_media_item, get_random_roll_media_index
from bot.keyboards.inline import ngam_xinh_menu_keyboard, roll_media_keyboard

logger = logging.getLogger(__name__)

router = Router(name="entertainment")


@router.callback_query(F.data == "ngam_xinh_main")
async def ngam_xinh_main_handler(call: CallbackQuery, state: FSMContext):
    """
    Sub-menu for 'Ngắm xinh' (Ngắm Video & Ngắm Ảnh/Emoji).
    """
    await state.clear()
    text = (
        "<b>🌸 Khu Vực Ngắm Xinh</b>\n\n"
        "Chào mừng bạn đến với góc thư giãn! Hãy chọn loại nội dung bạn muốn xem bên dưới:"
    )
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
            try:
                await call.message.delete()
            except Exception:
                pass
            await call.message.answer_sticker(sticker=item.file_id)
            await call.message.answer(caption_text, reply_markup=markup, parse_mode="HTML")

        else:  # photo / default
            media = InputMediaPhoto(media=item.file_id, caption=caption_text, parse_mode="HTML")
            try:
                await call.message.edit_media(media=media, reply_markup=markup)
            except Exception:
                try:
                    await call.message.delete()
                except Exception:
                    pass
                await call.message.answer_photo(photo=item.file_id, caption=caption_text, reply_markup=markup, parse_mode="HTML")

    except Exception as e:
        logger.error("Error rendering roll_media #%s: %s", index, e)
        try:
            await call.message.answer_photo(photo=item.file_id, caption=caption_text, reply_markup=markup, parse_mode="HTML")
        except Exception as e2:
            logger.error("Fallback answer failed: %s", e2)
            await call.message.answer(f"{caption_text}\n(Không thể hiển thị media: {item.file_id[:15]}...)", reply_markup=markup, parse_mode="HTML")
