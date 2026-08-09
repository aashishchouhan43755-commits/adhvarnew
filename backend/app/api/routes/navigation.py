from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.api.dependencies import get_db
from app.schemas.navigation import RouteResponse
from app.services.pathfinding_service import PathfindingService

router = APIRouter(
    prefix="/navigation",
    tags=["Navigation"],
)


@router.get("/path")
def shortest_path(
    start_node_id: int,
    end_node_id: int,
    db: Session = Depends(get_db),
):
    service = PathfindingService(db)

    try:
        return service.shortest_path(
            start_node_id,
            end_node_id,
        )
    except ValueError as e:
        raise HTTPException(
            status_code=400,
            detail=str(e),
        )


@router.get("/route", response_model=RouteResponse)
def route(
    start_node_id: int,
    end_node_id: int,
    db: Session = Depends(get_db),
):
    """
    Enriched, multi-floor-aware route: distance, estimated walking
    time, floors traversed, full node-by-node path, and human-readable
    step-by-step directions (including lift/staircase transitions).
    """
    service = PathfindingService(db)

    try:
        return service.find_route(
            start_node_id,
            end_node_id,
        )
    except ValueError as e:
        raise HTTPException(
            status_code=400,
            detail=str(e),
        )