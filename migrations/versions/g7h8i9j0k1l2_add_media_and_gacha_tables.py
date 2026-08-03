"""add media_vault, media_capture_settings and gacha tables

Revision ID: g7h8i9j0k1l2
Revises: b7c9d1e3f5a7
Create Date: 2026-08-03 10:10:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy import inspect

# revision identifiers, used by Alembic.
revision: str = 'g7h8i9j0k1l2'
down_revision: Union[str, None] = 'b7c9d1e3f5a7'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    bind = op.get_bind()
    inspector = inspect(bind)
    existing_tables = inspector.get_table_names()

    if 'media_vault' not in existing_tables:
        op.create_table(
            'media_vault',
            sa.Column('id', sa.Integer(), nullable=False),
            sa.Column('file_id', sa.Text(), nullable=False),
            sa.Column('converted_file_id', sa.Text(), nullable=True),
            sa.Column('file_unique_id', sa.String(length=255), nullable=True),
            sa.Column('media_type', sa.String(length=50), nullable=False, server_default='photo'),
            sa.Column('file_name', sa.String(length=255), nullable=True),
            sa.Column('file_size', sa.BigInteger(), nullable=True),
            sa.Column('caption', sa.Text(), nullable=True),
            sa.Column('uploader_user_id', sa.BigInteger(), nullable=True),
            sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
            sa.PrimaryKeyConstraint('id'),
        )
        op.create_index('ix_media_vault_file_id', 'media_vault', ['file_id'])
        op.create_index('ix_media_vault_media_type', 'media_vault', ['media_type'])
        op.create_index('ix_media_vault_uploader_user_id', 'media_vault', ['uploader_user_id'])

    if 'media_capture_settings' not in existing_tables:
        op.create_table(
            'media_capture_settings',
            sa.Column('id', sa.Integer(), nullable=False),
            sa.Column('mode', sa.String(length=50), nullable=False, server_default='allow_all'),
            sa.Column('allowed_user_ids', sa.Text(), nullable=True),
            sa.PrimaryKeyConstraint('id'),
        )

    if 'gacha_settings' not in existing_tables:
        op.create_table(
            'gacha_settings',
            sa.Column('id', sa.Integer(), nullable=False),
            sa.Column('spin_price', sa.Numeric(precision=12, scale=2), nullable=False, server_default='10000.00'),
            sa.Column('is_active', sa.Boolean(), nullable=False, server_default='true'),
            sa.Column('title', sa.String(length=255), nullable=False, server_default='🎰 Vòng Quay Gacha May Mắn'),
            sa.Column('description', sa.Text(), nullable=True),
            sa.Column('selected_item_ids', sa.Text(), nullable=True),
            sa.PrimaryKeyConstraint('id'),
        )

    if 'gacha_items' not in existing_tables:
        op.create_table(
            'gacha_items',
            sa.Column('id', sa.Integer(), nullable=False),
            sa.Column('name', sa.String(length=255), nullable=False),
            sa.Column('description', sa.Text(), nullable=True),
            sa.Column('item_type', sa.String(length=50), nullable=False, server_default='text_gift'),
            sa.Column('goods_id', sa.Integer(), nullable=True),
            sa.Column('reward_value', sa.Text(), nullable=True),
            sa.Column('drop_rate', sa.Numeric(precision=6, scale=2), nullable=False, server_default='10.00'),
            sa.Column('stock_quantity', sa.Integer(), nullable=False, server_default='-1'),
            sa.Column('image_url', sa.Text(), nullable=True),
            sa.Column('is_active', sa.Boolean(), nullable=False, server_default='true'),
            sa.ForeignKeyConstraint(['goods_id'], ['goods.id'], ondelete='SET NULL'),
            sa.PrimaryKeyConstraint('id'),
        )

    if 'gacha_user_wins' not in existing_tables:
        op.create_table(
            'gacha_user_wins',
            sa.Column('id', sa.Integer(), nullable=False),
            sa.Column('user_id', sa.BigInteger(), nullable=False),
            sa.Column('gacha_item_id', sa.Integer(), nullable=True),
            sa.Column('item_name', sa.String(length=255), nullable=False),
            sa.Column('reward_details', sa.Text(), nullable=True),
            sa.Column('won_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
            sa.ForeignKeyConstraint(['gacha_item_id'], ['gacha_items.id'], ondelete='SET NULL'),
            sa.ForeignKeyConstraint(['user_id'], ['users.telegram_id'], ondelete='CASCADE'),
            sa.PrimaryKeyConstraint('id'),
        )


def downgrade() -> None:
    op.drop_table('gacha_user_wins')
    op.drop_table('gacha_items')
    op.drop_table('gacha_settings')
    op.drop_table('media_capture_settings')
    op.drop_index('ix_media_vault_uploader_user_id', table_name='media_vault')
    op.drop_index('ix_media_vault_media_type', table_name='media_vault')
    op.drop_index('ix_media_vault_file_id', table_name='media_vault')
    op.drop_table('media_vault')
