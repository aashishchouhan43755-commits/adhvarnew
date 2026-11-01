import '../../../../core/models/building_model.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/repositories/building_repository.dart';
import '../datasources/building_remote_datasource.dart';
import 'building_offline_repository_impl.dart';

class BuildingRepositoryImpl implements BuildingRepository {
  final BuildingRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  const BuildingRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<List<BuildingModel>> getBuildings() async {
    try {
      if (!await networkInfo.isConnected) {
        return const BuildingOfflineRepositoryImpl().getBuildings();
      }
      return await remoteDataSource.getBuildings();
    } catch (_) {
      return const BuildingOfflineRepositoryImpl().getBuildings();
    }
  }

  @override
  Future<BuildingModel> getBuildingById(int buildingId) async {
    try {
      if (!await networkInfo.isConnected) {
        return const BuildingOfflineRepositoryImpl().getBuildingById(buildingId);
      }
      return await remoteDataSource.getBuildingById(buildingId);
    } catch (_) {
      return const BuildingOfflineRepositoryImpl().getBuildingById(buildingId);
    }
  }
}
