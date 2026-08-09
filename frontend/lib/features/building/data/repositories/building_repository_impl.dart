import '../../../../core/models/building_model.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/repositories/building_repository.dart';
import '../datasources/building_remote_datasource.dart';

class BuildingRepositoryImpl implements BuildingRepository {
  final BuildingRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  const BuildingRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<List<BuildingModel>> getBuildings() async {
    if (!await networkInfo.isConnected) {
      throw Exception('No internet connection');
    }

    return remoteDataSource.getBuildings();
  }

  @override
  Future<BuildingModel> getBuildingById(int buildingId) async {
    if (!await networkInfo.isConnected) {
      throw Exception('No internet connection');
    }

    return remoteDataSource.getBuildingById(buildingId);
  }
}
