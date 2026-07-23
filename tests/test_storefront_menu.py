from bot.database.main import Database


class TestStorefrontSettings:
    async def test_descriptions_fall_back_and_keep_admin_html_verbatim(self):
        from bot.database.methods.read import get_storefront_descriptions
        from bot.database.models import StorefrontSettings

        async with Database().engine.begin() as connection:
            await connection.run_sync(StorefrontSettings.__table__.create, checkfirst=True)

        from bot.i18n.main import use_locale

        with use_locale("vi"):
            assert await get_storefront_descriptions() == ("⛩️ Menu chính", "\u2060")

        async with Database().session() as session:
            session.add(StorefrontSettings(
                main_menu_description="<b>Chào mừng</b>",
                shop_description="<i>Sản phẩm nổi bật</i>",
            ))

        assert await get_storefront_descriptions() == (
            "<b>Chào mừng</b>",
            "<i>Sản phẩm nổi bật</i>",
        )


class TestStorefrontShop:
    async def test_shop_groups_products_and_places_browse_then_close(self, make_callback_query, fsm_context, item_factory):
        from bot.handlers.user.shop_and_goods import shop_callback_handler

        await item_factory(name="Alpha", price=10, category="Accounts", values=[("a", False)])
        await item_factory(name="Beta", price=10, category="Games", values=[("b", False)])
        from sqlalchemy import select
        from bot.database.main import Database
        from bot.database.models import ItemValues
        async with Database().session() as session:
            alpha_stock = (await session.execute(
                select(ItemValues).where(ItemValues.value == "a")
            )).scalars().one()
            alpha_stock.quantity = 100
        call = make_callback_query(data="shop", user_id=600000)

        await shop_callback_handler(call, fsm_context)

        text = call.message.edit_text.call_args.args[0]
        markup = call.message.edit_text.call_args.kwargs["reply_markup"]
        buttons = [button for row in markup.inline_keyboard for button in row]
        assert text == "\u2060"
        assert buttons[0].callback_data == "shop_categories"
        alpha_row = next(row for row in markup.inline_keyboard if row[0].text == "Alpha")
        assert len(alpha_row) == 2
        assert alpha_row[0].callback_data == "shop-home-item:0"
        assert alpha_row[1].callback_data == "shop-home-item:0"
        assert "10" in alpha_row[1].text and "100" in alpha_row[1].text
        assert buttons[-1].callback_data == "close"

    async def test_category_browser_has_search_and_close_at_end(self, make_callback_query, fsm_context, category_factory):
        from bot.handlers.user.shop_and_goods import shop_categories_handler

        await category_factory("Accounts")
        call = make_callback_query(data="shop_categories", user_id=600000)
        await shop_categories_handler(call, fsm_context)

        markup = call.message.edit_text.call_args.kwargs["reply_markup"]
        buttons = [button for row in markup.inline_keyboard for button in row]
        assert any(button.callback_data == "shop_search" for button in buttons)
        assert buttons[-1].callback_data == "close"

class TestStorefrontMainMenu:
    async def test_back_to_menu_uses_admin_description_as_html(self, fsm_context):
        from unittest.mock import AsyncMock, MagicMock, patch
        from bot.handlers.user.main import back_to_menu_callback_handler

        call = MagicMock()
        call.from_user.id = 999001
        call.message.text = "old text"
        call.message.edit_text = AsyncMock()
        with patch("bot.handlers.user.main.check_user_cached", new=AsyncMock(return_value={"role_id": 1})), \
             patch("bot.handlers.user.main.root_content_page_buttons", new=AsyncMock(return_value=[])), \
             patch("bot.handlers.user.main.get_storefront_descriptions", new=AsyncMock(return_value=("<b>Welcome</b>", "Shop"))):
            await back_to_menu_callback_handler(call, fsm_context)

        assert call.message.edit_text.await_args.args[0] == "<b>Welcome</b>"
        assert call.message.edit_text.await_args.kwargs["parse_mode"] == "HTML"