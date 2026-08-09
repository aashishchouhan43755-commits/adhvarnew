import '../../../../core/models/floor_model.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/repositories/floor_repository.dart';
import '../datasources/floor_remote_datasource.dart';

class FloorRepositoryImpl implements FloorRepository {
  final FloorRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  const FloorRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<List<FloorModel>> getFloors(int buildingId) async {
    if (!await networkInfo.isConnected) {
      throw Exception('No internet connection');
    }

    return remoteDataSource.getFloors(buildingId);
  }

  @override
  Future<FloorModel> getFloorById(int floorId) async {
    if (!await networkInfo.isConnected) {
      throw Exception('No internet connection');
    }

    return remoteDataSource.getFloorById(floorId);
  }
}
