import '../../../../core/models/floor_model.dart';
import '../../../../core/models/node_model.dart';
import '../../../../core/models/route_model.dart';
import '../../../../core/offline/offline_adhvar_data.dart';
import '../../domain/repositories/maps_repository.dart';

/// Serves floors/nodes/routes from the in-memory offline dataset and the
/// on-device Dijkstra implementation, instead of a remote API. Used so
/// the app runs as a standalone prototype with no backend server
/// required. Swap the provider back to [MapsRepositoryImpl]
/// (data/repositories/maps_repository_impl.dart) to use the real FastAPI
/// backend instead.
class MapsOfflineRepositoryImpl implements MapsRepository {
  const MapsOfflineRepositoryImpl();

  @override
  Future<List<FloorModel>> getFloorsByBuilding(int buildingId) async {
    return OfflineAdhvarData.floorsByBuilding(buildingId);
  }

  @override
  Future<List<NodeModel>> getNodesByFloor(int floorId) async {
    return OfflineAdhvarData.nodesByFloor(floorId);
  }

  @override
  Future<RouteModel> getRoute(int startNodeId, int endNodeId) async {
    return OfflineAdhvarData.findRoute(startNodeId, endNodeId);
  }
}
