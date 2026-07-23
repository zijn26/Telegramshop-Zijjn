from unittest.mock import AsyncMock


def _callback_data(markup):
    return [button.callback_data for row in markup.inline_keyboard for button in row]


def test_main_menu_contains_language_button():
    from bot.keyboards.inline import main_menu

    assert "language" in _callback_data(main_menu(role=1))


def test_language_keyboard_offers_all_supported_locales():
    from bot.keyboards.inline import language_keyboard

    callbacks = _callback_data(language_keyboard("en"))

    assert callbacks == ["language:vi", "language:en", "language:ru", "back_to_menu"]


async def test_language_selection_persists_and_redraws_menu(
    user_factory, make_callback_query
):
    from bot.database.methods.read import get_user_language
    from bot.handlers.user.language import language_select_handler

    await user_factory(telegram_id=13001)
    call = make_callback_query(data="language:en", user_id=13001)
    state = AsyncMock()

    await language_select_handler(call, state)

    assert await get_user_language(13001) == "en"
    call.message.edit_text.assert_awaited_once()
    assert "Main menu" in call.message.edit_text.await_args.args[0]


async def test_invalid_language_selection_is_rejected(
    user_factory, make_callback_query
):
    from bot.database.methods.read import get_user_language
    from bot.handlers.user.language import language_select_handler

    await user_factory(telegram_id=13002)
    call = make_callback_query(data="language:de", user_id=13002)

    await language_select_handler(call, AsyncMock())

    assert await get_user_language(13002) == "vi"
    call.answer.assert_awaited_once()
    call.message.edit_text.assert_not_awaited()
