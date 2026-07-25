import pytest
from unittest.mock import AsyncMock, MagicMock, patch
from bot.keyboards.inline import main_menu, entertainment_keyboard, ngam_xinh_menu_keyboard, roll_media_keyboard
from bot.misc.button_registry import get_all_discovered_buttons, get_system_button_text
from bot.database.methods.media import record_media_vault, get_roll_media_item, get_random_roll_media_index
from bot.handlers.user.entertainment import ngam_xinh_main_handler, roll_media_handler, roll_media_rand_handler


def test_main_menu_has_full_row_entertainment_button():
    markup = main_menu(role=1, helper="12345678")
    buttons = [btn for row in markup.inline_keyboard for btn in row]
    ent_btn = next((b for b in buttons if b.callback_data == "entertainment"), None)
    assert ent_btn is not None
    assert "Giải trí" in ent_btn.text

    ent_row_idx = next(i for i, row in enumerate(markup.inline_keyboard) if any(b.callback_data == "entertainment" for b in row))
    rules_row_idx = next(i for i, row in enumerate(markup.inline_keyboard) if any(b.callback_data == "rules" for b in row))

    assert len(markup.inline_keyboard[ent_row_idx]) == 1
    assert rules_row_idx > ent_row_idx


def test_entertainment_keyboard_has_ngam_xinh_and_back():
    markup = entertainment_keyboard()
    buttons = [btn for row in markup.inline_keyboard for btn in row]
    assert any(b.callback_data == "ngam_xinh_main" for b in buttons)
    assert any(b.callback_data == "back_to_menu" for b in buttons)


def test_ngam_xinh_menu_keyboard():
    markup = ngam_xinh_menu_keyboard()
    buttons = [btn for row in markup.inline_keyboard for btn in row]
    assert any(b.callback_data == "roll_media:video:0" for b in buttons)
    assert any(b.callback_data == "roll_media:photo:0" for b in buttons)
    assert any(b.callback_data == "entertainment" for b in buttons)


def test_roll_media_keyboard():
    markup = roll_media_keyboard("video", 1, 5)
    buttons = [btn for row in markup.inline_keyboard for btn in row]
    cb_data = [b.callback_data for b in buttons]
    assert "roll_media:video:0" in cb_data  # prev
    assert "roll_media_rand:video" in cb_data  # random
    assert "roll_media:video:2" in cb_data  # next
    assert "ngam_xinh_main" in cb_data  # back


@pytest.mark.asyncio
async def test_roll_media_db_retrieval():
    # Insert test media items
    v1 = await record_media_vault(file_id="TEST_VID_FILE_1", media_type="video", file_name="vid1.mp4")
    p1 = await record_media_vault(file_id="TEST_PIC_FILE_1", media_type="photo", file_name="pic1.jpg")
    e1 = await record_media_vault(file_id="TEST_EMOJI_FILE_1", media_type="emoji", file_name="Sticker 🔥")

    # Test Video retrieval
    item_v, count_v = await get_roll_media_item("video", 0)
    assert count_v >= 1
    assert item_v is not None
    assert item_v.media_type == "video"

    # Test Photo/Emoji retrieval
    item_p, count_p = await get_roll_media_item("photo", 0)
    assert count_p >= 2

    # Test random index generator
    rand_idx = await get_random_roll_media_index("video")
    assert 0 <= rand_idx < count_v


@pytest.mark.asyncio
async def test_ngam_xinh_handlers(fsm_context):
    call = MagicMock()
    call.from_user.id = 12345
    call.message.text = "Menu Text"
    call.message.edit_text = AsyncMock()
    call.answer = AsyncMock()

    # 1. Ngắm xinh main menu
    await ngam_xinh_main_handler(call, fsm_context)
    call.message.edit_text.assert_awaited_once()

    # 2. Roll media handler (valid index)
    call_roll = MagicMock()
    call_roll.data = "roll_media:video:0"
    call_roll.answer = AsyncMock()
    call_roll.message.edit_media = AsyncMock()

    await roll_media_handler(call_roll, fsm_context)
    call_roll.answer.assert_awaited()
