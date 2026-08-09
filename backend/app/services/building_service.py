from sqlalchemy.orm import Session

from app.models.building import Building
from app.repositories.building_repository import BuildingRepository
from app.schemas.building import BuildingCreate, BuildingUpdate


class BuildingService:
    def __init__(self, db: Session):
        self.repository = BuildingRepository(db)

    def get_all(self) -> list[Building]:
        return self.repository.get_all()

    def get_by_id(self, building_id: int) -> Building:
        building = self.repository.get_by_id(building_id)

        if not building:
            raise ValueError("Building not found")

        return building

    def create(self, building: BuildingCreate) -> Building:
        existing = self.repository.get_by_code(building.code)

        if existing:
            raise ValueError("Building code already exists")

        return self.repository.create(building)

    def update(
        self,
        building_id: int,
        building: BuildingUpdate,
    ) -> Building:

        db_building = self.repository.get_by_id(building_id)

        if not db_building:
            raise ValueError("Building not found")

        return self.repository.update(db_building, building)

    def delete(self, building_id: int) -> None:
        db_building = self.repository.get_by_id(building_id)

        if not db_building:
            raise ValueError("Building not found")

        self.repository.delete(db_building)