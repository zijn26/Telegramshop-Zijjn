import pytest
from bot.database.main import Database
from bot.misc.button_registry import (
    register_system_button,
    get_all_discovered_buttons,
    save_system_button_description,
    get_system_button_text,
)


@pytest.mark.asyncio
async def test_button_registration_decorator():
    @register_system_button(
        key="vip_upgrade_test",
        name="⭐ Nâng cấp VIP (Test)",
        help_text="Mô tả quyền lợi nâng cấp VIP",
    )
    async def dummy_handler():
        pass

    buttons = get_all_discovered_buttons()
    keys = [b["key"] for b in buttons]
    assert "vip_upgrade_test" in keys
    assert "main_menu" in keys
    assert "shop" in keys


@pytest.mark.asyncio
async def test_save_and_get_system_button_description():
    key = "vip_upgrade_test"
    html_desc = "<b>Quyền lợi VIP:</b> Giảm 10% tất cả đơn hàng!"

    await save_system_button_description(key, html_desc)

    text = await get_system_button_text(key)
    assert text == html_desc

    # Test clear
    await save_system_button_description(key, "")
    text_cleared = await get_system_button_text(key)
    assert text_cleared is None
