from html import unescape

from aiogram import F, Router
from aiogram.exceptions import TelegramBadRequest
from aiogram.types import CallbackQuery, InlineKeyboardButton, InlineKeyboardMarkup
from aiogram.utils.keyboard import InlineKeyboardBuilder
from sqlalchemy import select

from bot.database.main import Database
from bot.database.models import ContentPage
from bot.i18n import localize
from bot.logger_mesh import logger

router = Router()


async def root_content_page_buttons() -> list[tuple[str, str]]:
    async with Database().session() as session:
        pages = (await session.scalars(
            select(ContentPage).where(
                ContentPage.parent_id.is_(None), ContentPage.is_active.is_(True)
            ).order_by(ContentPage.sort_order, ContentPage.id)
        )).all()
    return [(page.button_text, f"content:{page.id}") for page in pages]


async def _get_page(page_id: int) -> ContentPage | None:
    async with Database().session() as session:
        return await session.get(ContentPage, page_id)


async def _page_keyboard(page: ContentPage) -> InlineKeyboardMarkup:
    async with Database().session() as session:
        children = (await session.scalars(
            select(ContentPage).where(
                ContentPage.parent_id == page.id, ContentPage.is_active.is_(True)
            ).order_by(ContentPage.sort_order, ContentPage.id)
        )).all()
    kb = InlineKeyboardBuilder()
    for child in children:
        kb.button(text=child.button_text, callback_data=f"content:{child.id}")
    kb.button(text=localize("btn.back"), callback_data=(f"content:{page.parent_id}" if page.parent_id else "back_to_menu"))
    kb.adjust(1)
    return kb.as_markup()


async def _send_page(call: CallbackQuery, page: ContentPage) -> None:
    markup = await _page_keyboard(page)
    if not page.media:
        try:
            await call.message.edit_text(page.content, parse_mode="HTML", reply_markup=markup)
        except TelegramBadRequest:
            await call.message.edit_text(unescape(page.content), reply_markup=markup)
        return

    method = {"photo": call.message.answer_photo, "animation": call.message.answer_animation, "video": call.message.answer_video}.get(page.media_type or "photo")
    try:
        await method(page.media, caption=page.content, parse_mode="HTML", reply_markup=markup)
    except TelegramBadRequest as error:
        logger.warning("Content page %s media could not be sent: %s", page.id, error)
        try:
            await call.message.edit_text(page.content, parse_mode="HTML", reply_markup=markup)
        except TelegramBadRequest:
            await call.message.edit_text(unescape(page.content), reply_markup=markup)


@router.callback_query(F.data.startswith("content:"))
async def content_page_handler(call: CallbackQuery) -> None:
    try:
        page_id = int(call.data.split(":", 1)[1])
    except (ValueError, IndexError):
        await call.answer(localize("errors.invalid_data"), show_alert=True)
        return
    page = await _get_page(page_id)
    if not page or not page.is_active:
        await call.answer(localize("errors.invalid_data"), show_alert=True)
        return
    await _send_page(call, page)
    await call.answer()
