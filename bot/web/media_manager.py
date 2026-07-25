import os
import json
import re
from jinja2 import Environment, FileSystemLoader
from starlette.requests import Request
from starlette.responses import HTMLResponse, RedirectResponse, JSONResponse
from starlette.routing import Route
from sqlalchemy import select

from bot.database.main import Database
from bot.database.models.media import MediaVault, MediaCaptureSettings
from bot.database.methods.media import record_media_vault, get_media_vault_list
from bot.database.methods.audit import log_audit

import sqladmin

templates_dir = os.path.join(os.path.dirname(__file__), "templates")
sqladmin_templates_dir = os.path.join(os.path.dirname(sqladmin.__file__), "templates")
jinja_env = Environment(
    loader=FileSystemLoader([templates_dir, sqladmin_templates_dir]),
    autoescape=True,
)


def _check_auth(request: Request) -> bool:
    return request.session.get("authenticated", False)


async def media_manager_page(request: Request):
    if not _check_auth(request):
        return RedirectResponse(url="/admin/login", status_code=303)

    media_type = request.query_params.get("media_type", "all").strip()
    search = request.query_params.get("search", "").strip()
    try:
        page = int(request.query_params.get("page", 1))
        if page < 1:
            page = 1
    except (ValueError, TypeError):
        page = 1

    per_page = 12

    items, total_items, total_pages = await get_media_vault_list(
        media_type=media_type,
        search=search,
        page=page,
        per_page=per_page
    )

    from bot.database.methods.media import get_media_capture_settings
    settings = await get_media_capture_settings()

    allowed_ids_list = []
    if settings.allowed_user_ids:
        try:
            allowed_ids_list = json.loads(settings.allowed_user_ids)
            if not isinstance(allowed_ids_list, list):
                allowed_ids_list = []
        except Exception:
            allowed_ids_list = []

    template = jinja_env.get_template("media_manager.html")
    url_for = getattr(request, "url_for", lambda name, **kwargs: f"/{name}")
    html_content = template.render(
        request=request,
        url_for=url_for,
        title="🖼️ Quản lý File ID & Media Telegram",
        subtitle="Kho lưu trữ file_id Telegram, ảnh, video & phương tiện tự động thu thập từ Bot",
        items=items,
        media_type=media_type,
        search=search,
        page=page,
        total_items=total_items,
        total_pages=total_pages,
        per_page=per_page,
        settings=settings,
        allowed_ids_list=allowed_ids_list,
        admin=getattr(request.app.state, "admin", None),
    )
    return HTMLResponse(html_content)


async def save_media_vault(request: Request):
    if not _check_auth(request):
        return JSONResponse({"error": "Unauthorized"}, status_code=401)

    form = await request.form()
    file_id = form.get("file_id", "").strip()
    media_type = form.get("media_type", "photo").strip()
    file_name = form.get("file_name", "").strip() or None
    caption = form.get("caption", "").strip() or None

    if not file_id:
        return RedirectResponse(url="/admin/media-manager?error=missing_file_id", status_code=303)

    await record_media_vault(
        file_id=file_id,
        media_type=media_type,
        file_name=file_name,
        caption=caption,
        uploader_user_id=None
    )

    await log_audit("media_vault_add", resource_type="MediaVault", resource_id=file_id[:15], details=f"Manual add file_id: {file_id}", ip_address=request.client.host if request.client else "")

    return RedirectResponse(url="/admin/media-manager", status_code=303)


async def delete_media_vault(request: Request):
    if not _check_auth(request):
        return JSONResponse({"error": "Unauthorized"}, status_code=401)

    form = await request.form()
    media_id_str = form.get("id", "").strip()

    if media_id_str.isdigit():
        media_id = int(media_id_str)
        async with Database().session() as session:
            media = await session.get(MediaVault, media_id)
            if media:
                await session.delete(media)
                await session.commit()
                await log_audit("media_vault_delete", resource_type="MediaVault", resource_id=str(media_id), details=media.file_id[:15], ip_address=request.client.host if request.client else "")

    return RedirectResponse(url="/admin/media-manager", status_code=303)


async def cleanup_stale_media_vault(request: Request):
    if not _check_auth(request):
        return JSONResponse({"error": "Unauthorized"}, status_code=401)

    from bot.web.admin import get_notifier_bot
    from bot.database.methods.media import verify_and_clean_stale_media

    bot = get_notifier_bot()
    checked, deleted = await verify_and_clean_stale_media(bot)

    await log_audit(
        "media_vault_cleanup",
        resource_type="MediaVault",
        details=f"Checked {checked} file_ids, deleted {deleted} stale/expired file_ids",
        ip_address=request.client.host if request.client else ""
    )

    return RedirectResponse(
        url=f"/admin/media-manager?msg=cleaned&checked={checked}&deleted={deleted}",
        status_code=303
    )


async def media_proxy(request: Request):
    """Proxy Telegram media file directly to browser for image/video/audio preview."""
    if not _check_auth(request):
        return Response("Unauthorized", status_code=401)

    media_id = request.path_params.get("media_id")
    if not media_id or not str(media_id).isdigit():
        return Response("Invalid media ID", status_code=400)

    from bot.web.admin import get_notifier_bot
    bot = get_notifier_bot()
    if not bot:
        return Response("Bot not initialized", status_code=503)

    async with Database().session() as session:
        media = await session.get(MediaVault, int(media_id))
        if not media:
            return Response("Media file not found", status_code=404)

        try:
            file_info = await bot.get_file(media.file_id)
            file_url = f"https://api.telegram.org/file/bot{bot.token}/{file_info.file_path}"
        except Exception as e:
            return Response(f"Failed to fetch Telegram file: {e}", status_code=502)

    import aiohttp
    from starlette.responses import StreamingResponse

    content_type = "application/octet-stream"
    m_type = (media.media_type or "").lower()
    if m_type == "photo":
        content_type = "image/jpeg"
    elif m_type in ("video", "animation"):
        content_type = "video/mp4"
    elif m_type in ("audio", "voice"):
        content_type = "audio/ogg"

    if file_info.file_path:
        ext = os.path.splitext(file_info.file_path)[1].lower()
        if ext in (".jpg", ".jpeg"):
            content_type = "image/jpeg"
        elif ext == ".png":
            content_type = "image/png"
        elif ext == ".mp4":
            content_type = "video/mp4"
        elif ext in (".mp3", ".ogg", ".oga"):
            content_type = f"audio/{ext.strip('.')}"

    async def stream_media():
        async with aiohttp.ClientSession() as client:
            async with client.get(file_url) as resp:
                if resp.status == 200:
                    async for chunk in resp.content.iter_chunked(65536):
                        yield chunk

    return StreamingResponse(stream_media(), media_type=content_type)


async def save_media_capture_settings(request: Request):
    if not _check_auth(request):
        return JSONResponse({"error": "Unauthorized"}, status_code=401)

    form = await request.form()
    mode = form.get("mode", "allow_all").strip()

    async with Database().session() as session:
        settings = (await session.scalars(select(MediaCaptureSettings))).first()
        if not settings:
            settings = MediaCaptureSettings(mode=mode, allowed_user_ids="[]")
            session.add(settings)
        else:
            settings.mode = mode
        await session.commit()

    await log_audit(
        "media_capture_settings_update",
        resource_type="MediaCaptureSettings",
        details=f"mode={mode}",
        ip_address=request.client.host if request.client else ""
    )

    return RedirectResponse(url="/admin/media-manager?msg=settings_saved", status_code=303)


async def add_allowed_user(request: Request):
    if not _check_auth(request):
        return JSONResponse({"error": "Unauthorized"}, status_code=401)

    form = await request.form()
    new_user_id_str = form.get("new_user_id", "").strip()

    if new_user_id_str.isdigit():
        new_uid = int(new_user_id_str)
        async with Database().session() as session:
            settings = (await session.scalars(select(MediaCaptureSettings))).first()
            if not settings:
                settings = MediaCaptureSettings(mode="allow_selected", allowed_user_ids="[]")
                session.add(settings)

            # Auto-switch mode to allow_selected when adding an allowed user ID
            settings.mode = "allow_selected"

            allowed_list = []
            if settings.allowed_user_ids:
                try:
                    allowed_list = json.loads(settings.allowed_user_ids)
                    if not isinstance(allowed_list, list):
                        allowed_list = []
                except Exception:
                    allowed_list = []

            if new_uid not in allowed_list:
                allowed_list.append(new_uid)
                settings.allowed_user_ids = json.dumps(allowed_list)
                await session.commit()
                await log_audit("media_capture_user_add", resource_type="MediaCaptureSettings", details=f"Added allowed user_id: {new_uid}", ip_address=request.client.host if request.client else "")

    return RedirectResponse(url="/admin/media-manager?msg=settings_saved", status_code=303)


async def remove_allowed_user(request: Request):
    if not _check_auth(request):
        return JSONResponse({"error": "Unauthorized"}, status_code=401)

    form = await request.form()
    rem_user_id_str = form.get("user_id", "").strip()

    if rem_user_id_str.isdigit():
        rem_uid = int(rem_user_id_str)
        async with Database().session() as session:
            settings = (await session.scalars(select(MediaCaptureSettings))).first()
            if settings and settings.allowed_user_ids:
                try:
                    allowed_list = json.loads(settings.allowed_user_ids)
                    if not isinstance(allowed_list, list):
                        allowed_list = []
                except Exception:
                    allowed_list = []

                if rem_uid in allowed_list:
                    allowed_list.remove(rem_uid)
                    settings.allowed_user_ids = json.dumps(allowed_list)
                    await session.commit()
                    await log_audit("media_capture_user_remove", resource_type="MediaCaptureSettings", details=f"Removed allowed user_id: {rem_uid}", ip_address=request.client.host if request.client else "")

    return RedirectResponse(url="/admin/media-manager?msg=settings_saved", status_code=303)


media_manager_routes = [
    Route("/admin/media-manager", media_manager_page),
    Route("/admin/media-manager/add", save_media_vault, methods=["POST"]),
    Route("/admin/media-manager/delete", delete_media_vault, methods=["POST"]),
    Route("/admin/media-manager/cleanup", cleanup_stale_media_vault, methods=["POST"]),
    Route("/admin/media-manager/preview/{media_id}", media_proxy),
    Route("/admin/media-manager/settings", save_media_capture_settings, methods=["POST"]),
    Route("/admin/media-manager/add-allowed-user", add_allowed_user, methods=["POST"]),
    Route("/admin/media-manager/remove-allowed-user", remove_allowed_user, methods=["POST"]),
]
