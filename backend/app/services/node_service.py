from sqlalchemy.orm import Session

from app.models.node import Node
from app.repositories.floor_repository import FloorRepository
from app.repositories.node_repository import NodeRepository
from app.repositories.room_repository import RoomRepository
from app.schemas.node import NodeCreate, NodeUpdate


class NodeService:
    def __init__(self, db: Session):
        self.repository = NodeRepository(db)
        self.floor_repository = FloorRepository(db)
        self.room_repository = RoomRepository(db)

    def get_all(self) -> list[Node]:
        return self.repository.get_all()

    def get_by_id(self, node_id: int) -> Node:
        node = self.repository.get_by_id(node_id)

        if not node:
            raise ValueError("Node not found")

        return node

    def get_by_floor(self, floor_id: int) -> list[Node]:
        if not self.floor_repository.get_by_id(floor_id):
            raise ValueError("Floor not found")

        return self.repository.get_by_floor(floor_id)

    def create(self, node: NodeCreate) -> Node:
        if not self.floor_repository.get_by_id(node.floor_id):
            raise ValueError("Floor not found")

        self._validate_room_floor(node.room_id, node.floor_id)

        return self.repository.create(node)

    def update(
        self,
        node_id: int,
        node: NodeUpdate,
    ) -> Node:
        db_node = self.repository.get_by_id(node_id)

        if not db_node:
            raise ValueError("Node not found")

        if "floor_id" in node.model_fields_set and node.floor_id is None:
            raise ValueError("Floor is required")

        effective_floor_id = (
            node.floor_id
            if "floor_id" in node.model_fields_set
            else db_node.floor_id
        )
        effective_room_id = (
            node.room_id
            if "room_id" in node.model_fields_set
            else db_node.room_id
        )

        if not self.floor_repository.get_by_id(effective_floor_id):
            raise ValueError("Floor not found")

        self._validate_room_floor(effective_room_id, effective_floor_id)

        return self.repository.update(db_node, node)

    def delete(self, node_id: int) -> None:
        db_node = self.repository.get_by_id(node_id)

        if not db_node:
            raise ValueError("Node not found")

        self.repository.delete(db_node)

    def _validate_room_floor(self, room_id: int | None, floor_id: int) -> None:
        if room_id is None:
            return

        room = self.room_repository.get_by_id(room_id)

        if not room:
            raise ValueError("Room not found")

        if room.floor_id != floor_id:
            raise ValueError("A room node must belong to the room's floor")
