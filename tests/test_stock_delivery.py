from pathlib import Path

from sqlalchemy import select

from bot.database.main import Database
from bot.database.methods.transactions import buy_item_transaction
from bot.database.models.main import BoughtGoods, Goods, ItemValues


class TestStockDelivery:
    async def test_stock_form_excludes_computed_product_name(self):
        from bot.web.admin import ItemValuesAdmin

        view = ItemValuesAdmin()
        view.session_maker = Database().__dict__["_Database__SessionLocal"]
        form = (await view.scaffold_form())()

        assert "product_name" not in form._fields
        assert "file_name" not in form._fields
        assert "quantity" not in form._fields
        assert "delivery_type" not in form._fields
        assert "stock_input_mode" in form._fields
        assert "file_path" in form._fields
        assert "upload_files" in form._fields
        assert "text_file" in form._fields

    def test_text_import_uses_each_nonempty_line_as_one_stock_value(self):
        from bot.web.admin import _parse_text_stock_values

        assert _parse_text_stock_values(" one\n\n two \r\n") == ["one", "two"]

    async def test_text_file_import_creates_one_stock_row_per_nonempty_line(self, item_factory):
        from unittest.mock import MagicMock
        from bot.web.admin import ItemValuesAdmin

        await item_factory(name="Text import", price=100)
        async with Database().session() as session:
            goods = (await session.execute(select(Goods).where(Goods.name == "Text import"))).scalar_one()

        class Upload:
            filename = "stock.txt"
            async def read(self):
                return b"first\n\nsecond\n"

        view = ItemValuesAdmin()
        view.session_maker = Database().__dict__["_Database__SessionLocal"]
        view.is_async = True
        request = MagicMock()
        request.client.host = "127.0.0.1"
        await view.insert_model(request, {
            "stock_input_mode": "text_file",
            "text_file": Upload(),
            "item_id": goods.id,
            "is_infinity": False,
            "value": None,
            "file_path": None,
        })

        async with Database().session() as session:
            rows = (await session.execute(
                select(ItemValues).where(ItemValues.item_id == goods.id).order_by(ItemValues.id)
            )).scalars().all()
        assert [(row.value, row.delivery_type, row.quantity) for row in rows] == [
            ("first", "text", 1), ("second", "text", 1),
        ]
    async def test_file_and_text_delivery_are_preserved_on_purchase(self, user_factory, item_factory, tmp_path):
        await user_factory(telegram_id=845001, balance=500)
        await item_factory(name="File stock", price=100, values=[("login:secret", False)])
        stored_file = tmp_path / "account.txt"
        stored_file.write_text("file delivery", encoding="utf-8")

        async with Database().session() as session:
            goods = (await session.execute(select(Goods).where(Goods.name == "File stock"))).scalar_one()
            goods.delivery_template = "<b>Thông tin đơn hàng</b>\n<code>{{delivery}}</code>"
            stock = (await session.execute(
                select(ItemValues).where(ItemValues.item_id == goods.id)
            )).scalar_one()
            stock.delivery_type = "both"
            stock.file_path = str(stored_file)
            stock.file_name = "account.txt"

        ok, message, data = await buy_item_transaction(845001, "File stock")

        assert (ok, message) == (True, "success")
        assert data["delivery_type"] == "both"
        assert data["file_path"] == str(stored_file)
        assert data["file_name"] == "account.txt"
        assert data["delivery_template"] == "<b>Thông tin đơn hàng</b>\n<code>{{delivery}}</code>"

        async with Database().session() as session:
            bought = (await session.execute(select(BoughtGoods))).scalar_one()
            assert bought.delivery_type == "both"
            assert bought.file_name == "account.txt"
            assert bought.file_path == str(stored_file)


def test_configured_delivery_template_is_appended_to_purchase_summary():
    from bot.handlers.user.balance_and_payment import _compose_configured_delivery_receipt

    result = _compose_configured_delivery_receipt(
        "🧾 Sản phẩm: Test", "<b>Thông tin:</b> <code>{{delivery}}</code>", "text", "user:secret"
    )

    assert result == "🧾 Sản phẩm: Test\n\n<b>Thông tin:</b> <code>user:secret</code>"