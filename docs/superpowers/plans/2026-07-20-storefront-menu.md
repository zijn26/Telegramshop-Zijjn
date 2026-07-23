# Storefront Menu Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the main menu and shop descriptions editable, and show a grouped shop preview by default.

**Architecture:** A singleton `StorefrontSettings` ORM model holds the two administrator-authored HTML strings. A small read helper supplies fallback localized titles. Shop handlers use the helper and build a capped inline keyboard grouped by category.

**Tech Stack:** Python, SQLAlchemy async, Alembic, Aiogram, SQLAdmin, pytest.

## Global Constraints

- Do not add dependencies or background services.
- Do not translate administrator-authored descriptions.
- Preserve the existing full category catalog and search flow.
- Keep Telegram callback data and inline keyboard limits safe.

---

### Task 1: Settings persistence

**Files:**
- Modify: `bot/database/models/main.py`, `bot/database/methods/read.py`, `bot/web/admin.py`
- Create: `migrations/versions/e0f1a2b3c4d5_add_storefront_settings.py`
- Test: `tests/test_storefront_settings.py`

- [ ] Write a test that verifies empty settings use localized fallback strings and stored values are returned verbatim.
- [ ] Run the focused test and confirm it fails because the settings model/helper is absent.
- [ ] Add the singleton model, retrieval helper, migration, and SQLAdmin view.
- [ ] Run the focused test and confirm it passes.

### Task 2: Menu and shop behavior

**Files:**
- Modify: `bot/handlers/user/main.py`, `bot/handlers/user/shop_and_goods.py`, `bot/i18n/strings.py`, `bot/i18n/vi_part2.py`, `bot/web/templates/layout.html`
- Test: `tests/test_shop_handlers.py`, `tests/test_content_pages.py`

- [ ] Write tests for custom main-menu text, top browse button, grouped product callbacks, and final close button.
- [ ] Run the focused tests and confirm they fail against the current category-first behavior.
- [ ] Render descriptions as Telegram HTML, add grouped preview/product opening, and retain full category browsing with search and close.
- [ ] Run focused handler tests and compile checks.
