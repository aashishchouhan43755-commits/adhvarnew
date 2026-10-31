# Adhvar — Intelligent Indoor Navigation System

[![FastAPI](https://img.shields.io/badge/FastAPI-005571?style=for-the-badge&logo=fastapi)](https://fastapi.tiangolo.com)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)](https://www.postgresql.org)
[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Render](https://img.shields.io/badge/Render-46E3B7?style=for-the-badge&logo=render&logoColor=white)](https://render.com)

**Adhvar** is a full-stack, multi-floor indoor navigation and facility management platform built using **Flutter** (mobile client), **FastAPI** (REST API backend), and **PostgreSQL** (relational database).

It features interactive SVG floor maps, room search, automated Dijkstra-based multi-floor pathfinding, user authentication, and comprehensive **CRUD** (Create, Read, Update, Delete, Search) operations connected to a live database.

---

## 🌐 Live Deployment & Interactive Documentation

- **🚀 Live Deployed API (Render Swagger UI)**: [https://adhvar-api.onrender.com/docs](https://adhvar-api.onrender.com/docs)
- **📖 Alternative Documentation (ReDoc)**: [https://adhvar-api.onrender.com/redoc](https://adhvar-api.onrender.com/redoc)
- **💻 Local Development URL**: `http://127.0.0.1:8000/docs`

> *Examiners and evaluators can click the live Render link above to test working CRUD and Search operations directly from their browser without any local setup.*

---

## 🌟 Key Features

- **Multi-Floor Pathfinding**: Computes optimal route trajectories across corridor grids, staircases, and elevators using Dijkstra's shortest path algorithm.
- **Interactive SVG Floor Plans**: Dynamic map rendering, room highlighting, and animated route visualization on Flutter.
- **Full CRUD & Search Operations**: Complete management for campus buildings, floors, rooms, nodes, and navigation edges.
- **Instant Search**: Case-insensitive partial matching across room names, numbers, and types with real-time building and floor context.
- **Secure Authentication**: JWT-based session security, email OTP verification, and password reset workflows.
- **Database Migrations & Auto-Seeding**: Managed via Alembic for reproducible schema builds and instant multi-building data population.

---

## 🏛️ System Architecture & Coding Standards

The backend is built following a clean **N-Tier Layered Architecture** with strict separation of concerns, strong type validation, and centralized exception handling:

```
backend/app/
├── api/routes/          # API Controllers & HTTP request handlers
├── schemas/             # Pydantic v2 schemas for strict input validation
├── services/            # Business logic & Dijkstra pathfinding algorithms
├── repositories/        # Database access layer (SQLAlchemy queries & CRUD)
├── models/              # Relational database models (DeclarativeBase)
├── core/                # Configuration, JWT security, email OTP & seed datasets
└── db/                  # Session management & Alembic migrations
```

- **Input Validation**: Pydantic v2 models validate every request body and query parameter before touching business logic.
- **Exception Handling**: Standardized HTTP status codes (`400 Bad Request`, `404 Not Found`, `422 Validation Error`, `500 Internal Server Error`).
- **Coding Standards**: PEP 8 compliant, type hints throughout, and modular dependency injection.

---

## 📊 Working CRUD & Search Operations (NSP Midterm 2 Demonstration)

The system provides fully connected CRUD and search operations with PostgreSQL:

| Operation | HTTP Method | Endpoint | Description | Status Code |
| :--- | :--- | :--- | :--- | :--- |
| **Create** | `POST` | `/api/v1/rooms` | Adds a new room with input validation | `201 Created` |
| **Read (All)** | `GET` | `/api/v1/rooms` | Fetches all campus rooms | `200 OK` |
| **Read (One)** | `GET` | `/api/v1/rooms/{id}` | Fetches detailed info for a specific room | `200 OK` / `404 Not Found` |
| **Search** | `GET` | `/api/v1/rooms/search?q={query}` | Searches rooms by name, number, or category | `200 OK` |
| **Update** | `PUT` | `/api/v1/rooms/{id}` | Updates existing room details | `200 OK` / `404 Not Found` |
| **Delete** | `DELETE` | `/api/v1/rooms/{id}` | Removes a room and cascades references | `204 No Content` / `404 Not Found` |

> *Full CRUD endpoints are also implemented for `/buildings`, `/floors`, `/nodes`, and `/edges`.*

---

## 🛠️ Technology Stack

- **Backend**: FastAPI, Python 3.11, SQLAlchemy 2.0, Alembic, Pydantic v2, Uvicorn
- **Database**: PostgreSQL (Hosted on Render / Local)
- **Frontend**: Flutter, Dart, Custom Painters, SVG Rendering
- **Deployment**: Render Web Service + Render Managed PostgreSQL, GitHub

---

## 🚀 Quick Start Guide

### 1. Backend Setup

```bash
cd backend

# Create and activate virtual environment
python -m venv venv
.\venv\Scripts\activate  # On Linux/macOS: source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run migrations and seed sample campus data
alembic upgrade head
python -m app.db.seed

# Start development server
uvicorn app.main:app --reload
```

Interactive API documentation will be available locally at `http://127.0.0.1:8000/docs`.

### 2. Frontend Setup (Flutter)

```bash
cd frontend

# Install Flutter dependencies
flutter pub get

# Run in offline demo mode
flutter run

# Or run connected to the backend API
flutter run --dart-define=ADHVAR_USE_BACKEND=true
```

---

## 📁 Repository Structure

- [`frontend/`](frontend/): Flutter client application (maps, navigation, search UI). See [frontend/README.md](frontend/README.md).
- [`backend/`](backend/): FastAPI REST backend, database models, and Dijkstra engine. See [backend/README.md](backend/README.md).
