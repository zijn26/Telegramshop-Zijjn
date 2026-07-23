# Per-user Language Selection Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Give every Telegram user a persisted Vietnamese, English, or Russian UI preference, selected from the main menu, with Vietnamese as the default.

**Architecture:** Store an allowed locale on `users`, resolve it in an outer aiogram middleware, and expose it through a request-local `ContextVar` so existing localization call sites remain unchanged. Add a language selector handler and a Vietnamese catalog while preserving administrator-authored database text verbatim.

**Tech Stack:** Python 3.11, aiogram 3, SQLAlchemy 2, Alembic, PostgreSQL 16, pytest/pytest-asyncio.

## Global Constraints

- Selectable locales are exactly `vi`, `en`, and `ru`.
- Default and translation fallback locale is `vi`.
- Product/category names, product descriptions, stock values, rules, and broadcast text are never translated.
- SQLAdmin web localization is out of scope.
- No new runtime dependency.
- Git commits are omitted because the user intentionally removed repository Git metadata.

---

### Task 1: Locale data model and persistence

**Files:**
- Create: `migrations/versions/c8d9e0f1a2b3_add_user_language.py`
- Modify: `bot/database/models/main.py`
- Modify: `bot/database/methods/read.py`
- Modify: `bot/database/methods/update.py`
- Test: `tests/test_database_crud.py`

**Interfaces:**
- Produces `User.language: str`, `get_user_language(telegram_id) -> str`, and `set_user_language(telegram_id, language) -> bool`.
- Allowed values are enforced in both Python and PostgreSQL.

- [ ] Write failing tests proving a newly created user has `language == "vi"`, valid updates persist, and invalid locale updates are rejected.
- [ ] Run `pytest tests/test_database_crud.py -k language -v`; expect failures because the column/functions do not exist.
- [ ] Add the model column/check constraint, migration from head `b7c9d1e3f5a7`, and minimal read/update methods with user-cache invalidation.
- [ ] Re-run the focused tests; expect PASS.

### Task 2: Request-local localization and middleware

**Files:**
- Create: `bot/middleware/locale.py`
- Modify: `bot/middleware/__init__.py`
- Modify: `bot/main.py`
- Modify: `bot/i18n/main.py`
- Modify: `bot/i18n/__init__.py`
- Test: `tests/test_i18n.py`
- Test: `tests/test_middleware.py`

**Interfaces:**
- Produces `SUPPORTED_LOCALES`, `normalize_locale(locale)`, `use_locale(locale)` context manager, `get_locale()`, and `LocaleMiddleware`.
- `localize(key, locale=None, **kwargs)` uses explicit locale, then context locale, then `vi`.

- [ ] Write failing tests for Vietnamese default, explicit/context locale selection, reset after context exit, known-user middleware resolution, and unknown-user Vietnamese fallback.
- [ ] Run focused i18n/middleware tests; expect failures for missing context and middleware.
- [ ] Implement the `ContextVar` API and outer middleware; register it before rate limiting/auth/security so their error messages are localized.
- [ ] Re-run focused tests; expect PASS and no context leakage.

### Task 3: Language selector UI and handler

**Files:**
- Modify: `bot/keyboards/inline.py`
- Modify: `bot/handlers/user/main.py`
- Test: `tests/test_keyboards.py`
- Test: `tests/test_user_handlers.py`

**Interfaces:**
- Produces `language_keyboard(current_locale)` and callback values `language`, `language:vi`, `language:en`, `language:ru`.
- Consumes `set_user_language` and `use_locale` from Tasks 1–2.

- [ ] Write failing tests for the main-menu language button, three selector choices, invalid locale rejection, persistence, and immediate localized menu redraw.
- [ ] Run focused keyboard/user-handler tests; expect failures because callbacks/buttons are absent.
- [ ] Add the minimal keyboard and handlers without changing administrator-authored text.
- [ ] Re-run focused tests; expect PASS.

### Task 4: Vietnamese system catalog

**Files:**
- Create: `bot/i18n/vi.py`
- Modify: `bot/i18n/strings.py`
- Test: `tests/test_i18n.py`

**Interfaces:**
- Produces `VI_TRANSLATIONS: dict[str, str]` with the complete system key set.
- Existing `en` and `ru` catalogs remain selectable and unchanged.

- [ ] Write failing parity tests asserting Vietnamese contains every English system key and preserves all format placeholders.
- [ ] Run `pytest tests/test_i18n.py -v`; expect missing `vi` failures.
- [ ] Add Vietnamese translations for all system-owned keys and merge them into `TRANSLATIONS`.
- [ ] Re-run i18n tests; expect PASS with key/placeholder parity.

### Task 5: Recipient-localized cross-user notifications

**Files:**
- Modify: `bot/handlers/user/balance_and_payment.py`
- Modify: `bot/handlers/admin/user_management.py`
- Modify: `bot/handlers/admin/role_management.py`
- Modify: `bot/misc/services/restock_notifier.py`
- Test: `tests/test_payment_handlers.py`
- Test: `tests/test_admin_handlers.py`
- Test: `tests/test_shop_handlers.py`

**Interfaces:**
- Cross-user system notifications call `localize(..., locale=await get_user_language(target_id))`.
- Raw broadcast and administrator-authored content remain unchanged.

- [ ] Write failing tests showing recipient locale wins over sender/admin locale for referral, balance, role, and restock notifications.
- [ ] Run the focused tests; expect wrong-language failures.
- [ ] Add explicit recipient locale lookups only at cross-user notification boundaries.
- [ ] Re-run focused tests; expect PASS.

### Task 6: Verification

**Files:**
- Modify if needed: `README.md` configuration/localization notes.

- [ ] Run `pytest tests/test_i18n.py tests/test_keyboards.py tests/test_user_handlers.py tests/test_middleware.py tests/test_database_crud.py tests/test_payment_handlers.py tests/test_admin_handlers.py tests/test_shop_handlers.py -q`.
- [ ] Run full `pytest -q`.
- [ ] Run `python -m compileall -q bot migrations`.
- [ ] Inspect the migration upgrade/downgrade and document deployment command `alembic upgrade head`.
