"""add editable storefront descriptions

Revision ID: e0f1a2b3c4d5
Revises: d9e0f1a2b3c4
"""
from alembic import op
import sqlalchemy as sa


revision = "e0f1a2b3c4d5"
down_revision = "d9e0f1a2b3c4"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "storefront_settings",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("main_menu_description", sa.Text(), nullable=True),
        sa.Column("shop_description", sa.Text(), nullable=True),
        sa.Column("extra_descriptions", sa.Text(), nullable=True),
    )
    op.execute(
        sa.text(
            "INSERT INTO storefront_settings (id, main_menu_description, shop_description) "
            "VALUES (1, NULL, NULL)"
        )
    )


def downgrade() -> None:
    op.drop_table("storefront_settings")
