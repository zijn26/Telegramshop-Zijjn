from sqlalchemy import select

from bot.database.main import Database


class TestStockQuantity:
    async def test_one_stock_value_with_quantity_three_can_be_bought_three_times(
            self, user_factory, item_factory,
    ):
        from bot.database.models import ItemValues
        from bot.database.methods.transactions import buy_item_transaction

        await user_factory(telegram_id=990001, balance=1000)
        await item_factory(name="Quantity product", price=10, values=[("shared-value", False)])

        async with Database().session() as session:
            stock = (await session.execute(select(ItemValues))).scalars().one()
            stock.quantity = 3

        success, message, _data = await buy_item_transaction(990001, "Quantity product")
        assert success is True
        assert message == "success"

        async with Database().session() as session:
            remaining = (await session.execute(select(ItemValues.quantity))).scalar_one()
        assert remaining == 2


class TestProductNameNormalization:
    def test_purchase_request_preserves_existing_trailing_space(self):
        from bot.misc.validators import ItemPurchaseRequest

        request = ItemPurchaseRequest(item_name="Product ", user_id=990001)

        assert request.item_name == "Product "