"""add administrator content pages

Revision ID: d9e0f1a2b3c4
Revises: c8d9e0f1a2b3
"""
from alembic import op
import sqlalchemy as sa

revision = "d9e0f1a2b3c4"
down_revision = "c8d9e0f1a2b3"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "content_pages",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("button_text", sa.String(length=64), nullable=False),
        sa.Column("content", sa.Text(), nullable=False),
        sa.Column("parent_id", sa.Integer(), sa.ForeignKey("content_pages.id", ondelete="CASCADE"), nullable=True),
        sa.Column("media", sa.Text(), nullable=True),
        sa.Column("media_type", sa.String(length=16), nullable=True),
        sa.Column("is_active", sa.Boolean(), nullable=False, server_default=sa.true()),
        sa.Column("sort_order", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.CheckConstraint("media_type IS NULL OR media_type IN ('photo', 'animation', 'video')", name="ck_content_pages_media_type"),
    )
    op.create_index("ix_content_pages_parent_id", "content_pages", ["parent_id"])
    op.create_index("ix_content_pages_is_active", "content_pages", ["is_active"])


def downgrade() -> None:
    op.drop_index("ix_content_pages_is_active", table_name="content_pages")
    op.drop_index("ix_content_pages_parent_id", table_name="content_pages")
    op.drop_table("content_pages")
