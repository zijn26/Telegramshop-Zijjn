# Storefront Menu Design

## Goal

Let an administrator edit the text shown above the Telegram main menu and shop, and make the shop initially show products grouped by category.

## Design

One singleton database row stores `main_menu_description` and `shop_description`. These are administrator-authored Telegram HTML, so they are rendered verbatim and are never localized. Empty values fall back to the existing localized titles.

The default `shop` callback renders the shop description, a top-level category-browse action, then category headings and product buttons. A capped preview prevents violating Telegram message and inline-keyboard limits; category browse remains the complete catalog view. The browse view keeps search and adds a final close action.

## Verification

Focused async tests cover editable text, grouped product callbacks, category browsing, and close placement. The relevant handler tests plus compile checks are run after implementation.
