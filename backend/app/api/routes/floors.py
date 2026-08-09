from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.api.dependencies import get_db
from app.schemas.floor import (
    FloorCreate,
    FloorResponse,
    FloorUpdate,
)
from app.services.floor_service import FloorService

router = APIRouter(
    prefix="/floors",
    tags=["Floors"],
)


@router.post(
    "",
    response_model=FloorResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_floor(
    floor: FloorCreate,
    db: Session = Depends(get_db),
):
    service = FloorService(db)

    try:
        return service.create(floor)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e),
        )


@router.get(
    "",
    response_model=list[FloorResponse],
)
def get_floors(
    db: Session = Depends(get_db),
):
    service = FloorService(db)
    return service.get_all()


@router.get(
    "/building/{building_id}",
    response_model=list[FloorResponse],
)
def get_floors_by_building(
    building_id: int,
    db: Session = Depends(get_db),
):
    service = FloorService(db)

    try:
        return service.get_by_building(building_id)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e),
        )


@router.get(
    "/{floor_id}",
    response_model=FloorResponse,
)
def get_floor(
    floor_id: int,
    db: Session = Depends(get_db),
):
    service = FloorService(db)

    try:
        return service.get_by_id(floor_id)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e),
        )


@router.put(
    "/{floor_id}",
    response_model=FloorResponse,
)
def update_floor(
    floor_id: int,
    floor: FloorUpdate,
    db: Session = Depends(get_db),
):
    service = FloorService(db)

    try:
        return service.update(floor_id, floor)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e),
        )


@router.delete(
    "/{floor_id}",
    status_code=status.HTTP_204_NO_CONTENT,
)
def delete_floor(
    floor_id: int,
    db: Session = Depends(get_db),
):
    service = FloorService(db)

    try:
        service.delete(floor_id)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e),
        )