import '../../../../core/models/building_model.dart';
import '../repositories/building_repository.dart';

class GetBuildingByIdUseCase {
  final BuildingRepository repository;

  const GetBuildingByIdUseCase(this.repository);

  Future<BuildingModel> call(int buildingId) {
    return repository.getBuildingById(buildingId);
  }
}
