from bot.database.main import Database
from bot.database.models import ContentPage
from unittest.mock import AsyncMock, MagicMock, patch
from aiogram.exceptions import TelegramBadRequest


class TestContentPages:
    async def test_back_from_media_page_sends_a_new_text_menu(self, fsm_context):
        from bot.handlers.user.main import back_to_menu_callback_handler
        call = MagicMock()
        call.from_user.id = 970100
        call.message.text = None
        call.message.delete = AsyncMock()
        call.message.answer = AsyncMock()
        with patch("bot.handlers.user.main.check_user_cached", new=AsyncMock(return_value={"role_id": 1})), \
             patch("bot.handlers.user.main.root_content_page_buttons", new=AsyncMock(return_value=[])):
            await back_to_menu_callback_handler(call, fsm_context)
        call.message.delete.assert_awaited_once()
        call.message.answer.assert_awaited_once()
    async def test_bad_media_falls_back_to_a_text_page(self):
        from bot.handlers.user.content_pages import _send_page
        page = ContentPage(button_text="Payment methods", content="<b>Payment methods</b>", media="https://example.invalid/banner.png", media_type="photo")
        call = MagicMock()
        call.message.answer_photo = AsyncMock(side_effect=TelegramBadRequest(method=MagicMock(), message="failed to get HTTP URL content"))
        call.message.edit_text = AsyncMock()
        markup = MagicMock()
        with patch("bot.handlers.user.content_pages._page_keyboard", new=AsyncMock(return_value=markup)):
            await _send_page(call, page)
        call.message.edit_text.assert_awaited_once_with(page.content, parse_mode="HTML", reply_markup=markup)
    async def test_admin_form_lists_existing_pages_as_parent_choices(self):
        from bot.web.admin import ContentPageAdmin

        async with Database().session() as session:
            page = ContentPage(button_text="Trang cha", content="Nội dung")
            session.add(page)
            await session.flush()

        view = ContentPageAdmin()
        view.session_maker = Database().session
        form_class = await view.scaffold_form()
        form = form_class()
        assert (str(page.id), "Trang cha") in form.parent_id.choices
        assert ("", "Main menu (no parent)") in form.parent_id.choices
        assert ("animation", "GIF animation") in form.media_type.choices
    async def test_only_active_root_pages_appear_in_main_menu(self):
        from bot.handlers.user.content_pages import root_content_page_buttons

        async with Database().session() as session:
            root = ContentPage(button_text="📌 Information", content="<b>Info</b>", sort_order=2)
            hidden = ContentPage(button_text="Hidden", content="No", is_active=False)
            session.add_all([root, hidden])
            await session.flush()
            session.add(ContentPage(button_text="Child", content="More", parent_id=root.id))

        assert ("📌 Information", f"content:{root.id}") in await root_content_page_buttons()

    async def test_page_keyboard_shows_active_children_and_back(self):
        from bot.handlers.user.content_pages import _page_keyboard

        async with Database().session() as session:
            parent = ContentPage(button_text="Parent", content="Parent content")
            session.add(parent)
            await session.flush()
            child = ContentPage(button_text="Child", content="Child content", parent_id=parent.id)
            hidden = ContentPage(button_text="Hidden", content="Hidden", parent_id=parent.id, is_active=False)
            session.add_all([child, hidden])

        markup = await _page_keyboard(parent)
        buttons = [button for row in markup.inline_keyboard for button in row]
        assert buttons[0].text == "Child"
        assert buttons[0].callback_data == f"content:{child.id}"
        assert buttons[1].callback_data == "back_to_menu"
