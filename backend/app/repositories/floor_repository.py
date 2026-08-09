from sqlalchemy.orm import Session

from app.models.floor import Floor
from app.schemas.floor import FloorCreate, FloorUpdate


class FloorRepository:
    def __init__(self, db: Session):
        self.db = db

    def get_all(self) -> list[Floor]:
        return (
            self.db.query(Floor)
            .order_by(Floor.building_id, Floor.floor_number)
            .all()
        )

    def get_by_id(self, floor_id: int) -> Floor | None:
        return (
            self.db.query(Floor)
            .filter(Floor.id == floor_id)
            .first()
        )

    def get_by_building(self, building_id: int) -> list[Floor]:
        return (
            self.db.query(Floor)
            .filter(Floor.building_id == building_id)
            .order_by(Floor.floor_number)
            .all()
        )

    def create(self, floor: FloorCreate) -> Floor:
        db_floor = Floor(
            building_id=floor.building_id,
            floor_number=floor.floor_number,
            name=floor.name,
            map_image=floor.map_image,
        )

        self.db.add(db_floor)
        self.db.commit()
        self.db.refresh(db_floor)

        return db_floor

    def update(
        self,
        db_floor: Floor,
        floor: FloorUpdate,
    ) -> Floor:
        update_data = floor.model_dump(exclude_unset=True)

        for key, value in update_data.items():
            setattr(db_floor, key, value)

        self.db.commit()
        self.db.refresh(db_floor)

        return db_floor

    def delete(self, db_floor: Floor) -> None:
        self.db.delete(db_floor)
        self.db.commit()