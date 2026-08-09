import '../../../../core/models/floor_model.dart';
import '../../../../core/models/node_model.dart';
import '../../../../core/models/route_model.dart';

abstract class MapsRepository {
  Future<List<FloorModel>> getFloorsByBuilding(int buildingId);
  Future<List<NodeModel>> getNodesByFloor(int floorId);
  Future<RouteModel> getRoute(int startNodeId, int endNodeId);
}
