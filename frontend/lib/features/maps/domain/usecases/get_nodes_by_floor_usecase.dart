import '../../../../core/models/node_model.dart';
import '../repositories/maps_repository.dart';

class GetNodesByFloorUseCase {
  final MapsRepository repository;

  const GetNodesByFloorUseCase(this.repository);

  Future<List<NodeModel>> call(int floorId) {
    return repository.getNodesByFloor(floorId);
  }
}
