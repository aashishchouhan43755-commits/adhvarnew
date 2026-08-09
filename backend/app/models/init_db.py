def init_db() -> None:
    """Legacy compatibility entry point; use Alembic for schema creation."""
    print("Run `alembic upgrade head` from the backend directory.")


if __name__ == "__main__":
    init_db()
