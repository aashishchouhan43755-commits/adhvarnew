import '../../../../core/models/floor_model.dart';
import '../../../../core/models/node_model.dart';
import '../../../../core/models/route_model.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/repositories/maps_repository.dart';
import '../datasources/maps_remote_datasource.dart';

class MapsRepositoryImpl implements MapsRepository {
  final MapsRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  const MapsRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  Future<T> _guarded<T>(Future<T> Function() call) async {
    if (!await networkInfo.isConnected) {
      throw Exception('No internet connection');
    }
    return call();
  }

  @override
  Future<List<FloorModel>> getFloorsByBuilding(int buildingId) {
    return _guarded(() => remoteDataSource.getFloorsByBuilding(buildingId));
  }

  @override
  Future<List<NodeModel>> getNodesByFloor(int floorId) {
    return _guarded(() => remoteDataSource.getNodesByFloor(floorId));
  }

  @override
  Future<RouteModel> getRoute(int startNodeId, int endNodeId) {
    return _guarded(() => remoteDataSource.getRoute(startNodeId, endNodeId));
  }
}
