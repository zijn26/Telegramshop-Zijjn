from typing import Any, Awaitable, Callable, Dict

from aiogram import BaseMiddleware
from aiogram.types import CallbackQuery, Message, TelegramObject

from bot.database.methods.read import get_user_language
from bot.i18n.main import use_locale


class LocaleMiddleware(BaseMiddleware):
    """Select the persisted UI language for one Telegram update."""

    async def __call__(
        self,
        handler: Callable[[TelegramObject, Dict[str, Any]], Awaitable[Any]],
        event: TelegramObject,
        data: Dict[str, Any],
    ) -> Any:
        user = event.from_user if isinstance(event, (Message, CallbackQuery)) else None
        language = await get_user_language(user.id) if user else "vi"

        with use_locale(language):
            data["locale"] = language
            return await handler(event, data)
