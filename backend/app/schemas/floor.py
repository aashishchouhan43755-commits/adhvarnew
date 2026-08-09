from pydantic import BaseModel, ConfigDict


class FloorBase(BaseModel):
    building_id: int
    floor_number: int
    name: str
    map_image: str | None = None


class FloorCreate(FloorBase):
    pass


class FloorUpdate(BaseModel):
    building_id: int | None = None
    floor_number: int | None = None
    name: str | None = None
    map_image: str | None = None


class FloorResponse(FloorBase):
    id: int

    model_config = ConfigDict(from_attributes=True)