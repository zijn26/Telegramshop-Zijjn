"""add stock delivery payloads and product delivery templates

Revision ID: a9b8c7d6e5f4
Revises: f9a8b7c6d5e4
"""
from alembic import op
import sqlalchemy as sa


revision = "a9b8c7d6e5f4"
down_revision = "f9a8b7c6d5e4"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column("goods", sa.Column("delivery_template", sa.Text(), nullable=True))
    op.add_column("goods", sa.Column("restock_notification_template", sa.Text(), nullable=True))
    op.add_column("item_values", sa.Column("delivery_type", sa.String(length=12), nullable=False, server_default="text"))
    op.add_column("item_values", sa.Column("file_path", sa.Text(), nullable=True))
    op.add_column("item_values", sa.Column("file_name", sa.String(length=255), nullable=True))
    op.add_column("bought_goods", sa.Column("delivery_type", sa.String(length=12), nullable=False, server_default="text"))
    op.add_column("bought_goods", sa.Column("file_path", sa.Text(), nullable=True))
    op.add_column("bought_goods", sa.Column("file_name", sa.String(length=255), nullable=True))


def downgrade() -> None:
    op.drop_column("bought_goods", "file_name")
    op.drop_column("bought_goods", "file_path")
    op.drop_column("bought_goods", "delivery_type")
    op.drop_column("item_values", "file_name")
    op.drop_column("item_values", "file_path")
    op.drop_column("item_values", "delivery_type")
    op.drop_column("goods", "restock_notification_template")
    op.drop_column("goods", "delivery_template")
