from pathlib import Path


def test_admin_html_toolbar_contains_telegram_formatting_actions():
    template = Path("bot/web/templates/layout.html").read_text(encoding="utf-8")

    assert 'id="html-toolbar-toggle"' in template
    for action in ("bold", "italic", "underline", "strike", "spoiler", "quote", "quote-expandable", "code", "pre", "pre-python", "link"):
        assert f'data-format="{action}"' in template


def test_delivery_toolbar_button_targets_product_template_when_no_field_is_focused():
    template = Path("bot/web/templates/layout.html").read_text(encoding="utf-8")

    assert 'data-format="delivery"' in template
    assert 'document.querySelector(\'[name="delivery_template"]\')' in template
    assert 'activeTextField || deliveryTemplate' in template

def test_delivery_placeholder_is_escaped_from_jinja_rendering():
    template = Path("bot/web/templates/layout.html").read_text(encoding="utf-8")

    assert "{% raw %}{{delivery}}{% endraw %}" in template