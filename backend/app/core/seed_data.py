"""
Multi-building dataset generator for Adhvar Indoor Navigation.

Seeds:
1. Adhvar Innovation Center (AIC) - 3 Floors (Ground, 1st, 2nd) - 30 rooms
2. Main Academic Block (MAB) - 3 Floors (Ground, 1st, 2nd) - 15 rooms
3. Science & Technology Tower (STT) - 3 Floors (Ground, 1st, 2nd) - 15 rooms
4. Student Activity & Sports Complex (SAC) - 2 Floors (Ground, 1st) - 10 rooms
"""

from sqlalchemy.orm import Session

from app.models.building import Building
from app.models.edge import Edge
from app.models.floor import Floor
from app.models.node import Node
from app.models.room import Room

# ---------------------------------------------------------------------------
# H-Grid corridor intersection nodes (label, x, y)
# ---------------------------------------------------------------------------
CORRIDOR_GRID = [
    ("T-Left",    90,  80),   # idx 0
    ("T-Center", 215,  80),   # idx 1
    ("T-Right",  340,  80),   # idx 2
    ("M-Left",    90, 155),   # idx 3
    ("M-Center", 215, 155),   # idx 4
    ("M-Right",  340, 155),   # idx 5
    ("B-Left",    90, 230),   # idx 6
    ("B-Center", 215, 230),   # idx 7
    ("B-Right",  340, 230),   # idx 8
]

CORRIDOR_EDGE_PAIRS = [
    (0, 1), (1, 2),
    (3, 4), (4, 5),
    (6, 7), (7, 8),
    (0, 3), (3, 6),
    (1, 4), (4, 7),
    (2, 5), (5, 8),
]

LIFT_POSITIONS = [
    ("Lift 1",  35,  80, 0),
    ("Lift 2",  35, 230, 6),
]

STAIR_POSITIONS = [
    ("Staircase 1", 395,  80, 2),
    ("Staircase 2", 395, 230, 8),
]

WASHROOM_POSITIONS = [
    ("Washroom - Male",   195, 192, 4),
    ("Washroom - Female", 235, 192, 4),
]

EXIT_POSITIONS = [
    ("Emergency Exit", 395, 155, 5),
]

ROOM_POSITIONS = [
    ( 90,  30, 0),
    (160,  30, 1),
    (215,  30, 1),
    (270,  30, 1),
    (340,  30, 2),
    ( 90, 260, 6),
    (160, 260, 7),
    (215, 260, 7),
    (270, 260, 7),
    (340, 260, 8),
]

LIFT_TRANSITION_DISTANCE  = 15.0
STAIR_TRANSITION_DISTANCE = 22.0


def _dist(ax: float, ay: float, bx: float, by: float) -> float:
    return round(((ax - bx) ** 2 + (ay - by) ** 2) ** 0.5, 2)


def _seed_single_building(
    db: Session,
    name: str,
    code: str,
    address: str,
    description: str,
    floors_data: dict[int, tuple[str, list[tuple[str, str, str]]]],
) -> None:
    existing = db.query(Building).filter(Building.code == code).first()
    if existing:
        print(f"Building {name} ({code}) already exists.")
        return

    building = Building(
        name=name,
        code=code,
        address=address,
        description=description,
    )
    db.add(building)
    db.commit()
    db.refresh(building)

    lift_nodes:  dict[str, list[Node]] = {"Lift 1": [], "Lift 2": []}
    stair_nodes: dict[str, list[Node]] = {"Staircase 1": [], "Staircase 2": []}

    for floor_number, (floor_name, rooms_list) in floors_data.items():
        floor = Floor(
            building_id=building.id,
            floor_number=floor_number,
            name=floor_name,
            map_image=f"assets/maps/floor_{floor_number}.svg",
        )
        db.add(floor)
        db.commit()
        db.refresh(floor)

        edges: list[Edge] = []

        # Corridor nodes
        corridor_nodes: list[Node] = []
        for label, cx, cy in CORRIDOR_GRID:
            node = Node(
                floor_id=floor.id,
                room_id=None,
                name=label,
                x=float(cx),
                y=float(cy),
                node_type="corridor",
            )
            db.add(node)
            corridor_nodes.append(node)

        db.commit()
        for n in corridor_nodes:
            db.refresh(n)

        for ai, bi in CORRIDOR_EDGE_PAIRS:
            a = corridor_nodes[ai]
            b = corridor_nodes[bi]
            edges.append(Edge(
                from_node_id=a.id,
                to_node_id=b.id,
                distance=_dist(a.x, a.y, b.x, b.y),
                is_bidirectional=1,
            ))

        # Lifts
        for label, lx, ly, cor_idx in LIFT_POSITIONS:
            node = Node(
                floor_id=floor.id,
                room_id=None,
                name=f"{label} - Floor {floor_number}",
                x=float(lx),
                y=float(ly),
                node_type="lift",
            )
            db.add(node)
            db.commit()
            db.refresh(node)
            lift_nodes[label].append(node)
            cor = corridor_nodes[cor_idx]
            edges.append(Edge(
                from_node_id=node.id,
                to_node_id=cor.id,
                distance=_dist(lx, ly, cor.x, cor.y),
                is_bidirectional=1,
            ))

        # Staircases
        for label, sx, sy, cor_idx in STAIR_POSITIONS:
            node = Node(
                floor_id=floor.id,
                room_id=None,
                name=f"{label} - Floor {floor_number}",
                x=float(sx),
                y=float(sy),
                node_type="staircase",
            )
            db.add(node)
            db.commit()
            db.refresh(node)
            stair_nodes[label].append(node)
            cor = corridor_nodes[cor_idx]
            edges.append(Edge(
                from_node_id=node.id,
                to_node_id=cor.id,
                distance=_dist(sx, sy, cor.x, cor.y),
                is_bidirectional=1,
            ))

        # Washrooms
        for label, wx, wy, cor_idx in WASHROOM_POSITIONS:
            node = Node(
                floor_id=floor.id,
                room_id=None,
                name=f"{label} (Floor {floor_number})",
                x=float(wx),
                y=float(wy),
                node_type="washroom",
            )
            db.add(node)
            db.commit()
            db.refresh(node)
            cor = corridor_nodes[cor_idx]
            edges.append(Edge(
                from_node_id=node.id,
                to_node_id=cor.id,
                distance=_dist(wx, wy, cor.x, cor.y),
                is_bidirectional=1,
            ))

        # Emergency exits
        for label, ex, ey, cor_idx in EXIT_POSITIONS:
            node = Node(
                floor_id=floor.id,
                room_id=None,
                name=f"{label} (Floor {floor_number})",
                x=float(ex),
                y=float(ey),
                node_type="emergency_exit",
            )
            db.add(node)
            db.commit()
            db.refresh(node)
            cor = corridor_nodes[cor_idx]
            edges.append(Edge(
                from_node_id=node.id,
                to_node_id=cor.id,
                distance=_dist(ex, ey, cor.x, cor.y),
                is_bidirectional=1,
            ))

        # Rooms
        for idx, (room_number, room_name, room_type) in enumerate(rooms_list):
            room = Room(
                floor_id=floor.id,
                room_number=room_number,
                room_name=room_name,
                room_type=room_type,
            )
            db.add(room)
            db.commit()
            db.refresh(room)

            pos_idx = idx % len(ROOM_POSITIONS)
            rx, ry, cor_idx = ROOM_POSITIONS[pos_idx]
            node_type = "reception" if room_type == "reception" else "room"
            room_node = Node(
                floor_id=floor.id,
                room_id=room.id,
                name=room_name,
                x=float(rx + (idx // len(ROOM_POSITIONS)) * 10),
                y=float(ry),
                node_type=node_type,
            )
            db.add(room_node)
            db.commit()
            db.refresh(room_node)

            cor = corridor_nodes[cor_idx]
            edges.append(Edge(
                from_node_id=room_node.id,
                to_node_id=cor.id,
                distance=_dist(rx, ry, cor.x, cor.y),
                is_bidirectional=1,
            ))

        db.add_all(edges)
        db.commit()

    # Inter-floor transitions
    inter_floor_edges: list[Edge] = []
    for nodes_by_floor in lift_nodes.values():
        for a, b in zip(nodes_by_floor, nodes_by_floor[1:]):
            inter_floor_edges.append(Edge(
                from_node_id=a.id,
                to_node_id=b.id,
                distance=LIFT_TRANSITION_DISTANCE,
                is_bidirectional=1,
            ))

    for nodes_by_floor in stair_nodes.values():
        for a, b in zip(nodes_by_floor, nodes_by_floor[1:]):
            inter_floor_edges.append(Edge(
                from_node_id=a.id,
                to_node_id=b.id,
                distance=STAIR_TRANSITION_DISTANCE,
                is_bidirectional=1,
            ))

    db.add_all(inter_floor_edges)
    db.commit()
    print(f"Seeded building: {name} ({code}) with {len(floors_data)} floors.")


def seed_database(db: Session) -> None:
    # 1. Adhvar Innovation Center (AIC)
    aic_floors = {
        1: ("Ground Floor", [
            ("G01", "Reception",          "reception"),
            ("G02", "Help Desk",          "office"),
            ("G03", "Visitor Lounge",     "lounge"),
            ("G04", "Security Office",    "office"),
            ("G05", "Cafeteria",          "cafeteria"),
            ("G06", "Server Room",        "utility"),
            ("G07", "IT Support Desk",    "office"),
            ("G08", "Store Room",         "utility"),
            ("G09", "Admin Office",       "office"),
            ("G10", "Guest Waiting Area", "lounge"),
        ]),
        2: ("First Floor", [
            ("101", "Conference Room A",  "meeting"),
            ("102", "Conference Room B",  "meeting"),
            ("103", "Manager Cabin 1",    "office"),
            ("104", "Manager Cabin 2",    "office"),
            ("105", "HR Office",          "office"),
            ("106", "Finance Office",     "office"),
            ("107", "Training Room",      "classroom"),
            ("108", "Meeting Pod 1",      "meeting"),
            ("109", "Meeting Pod 2",      "meeting"),
            ("110", "Open Workspace",     "workspace"),
        ]),
        3: ("Second Floor", [
            ("201", "Innovation Lab",     "lab"),
            ("202", "Design Studio",      "studio"),
            ("203", "R&D Lab 1",          "lab"),
            ("204", "R&D Lab 2",          "lab"),
            ("205", "Robotics Lab",       "lab"),
            ("206", "AI Research Lab",    "lab"),
            ("207", "Library",            "library"),
            ("208", "Seminar Hall",       "hall"),
            ("209", "Director Cabin",     "office"),
            ("210", "Board Room",         "meeting"),
        ]),
    }
    _seed_single_building(
        db,
        name="Adhvar Innovation Center",
        code="AIC",
        address="Adhvar Tech Park, Sector 21",
        description="Flagship demo building for Adhvar indoor navigation: 3 floors, 30 rooms, labs, and collaboration spaces.",
        floors_data=aic_floors,
    )

    # 2. Main Academic Block (MAB)
    mab_floors = {
        1: ("Ground Floor", [
            ("M01", "Academic Reception", "reception"),
            ("M02", "Dean Office",         "office"),
            ("M03", "Main Auditorium",    "hall"),
            ("M04", "Faculty Lounge",     "lounge"),
            ("M05", "Student Service Center", "office"),
        ]),
        2: ("First Floor", [
            ("M101", "Lecture Hall 1",    "classroom"),
            ("M102", "Lecture Hall 2",    "classroom"),
            ("M103", "Computer Lab 1",    "lab"),
            ("M104", "Computer Lab 2",    "lab"),
            ("M105", "Department Office", "office"),
        ]),
        3: ("Second Floor", [
            ("M201", "Central Library",   "library"),
            ("M202", "Reading Room",      "study"),
            ("M203", "Research Scholar Room", "office"),
            ("M204", "E-Resource Center", "lab"),
            ("M205", "Archival Storage",   "utility"),
        ]),
    }
    _seed_single_building(
        db,
        name="Main Academic Block",
        code="MAB",
        address="Academic Complex, East Wing",
        description="Primary academic hub featuring auditoriums, lecture halls, computer labs, and the Central Library across 3 floors.",
        floors_data=mab_floors,
    )

    # 3. Science & Technology Tower (STT)
    stt_floors = {
        1: ("Ground Floor", [
            ("S01", "Tech Lobby",         "reception"),
            ("S02", "Physics Lab",        "lab"),
            ("S03", "Chemistry Lab",      "lab"),
            ("S04", "Instrument Room",    "utility"),
            ("S05", "Safety Cell",        "office"),
        ]),
        2: ("First Floor", [
            ("S101", "Robotics & Automation Lab", "lab"),
            ("S102", "AI & Data Science Center", "lab"),
            ("S103", "Electronics Lab",   "lab"),
            ("S104", "IoT Prototyping Hub", "lab"),
            ("S105", "Faculty Cabin A",   "office"),
        ]),
        3: ("Second Floor", [
            ("S201", "Biotech Cleanroom", "lab"),
            ("S202", "Nanotech Research Lab", "lab"),
            ("S203", "Supercomputing Facility", "lab"),
            ("S204", "Quantum Compute Lab", "lab"),
            ("S205", "Conference Room Tech", "meeting"),
        ]),
    }
    _seed_single_building(
        db,
        name="Science & Technology Tower",
        code="STT",
        address="Research Zone, North Campus",
        description="State-of-the-art research facility with specialized science, AI, robotics, and cleanroom laboratories across 3 floors.",
        floors_data=stt_floors,
    )

    # 4. Student Activity & Sports Complex (SAC)
    sac_floors = {
        1: ("Ground Floor", [
            ("SAC01", "Sports Desk",       "reception"),
            ("SAC02", "Indoor Gymnasium",  "gym"),
            ("SAC03", "Health & Medical Center", "medical"),
            ("SAC04", "Food Court & Cafe", "cafeteria"),
            ("SAC05", "Equipment Store",   "utility"),
        ]),
        2: ("First Floor", [
            ("SAC101", "Badminton Court 1", "sports"),
            ("SAC102", "Badminton Court 2", "sports"),
            ("SAC103", "Student Clubs Hub", "lounge"),
            ("SAC104", "Music & Dance Studio", "studio"),
            ("SAC105", "Recreation Room",  "lounge"),
        ]),
    }
    _seed_single_building(
        db,
        name="Student Activity & Sports Complex",
        code="SAC",
        address="Student Amenities Zone, South Campus",
        description="Vibrant student hub housing indoor sports courts, gymnasium, health center, food court, and club studios.",
        floors_data=sac_floors,
    )
