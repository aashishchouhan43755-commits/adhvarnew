import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_environment.dart';
import '../../../../core/models/floor_model.dart';
import '../../../../core/models/node_model.dart';
import '../../../../core/models/room_search_result_model.dart';
import '../../../../core/models/route_model.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/maps_remote_datasource.dart';
import '../../data/repositories/maps_offline_repository_impl.dart';
import '../../data/repositories/maps_repository_impl.dart';
import '../../domain/repositories/maps_repository.dart';
import '../../domain/usecases/get_floors_by_building_usecase.dart';
import '../../domain/usecases/get_nodes_by_floor_usecase.dart';
import '../../domain/usecases/get_route_usecase.dart';

final mapsRemoteDataSourceProvider = Provider<MapsRemoteDataSource>((ref) {
  return MapsRemoteDataSourceImpl();
});

final mapsRepositoryProvider = Provider<MapsRepository>((ref) {
  if (AppEnvironment.useBackend) {
    return MapsRepositoryImpl(
      remoteDataSource: ref.read(mapsRemoteDataSourceProvider),
      networkInfo: ref.read(networkInfoProvider),
    );
  }

  return const MapsOfflineRepositoryImpl();
});

final getFloorsByBuildingUseCaseProvider =
    Provider<GetFloorsByBuildingUseCase>((ref) {
  return GetFloorsByBuildingUseCase(ref.read(mapsRepositoryProvider));
});

final getNodesByFloorUseCaseProvider = Provider<GetNodesByFloorUseCase>((
  ref,
) {
  return GetNodesByFloorUseCase(ref.read(mapsRepositoryProvider));
});

final getRouteUseCaseProvider = Provider<GetRouteUseCase>((ref) {
  return GetRouteUseCase(ref.read(mapsRepositoryProvider));
});

/// Floors belonging to a building, sorted by floor_number.
final floorsByBuildingProvider =
    FutureProvider.family<List<FloorModel>, int>((ref, buildingId) {
  return ref.read(getFloorsByBuildingUseCaseProvider)(buildingId);
});

/// Navigation nodes on a single floor (rooms, corridors, lifts, stairs,
/// washrooms, emergency exits) - what the map canvas plots as dots.
final nodesByFloorProvider = FutureProvider.family<List<NodeModel>, int>((
  ref,
  floorId,
) {
  return ref.read(getNodesByFloorUseCaseProvider)(floorId);
});

/// Holds the user's chosen start/destination rooms and the resulting
/// route (once both are picked), for the currently open indoor map.
class RouteSelectionState {
  final RoomSearchResultModel? start;
  final RoomSearchResultModel? destination;
  final AsyncValue<RouteModel?> route;

  const RouteSelectionState({
    this.start,
    this.destination,
    this.route = const AsyncValue.data(null),
  });

  RouteSelectionState copyWith({
    RoomSearchResultModel? start,
    RoomSearchResultModel? destination,
    AsyncValue<RouteModel?>? route,
    bool clearStart = false,
    bool clearDestination = false,
  }) {
    return RouteSelectionState(
      start: clearStart ? null : (start ?? this.start),
      destination: clearDestination ? null : (destination ?? this.destination),
      route: route ?? this.route,
    );
  }
}

class RouteSelectionNotifier extends StateNotifier<RouteSelectionState> {
  RouteSelectionNotifier(this._getRoute) : super(const RouteSelectionState());

  final GetRouteUseCase _getRoute;

  void setStart(RoomSearchResultModel room) {
    state = state.copyWith(start: room);
    _maybeFetchRoute();
  }

  void setDestination(RoomSearchResultModel room) {
    state = state.copyWith(destination: room);
    _maybeFetchRoute();
  }

  void clear() {
    state = const RouteSelectionState();
  }

  Future<void> _maybeFetchRoute() async {
    final start = state.start;
    final destination = state.destination;

    if (start?.nodeId == null || destination?.nodeId == null) {
      return;
    }

    state = state.copyWith(route: const AsyncValue.loading());

    try {
      final route = await _getRoute(start!.nodeId!, destination!.nodeId!);
      state = state.copyWith(route: AsyncValue.data(route));
    } catch (e, st) {
      state = state.copyWith(route: AsyncValue.error(e, st));
    }
  }
}

final routeSelectionProvider =
    StateNotifierProvider.autoDispose<RouteSelectionNotifier, RouteSelectionState>(
  (ref) => RouteSelectionNotifier(ref.read(getRouteUseCaseProvider)),
);
