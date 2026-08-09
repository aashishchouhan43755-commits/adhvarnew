from sqlalchemy import Column, ForeignKey, Integer, String
from sqlalchemy.orm import relationship

from app.db.database import Base


class Room(Base):
    __tablename__ = "rooms"

    id = Column(Integer, primary_key=True, index=True)
    floor_id = Column(
        Integer,
        ForeignKey("floors.id", ondelete="CASCADE"),
        nullable=False,
    )

    room_number = Column(String(30), nullable=False)
    room_name = Column(String(150), nullable=False)
    room_type = Column(String(50), nullable=False)

    floor = relationship(
        "Floor",
        back_populates="rooms",
    )

    nodes = relationship(
        "Node",
        back_populates="room",
    )

    def __repr__(self):
        return (
            f"<Room(id={self.id}, "
            f"room_number='{self.room_number}', "
            f"room_name='{self.room_name}')>"
        )