from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.api.dependencies import get_db
from app.schemas.node import (
    NodeCreate,
    NodeResponse,
    NodeUpdate,
)
from app.services.node_service import NodeService

router = APIRouter(
    prefix="/nodes",
    tags=["Nodes"],
)


@router.post(
    "",
    response_model=NodeResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_node(
    node: NodeCreate,
    db: Session = Depends(get_db),
):
    service = NodeService(db)

    try:
        return service.create(node)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e),
        )


@router.get(
    "",
    response_model=list[NodeResponse],
)
def get_nodes(
    db: Session = Depends(get_db),
):
    service = NodeService(db)
    return service.get_all()


@router.get(
    "/floor/{floor_id}",
    response_model=list[NodeResponse],
)
def get_nodes_by_floor(
    floor_id: int,
    db: Session = Depends(get_db),
):
    service = NodeService(db)

    try:
        return service.get_by_floor(floor_id)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e),
        )


@router.get(
    "/{node_id}",
    response_model=NodeResponse,
)
def get_node(
    node_id: int,
    db: Session = Depends(get_db),
):
    service = NodeService(db)

    try:
        return service.get_by_id(node_id)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e),
        )


@router.put(
    "/{node_id}",
    response_model=NodeResponse,
)
def update_node(
    node_id: int,
    node: NodeUpdate,
    db: Session = Depends(get_db),
):
    service = NodeService(db)

    try:
        return service.update(node_id, node)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e),
        )


@router.delete(
    "/{node_id}",
    status_code=status.HTTP_204_NO_CONTENT,
)
def delete_node(
    node_id: int,
    db: Session = Depends(get_db),
):
    service = NodeService(db)

    try:
        service.delete(node_id)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e),
        )