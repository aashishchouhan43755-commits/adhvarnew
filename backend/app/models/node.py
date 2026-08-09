from sqlalchemy import Column, Float, ForeignKey, Integer, String
from sqlalchemy.orm import relationship

from app.db.database import Base


class Node(Base):
    __tablename__ = "nodes"

    id = Column(Integer, primary_key=True, index=True)

    floor_id = Column(
        Integer,
        ForeignKey("floors.id", ondelete="CASCADE"),
        nullable=False,
    )

    room_id = Column(
        Integer,
        ForeignKey("rooms.id", ondelete="SET NULL"),
        nullable=True,
    )

    name = Column(String(100), nullable=False)

    x = Column(Float, nullable=False)
    y = Column(Float, nullable=False)

    node_type = Column(
        String(30),
        nullable=False,
        default="corridor",
    )

    floor = relationship(
        "Floor",
        back_populates="nodes",
    )

    room = relationship(
        "Room",
        back_populates="nodes",
    )

    outgoing_edges = relationship(
        "Edge",
        foreign_keys="Edge.from_node_id",
        back_populates="from_node",
        cascade="all, delete-orphan",
    )

    incoming_edges = relationship(
        "Edge",
        foreign_keys="Edge.to_node_id",
        back_populates="to_node",
        cascade="all, delete-orphan",
    )

    def __repr__(self):
        return (
            f"<Node(id={self.id}, "
            f"name='{self.name}', "
            f"x={self.x}, y={self.y})>"
        )