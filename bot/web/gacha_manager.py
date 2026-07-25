import os
import json
from decimal import Decimal
from jinja2 import Environment, FileSystemLoader
from starlette.requests import Request
from starlette.responses import HTMLResponse, RedirectResponse, JSONResponse
from starlette.routing import Route
import math
from sqlalchemy import select, func

from bot.database.main import Database
from bot.database.models.main import Goods
from bot.database.models.gacha import GachaSettings, GachaItem, GachaUserWin
from bot.database.methods.audit import log_audit
from bot.database.methods.gacha import get_gacha_settings

import sqladmin

templates_dir = os.path.join(os.path.dirname(__file__), "templates")
sqladmin_templates_dir = os.path.join(os.path.dirname(sqladmin.__file__), "templates")
jinja_env = Environment(
    loader=FileSystemLoader([templates_dir, sqladmin_templates_dir]),
    autoescape=True,
)


def _check_auth(request: Request) -> bool:
    return request.session.get("authenticated", False)


async def gacha_manager_page(request: Request):
    if not _check_auth(request):
        return RedirectResponse(url="/admin/login", status_code=303)

    try:
        page = int(request.query_params.get("page", 1))
        if page < 1:
            page = 1
    except (ValueError, TypeError):
        page = 1

    per_page = 10

    async with Database().session() as session:
        settings = (await session.scalars(select(GachaSettings))).first()
        if not settings:
            settings = GachaSettings(spin_price=Decimal("10000.00"), is_active=True, title="🎰 Vòng Quay Gacha May Mắn")
            session.add(settings)
            await session.commit()

        items = (await session.scalars(select(GachaItem).order_by(GachaItem.drop_rate.desc(), GachaItem.id))).all()
        all_goods = (await session.scalars(select(Goods).order_by(Goods.name))).all()

        total_wins = (await session.scalar(select(func.count(GachaUserWin.id)))) or 0
        total_pages = max(1, math.ceil(total_wins / per_page))
        if page > total_pages:
            page = total_pages

        offset = (page - 1) * per_page
        wins = (await session.scalars(
            select(GachaUserWin).order_by(GachaUserWin.won_at.desc()).offset(offset).limit(per_page)
        )).all()

    selected_ids_list = []
    if settings.selected_item_ids:
        try:
            selected_ids_list = json.loads(settings.selected_item_ids)
            if not isinstance(selected_ids_list, list):
                selected_ids_list = []
        except Exception:
            selected_ids_list = []

    items_data = [
        {
            "id": i.id,
            "name": i.name,
            "description": i.description or "",
            "item_type": i.item_type,
            "goods_id": i.goods_id or "",
            "reward_value": i.reward_value or "",
            "drop_rate": float(i.drop_rate),
            "stock_quantity": i.stock_quantity,
            "image_url": i.image_url or "",
            "is_active": i.is_active,
        }
        for i in items
    ]

    template = jinja_env.get_template("gacha_manager.html")
    url_for = getattr(request, "url_for", lambda name, **kwargs: f"/{name}")
    html_content = template.render(
        request=request,
        url_for=url_for,
        title="🎰 Quản lý Vòng quay Gacha",
        subtitle="Cài đặt giá quay, vật phẩm thưởng & tỷ lệ trúng gacha",
        settings=settings,
        items=items,
        items_data=items_data,
        all_goods=all_goods,
        selected_ids_list=selected_ids_list,
        wins=wins,
        page=page,
        total_pages=total_pages,
        total_wins=total_wins,
        per_page=per_page,
        admin=getattr(request.app.state, "admin", None),
    )
    return HTMLResponse(html_content)


async def save_gacha_settings(request: Request):
    if not _check_auth(request):
        return JSONResponse({"error": "Unauthorized"}, status_code=401)

    form = await request.form()
    spin_price_str = form.get("spin_price", "10000").strip()
    is_active = form.get("is_active") == "1" or form.get("is_active") == "true"
    title = form.get("title", "🎰 Vòng Quay Gacha May Mắn").strip()
    description = form.get("description", "").strip() or None
    if hasattr(form, "getlist"):
        selected_item_ids = form.getlist("selected_item_ids")
    else:
        raw = form.get("selected_item_ids", [])
        selected_item_ids = raw if isinstance(raw, list) else ([raw] if raw else [])

    try:
        spin_price = Decimal(spin_price_str)
    except Exception:
        spin_price = Decimal("10000.00")

    selected_ids_clean = [int(x) for x in selected_item_ids if str(x).isdigit()]

    async with Database().session() as session:
        settings = (await session.scalars(select(GachaSettings))).first()
        if not settings:
            settings = GachaSettings()
            session.add(settings)

        settings.spin_price = spin_price
        settings.is_active = is_active
        settings.title = title
        settings.description = description
        settings.selected_item_ids = json.dumps(selected_ids_clean) if selected_ids_clean else None
        await log_audit("gacha_settings_update", resource_type="GachaSettings", resource_id="1", details=f"Updated spin price to {spin_price}", ip_address=request.client.host if request.client else "")

    return RedirectResponse(url="/admin/gacha-manager", status_code=303)


async def save_gacha_item(request: Request):
    if not _check_auth(request):
        return JSONResponse({"error": "Unauthorized"}, status_code=401)

    form = await request.form()
    item_id_str = form.get("id", "").strip()
    name = form.get("name", "").strip()
    description = form.get("description", "").strip() or None
    item_type = form.get("item_type", "text_gift").strip()
    goods_id_str = form.get("goods_id", "").strip()
    reward_value = form.get("reward_value", "").strip() or None
    drop_rate_str = form.get("drop_rate", "10.0").strip()
    stock_quantity_str = form.get("stock_quantity", "-1").strip()
    image_url = form.get("image_url", "").strip() or None
    is_active = form.get("is_active") == "1" or form.get("is_active") == "true"

    if not name:
        return RedirectResponse(url="/admin/gacha-manager?error=missing_name", status_code=303)

    goods_id = int(goods_id_str) if goods_id_str.isdigit() else None

    try:
        drop_rate = float(drop_rate_str)
    except Exception:
        drop_rate = 10.0

    try:
        stock_quantity = int(stock_quantity_str)
    except Exception:
        stock_quantity = -1

    async with Database().session() as session:
        if item_id_str.isdigit():
            item_id = int(item_id_str)
            item = await session.get(GachaItem, item_id)
            if item:
                item.name = name
                item.description = description
                item.item_type = item_type
                item.goods_id = goods_id
                item.reward_value = reward_value
                item.drop_rate = drop_rate
                item.stock_quantity = stock_quantity
                item.image_url = image_url
                item.is_active = is_active
                await log_audit("gacha_item_update", resource_type="GachaItem", resource_id=str(item_id), details=name, ip_address=request.client.host if request.client else "")
        else:
            item = GachaItem(
                name=name,
                description=description,
                item_type=item_type,
                goods_id=goods_id,
                reward_value=reward_value,
                drop_rate=drop_rate,
                stock_quantity=stock_quantity,
                image_url=image_url,
                is_active=is_active,
            )
            session.add(item)
            await session.flush()
            await log_audit("gacha_item_create", resource_type="GachaItem", resource_id=str(item.id), details=name, ip_address=request.client.host if request.client else "")

    return RedirectResponse(url="/admin/gacha-manager", status_code=303)


async def delete_gacha_item(request: Request):
    if not _check_auth(request):
        return JSONResponse({"error": "Unauthorized"}, status_code=401)

    form = await request.form()
    item_id_str = form.get("id", "").strip()

    if item_id_str.isdigit():
        item_id = int(item_id_str)
        async with Database().session() as session:
            item = await session.get(GachaItem, item_id)
            if item:
                await session.delete(item)
                await log_audit("gacha_item_delete", resource_type="GachaItem", resource_id=str(item_id), details=item.name, ip_address=request.client.host if request.client else "")

    return RedirectResponse(url="/admin/gacha-manager", status_code=303)


gacha_manager_routes = [
    Route("/admin/gacha-manager", gacha_manager_page),
    Route("/admin/gacha-manager/save-settings", save_gacha_settings, methods=["POST"]),
    Route("/admin/gacha-manager/save-item", save_gacha_item, methods=["POST"]),
    Route("/admin/gacha-manager/delete-item", delete_gacha_item, methods=["POST"]),
]
