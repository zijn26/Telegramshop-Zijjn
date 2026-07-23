from __future__ import annotations
from contextlib import contextmanager
from contextvars import ContextVar
from functools import lru_cache
from typing import Any, Iterator

from bot.misc import EnvKeys
from .catalog import TRANSLATIONS, DEFAULT_LOCALE
from bot.logger_mesh import logger


SUPPORTED_LOCALES = frozenset({"vi", "en", "ru"})
_current_locale: ContextVar[str | None] = ContextVar("current_locale", default=None)


def normalize_locale(locale: str | None) -> str:
    normalized = (locale or "").strip().lower()
    return normalized if normalized in SUPPORTED_LOCALES else DEFAULT_LOCALE


@lru_cache(maxsize=1)
def _get_configured_locale() -> str:
    return normalize_locale(EnvKeys.BOT_LOCALE)


def get_locale() -> str:
    return _current_locale.get() or _get_configured_locale()


get_locale.cache_clear = _get_configured_locale.cache_clear


@contextmanager
def use_locale(locale: str | None) -> Iterator[str]:
    normalized = normalize_locale(locale)
    token = _current_locale.set(normalized)
    try:
        yield normalized
    finally:
        _current_locale.reset(token)


def localize(key: str, /, locale: str | None = None, **kwargs: Any) -> str:
    """Get a system translation without modifying administrator-authored text."""
    loc = normalize_locale(locale) if locale is not None else get_locale()

    text = TRANSLATIONS.get(loc, {}).get(key)
    if text is None:
        text = TRANSLATIONS.get(DEFAULT_LOCALE, {}).get(key)
    if text is None:
        text = key

    if kwargs:
        try:
            text = text.format(**kwargs)
        except (KeyError, ValueError, TypeError) as e:
            logger.error(f"Failed to format translation key '{key}' with kwargs {kwargs}: {e}")

    return str(text)
