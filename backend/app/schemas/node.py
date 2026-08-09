from pydantic import BaseModel, ConfigDict


class NodeBase(BaseModel):
    floor_id: int
    room_id: int | None = None
    name: str
    x: float
    y: float
    node_type: str = "corridor"


class NodeCreate(NodeBase):
    pass


class NodeUpdate(BaseModel):
    floor_id: int | None = None
    room_id: int | None = None
    name: str | None = None
    x: float | None = None
    y: float | None = None
    node_type: str | None = None


class NodeResponse(NodeBase):
    id: int

    model_config = ConfigDict(from_attributes=True)