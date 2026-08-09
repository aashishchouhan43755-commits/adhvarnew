from sqlalchemy.orm import Session

from app.models.floor import Floor
from app.repositories.floor_repository import FloorRepository
from app.repositories.building_repository import BuildingRepository
from app.schemas.floor import FloorCreate, FloorUpdate


class FloorService:
    def __init__(self, db: Session):
        self.repository = FloorRepository(db)
        self.building_repository = BuildingRepository(db)

    def get_all(self) -> list[Floor]:
        return self.repository.get_all()

    def get_by_id(self, floor_id: int) -> Floor:
        floor = self.repository.get_by_id(floor_id)

        if not floor:
            raise ValueError("Floor not found")

        return floor

    def get_by_building(self, building_id: int) -> list[Floor]:
        if not self.building_repository.get_by_id(building_id):
            raise ValueError("Building not found")

        return self.repository.get_by_building(building_id)

    def create(self, floor: FloorCreate) -> Floor:
        if not self.building_repository.get_by_id(floor.building_id):
            raise ValueError("Building not found")

        return self.repository.create(floor)

    def update(
        self,
        floor_id: int,
        floor: FloorUpdate,
    ) -> Floor:
        db_floor = self.repository.get_by_id(floor_id)

        if not db_floor:
            raise ValueError("Floor not found")

        if (
            floor.building_id is not None
            and not self.building_repository.get_by_id(floor.building_id)
        ):
            raise ValueError("Building not found")

        return self.repository.update(db_floor, floor)

    def delete(self, floor_id: int) -> None:
        db_floor = self.repository.get_by_id(floor_id)

        if not db_floor:
            raise ValueError("Floor not found")

        self.repository.delete(db_floor)