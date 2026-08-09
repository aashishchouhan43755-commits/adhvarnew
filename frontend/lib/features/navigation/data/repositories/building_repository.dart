import '../datasources/building_remote_data_source.dart';
import 'package:frontend/core/models/building_model.dart';

class BuildingRepository {
  final BuildingRemoteDataSource _remoteDataSource = BuildingRemoteDataSource();

  Future<List<BuildingModel>> getBuildings() async {
    return await _remoteDataSource.getBuildings();
  }

  Future<BuildingModel> getBuilding(int id) async {
    return await _remoteDataSource.getBuilding(id);
  }

  Future<BuildingModel> createBuilding({
    required String name,
    required String code,
    String? description,
  }) async {
    return await _remoteDataSource.createBuilding(
      name: name,
      code: code,
      description: description,
    );
  }

  Future<BuildingModel> updateBuilding({
    required int id,
    required String name,
    required String code,
    String? description,
  }) async {
    return await _remoteDataSource.updateBuilding(
      id: id,
      name: name,
      code: code,
      description: description,
    );
  }

  Future<void> deleteBuilding(int id) async {
    await _remoteDataSource.deleteBuilding(id);
  }
}
