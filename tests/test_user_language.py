import datetime
from unittest.mock import AsyncMock, patch

from aiogram.types import Chat, Message, User


def _message(user_id: int) -> Message:
    return Message(
        message_id=1,
        date=datetime.datetime.now(datetime.timezone.utc),
        chat=Chat(id=user_id, type="private"),
        from_user=User(id=user_id, is_bot=False, first_name="Test"),
    )


class TestPerRequestLocale:
    def test_vietnamese_is_the_invalid_configuration_fallback(self):
        from bot.i18n.main import get_locale

        get_locale.cache_clear()
        with patch("bot.i18n.main.EnvKeys") as env:
            env.BOT_LOCALE = "unsupported"
            assert get_locale() == "vi"
        get_locale.cache_clear()

    def test_context_locale_overrides_deployment_default_and_resets(self):
        from bot.i18n.main import get_locale, use_locale

        get_locale.cache_clear()
        with patch("bot.i18n.main.EnvKeys") as env:
            env.BOT_LOCALE = "vi"
            with use_locale("en"):
                assert get_locale() == "en"
            assert get_locale() == "vi"
        get_locale.cache_clear()

    def test_normalize_locale_accepts_supported_values_only(self):
        from bot.i18n.main import normalize_locale

        assert normalize_locale("  RU ") == "ru"
        assert normalize_locale("de") == "vi"


class TestLocaleMiddleware:
    async def test_uses_persisted_user_language_and_resets_context(self):
        from bot.i18n.main import get_locale
        from bot.middleware.locale import LocaleMiddleware

        before = get_locale()

        async def handler(_event, _data):
            return get_locale()

        with patch(
            "bot.middleware.locale.get_user_language",
            new=AsyncMock(return_value="en"),
        ):
            result = await LocaleMiddleware()(handler, _message(123), {})

        assert result == "en"
        assert get_locale() == before

    async def test_defaults_unknown_user_to_vietnamese(self):
        from bot.i18n.main import get_locale
        from bot.middleware.locale import LocaleMiddleware

        async def handler(_event, _data):
            return get_locale()

        assert await LocaleMiddleware()(handler, _message(999), {}) == "vi"
