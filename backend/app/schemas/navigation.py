from pydantic import BaseModel


class PathNode(BaseModel):
    id: int
    name: str
    node_type: str
    floor_id: int
    floor_number: int
    x: float
    y: float


class RouteResponse(BaseModel):
    distance: float
    estimated_time_seconds: float
    start_node_id: int
    end_node_id: int
    floors_traversed: list[int]
    path: list[PathNode]
    steps: list[str]
