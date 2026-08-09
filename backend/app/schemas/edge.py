from pydantic import BaseModel, ConfigDict, Field


class EdgeBase(BaseModel):
    from_node_id: int
    to_node_id: int
    distance: float = Field(gt=0)
    is_bidirectional: int = Field(default=1, ge=0, le=1)


class EdgeCreate(EdgeBase):
    pass


class EdgeUpdate(BaseModel):
    from_node_id: int | None = None
    to_node_id: int | None = None
    distance: float | None = Field(default=None, gt=0)
    is_bidirectional: int | None = Field(default=None, ge=0, le=1)


class EdgeResponse(EdgeBase):
    id: int

    model_config = ConfigDict(from_attributes=True)
