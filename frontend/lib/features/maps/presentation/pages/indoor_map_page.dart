import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/floor_model.dart';
import '../../../../core/models/room_search_result_model.dart';
import '../../../../core/models/route_model.dart';
import '../providers/maps_provider.dart';
import '../widgets/floor_switcher.dart';
import '../widgets/map_canvas.dart';
import '../widgets/map_legend_widget.dart';
import '../widgets/route_panel.dart';

class IndoorMapPage extends ConsumerStatefulWidget {
  final int buildingId;
  final String buildingName;
  final int? floorId;
  final String? floorName;

  /// Optional: pre-fills the destination picker.
  final RoomSearchResultModel? presetDestination;

  const IndoorMapPage({
    super.key,
    required this.buildingId,
    required this.buildingName,
    this.floorId,
    this.floorName,
    this.presetDestination,
  });

  @override
  ConsumerState<IndoorMapPage> createState() => _IndoorMapPageState();
}

class _IndoorMapPageState extends ConsumerState<IndoorMapPage>
    with TickerProviderStateMixin {
  int? _selectedFloorId;
  late final AnimationController _routeAnimationController;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    _selectedFloorId = widget.floorId;

    _routeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    if (widget.presetDestination != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(routeSelectionProvider.notifier)
            .setDestination(widget.presetDestination!);
      });
    }
  }

  @override
  void dispose() {
    _routeAnimationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onFloorSelected(int floorId) {
    setState(() => _selectedFloorId = floorId);
  }

  void _playRouteAnimation() {
    _routeAnimationController
      ..reset()
      ..forward();
  }

  void _focusRouteStart(RouteModel route, List<FloorModel> floors) {
    if (route.path.isEmpty) return;

    final startFloorNumber = route.path.first.floorNumber;
    final startFloor = floors.where(
      (floor) => floor.floorNumber == startFloorNumber,
    );

    if (startFloor.isEmpty || _selectedFloorId == startFloor.first.id) return;

    setState(() => _selectedFloorId = startFloor.first.id);
  }

  @override
  Widget build(BuildContext context) {
    final floorsAsync = ref.watch(floorsByBuildingProvider(widget.buildingId));
    final selection = ref.watch(routeSelectionProvider);

    ref.listen(routeSelectionProvider, (previous, next) {
      final route = next.route.asData?.value;
      final previousRoute = previous?.route.asData?.value;
      final floors = floorsAsync.asData?.value;

      if (route != null && route != previousRoute) {
        if (floors != null) _focusRouteStart(route, floors);
        _playRouteAnimation();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5FB),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF1d4ed8), Color(0xFF7c3aed)],
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x221d4ed8),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: NavigationToolbar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new,
                    color: Colors.white, size: 18),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/building-list');
                  }
                },
              ),
              middle: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_city_rounded,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    widget.buildingName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              centerMiddle: true,
            ),
          ),
        ),
      ),
      body: floorsAsync.when(
        data: (floors) {
          if (floors.isEmpty) {
            return const Center(
              child: Text("No floors found for this building."),
            );
          }

          final selectedFloorId = _selectedFloorId ??
              (widget.floorName == null
                  ? floors.first.id
                  : floors
                      .firstWhere(
                        (f) => f.name == widget.floorName,
                        orElse: () => floors.first,
                      )
                      .id);
          final selectedFloor =
              floors.firstWhere((f) => f.id == selectedFloorId);

          final nodesAsync = ref.watch(nodesByFloorProvider(selectedFloorId));

          return Column(
            children: [
              const SizedBox(height: 12),

              // Floor switcher
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: FloorSwitcher(
                  floors: floors,
                  selectedFloorId: selectedFloorId,
                  onSelected: (floor) => _onFloorSelected(floor.id),
                ),
              ),

              const SizedBox(height: 10),

              // Map area
              Expanded(
                child: nodesAsync.when(
                  data: (nodes) {
                    final route = selection.route.value;
                    final List<RoutePathNodeModel> routeNodesOnFloor =
                        route == null
                            ? const []
                            : route.nodesForFloor(selectedFloor.floorNumber);

                    return Stack(
                      children: [
                        // Map canvas
                        Positioned.fill(
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.07),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: AnimatedBuilder(
                              animation: Listenable.merge([
                                _routeAnimationController,
                                _pulseController,
                              ]),
                              builder: (context, _) {
                                return MapCanvas(
                                  svgAssetPath: selectedFloor.mapImage,
                                  nodes: nodes,
                                  routeNodesOnFloor: routeNodesOnFloor,
                                  startNodeId: selection.start?.nodeId,
                                  destinationNodeId:
                                      selection.destination?.nodeId,
                                  routeProgress: CurvedAnimation(
                                    parent: _routeAnimationController,
                                    curve: Curves.easeOut,
                                  ).value,
                                  pulseValue: _pulseController.value,
                                  onNodeTap: (node) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text(node.name),
                                        duration: const Duration(seconds: 1),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),

                        // Floor hint banner (multi-floor routes)
                        if (route != null &&
                            route.floorsTraversed.length > 1)
                          Positioned(
                            top: 12,
                            right: 24,
                            child: _FloorHintBanner(
                              floorsTraversed: route.floorsTraversed,
                              currentFloorNumber: selectedFloor.floorNumber,
                              floors: floors,
                              onFloorSelected: _onFloorSelected,
                            ),
                          ),

                        // Map legend (top-left)
                        const Positioned(
                          top: 12,
                          left: 20,
                          child: MapLegendWidget(),
                        ),
                      ],
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, err) => const Center(
                    child: Text("Couldn't load this floor's map."),
                  ),
                ),
              ),

              // Route panel
              const RoutePanel(),
            ],
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (_, err) => const Center(
          child: Text("Couldn't load floors for this building."),
        ),
      ),
    );
  }
}

// ── Floor hint banner ─────────────────────────────────────────────────────────

class _FloorHintBanner extends StatelessWidget {
  final List<int> floorsTraversed;
  final int currentFloorNumber;
  final List<FloorModel> floors;
  final ValueChanged<int> onFloorSelected;

  const _FloorHintBanner({
    required this.floorsTraversed,
    required this.currentFloorNumber,
    required this.floors,
    required this.onFloorSelected,
  });

  @override
  Widget build(BuildContext context) {
    final currentIndex = floorsTraversed.indexOf(currentFloorNumber);
    final nextFloorNumber =
        currentIndex >= 0 && currentIndex < floorsTraversed.length - 1
            ? floorsTraversed[currentIndex + 1]
            : null;
    FloorModel? nextFloor;
    if (nextFloorNumber != null) {
      for (final floor in floors) {
        if (floor.floorNumber == nextFloorNumber) {
          nextFloor = floor;
          break;
        }
      }
    }
    final isLast = currentIndex == floorsTraversed.length - 1;
    final targetFloorId = nextFloor?.id;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: targetFloorId == null
            ? null
            : () => onFloorSelected(targetFloorId),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1d4ed8), Color(0xFF7c3aed)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1d4ed8).withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isLast
                    ? Icons.flag_rounded
                    : Icons.arrow_upward_rounded,
                color: Colors.white,
                size: 14,
              ),
              const SizedBox(width: 5),
              Text(
                isLast
                    ? "You've arrived!"
                    : "Continue to ${nextFloor?.name ?? 'next floor'}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
