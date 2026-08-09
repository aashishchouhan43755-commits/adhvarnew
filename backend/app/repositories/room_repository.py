from sqlalchemy import or_
from sqlalchemy.engine import Row
from sqlalchemy.orm import Session

from app.models.building import Building
from app.models.floor import Floor
from app.models.node import Node
from app.models.room import Room
from app.schemas.room import RoomCreate, RoomUpdate


class RoomRepository:
    def __init__(self, db: Session):
        self.db = db

    def get_all(self) -> list[Room]:
        return (
            self.db.query(Room)
            .order_by(Room.floor_id, Room.room_number)
            .all()
        )

    def get_by_id(self, room_id: int) -> Room | None:
        return (
            self.db.query(Room)
            .filter(Room.id == room_id)
            .first()
        )

    def get_by_floor(self, floor_id: int) -> list[Room]:
        return (
            self.db.query(Room)
            .filter(Room.floor_id == floor_id)
            .order_by(Room.room_number)
            .all()
        )

    def create(self, room: RoomCreate) -> Room:
        db_room = Room(
            floor_id=room.floor_id,
            room_number=room.room_number,
            room_name=room.room_name,
            room_type=room.room_type,
        )

        self.db.add(db_room)
        self.db.commit()
        self.db.refresh(db_room)

        return db_room

    def update(
        self,
        db_room: Room,
        room: RoomUpdate,
    ) -> Room:
        update_data = room.model_dump(exclude_unset=True)

        for key, value in update_data.items():
            setattr(db_room, key, value)

        self.db.commit()
        self.db.refresh(db_room)

        return db_room

    def delete(self, db_room: Room) -> None:
        self.db.delete(db_room)
        self.db.commit()

    def search(self, query: str, limit: int) -> list[Row]:
        escaped_query = (
            query.replace("\\", "\\\\")
            .replace("%", "\\%")
            .replace("_", "\\_")
        )
        like = f"%{escaped_query}%"

        return (
            self.db.query(
                Room.id,
                Room.room_number,
                Room.room_name,
                Room.room_type,
                Room.floor_id,
                Floor.floor_number,
                Floor.name.label("floor_name"),
                Building.id.label("building_id"),
                Building.name.label("building_name"),
                Node.id.label("node_id"),
                Node.x,
                Node.y,
            )
            .join(Floor, Room.floor_id == Floor.id)
            .join(Building, Floor.building_id == Building.id)
            .outerjoin(Node, Node.room_id == Room.id)
            .filter(
                or_(
                    Room.room_name.ilike(like, escape="\\"),
                    Room.room_number.ilike(like, escape="\\"),
                    Room.room_type.ilike(like, escape="\\"),
                )
            )
            .order_by(Floor.floor_number, Room.room_number, Room.id)
            .limit(limit)
            .all()
        )
