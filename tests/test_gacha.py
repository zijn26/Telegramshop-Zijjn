import pytest
from decimal import Decimal
from unittest.mock import AsyncMock, MagicMock, patch

from bot.database.main import Database
from bot.database.models.main import User
from bot.database.models.gacha import GachaSettings, GachaItem, GachaUserWin
from bot.database.methods.gacha import (
    get_gacha_settings,
    get_active_gacha_items,
    spin_gacha_for_user,
    get_user_gacha_wins,
)
from bot.web.gacha_manager import (
    gacha_manager_page,
    save_gacha_settings,
    save_gacha_item,
    delete_gacha_item,
)


@pytest.mark.asyncio
async def test_gacha_settings_and_items_creation(user_factory):
    settings = await get_gacha_settings()
    assert settings is not None
    assert settings.spin_price >= Decimal("0")

    async with Database().session() as session:
        item = GachaItem(
            name="Test Prize 100k",
            item_type="balance_reward",
            reward_value="100000",
            drop_rate=100.0,
            stock_quantity=-1,
            is_active=True,
        )
        session.add(item)
        await session.commit()

    active_items = await get_active_gacha_items()
    names = [i.name for i in active_items]
    assert "Test Prize 100k" in names


@pytest.mark.asyncio
async def test_spin_gacha_insufficient_balance(user_factory):
    await user_factory(telegram_id=770001, balance=5000)
    settings = await get_gacha_settings()
    settings.spin_price = Decimal("10000")

    success, msg, item, detail = await spin_gacha_for_user(770001)
    assert success is False
    assert "không đủ" in msg.lower() or "số dư" in msg.lower()


@pytest.mark.asyncio
async def test_spin_gacha_success_and_reward(user_factory):
    await user_factory(telegram_id=770002, balance=50000)

    async with Database().session() as session:
        settings = (await session.scalars(select_settings := None or GachaSettings.__table__.select())).first() if False else None
        # Ensure we have active prize
        prize = GachaItem(
            name="Win 20k Balance",
            item_type="balance_reward",
            reward_value="20000",
            drop_rate=100.0,
            stock_quantity=-1,
            is_active=True,
        )
        session.add(prize)
        await session.commit()

    success, msg, item, detail = await spin_gacha_for_user(770002)
    assert success is True
    assert item is not None
    assert detail != ""

    # Check wins history
    wins = await get_user_gacha_wins(770002)
    assert len(wins) >= 1
    assert wins[0].user_id == 770002


def _make_auth_request(method="GET", form_data=None):
    request = MagicMock()
    request.session = {"authenticated": True}
    request.client.host = "127.0.0.1"
    admin_mock = MagicMock()
    admin_mock._menu.items = []
    request.app.state.admin = admin_mock
    if form_data:
        async def _form():
            return form_data
        request.form = _form
    return request


@pytest.mark.asyncio
async def test_gacha_manager_web_routes():
    # 1. Test GET page
    req_get = _make_auth_request("GET")
    res_get = await gacha_manager_page(req_get)
    assert res_get.status_code == 200
    assert "Quản lý Vòng quay Gacha" in res_get.body.decode("utf-8")

    # 2. Test Save Settings
    req_set = _make_auth_request("POST", {
        "spin_price": "15000",
        "is_active": "1",
        "title": "🎰 Gacha Siêu Cấp",
        "description": "Thử vận may vip",
    })
    res_set = await save_gacha_settings(req_set)
    assert res_set.status_code == 303

    # 3. Test Save Gacha Item
    req_item = _make_auth_request("POST", {
        "id": "",
        "name": "🎁 Thẻ Nạp 100k VIP",
        "item_type": "text_gift",
        "reward_value": "CARD-100K-8888",
        "drop_rate": "5.5",
        "stock_quantity": "10",
        "description": "Thẻ nạp vip",
        "image_url": "",
        "is_active": "1",
    })
    res_item = await save_gacha_item(req_item)
    assert res_item.status_code == 303

    # Verify item in DB
    async with Database().session() as session:
        from sqlalchemy import select
        saved_item = (await session.scalars(
            select(GachaItem).where(GachaItem.name == "🎁 Thẻ Nạp 100k VIP")
        )).first()
        assert saved_item is not None
        assert saved_item.drop_rate == 5.5
        assert saved_item.stock_quantity == 10
        item_id = saved_item.id

    # 4. Test Delete Item
    req_del = _make_auth_request("POST", {"id": str(item_id)})
    res_del = await delete_gacha_item(req_del)
    assert res_del.status_code == 303

    async with Database().session() as session:
        deleted = await session.get(GachaItem, item_id)
        assert deleted is None
