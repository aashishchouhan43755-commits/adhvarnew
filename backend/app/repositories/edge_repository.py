from sqlalchemy.orm import Session

from app.models.edge import Edge
from app.schemas.edge import EdgeCreate, EdgeUpdate


class EdgeRepository:
    def __init__(self, db: Session):
        self.db = db

    def get_all(self) -> list[Edge]:
        return (
            self.db.query(Edge)
            .order_by(Edge.from_node_id, Edge.to_node_id)
            .all()
        )

    def get_by_id(self, edge_id: int) -> Edge | None:
        return (
            self.db.query(Edge)
            .filter(Edge.id == edge_id)
            .first()
        )

    def get_by_node(self, node_id: int) -> list[Edge]:
        return (
            self.db.query(Edge)
            .filter(Edge.from_node_id == node_id)
            .all()
        )

    def create(self, edge: EdgeCreate) -> Edge:
        db_edge = Edge(
            from_node_id=edge.from_node_id,
            to_node_id=edge.to_node_id,
            distance=edge.distance,
            is_bidirectional=edge.is_bidirectional,
        )

        self.db.add(db_edge)
        self.db.commit()
        self.db.refresh(db_edge)

        return db_edge

    def update(
        self,
        db_edge: Edge,
        edge: EdgeUpdate,
    ) -> Edge:
        update_data = edge.model_dump(exclude_unset=True)

        for key, value in update_data.items():
            setattr(db_edge, key, value)

        self.db.commit()
        self.db.refresh(db_edge)

        return db_edge

    def delete(self, db_edge: Edge) -> None:
        self.db.delete(db_edge)
        self.db.commit()