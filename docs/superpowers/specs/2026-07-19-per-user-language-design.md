# Per-user language selection design

## Goal

Add a language button to the Telegram main menu so each user can choose Vietnamese, English, or Russian. Vietnamese is the default. The selection persists across restarts.

## Scope

- Translate system-owned Telegram UI: menus, buttons, prompts, confirmations, errors, user flows, and Telegram admin flows.
- Keep administrator-authored content unchanged: category names, product names, product descriptions, stock values, rules, and broadcast text.
- Keep the existing English and Russian catalogs and add a Vietnamese catalog with the same keys.
- The SQLAdmin web interface is outside this language selector; it keeps its existing interface language.

## Data model

Add `users.language` as a non-null `VARCHAR(8)` column with server default `vi`. A check constraint permits only `vi`, `en`, and `ru`. Existing users are migrated to `vi`.

## Runtime localization

The localization module owns locale normalization and a request-local `ContextVar`. A Telegram middleware resolves the sender's persisted language for each message/callback/payment update, sets it for the duration of the update, and always resets it afterward. Existing `localize(key, **kwargs)` call sites therefore use the correct language without a broad rewrite.

When no user exists yet or no request context is active, localization falls back to Vietnamese. Code that sends asynchronous messages outside a user update must pass or establish the recipient locale explicitly.

## User flow

The main menu contains a language button. Pressing it opens three inline buttons:

- `🇻🇳 Tiếng Việt`
- `🇬🇧 English`
- `🇷🇺 Русский`

Selecting a language validates the callback value, persists it, invalidates the affected user cache, switches the current request locale, and redraws the main menu immediately. Invalid values are rejected without a database write.

## Compatibility

`BOT_LOCALE` remains as a legacy deployment fallback, but the application default and translation fallback become `vi`. Only `vi`, `en`, and `ru` are accepted for user preferences.

## Error handling

- Invalid locale callback: localized alert, no update.
- Missing translation key: fallback to Vietnamese, then return the key as today.
- Database failure while saving: normal handler error propagation/logging; no false success message.
- Unregistered `/start` user: Vietnamese is used and persisted by the database default.

## Testing

- Locale normalization, context isolation/reset, Vietnamese fallback, and translation formatting.
- User model default/constraint and migration behavior.
- Database read/update methods for language.
- Main-menu language button and selector keyboard.
- Language callback persistence and immediate menu redraw.
- Middleware resolves known users and defaults unknown users to Vietnamese.
- Existing localization and handler tests remain green.
