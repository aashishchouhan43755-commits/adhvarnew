from sqlalchemy import Column, Float, ForeignKey, Integer
from sqlalchemy.orm import relationship

from app.db.database import Base


class Edge(Base):
    __tablename__ = "edges"

    id = Column(Integer, primary_key=True, index=True)

    from_node_id = Column(
        Integer,
        ForeignKey("nodes.id", ondelete="CASCADE"),
        nullable=False,
    )

    to_node_id = Column(
        Integer,
        ForeignKey("nodes.id", ondelete="CASCADE"),
        nullable=False,
    )

    distance = Column(
        Float,
        nullable=False,
    )

    is_bidirectional = Column(
        Integer,
        default=1,
        nullable=False,
    )

    from_node = relationship(
        "Node",
        foreign_keys=[from_node_id],
        back_populates="outgoing_edges",
    )

    to_node = relationship(
        "Node",
        foreign_keys=[to_node_id],
        back_populates="incoming_edges",
    )

    def __repr__(self):
        return (
            f"<Edge(id={self.id}, "
            f"from={self.from_node_id}, "
            f"to={self.to_node_id}, "
            f"distance={self.distance})>"
        )