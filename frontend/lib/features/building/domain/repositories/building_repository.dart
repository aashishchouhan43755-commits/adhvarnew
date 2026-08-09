import '../../../../core/models/building_model.dart';

abstract class BuildingRepository {
  /// Get all buildings
  Future<List<BuildingModel>> getBuildings();

  /// Get a building by its ID
  Future<BuildingModel> getBuildingById(int buildingId);
}
