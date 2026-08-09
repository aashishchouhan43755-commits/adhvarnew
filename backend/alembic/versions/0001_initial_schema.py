"""Create the Adhvar base schema.

Revision ID: 0001_initial_schema
Revises:
Create Date: 2026-08-04
"""

from alembic import context, op
import sqlalchemy as sa


revision = "0001_initial_schema"
down_revision = None
branch_labels = None
depends_on = None


def _has_table(table_name: str) -> bool:
    if context.is_offline_mode():
        return False

    return sa.inspect(op.get_bind()).has_table(table_name)


def upgrade() -> None:
    # Guards keep this initial migration safe for installations created by
    # the former Base.metadata.create_all startup behavior.
    if not _has_table("buildings"):
        op.create_table(
            "buildings",
            sa.Column("id", sa.Integer(), primary_key=True),
            sa.Column("name", sa.String(length=150), nullable=False, unique=True),
            sa.Column("code", sa.String(length=30), nullable=False, unique=True),
            sa.Column("address", sa.Text(), nullable=True),
            sa.Column("description", sa.Text(), nullable=True),
        )
        op.create_index("ix_buildings_id", "buildings", ["id"])

    if not _has_table("users"):
        op.create_table(
            "users",
            sa.Column("id", sa.Integer(), primary_key=True),
            sa.Column("full_name", sa.String(length=100), nullable=False),
            sa.Column("email", sa.String(length=255), nullable=False, unique=True),
            sa.Column("hashed_password", sa.String(length=255), nullable=False),
            sa.Column("is_active", sa.Boolean(), nullable=False, server_default=sa.true()),
            sa.Column("is_superuser", sa.Boolean(), nullable=False, server_default=sa.false()),
            sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("CURRENT_TIMESTAMP")),
            sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("CURRENT_TIMESTAMP")),
        )
        op.create_index("ix_users_id", "users", ["id"])
        op.create_index("ix_users_email", "users", ["email"], unique=True)

    if not _has_table("floors"):
        op.create_table(
            "floors",
            sa.Column("id", sa.Integer(), primary_key=True),
            sa.Column("building_id", sa.Integer(), sa.ForeignKey("buildings.id", ondelete="CASCADE"), nullable=False),
            sa.Column("floor_number", sa.Integer(), nullable=False),
            sa.Column("name", sa.String(length=100), nullable=False),
            sa.Column("map_image", sa.String(length=255), nullable=True),
        )
        op.create_index("ix_floors_id", "floors", ["id"])

    if not _has_table("rooms"):
        op.create_table(
            "rooms",
            sa.Column("id", sa.Integer(), primary_key=True),
            sa.Column("floor_id", sa.Integer(), sa.ForeignKey("floors.id", ondelete="CASCADE"), nullable=False),
            sa.Column("room_number", sa.String(length=30), nullable=False),
            sa.Column("room_name", sa.String(length=150), nullable=False),
            sa.Column("room_type", sa.String(length=50), nullable=False),
        )
        op.create_index("ix_rooms_id", "rooms", ["id"])

    if not _has_table("nodes"):
        op.create_table(
            "nodes",
            sa.Column("id", sa.Integer(), primary_key=True),
            sa.Column("floor_id", sa.Integer(), sa.ForeignKey("floors.id", ondelete="CASCADE"), nullable=False),
            sa.Column("room_id", sa.Integer(), sa.ForeignKey("rooms.id", ondelete="SET NULL"), nullable=True),
            sa.Column("name", sa.String(length=100), nullable=False),
            sa.Column("x", sa.Float(), nullable=False),
            sa.Column("y", sa.Float(), nullable=False),
            sa.Column("node_type", sa.String(length=30), nullable=False, server_default="corridor"),
        )
        op.create_index("ix_nodes_id", "nodes", ["id"])

    if not _has_table("edges"):
        op.create_table(
            "edges",
            sa.Column("id", sa.Integer(), primary_key=True),
            sa.Column("from_node_id", sa.Integer(), sa.ForeignKey("nodes.id", ondelete="CASCADE"), nullable=False),
            sa.Column("to_node_id", sa.Integer(), sa.ForeignKey("nodes.id", ondelete="CASCADE"), nullable=False),
            sa.Column("distance", sa.Float(), nullable=False),
            sa.Column("is_bidirectional", sa.Integer(), nullable=False, server_default="1"),
        )
        op.create_index("ix_edges_id", "edges", ["id"])


def downgrade() -> None:
    for table_name in ("edges", "nodes", "rooms", "floors", "users", "buildings"):
        if _has_table(table_name):
            op.drop_table(table_name)
