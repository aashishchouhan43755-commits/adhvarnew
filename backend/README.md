# Adhvar FastAPI Backend

The backend REST API engine for the Adhvar Indoor Navigation System, built with **FastAPI**, **SQLAlchemy 2.0**, **PostgreSQL**, and **Pydantic v2**.

It powers spatial graph calculations, multi-floor indoor routing (Dijkstra's shortest path algorithm), user authentication, and comprehensive **CRUD + Search operations** for campus buildings, floors, rooms, and navigation waypoints.

---

## 🌐 Live Deployment & Documentation

- **🚀 Live Deployed API (Render Swagger UI)**: [https://adhvar-api.onrender.com/docs](https://adhvar-api.onrender.com/docs)
- **📖 Alternative Documentation (ReDoc)**: [https://adhvar-api.onrender.com/redoc](https://adhvar-api.onrender.com/redoc)
- **💻 Local Development URL**: `http://127.0.0.1:8000/docs`

---

## 🏗️ Architecture & Coding Standards

The backend strictly follows an **N-Tier Layered Architecture** to guarantee modularity, separation of concerns, and clean coding standards:

- **`app/api/routes/` (Presentation / API Layer)**: Defines RESTful endpoints, handles HTTP status codes, and injects dependencies (`Session`).
- **`app/schemas/` (Input Validation Layer)**: Pydantic v2 models that validate and serialize request/response bodies with strict type safety.
- **`app/services/` (Business Logic Layer)**: Implements core business logic, coordinate validations, and Dijkstra's multi-floor pathfinding algorithm.
- **`app/repositories/` (Data Access Layer)**: Executes SQLAlchemy ORM database queries for CRUD and search operations.
- **`app/models/` (Database Models)**: SQLAlchemy `DeclarativeBase` ORM entities.
- **`app/core/`**: Centralized configuration (`BaseSettings`), JWT authentication, password hashing, and seed datasets.
- **`app/db/`**: Database engine setup, session management, and Alembic database migration scripts.

---

## ⚡ Working CRUD & Search Operations (NSP Midterm 2 Demonstration)

The system exposes full CRUD and search operations connected directly to PostgreSQL:

| Feature | Method | Endpoint | Description | Status Code |
| :--- | :--- | :--- | :--- | :--- |
| **Create** | `POST` | `/api/v1/rooms` | Creates a room with Pydantic validation | `201 Created` |
| **Read (All)** | `GET` | `/api/v1/rooms` | Fetches all campus rooms | `200 OK` |
| **Read (One)** | `GET` | `/api/v1/rooms/{id}` | Fetches room details by ID | `200 OK` / `404 Not Found` |
| **Search** | `GET` | `/api/v1/rooms/search?q={query}` | Case-insensitive partial search across room name, number, & type | `200 OK` |
| **Update** | `PUT` | `/api/v1/rooms/{id}` | Updates existing room metadata | `200 OK` / `404 Not Found` |
| **Delete** | `DELETE` | `/api/v1/rooms/{id}` | Deletes a room and cascades references | `204 No Content` / `404 Not Found` |

> *Full CRUD operations are also available for `/buildings`, `/floors`, `/nodes`, and `/edges`.*

---

## 🛡️ Input Validation & Exception Handling

- **Input Validation**: Request bodies are parsed through Pydantic schemas. If a field fails validation (e.g. invalid type, missing required attribute, or string length violation), FastAPI automatically returns `422 Unprocessable Entity` with detailed error descriptions.
- **Exception Handling**: Services catch domain logic violations (e.g., room already exists, parent floor not found) and throw `ValueError`, which routes catch and translate to appropriate HTTP responses (`400 Bad Request`, `404 Not Found`).

---

## ⚙️ Environment Configuration

Create a `.env` file in the `backend/` directory for local development:

```env
# Application
DEBUG=True
HOST=0.0.0.0
PORT=8000

# Database (PostgreSQL)
# Format: postgresql+psycopg://username:password@host:port/database_name
DATABASE_URL=postgresql+psycopg://postgres:password@localhost:5432/adhvar

# Security (JWT)
SECRET_KEY=adhvar_super_secret_key_change_in_production_2026
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=60

# Frontend URL (for CORS)
FRONTEND_URL=http://localhost:3000
```

> *Note: On Render, `DATABASE_URL` is configured securely in the Render Dashboard Environment settings.*

---

## 🚀 Setup & Execution

### 1. Install Dependencies
```bash
# Optional: create & activate virtual environment
python -m venv venv
.\venv\Scripts\activate  # On Linux/macOS: source venv/bin/activate

pip install -r requirements.txt
```

### 2. Database Migrations & Seeding
```bash
# Apply schema to PostgreSQL
alembic upgrade head

# Seed initial multi-building campus data (AIC, MAB, STT, SAC)
python -m app.db.seed
```

### 3. Run Development Server
```bash
uvicorn app.main:app --reload
```

The server starts at `http://127.0.0.1:8000`.

---

## 📖 Interactive API Documentation

Interactive Swagger and ReDoc documentation are available at:
- **Swagger UI**: `http://127.0.0.1:8000/docs`
- **ReDoc**: `http://127.0.0.1:8000/redoc`
