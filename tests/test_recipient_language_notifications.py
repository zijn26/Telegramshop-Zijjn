from types import SimpleNamespace
from unittest.mock import AsyncMock, MagicMock, patch

from bot.i18n import localize
from bot.i18n.main import use_locale


class TestRecipientLocalizedNotifications:
    async def test_referral_bonus_uses_referrer_locale(self, user_factory):
        from bot.database.methods import set_user_language
        from bot.handlers.user.balance_and_payment import _notify_referrer_bonus

        await user_factory(telegram_id=970001)
        await set_user_language(970001, "en")
        bot = AsyncMock()

        with patch(
            "bot.handlers.user.balance_and_payment.get_user_referral",
            new=AsyncMock(return_value=970001),
        ), patch("bot.handlers.user.balance_and_payment.EnvKeys") as env, use_locale("vi"):
            env.REFERRAL_PERCENT = 10
            env.PAY_CURRENCY = "USD"
            await _notify_referrer_bonus(bot, 970002, 100, "Nguyen", 970002)

        assert "'locale': 'en'" in bot.send_message.await_args.args[1]

    async def test_restock_notification_uses_each_subscriber_locale(self, user_factory):
        from bot.database.methods import set_user_language
        from bot.misc.services.restock_notifier import notify_restock

        await user_factory(telegram_id=970011)
        await user_factory(telegram_id=970012)
        await set_user_language(970011, "en")
        await set_user_language(970012, "ru")
        manager = MagicMock()
        manager.broadcast = AsyncMock(return_value=SimpleNamespace(sent=1, failed=0))

        with patch(
            "bot.misc.services.restock_notifier.pop_stock_subscribers",
            new=AsyncMock(return_value=[970011, 970012]),
        ), patch(
            "bot.misc.services.restock_notifier.BroadcastManager",
            return_value=manager,
        ), patch(
            "bot.misc.services.restock_notifier.localize",
            side_effect=lambda key, **kwargs: f"{key}:{kwargs}",
        ), use_locale("vi"):
            assert await notify_restock(AsyncMock(), "Premium plan") == 2

        texts = [call.kwargs["text"] for call in manager.broadcast.await_args_list]
        assert any("'locale': 'en'" in text for text in texts)
        assert any("'locale': 'ru'" in text for text in texts)
