from pydantic import BaseModel, ConfigDict


class RoomBase(BaseModel):
    floor_id: int
    room_number: str
    room_name: str
    room_type: str


class RoomCreate(RoomBase):
    pass


class RoomUpdate(BaseModel):
    floor_id: int | None = None
    room_number: str | None = None
    room_name: str | None = None
    room_type: str | None = None


class RoomResponse(RoomBase):
    id: int

    model_config = ConfigDict(from_attributes=True)


class RoomSearchResult(BaseModel):
    id: int
    room_number: str
    room_name: str
    room_type: str

    floor_id: int
    floor_number: int
    floor_name: str

    building_id: int
    building_name: str

    node_id: int | None = None
    x: float | None = None
    y: float | None = None

    model_config = ConfigDict(from_attributes=True)