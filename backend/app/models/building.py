from sqlalchemy import Column, Integer, String, Text
from sqlalchemy.orm import relationship

from app.db.database import Base


class Building(Base):
    __tablename__ = "buildings"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(150), nullable=False, unique=True)
    code = Column(String(30), nullable=False, unique=True)
    address = Column(Text, nullable=True)
    description = Column(Text, nullable=True)

    floors = relationship(
        "Floor",
        back_populates="building",
        cascade="all, delete-orphan",
    )

    @property
    def total_floors(self) -> int:
        """Derived from the floors relationship; not a stored column."""
        return len(self.floors)

    def __repr__(self):
        return f"<Building(id={self.id}, name='{self.name}')>"