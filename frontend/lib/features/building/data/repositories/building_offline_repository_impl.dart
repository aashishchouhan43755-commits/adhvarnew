import '../../../../core/models/building_model.dart';
import '../../../../core/offline/offline_adhvar_data.dart';
import '../../domain/repositories/building_repository.dart';

/// Serves buildings from the in-memory offline dataset instead of a
/// remote API. Used so the app runs as a standalone prototype with no
/// backend server required. Swap the provider back to
/// [BuildingRepositoryImpl] (data/repositories/building_repository_impl.dart)
/// to use the real FastAPI backend instead.
class BuildingOfflineRepositoryImpl implements BuildingRepository {
  const BuildingOfflineRepositoryImpl();

  @override
  Future<List<BuildingModel>> getBuildings() async {
    return OfflineAdhvarData.buildings;
  }

  @override
  Future<BuildingModel> getBuildingById(int buildingId) async {
    return OfflineAdhvarData.buildings.firstWhere(
      (b) => b.id == buildingId,
      orElse: () => throw Exception('Building not found'),
    );
  }
}
