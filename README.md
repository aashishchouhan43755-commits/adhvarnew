# Adhvar — Intelligent Indoor Navigation System

[![FastAPI](https://img.shields.io/badge/FastAPI-005571?style=for-the-badge&logo=fastapi)](https://fastapi.tiangolo.com)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)](https://www.postgresql.org)
[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Render](https://img.shields.io/badge/Render-46E3B7?style=for-the-badge&logo=render&logoColor=white)](https://render.com)

**Adhvar** is a full-stack, multi-floor indoor navigation and facility management platform built using **Flutter** (mobile frontend), **FastAPI** (RESTful API backend), and **PostgreSQL** (relational database). 

It features interactive SVG floor maps, room search, automated Dijkstra-based multi-floor route pathfinding, user authentication, and comprehensive **CRUD** (Create, Read, Update, Delete, Search) operations connected to a live database.

---

## 🌟 Key Features

- **Multi-Floor Pathfinding**: Optimal route calculation across corridor grids, staircases, and elevators using Dijkstra's algorithm.
- **Interactive SVG Floor Plans**: Dynamic map rendering, room highlighting, and animated path trajectories.
- **Full CRUD & Search Operations**: Complete administrative management for campus buildings, floors, rooms, and navigation waypoints.
- **Instant Search**: Case-insensitive partial matching across room names, numbers, and types with real-time building/floor context.
- **Secure Authentication**: JWT-based session security, email OTP verification, and password reset flows.
- **Database Migrations & Seeding**: Managed with Alembic for reproducible schema builds and instant multi-building data initialization.

---

## 🏛️ System Architecture & Coding Standards

The backend is built following a clean **Layered Modular Architecture** with strict separation of concerns, strong type validation, and centralized exception handling:
