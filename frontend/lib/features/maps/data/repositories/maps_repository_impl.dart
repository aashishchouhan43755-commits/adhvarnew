import '../../../../core/models/floor_model.dart';
import '../../../../core/models/node_model.dart';
import '../../../../core/models/route_model.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/repositories/maps_repository.dart';
import '../datasources/maps_remote_datasource.dart';
import 'maps_offline_repository_impl.dart';

class MapsRepositoryImpl implements MapsRepository {
  final MapsRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  const MapsRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  Future<T> _guarded<T>(
    Future<T> Function() call,
    Future<T> Function() fallback,
  ) async {
    try {
      if (!await networkInfo.isConnected) {
        return await fallback();
      }
      return await call();
    } catch (_) {
      return await fallback();
    }
  }

  @override
  Future<List<FloorModel>> getFloorsByBuilding(int buildingId) {
    return _guarded(
      () => remoteDataSource.getFloorsByBuilding(buildingId),
      () => const MapsOfflineRepositoryImpl().getFloorsByBuilding(buildingId),
    );
  }

  @override
  Future<List<NodeModel>> getNodesByFloor(int floorId) {
    return _guarded(
      () => remoteDataSource.getNodesByFloor(floorId),
      () => const MapsOfflineRepositoryImpl().getNodesByFloor(floorId),
    );
  }

  @override
  Future<RouteModel> getRoute(int startNodeId, int endNodeId) {
    return _guarded(
      () => remoteDataSource.getRoute(startNodeId, endNodeId),
      () => const MapsOfflineRepositoryImpl().getRoute(startNodeId, endNodeId),
    );
  }
}
