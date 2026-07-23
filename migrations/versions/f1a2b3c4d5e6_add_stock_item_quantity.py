"""add quantity to stock items

Revision ID: f9a8b7c6d5e4
Revises: e0f1a2b3c4d5
"""
from alembic import op
import sqlalchemy as sa


revision = "f9a8b7c6d5e4"
down_revision = "e0f1a2b3c4d5"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column(
        "item_values",
        sa.Column("quantity", sa.Integer(), nullable=False, server_default="1"),
    )
    op.create_check_constraint(
        "ck_item_values_quantity_positive", "item_values", "quantity > 0"
    )


def downgrade() -> None:
    op.drop_constraint("ck_item_values_quantity_positive", "item_values", type_="check")
    op.drop_column("item_values", "quantity")
