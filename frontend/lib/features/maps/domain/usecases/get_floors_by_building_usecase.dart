import '../../../../core/models/floor_model.dart';
import '../repositories/maps_repository.dart';

class GetFloorsByBuildingUseCase {
  final MapsRepository repository;

  const GetFloorsByBuildingUseCase(this.repository);

  Future<List<FloorModel>> call(int buildingId) {
    return repository.getFloorsByBuilding(buildingId);
  }
}
