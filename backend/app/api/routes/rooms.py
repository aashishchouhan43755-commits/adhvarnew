from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.api.dependencies import get_db
from app.schemas.room import (
    RoomCreate,
    RoomResponse,
    RoomSearchResult,
    RoomUpdate,
)
from app.services.room_service import RoomService

router = APIRouter(
    prefix="/rooms",
    tags=["Rooms"],
)


@router.post(
    "",
    response_model=RoomResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_room(
    room: RoomCreate,
    db: Session = Depends(get_db),
):
    service = RoomService(db)

    try:
        return service.create(room)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e),
        )


@router.get(
    "",
    response_model=list[RoomResponse],
)
def get_rooms(
    db: Session = Depends(get_db),
):
    service = RoomService(db)
    return service.get_all()


@router.get(
    "/floor/{floor_id}",
    response_model=list[RoomResponse],
)
def get_rooms_by_floor(
    floor_id: int,
    db: Session = Depends(get_db),
):
    service = RoomService(db)

    try:
        return service.get_by_floor(floor_id)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e),
        )


@router.get(
    "/search",
    response_model=list[RoomSearchResult],
)
def search_rooms(
    q: str = Query(default="", max_length=100),
    db: Session = Depends(get_db),
):
    """
    Search rooms by name, room number, or room type (case-insensitive
    partial match). Returns each match with its building/floor context
    and primary navigation node, ready for use as a navigation start
    or destination point.
    """
    service = RoomService(db)
    return service.search(q)


@router.get(
    "/{room_id}",
    response_model=RoomResponse,
)
def get_room(
    room_id: int,
    db: Session = Depends(get_db),
):
    service = RoomService(db)

    try:
        return service.get_by_id(room_id)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e),
        )


@router.put(
    "/{room_id}",
    response_model=RoomResponse,
)
def update_room(
    room_id: int,
    room: RoomUpdate,
    db: Session = Depends(get_db),
):
    service = RoomService(db)

    try:
        return service.update(room_id, room)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e),
        )


@router.delete(
    "/{room_id}",
    status_code=status.HTTP_204_NO_CONTENT,
)
def delete_room(
    room_id: int,
    db: Session = Depends(get_db),
):
    service = RoomService(db)

    try:
        service.delete(room_id)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e),
        )
