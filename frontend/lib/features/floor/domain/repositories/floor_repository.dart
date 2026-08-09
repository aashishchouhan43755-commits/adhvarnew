import '../../../../core/models/floor_model.dart';

abstract class FloorRepository {
  /// Returns all floors of a building.
  Future<List<FloorModel>> getFloors(int buildingId);

  /// Returns a single floor by its ID.
  Future<FloorModel> getFloorById(int floorId);
}
