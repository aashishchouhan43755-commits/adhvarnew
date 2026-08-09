"""
Indoor navigation / pathfinding engine.

Graph construction (`_build_graph`) and the search algorithm (`_dijkstra`)
are kept separate from route *enrichment* (`find_route`), which turns a
raw list of node ids into distance, an estimated walking time, the
floors traversed, and human-readable step-by-step directions -
including lift/staircase transitions between floors.

This separation is deliberate: a future A* implementation only needs to
add a new search method that consumes the same `graph` produced by
`_build_graph` and returns the same `(distance, path_ids)` shape that
`_dijkstra` returns today - `find_route` and everything downstream of it
would not need to change.
"""

from collections import defaultdict
import heapq
import math

from sqlalchemy.orm import Session, joinedload

from app.models.edge import Edge
from app.models.node import Node

# Distances in the graph are treated as meters. This is an average adult
# indoor walking speed, used only to produce a friendly ETA.
WALKING_SPEED_MPS = 1.4

# Node types that represent a floor-to-floor transition point.
TRANSITION_NODE_TYPES = {"lift", "staircase"}


class PathfindingService:
    def __init__(self, db: Session):
        self.db = db

    # ------------------------------------------------------------------
    # Graph construction - shared by any current or future search method
    # ------------------------------------------------------------------
    def _build_graph(self) -> dict[int, list[tuple[int, float]]]:
        graph: dict[int, list[tuple[int, float]]] = defaultdict(list)

        edges = self.db.query(Edge).all()

        for edge in edges:
            if not math.isfinite(edge.distance) or edge.distance <= 0:
                raise ValueError(f"Edge {edge.id} has an invalid distance")

            graph[edge.from_node_id].append(
                (edge.to_node_id, edge.distance)
            )

            if edge.is_bidirectional:
                graph[edge.to_node_id].append(
                    (edge.from_node_id, edge.distance)
                )

        return graph

    # ------------------------------------------------------------------
    # Core search algorithm
    # ------------------------------------------------------------------
    def _dijkstra(
        self,
        graph: dict[int, list[tuple[int, float]]],
        start_node_id: int,
        end_node_id: int,
    ) -> tuple[float, list[int]]:
        distances = {start_node_id: 0}
        previous: dict[int, int] = {}
        pq = [(0, start_node_id)]
        visited = set()

        while pq:
            current_distance, current = heapq.heappop(pq)

            if current in visited:
                continue

            visited.add(current)

            if current == end_node_id:
                break

            for neighbor, weight in graph.get(current, ()):
                distance = current_distance + weight

                if distance < distances.get(neighbor, float("inf")):
                    distances[neighbor] = distance
                    previous[neighbor] = current

                    heapq.heappush(pq, (distance, neighbor))

        if end_node_id not in distances:
            raise ValueError("No route found")

        path = []
        node = end_node_id

        while node != start_node_id:
            path.append(node)
            if node not in previous:
                raise ValueError("Navigation graph is incomplete")
            node = previous[node]

        path.append(start_node_id)
        path.reverse()

        return distances[end_node_id], path

    def _validate_nodes(self, start_node_id: int, end_node_id: int) -> None:
        start = self.db.query(Node).filter(Node.id == start_node_id).first()
        end = self.db.query(Node).filter(Node.id == end_node_id).first()

        if not start or not end:
            raise ValueError("Invalid node")

        if start.floor.building_id != end.floor.building_id:
            raise ValueError("Navigation is only available within one building")

    # ------------------------------------------------------------------
    # Public: raw shortest path - unchanged response shape, kept for
    # backward compatibility with any existing caller of /navigation/path.
    # ------------------------------------------------------------------
    def shortest_path(self, start_node_id: int, end_node_id: int) -> dict:
        self._validate_nodes(start_node_id, end_node_id)

        graph = self._build_graph()
        distance, path = self._dijkstra(graph, start_node_id, end_node_id)

        return {
            "distance": distance,
            "path": path,
        }

    # ------------------------------------------------------------------
    # Public: enriched, multi-floor-aware route
    # ------------------------------------------------------------------
    def find_route(self, start_node_id: int, end_node_id: int) -> dict:
        self._validate_nodes(start_node_id, end_node_id)

        graph = self._build_graph()
        distance, path_ids = self._dijkstra(graph, start_node_id, end_node_id)

        nodes_by_id = {
            node.id: node
            for node in (
                self.db.query(Node)
                .options(joinedload(Node.floor))
                .filter(Node.id.in_(path_ids))
                .all()
            )
        }
        if len(nodes_by_id) != len(path_ids):
            raise ValueError("Navigation graph references an unavailable node")

        path_nodes = [nodes_by_id[node_id] for node_id in path_ids]

        return {
            "distance": round(distance, 2),
            "estimated_time_seconds": round(distance / WALKING_SPEED_MPS, 1),
            "start_node_id": start_node_id,
            "end_node_id": end_node_id,
            "floors_traversed": self._floors_traversed(path_nodes),
            "path": [
                {
                    "id": node.id,
                    "name": node.name,
                    "node_type": node.node_type,
                    "floor_id": node.floor_id,
                    "floor_number": node.floor.floor_number,
                    "x": node.x,
                    "y": node.y,
                }
                for node in path_nodes
            ],
            "steps": self._build_steps(path_nodes),
        }

    # ------------------------------------------------------------------
    # Route enrichment helpers
    # ------------------------------------------------------------------
    def _floors_traversed(self, path_nodes: list[Node]) -> list[int]:
        floors: list[int] = []

        for node in path_nodes:
            floor_number = node.floor.floor_number

            if not floors or floors[-1] != floor_number:
                floors.append(floor_number)

        return floors

    def _build_steps(self, path_nodes: list[Node]) -> list[str]:
        if len(path_nodes) < 2:
            return [f"You are already at {path_nodes[0].name}."]

        steps = [f"Start at {path_nodes[0].name}."]
        last_index = len(path_nodes) - 1

        for i in range(1, len(path_nodes)):
            previous_node = path_nodes[i - 1]
            current_node = path_nodes[i]
            is_last = i == last_index

            is_departure = (
                current_node.node_type in TRANSITION_NODE_TYPES
                and i + 1 <= last_index
                and path_nodes[i + 1].floor_id != current_node.floor_id
            )
            is_landing = (
                previous_node.node_type in TRANSITION_NODE_TYPES
                and current_node.node_type == previous_node.node_type
                and current_node.floor_id != previous_node.floor_id
            )

            # Check departure first: on a route spanning 3+ floors via the
            # same shaft, a node can be both the landing from the floor
            # below AND the departure to the floor above. If landing were
            # checked first, that second hop would be silently dropped.
            if is_departure:
                next_node = path_nodes[i + 1]
                verb = (
                    "Take the lift"
                    if current_node.node_type == "lift"
                    else "Take the stairs"
                )
                direction = (
                    "up"
                    if next_node.floor.floor_number > current_node.floor.floor_number
                    else "down"
                )
                shaft_label = current_node.name.split(" - ")[0]

                steps.append(
                    f"{verb} {direction} to {next_node.floor.name} via {shaft_label}."
                )
                continue

            if is_landing:
                if is_last:
                    steps.append(f"You have arrived at {current_node.name}.")
                continue

            if is_last:
                steps.append(f"You have arrived at {current_node.name}.")
            elif current_node.node_type == "corridor":
                # Plain corridor waypoints keep the graph connected but
                # add no value to a human-readable direction list.
                continue
            else:
                steps.append(f"Head to {current_node.name}.")

        return steps
