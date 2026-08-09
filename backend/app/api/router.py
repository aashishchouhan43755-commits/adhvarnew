from fastapi import APIRouter

from app.api.routes import auth
from app.api.routes import users
from app.api.routes import buildings
from app.api.routes import floors
from app.api.routes import rooms
from app.api.routes import nodes
from app.api.routes import edges
from app.api.routes import navigation
from app.api.routes import password_reset

api_router = APIRouter()

api_router.include_router(auth.router)
api_router.include_router(users.router)
api_router.include_router(buildings.router)
api_router.include_router(floors.router)
api_router.include_router(rooms.router)
api_router.include_router(nodes.router)
api_router.include_router(edges.router)
api_router.include_router(navigation.router)
api_router.include_router(password_reset.router)