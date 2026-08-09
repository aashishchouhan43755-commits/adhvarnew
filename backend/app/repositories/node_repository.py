from sqlalchemy.orm import Session

from app.models.node import Node
from app.schemas.node import NodeCreate, NodeUpdate


class NodeRepository:
    def __init__(self, db: Session):
        self.db = db

    def get_all(self) -> list[Node]:
        return (
            self.db.query(Node)
            .order_by(Node.floor_id, Node.id)
            .all()
        )

    def get_by_id(self, node_id: int) -> Node | None:
        return (
            self.db.query(Node)
            .filter(Node.id == node_id)
            .first()
        )

    def get_by_floor(self, floor_id: int) -> list[Node]:
        return (
            self.db.query(Node)
            .filter(Node.floor_id == floor_id)
            .order_by(Node.id)
            .all()
        )

    def create(self, node: NodeCreate) -> Node:
        db_node = Node(
            floor_id=node.floor_id,
            room_id=node.room_id,
            name=node.name,
            x=node.x,
            y=node.y,
            node_type=node.node_type,
        )

        self.db.add(db_node)
        self.db.commit()
        self.db.refresh(db_node)

        return db_node

    def update(
        self,
        db_node: Node,
        node: NodeUpdate,
    ) -> Node:
        update_data = node.model_dump(exclude_unset=True)

        for key, value in update_data.items():
            setattr(db_node, key, value)

        self.db.commit()
        self.db.refresh(db_node)

        return db_node

    def delete(self, db_node: Node) -> None:
        self.db.delete(db_node)
        self.db.commit()