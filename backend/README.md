# Adhvar FastAPI backend

## Setup

Create `backend/.env` with PostgreSQL and JWT configuration:

```env
DATABASE_URL=postgresql+psycopg://postgres:password@localhost:5432/adhvar
SECRET_KEY=replace-with-a-long-random-secret
```

Install dependencies, apply the schema, and load the demo data:

```bash
pip install -r requirements.txt
alembic upgrade head
python -m app.db.seed
uvicorn app.main:app --reload
```

The API will be available at `http://127.0.0.1:8000`, with interactive API
documentation at `/docs`.

For a database created by an older project version, back it up first. The
initial migration is guarded against recreating existing tables; run
`alembic stamp head` after verifying that its schema matches this project.
