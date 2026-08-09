from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.api.dependencies import get_db
from app.schemas.edge import (
    EdgeCreate,
    EdgeResponse,
    EdgeUpdate,
)
from app.services.edge_service import EdgeService

router = APIRouter(
    prefix="/edges",
    tags=["Edges"],
)


@router.post(
    "",
    response_model=EdgeResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_edge(
    edge: EdgeCreate,
    db: Session = Depends(get_db),
):
    service = EdgeService(db)

    try:
        return service.create(edge)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e),
        )


@router.get(
    "",
    response_model=list[EdgeResponse],
)
def get_edges(
    db: Session = Depends(get_db),
):
    service = EdgeService(db)
    return service.get_all()


@router.get(
    "/node/{node_id}",
    response_model=list[EdgeResponse],
)
def get_edges_by_node(
    node_id: int,
    db: Session = Depends(get_db),
):
    service = EdgeService(db)

    try:
        return service.get_by_node(node_id)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e),
        )


@router.get(
    "/{edge_id}",
    response_model=EdgeResponse,
)
def get_edge(
    edge_id: int,
    db: Session = Depends(get_db),
):
    service = EdgeService(db)

    try:
        return service.get_by_id(edge_id)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e),
        )


@router.put(
    "/{edge_id}",
    response_model=EdgeResponse,
)
def update_edge(
    edge_id: int,
    edge: EdgeUpdate,
    db: Session = Depends(get_db),
):
    service = EdgeService(db)

    try:
        return service.update(edge_id, edge)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e),
        )


@router.delete(
    "/{edge_id}",
    status_code=status.HTTP_204_NO_CONTENT,
)
def delete_edge(
    edge_id: int,
    db: Session = Depends(get_db),
):
    service = EdgeService(db)

    try:
        service.delete(edge_id)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e),
        )