import '../../../../core/models/route_model.dart';
import '../repositories/maps_repository.dart';

class GetRouteUseCase {
  final MapsRepository repository;

  const GetRouteUseCase(this.repository);

  Future<RouteModel> call(int startNodeId, int endNodeId) {
    return repository.getRoute(startNodeId, endNodeId);
  }
}
