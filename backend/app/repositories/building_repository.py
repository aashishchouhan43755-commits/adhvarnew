from sqlalchemy.orm import Session

from app.models.building import Building
from app.schemas.building import BuildingCreate, BuildingUpdate


class BuildingRepository:
    def __init__(self, db: Session):
        self.db = db

    def get_all(self) -> list[Building]:
        return self.db.query(Building).order_by(Building.name).all()

    def get_by_id(self, building_id: int) -> Building | None:
        return (
            self.db.query(Building)
            .filter(Building.id == building_id)
            .first()
        )

    def get_by_code(self, code: str) -> Building | None:
        return (
            self.db.query(Building)
            .filter(Building.code == code)
            .first()
        )

    def create(self, building: BuildingCreate) -> Building:
        db_building = Building(
            name=building.name,
            code=building.code,
            address=building.address,
            description=building.description,
        )

        self.db.add(db_building)
        self.db.commit()
        self.db.refresh(db_building)

        return db_building

    def update(
        self,
        db_building: Building,
        building: BuildingUpdate,
    ) -> Building:

        update_data = building.model_dump(exclude_unset=True)

        for key, value in update_data.items():
            setattr(db_building, key, value)

        self.db.commit()
        self.db.refresh(db_building)

        return db_building

    def delete(self, db_building: Building) -> None:
        self.db.delete(db_building)
        self.db.commit()