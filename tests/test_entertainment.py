import pytest
from unittest.mock import AsyncMock, MagicMock, patch
from bot.keyboards.inline import main_menu, entertainment_keyboard
from bot.misc.button_registry import get_all_discovered_buttons, get_system_button_text


def test_main_menu_has_full_row_entertainment_button():
    markup = main_menu(role=1, helper="12345678")
    # Check that '🎮 Giải trí' exists with callback 'entertainment'
    buttons = [btn for row in markup.inline_keyboard for btn in row]
    ent_btn = next((b for b in buttons if b.callback_data == "entertainment"), None)
    assert ent_btn is not None
    assert "Giải trí" in ent_btn.text

    ent_row_idx = next(i for i, row in enumerate(markup.inline_keyboard) if any(b.callback_data == "entertainment" for b in row))
    rules_row_idx = next(i for i, row in enumerate(markup.inline_keyboard) if any(b.callback_data == "rules" for b in row))

    assert len(markup.inline_keyboard[ent_row_idx]) == 1
    assert rules_row_idx > ent_row_idx


def test_entertainment_keyboard_has_back_button():
    markup = entertainment_keyboard()
    buttons = [btn for row in markup.inline_keyboard for btn in row]
    assert any(b.callback_data == "back_to_menu" for b in buttons)


@pytest.mark.asyncio
async def test_entertainment_button_discovered():
    buttons = get_all_discovered_buttons()
    keys = [b["key"] for b in buttons]
    assert "entertainment" in keys


@pytest.mark.asyncio
async def test_entertainment_handler_renders_custom_or_default_text(fsm_context):
    from bot.handlers.user.main import entertainment_callback_handler

    call = MagicMock()
    call.from_user.id = 12345
    call.message.text = "Old text"
    call.message.edit_text = AsyncMock()

    with patch("bot.misc.button_registry.get_system_button_text", new=AsyncMock(return_value="<b>Custom Entertainment Text</b>")):
        await entertainment_callback_handler(call, fsm_context)

    call.message.edit_text.assert_awaited_once()
    args, kwargs = call.message.edit_text.call_args
    assert "Custom Entertainment Text" in args[0]
    assert kwargs.get("parse_mode") == "HTML"
