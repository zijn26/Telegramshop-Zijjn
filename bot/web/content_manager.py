import os
from jinja2 import Environment, FileSystemLoader
from starlette.requests import Request
from starlette.responses import HTMLResponse, RedirectResponse, JSONResponse
from starlette.routing import Route
from sqlalchemy import select

from bot.database.main import Database
from bot.database.models.main import ContentPage, StorefrontSettings
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


async def content_manager_page(request: Request):
    if not _check_auth(request):
        return RedirectResponse(url="/admin/login", status_code=303)

    async with Database().session() as session:
        pages = (await session.scalars(
            select(ContentPage).order_by(ContentPage.sort_order, ContentPage.id)
        )).all()

        storefront = (await session.scalars(select(StorefrontSettings))).first()
        if not storefront:
            storefront = StorefrontSettings(main_menu_description=None, shop_description=None)

    from bot.misc.button_registry import get_all_discovered_buttons, get_system_button_descriptions

    system_buttons = get_all_discovered_buttons()
    system_descs = await get_system_button_descriptions()

    # Convert pages to simple dicts for JSON serialization in JS edit modal
    pages_data = [
        {
            "id": p.id,
            "button_text": p.button_text,
            "content": p.content,
            "parent_id": p.parent_id or "",
            "media": p.media or "",
            "media_type": p.media_type or "",
            "is_active": p.is_active,
            "sort_order": p.sort_order,
        }
        for p in pages
    ]

    template = jinja_env.get_template("content_manager.html")
    url_for = getattr(request, "url_for", lambda name, **kwargs: f"/{name}")
    html_content = template.render(
        request=request,
        url_for=url_for,
        title="📌 Quản lý Trang Nội dung",
        subtitle="Chỉnh sửa mô tả các nút Telegram",
        pages=pages,
        pages_data=pages_data,
        storefront=storefront,
        system_buttons=system_buttons,
        system_descs=system_descs,
        admin=request.app.state.admin if hasattr(request.app.state, "admin") else None,
    )
    return HTMLResponse(html_content)


async def save_system_button(request: Request):
    if not _check_auth(request):
        return JSONResponse({"error": "Unauthorized"}, status_code=401)

    form = await request.form()
    key = form.get("key", "").strip()
    html_content = form.get("html_content", "").strip() or None

    if key:
        from bot.misc.button_registry import save_system_button_description
        await save_system_button_description(key, html_content)
        await log_audit("system_button_update", resource_type="SystemButton", resource_id=key, details=f"Updated description for {key}", ip_address=request.client.host if request.client else "")

    return RedirectResponse(url="/admin/content-manager", status_code=303)


async def save_content_page(request: Request):
    if not _check_auth(request):
        return JSONResponse({"error": "Unauthorized"}, status_code=401)

    form = await request.form()
    page_id_str = form.get("id", "").strip()
    button_text = form.get("button_text", "").strip()
    content = form.get("content", "").strip()
    parent_id_str = form.get("parent_id", "").strip()
    media = form.get("media", "").strip() or None
    media_type = form.get("media_type", "").strip() or None
    is_active = form.get("is_active") == "1" or form.get("is_active") == "true"
    sort_order_str = form.get("sort_order", "0").strip()

    if not button_text or not content:
        return RedirectResponse(url="/admin/content-manager?error=missing_fields", status_code=303)

    parent_id = int(parent_id_str) if parent_id_str.isdigit() else None
    sort_order = int(sort_order_str) if sort_order_str.lstrip("-").isdigit() else 0

    async with Database().session() as session:
        if page_id_str.isdigit():
            page_id = int(page_id_str)
            page = await session.get(ContentPage, page_id)
            if page:
                page.button_text = button_text
                page.content = content
                page.parent_id = parent_id
                page.media = media
                page.media_type = media_type
                page.is_active = is_active
                page.sort_order = sort_order
                await log_audit("content_page_update", resource_type="ContentPage", resource_id=str(page_id), details=button_text, ip_address=request.client.host if request.client else "")
        else:
            page = ContentPage(
                button_text=button_text,
                content=content,
                parent_id=parent_id,
                media=media,
                media_type=media_type,
                is_active=is_active,
                sort_order=sort_order,
            )
            session.add(page)
            await session.flush()
            await log_audit("content_page_create", resource_type="ContentPage", resource_id=str(page.id), details=button_text, ip_address=request.client.host if request.client else "")

    return RedirectResponse(url="/admin/content-manager", status_code=303)


async def delete_content_page(request: Request):
    if not _check_auth(request):
        return JSONResponse({"error": "Unauthorized"}, status_code=401)

    form = await request.form()
    page_id_str = form.get("id", "").strip()

    if page_id_str.isdigit():
        page_id = int(page_id_str)
        async with Database().session() as session:
            page = await session.get(ContentPage, page_id)
            if page:
                await session.delete(page)
                await log_audit("content_page_delete", resource_type="ContentPage", resource_id=str(page_id), details=page.button_text, ip_address=request.client.host if request.client else "")

    return RedirectResponse(url="/admin/content-manager", status_code=303)


async def save_storefront_settings(request: Request):
    if not _check_auth(request):
        return JSONResponse({"error": "Unauthorized"}, status_code=401)

    form = await request.form()
    main_menu_description = form.get("main_menu_description", "").strip() or None
    shop_description = form.get("shop_description", "").strip() or None

    async with Database().session() as session:
        storefront = (await session.scalars(select(StorefrontSettings))).first()
        if not storefront:
            storefront = StorefrontSettings()
            session.add(storefront)

        storefront.main_menu_description = main_menu_description
        storefront.shop_description = shop_description
        await log_audit("storefront_settings_update", resource_type="StorefrontSettings", resource_id="1", details="Updated main menu & shop descriptions", ip_address=request.client.host if request.client else "")

    return RedirectResponse(url="/admin/content-manager", status_code=303)


content_manager_routes = [
    Route("/admin/content-manager", content_manager_page),
    Route("/admin/content-manager/save", save_content_page, methods=["POST"]),
    Route("/admin/content-manager/delete", delete_content_page, methods=["POST"]),
    Route("/admin/content-manager/save-storefront", save_storefront_settings, methods=["POST"]),
    Route("/admin/content-manager/save-system-button", save_system_button, methods=["POST"]),
]
