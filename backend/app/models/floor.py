from sqlalchemy import Column, ForeignKey, Integer, String
from sqlalchemy.orm import relationship

from app.db.database import Base


class Floor(Base):
    __tablename__ = "floors"

    id = Column(Integer, primary_key=True, index=True)
    building_id = Column(
        Integer,
        ForeignKey("buildings.id", ondelete="CASCADE"),
        nullable=False,
    )
    floor_number = Column(Integer, nullable=False)
    name = Column(String(100), nullable=False)
    map_image = Column(String(255), nullable=True)

    building = relationship(
        "Building",
        back_populates="floors",
    )

    rooms = relationship(
        "Room",
        back_populates="floor",
        cascade="all, delete-orphan",
    )

    nodes = relationship(
        "Node",
        back_populates="floor",
        cascade="all, delete-orphan",
    )

    def __repr__(self):
        return (
            f"<Floor(id={self.id}, "
            f"building_id={self.building_id}, "
            f"floor={self.floor_number})>"
        )