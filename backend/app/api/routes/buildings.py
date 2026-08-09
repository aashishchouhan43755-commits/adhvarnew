from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.api.dependencies import get_db
from app.schemas.building import (
    BuildingCreate,
    BuildingResponse,
    BuildingUpdate,
)
from app.services.building_service import BuildingService

router = APIRouter(
    prefix="/buildings",
    tags=["Buildings"],
)


@router.post(
    "",
    response_model=BuildingResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_building(
    building: BuildingCreate,
    db: Session = Depends(get_db),
):
    service = BuildingService(db)

    try:
        return service.create(building)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e),
        )


@router.get(
    "",
    response_model=list[BuildingResponse],
)
def get_buildings(
    db: Session = Depends(get_db),
):
    service = BuildingService(db)
    return service.get_all()


@router.get(
    "/{building_id}",
    response_model=BuildingResponse,
)
def get_building(
    building_id: int,
    db: Session = Depends(get_db),
):
    service = BuildingService(db)

    try:
        return service.get_by_id(building_id)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e),
        )


@router.put(
    "/{building_id}",
    response_model=BuildingResponse,
)
def update_building(
    building_id: int,
    building: BuildingUpdate,
    db: Session = Depends(get_db),
):
    service = BuildingService(db)

    try:
        return service.update(building_id, building)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e),
        )


@router.delete(
    "/{building_id}",
    status_code=status.HTTP_204_NO_CONTENT,
)
def delete_building(
    building_id: int,
    db: Session = Depends(get_db),
):
    service = BuildingService(db)

    try:
        service.delete(building_id)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e),
        )