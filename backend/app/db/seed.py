from app.db.database import SessionLocal
from app.core.seed_data import seed_database


def main():
    db = SessionLocal()

    try:
        seed_database(db)
    finally:
        db.close()


if __name__ == "__main__":
    main()