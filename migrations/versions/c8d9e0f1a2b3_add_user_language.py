"""add per-user interface language

Revision ID: c8d9e0f1a2b3
Revises: b7c9d1e3f5a7
Create Date: 2026-07-19
"""
from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "c8d9e0f1a2b3"
down_revision: Union[str, None] = "b7c9d1e3f5a7"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column(
        "users",
        sa.Column("language", sa.String(length=8), nullable=False, server_default="vi"),
    )
    op.create_check_constraint(
        "ck_users_language",
        "users",
        "language IN ('vi', 'en', 'ru')",
    )


def downgrade() -> None:
    op.drop_constraint("ck_users_language", "users", type_="check")
    op.drop_column("users", "language")
