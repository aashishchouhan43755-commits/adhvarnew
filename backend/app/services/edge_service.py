from sqlalchemy.orm import Session

from app.models.edge import Edge
from app.repositories.edge_repository import EdgeRepository
from app.repositories.node_repository import NodeRepository
from app.schemas.edge import EdgeCreate, EdgeUpdate


class EdgeService:
    def __init__(self, db: Session):
        self.repository = EdgeRepository(db)
        self.node_repository = NodeRepository(db)

    def get_all(self) -> list[Edge]:
        return self.repository.get_all()

    def get_by_id(self, edge_id: int) -> Edge:
        edge = self.repository.get_by_id(edge_id)

        if not edge:
            raise ValueError("Edge not found")

        return edge

    def get_by_node(self, node_id: int) -> list[Edge]:
        if not self.node_repository.get_by_id(node_id):
            raise ValueError("Node not found")

        return self.repository.get_by_node(node_id)

    def create(self, edge: EdgeCreate) -> Edge:
        self._validate_edge_nodes(edge.from_node_id, edge.to_node_id)

        return self.repository.create(edge)

    def update(
        self,
        edge_id: int,
        edge: EdgeUpdate,
    ) -> Edge:
        db_edge = self.repository.get_by_id(edge_id)

        if not db_edge:
            raise ValueError("Edge not found")

        if (
            "from_node_id" in edge.model_fields_set
            and edge.from_node_id is None
        ):
            raise ValueError("Source node is required")

        if "to_node_id" in edge.model_fields_set and edge.to_node_id is None:
            raise ValueError("Destination node is required")

        if "distance" in edge.model_fields_set and edge.distance is None:
            raise ValueError("Distance is required")

        if (
            "is_bidirectional" in edge.model_fields_set
            and edge.is_bidirectional is None
        ):
            raise ValueError("Bidirectional flag is required")

        self._validate_edge_nodes(
            edge.from_node_id
            if "from_node_id" in edge.model_fields_set
            else db_edge.from_node_id,
            edge.to_node_id
            if "to_node_id" in edge.model_fields_set
            else db_edge.to_node_id,
        )

        return self.repository.update(db_edge, edge)

    def delete(self, edge_id: int) -> None:
        db_edge = self.repository.get_by_id(edge_id)

        if not db_edge:
            raise ValueError("Edge not found")

        self.repository.delete(db_edge)

    def _validate_edge_nodes(self, from_node_id: int, to_node_id: int) -> None:
        if from_node_id == to_node_id:
            raise ValueError("An edge must connect two different nodes")

        source = self.node_repository.get_by_id(from_node_id)
        destination = self.node_repository.get_by_id(to_node_id)

        if not source:
            raise ValueError("Source node not found")

        if not destination:
            raise ValueError("Destination node not found")

        if source.floor.building_id != destination.floor.building_id:
            raise ValueError("An edge cannot connect nodes from different buildings")
