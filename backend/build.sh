#!/usr/bin/env bash
# exit on error
set -o errexit

pip install --upgrade pip
pip install -r requirements.txt

# Run database migrations and seed data
alembic upgrade head || true
python -m app.db.seed || true
