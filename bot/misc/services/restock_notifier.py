from collections import defaultdict
from html import escape as html_escape

from aiogram import Bot

from bot.database.methods import get_user_language, get_item_info_cached
from bot.database.methods.delete import pop_stock_subscribers
from bot.i18n import localize
from bot.keyboards.inline import close
from bot.logger_mesh import logger
from bot.misc.services.broadcast_system import BroadcastManager


async def notify_restock(bot: Bot, item_name: str, added_quantity: int = 1) -> int:
    """Tell subscribers that an item is back, replacing placeholders in custom template or default text."""
    user_ids = await pop_stock_subscribers(item_name)
    if not user_ids:
        return 0

    item = await get_item_info_cached(item_name)

    recipients_by_locale: dict[str, list[int]] = defaultdict(list)
    for user_id in user_ids:
        recipients_by_locale[await get_user_language(user_id)].append(user_id)

    manager = BroadcastManager(bot, batch_size=30, batch_delay=1.0)
    sent = failed = 0
    escaped_name = html_escape(item_name, quote=False)

    template = item.get("restock_notification_template") if item else None

    for locale, locale_user_ids in recipients_by_locale.items():
        if template and template.strip():
            price_val = f"{int(item['price']):,}".replace(",", ".") if item and item.get("price") is not None else ""
            desc_val = html_escape(item.get("description", "") or "", quote=False) if item else ""
            
            text_to_send = (
                template.replace("{quantity}", str(added_quantity))
                        .replace("{qty}", str(added_quantity))
                        .replace("{name}", escaped_name)
                        .replace("{item_name}", escaped_name)
                        .replace("{product_name}", escaped_name)
                        .replace("{price}", price_val)
                        .replace("{description}", desc_val)
            )
        else:
            text_to_send = localize("stock.back_in_stock", locale=locale, name=escaped_name, quantity=added_quantity)

        stats = await manager.broadcast(
            user_ids=locale_user_ids,
            text=text_to_send,
            reply_markup=close(locale=locale),
            parse_mode="HTML",
        )
        sent += stats.sent
        failed += stats.failed

    logger.info(
        "restock notify %r (qty=%s): subscribers=%s sent=%s failed=%s",
        item_name, added_quantity, len(user_ids), sent, failed,
    )
    return sent
