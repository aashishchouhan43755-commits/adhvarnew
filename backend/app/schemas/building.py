from pydantic import BaseModel, ConfigDict


class BuildingBase(BaseModel):
    name: str
    code: str
    address: str | None = None
    description: str | None = None


class BuildingCreate(BuildingBase):
    pass


class BuildingUpdate(BaseModel):
    name: str | None = None
    code: str | None = None
    address: str | None = None
    description: str | None = None


class BuildingResponse(BuildingBase):
    id: int
    total_floors: int = 0

    model_config = ConfigDict(from_attributes=True)