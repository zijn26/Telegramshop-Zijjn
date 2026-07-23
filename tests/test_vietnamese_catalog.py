import string

from bot.i18n.catalog import DEFAULT_LOCALE, TRANSLATIONS


def _fields(template: str) -> set[str]:
    return {part[1] for part in string.Formatter().parse(template) if part[1]}


def test_vietnamese_is_default_locale():
    assert DEFAULT_LOCALE == "vi"


def test_all_catalogs_have_identical_system_keys():
    assert set(TRANSLATIONS["vi"]) == set(TRANSLATIONS["en"])
    assert set(TRANSLATIONS["ru"]) == set(TRANSLATIONS["en"])


def test_vietnamese_preserves_all_format_placeholders():
    for key, english in TRANSLATIONS["en"].items():
        assert _fields(TRANSLATIONS["vi"][key]) == _fields(english), key


def test_vietnamese_main_menu_copy():
    from bot.i18n.main import localize, use_locale

    with use_locale("vi"):
        assert localize("menu.title") == "⛩️ Menu chính"
        assert localize("btn.language") == "🌐 Ngôn ngữ"
