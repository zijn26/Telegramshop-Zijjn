import pytest
from unittest.mock import MagicMock
from bot.database.main import Database
from bot.database.models.main import ContentPage, StorefrontSettings
from bot.web.content_manager import (
    content_manager_page,
    save_content_page,
    delete_content_page,
    save_storefront_settings,
)


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
async def test_content_manager_page_render():
    req = _make_auth_request("GET")
    res = await content_manager_page(req)
    assert res.status_code == 200
    assert "Quản lý Trang Nội dung" in res.body.decode("utf-8")


@pytest.mark.asyncio
async def test_save_and_delete_content_page_handler():
    # 1. Create a page
    req_save = _make_auth_request("POST", {
        "id": "",
        "button_text": "📌 Hướng dẫn Nạp Thẻ",
        "content": "<b>Nội dung nạp thẻ</b>",
        "parent_id": "",
        "media": "https://example.com/photo.png",
        "media_type": "photo",
        "is_active": "1",
        "sort_order": "10",
    })
    res_save = await save_content_page(req_save)
    assert res_save.status_code == 303

    # Check DB
    async with Database().session() as session:
        from sqlalchemy import select
        page = (await session.scalars(
            select(ContentPage).where(ContentPage.button_text == "📌 Hướng dẫn Nạp Thẻ")
        )).first()
        assert page is not None
        assert page.content == "<b>Nội dung nạp thẻ</b>"
        assert page.sort_order == 10
        page_id = page.id

    # 2. Update page
    req_update = _make_auth_request("POST", {
        "id": str(page_id),
        "button_text": "📌 Hướng dẫn Nạp Thẻ (Update)",
        "content": "<b>Nội dung đã cập nhật</b>",
        "parent_id": "",
        "media": "",
        "media_type": "",
        "is_active": "1",
        "sort_order": "1",
    })
    res_update = await save_content_page(req_update)
    assert res_update.status_code == 303

    async with Database().session() as session:
        page_updated = await session.get(ContentPage, page_id)
        assert page_updated.button_text == "📌 Hướng dẫn Nạp Thẻ (Update)"
        assert page_updated.content == "<b>Nội dung đã cập nhật</b>"

    # 3. Delete page
    req_del = _make_auth_request("POST", {"id": str(page_id)})
    res_del = await delete_content_page(req_del)
    assert res_del.status_code == 303

    async with Database().session() as session:
        page_deleted = await session.get(ContentPage, page_id)
        assert page_deleted is None


@pytest.mark.asyncio
async def test_save_storefront_settings_handler():
    req = _make_auth_request("POST", {
        "main_menu_description": "<b>Chào mừng quý khách đến với shop!</b>",
        "shop_description": "🛒 <i>Danh sách dịch vụ:</i>",
    })
    res = await save_storefront_settings(req)
    assert res.status_code == 303

    async with Database().session() as session:
        from sqlalchemy import select
        storefront = (await session.scalars(select(StorefrontSettings))).first()
        assert storefront is not None
        assert storefront.main_menu_description == "<b>Chào mừng quý khách đến với shop!</b>"
        assert storefront.shop_description == "🛒 <i>Danh sách dịch vụ:</i>"
