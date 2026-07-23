import json
import logging
from typing import Callable, Any, Optional
from sqlalchemy import select

from bot.database.main import Database
from bot.database.models.main import StorefrontSettings

logger = logging.getLogger(__name__)


# In-memory registry of all system buttons discovered at startup
_DISCOVERED_BUTTONS: dict[str, dict[str, Any]] = {}


def register_system_button(key: str, name: str, help_text: str = "", default_text: str = "") -> Callable:
    """Decorator or function to register a system button for automatic discovery.

    Usage on handlers:
        @register_system_button(key="vip_upgrade", name="⭐ Nâng cấp VIP", help_text="Mô tả gói VIP")
        @router.callback_query(F.data == "vip_upgrade")
        async def handler(...):
            ...
    """
    _DISCOVERED_BUTTONS[key] = {
        "key": key,
        "name": name,
        "help_text": help_text,
        "default_text": default_text,
    }

    def decorator(func: Callable) -> Callable:
        return func

    return decorator


def _init_default_buttons():
    """Register built-in system buttons by default."""
    defaults = [
        ("main_menu", "⛩️ Menu chính (Main Menu)", "Văn bản chào mừng hiển thị ở đầu menu chính."),
        ("shop", "🛒 Cửa hàng (Shop Entry)", "Văn bản hiển thị khi vào danh mục cửa hàng."),
        ("rules", "📜 Điều khoản & Quy định (Rules)", "Văn bản quy định và điều khoản dịch vụ của shop."),
        ("support", "📞 Hỗ trợ khách hàng (Support)", "Thông tin liên hệ, hỗ trợ khách hàng."),
        ("top_up", "💰 Trang Nạp tiền (Deposit / TopUp)", "Hướng dẫn nạp tiền / thanh toán."),
        ("profile", "👤 Trang Cá nhân (Profile)", "Mô tả đầu trang thông tin cá nhân."),
        ("referral", "🤝 Hệ thống Giới thiệu (Referrals)", "Mô tả hoa hồng và link giới thiệu."),
        ("cart", "🛒 Giỏ hàng (Cart)", "Văn bản đầu trang giỏ hàng."),
        ("reviews", "⭐ Đánh giá (Reviews)", "Văn bản đầu trang đánh giá sản phẩm."),
        ("operation_history", "📜 Lịch sử giao dịch (History)", "Văn bản đầu trang lịch sử nạp/mua."),
        ("entertainment", "🎮 Giải trí (Entertainment)", "Văn bản hiển thị khi nhấn nút Giải trí ở Menu chính."),
    ]
    for key, name, help_txt in defaults:
        if key not in _DISCOVERED_BUTTONS:
            _DISCOVERED_BUTTONS[key] = {
                "key": key,
                "name": name,
                "help_text": help_txt,
                "default_text": "",
            }


_init_default_buttons()


def get_all_discovered_buttons() -> list[dict[str, Any]]:
    """Return list of all system buttons discovered at startup."""
    _init_default_buttons()
    return list(_DISCOVERED_BUTTONS.values())


async def get_system_button_descriptions() -> dict[str, str]:
    """Retrieve all custom HTML descriptions stored in StorefrontSettings."""
    async with Database().session() as session:
        storefront = (await session.scalars(select(StorefrontSettings))).first()
        if not storefront:
            return {}
        result = {}
        if storefront.main_menu_description:
            result["main_menu"] = storefront.main_menu_description
        if storefront.shop_description:
            result["shop"] = storefront.shop_description
        if storefront.extra_descriptions:
            try:
                extras = json.loads(storefront.extra_descriptions)
                if isinstance(extras, dict):
                    result.update(extras)
            except Exception as e:
                logger.warning("Failed to parse extra_descriptions JSON: %s", e)
        return result


async def get_system_button_text(key: str) -> Optional[str]:
    """Retrieve custom HTML description for a specific button key."""
    descs = await get_system_button_descriptions()
    return descs.get(key)


async def save_system_button_description(key: str, html_content: Optional[str]):
    """Save custom HTML description for a button key in StorefrontSettings."""
    async with Database().session() as session:
        storefront = (await session.scalars(select(StorefrontSettings))).first()
        if not storefront:
            storefront = StorefrontSettings()
            session.add(storefront)

        if key == "main_menu":
            storefront.main_menu_description = html_content or None
        elif key == "shop":
            storefront.shop_description = html_content or None
        else:
            extras = {}
            if storefront.extra_descriptions:
                try:
                    extras = json.loads(storefront.extra_descriptions)
                    if not isinstance(extras, dict):
                        extras = {}
                except Exception:
                    extras = {}
            if html_content and html_content.strip():
                extras[key] = html_content.strip()
            else:
                extras.pop(key, None)
            storefront.extra_descriptions = json.dumps(extras, ensure_ascii=False) if extras else None
