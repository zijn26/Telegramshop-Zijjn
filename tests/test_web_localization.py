from pathlib import Path


def test_admin_layout_defaults_to_vietnamese_and_offers_english():
    template = Path("bot/web/templates/layout.html").read_text(encoding="utf-8")

    assert 'value="vi"' in template
    assert 'Tiếng Việt' in template
    assert 'value="en"' in template
    assert 'English' in template
    assert 'localStorage.getItem("admin-language") || "vi"' in template
    assert 'data-i18n' in template
