from sqlalchemy.orm import Session

from app.models.room import Room
from app.repositories.floor_repository import FloorRepository
from app.repositories.room_repository import RoomRepository
from app.schemas.room import RoomCreate, RoomSearchResult, RoomUpdate


class RoomService:
    def __init__(self, db: Session):
        self.repository = RoomRepository(db)
        self.floor_repository = FloorRepository(db)

    def get_all(self) -> list[Room]:
        return self.repository.get_all()

    def get_by_id(self, room_id: int) -> Room:
        room = self.repository.get_by_id(room_id)

        if not room:
            raise ValueError("Room not found")

        return room

    def get_by_floor(self, floor_id: int) -> list[Room]:
        if not self.floor_repository.get_by_id(floor_id):
            raise ValueError("Floor not found")

        return self.repository.get_by_floor(floor_id)

    def create(self, room: RoomCreate) -> Room:
        if not self.floor_repository.get_by_id(room.floor_id):
            raise ValueError("Floor not found")

        return self.repository.create(room)

    def update(
        self,
        room_id: int,
        room: RoomUpdate,
    ) -> Room:
        db_room = self.repository.get_by_id(room_id)

        if not db_room:
            raise ValueError("Room not found")

        if (
            room.floor_id is not None
            and not self.floor_repository.get_by_id(room.floor_id)
        ):
            raise ValueError("Floor not found")

        return self.repository.update(db_room, room)

    def delete(self, room_id: int) -> None:
        db_room = self.repository.get_by_id(room_id)

        if not db_room:
            raise ValueError("Room not found")

        self.repository.delete(db_room)

    def search(self, query: str, limit: int = 25) -> list[RoomSearchResult]:
        normalized_query = " ".join(query.split())

        if not normalized_query:
            return []

        rows = self.repository.search(normalized_query, limit)

        return [
            RoomSearchResult(
                id=row.id,
                room_number=row.room_number,
                room_name=row.room_name,
                room_type=row.room_type,
                floor_id=row.floor_id,
                floor_number=row.floor_number,
                floor_name=row.floor_name,
                building_id=row.building_id,
                building_name=row.building_name,
                node_id=row.node_id,
                x=row.x,
                y=row.y,
            )
            for row in rows
        ]
