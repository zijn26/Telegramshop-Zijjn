import pytest
from unittest.mock import MagicMock, AsyncMock
from aiogram.exceptions import TelegramBadRequest

from bot.database.models.media import MediaVault, MediaCaptureSettings
from bot.database.methods.media import (
    record_media_vault,
    get_media_vault_list,
    verify_and_clean_stale_media,
    is_user_allowed_to_capture_media,
)
from bot.web.media_manager import (
    media_manager_page,
    save_media_vault,
    delete_media_vault,
    cleanup_stale_media_vault,
    media_proxy,
    save_media_capture_settings,
)
from bot.web.admin import set_notifier_bot
from bot.handlers.user.media_capture import capture_telegram_media


@pytest.mark.asyncio
async def test_record_and_get_media_vault():
    file_id = "AgACAgIAAxkBAAI123456789_TEST_PHOTO_FILE_ID"
    media = await record_media_vault(
        file_id=file_id,
        media_type="photo",
        file_name="test_photo.png",
        file_size=10240,
        caption="Test Photo Caption",
        uploader_user_id=998877,
    )
    assert media is not None
    assert media.file_id == file_id
    assert media.media_type == "photo"

    # Test retrieval
    items, total_items, total_pages = await get_media_vault_list(media_type="photo", search="test_photo")
    assert total_items >= 1
    found_ids = [i.file_id for i in items]
    assert file_id in found_ids


def _make_auth_request(method="GET", form_data=None, query_params=None):
    request = MagicMock()
    request.session = {"authenticated": True}
    request.client.host = "127.0.0.1"
    request.query_params = query_params or {}
    admin_mock = MagicMock()
    admin_mock._menu.items = []
    request.app.state.admin = admin_mock
    if form_data:
        async def _form():
            return form_data
        request.form = _form
    return request


@pytest.mark.asyncio
async def test_media_manager_web_routes():
    # 1. GET page
    req_get = _make_auth_request("GET", query_params={"media_type": "all", "page": "1"})
    res_get = await media_manager_page(req_get)
    assert res_get.status_code == 200
    assert "Telegram File ID" in res_get.body.decode("utf-8")

    # 2. Add manual file_id
    test_fid = "BAACAgIAAxkBAAI999999_TEST_MANUAL_VIDEO_ID"
    req_add = _make_auth_request("POST", {
        "file_id": test_fid,
        "media_type": "video",
        "file_name": "manual_video.mp4",
        "caption": "Manual Video Upload",
    })
    res_add = await save_media_vault(req_add)
    assert res_add.status_code == 303

    # Verify item in DB
    items, total_items, total_pages = await get_media_vault_list(media_type="video", search="manual_video")
    assert total_items >= 1
    item_id = items[0].id

    # 3. Delete file_id
    req_del = _make_auth_request("POST", {"id": str(item_id)})
    res_del = await delete_media_vault(req_del)
    assert res_del.status_code == 303


@pytest.mark.asyncio
async def test_verify_and_clean_stale_media():
    await record_media_vault(file_id="VALID_FILE_ID_123", media_type="photo")
    await record_media_vault(file_id="EXPIRED_FILE_ID_456", media_type="photo")

    bot_mock = AsyncMock()
    async def _get_file(file_id):
        if file_id == "EXPIRED_FILE_ID_456":
            raise TelegramBadRequest(method=MagicMock(), message="Bad Request: file is missing")
        return MagicMock()

    bot_mock.get_file = _get_file

    checked, deleted = await verify_and_clean_stale_media(bot_mock)
    assert checked >= 2
    assert deleted >= 1

    items, total_items, _ = await get_media_vault_list(media_type="photo", search="EXPIRED_FILE_ID_456")
    assert total_items == 0

    req_cleanup = _make_auth_request("POST")
    res_cleanup = await cleanup_stale_media_vault(req_cleanup)
    assert res_cleanup.status_code == 303


@pytest.mark.asyncio
async def test_media_proxy_preview_route():
    media = await record_media_vault(file_id="PREVIEW_TEST_FILE_ID", media_type="photo")

    req = _make_auth_request("GET")
    req.path_params = {"media_id": str(media.id)}

    bot_mock = AsyncMock()
    file_info = MagicMock()
    file_info.file_path = "photos/file_test.jpg"
    bot_mock.get_file = AsyncMock(return_value=file_info)
    bot_mock.token = "123456:TEST_TOKEN"

    set_notifier_bot(bot_mock)

    res = await media_proxy(req)
    assert res.status_code == 200
    assert res.media_type == "image/jpeg"


@pytest.mark.asyncio
async def test_sticker_emoji_capture_and_filtering():
    msg = MagicMock()
    msg.from_user.id = 112233
    msg.caption = "Nice sticker!"
    msg.photo = None
    msg.video = None
    msg.document = None
    msg.animation = None
    msg.audio = None
    msg.voice = None

    stk = MagicMock()
    stk.file_id = "STICKER_FILE_ID_999"
    stk.file_unique_id = "STICKER_UNIQUE_999"
    stk.emoji = "🔥"
    stk.custom_emoji_id = "543219876"
    stk.file_size = 5120
    stk.set_name = "FirePack"

    msg.sticker = stk

    await capture_telegram_media(msg)

    items, total, _ = await get_media_vault_list(media_type="sticker", search="STICKER_FILE_ID_999")
    assert total >= 1
    assert items[0].file_id == "STICKER_FILE_ID_999"
    assert items[0].media_type == "emoji"


@pytest.mark.asyncio
async def test_media_capture_access_control():
    # 1. Allow all mode
    req_settings_all = _make_auth_request("POST", {
        "mode": "allow_all",
        "allowed_user_ids": "",
    })
    res = await save_media_capture_settings(req_settings_all)
    assert res.status_code == 303
    assert await is_user_allowed_to_capture_media(999) is True

    # 2. Block all mode
    req_settings_block = _make_auth_request("POST", {
        "mode": "block_all",
        "allowed_user_ids": "",
    })
    await save_media_capture_settings(req_settings_block)
    assert await is_user_allowed_to_capture_media(999) is False

    # 3. Allow selected mode
    from bot.web.media_manager import add_allowed_user
    req_add_user = _make_auth_request("POST", {"new_user_id": "112233"})
    await add_allowed_user(req_add_user)
    assert await is_user_allowed_to_capture_media(112233) is True
    assert await is_user_allowed_to_capture_media(999999) is False
