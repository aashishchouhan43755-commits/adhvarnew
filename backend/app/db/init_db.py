def init_db() -> None:
    """Retained command entry point; schema changes are managed by Alembic."""
    print("Run `alembic upgrade head` from the backend directory.")


if __name__ == "__main__":
    init_db()
