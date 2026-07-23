from aiogram import F, Router
from aiogram.fsm.context import FSMContext
from aiogram.types import CallbackQuery

from bot.database.methods import check_role_cached, set_user_language
from bot.database.methods.read import get_storefront_descriptions
from bot.handlers.other import _parse_channel_username
from bot.i18n import localize
from bot.i18n.main import get_locale, use_locale
from bot.keyboards import language_keyboard, main_menu
from bot.misc import EnvKeys


router = Router()


@router.callback_query(F.data == "language")
async def language_menu_handler(call: CallbackQuery, state: FSMContext) -> None:
    await call.message.edit_text(
        localize("language.choose"),
        reply_markup=language_keyboard(get_locale()),
    )
    await state.clear()


@router.callback_query(F.data.startswith("language:"))
async def language_select_handler(call: CallbackQuery, state: FSMContext) -> None:
    language = (call.data or "").partition(":")[2]
    if not await set_user_language(call.from_user.id, language):
        await call.answer(localize("language.invalid"), show_alert=True)
        return

    with use_locale(language):
        role = await check_role_cached(call.from_user.id)
        markup = main_menu(
            role=role,
            channel=_parse_channel_username(),
            helper=EnvKeys.HELPER_ID,
        )
        menu_description, _ = await get_storefront_descriptions()
        await call.message.edit_text(menu_description, reply_markup=markup, parse_mode="HTML")
        await call.answer(localize("language.changed"))

    await state.clear()
