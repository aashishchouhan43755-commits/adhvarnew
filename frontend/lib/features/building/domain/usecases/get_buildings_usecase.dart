import '../../../../core/models/building_model.dart';
import '../repositories/building_repository.dart';

class GetBuildingsUseCase {
  final BuildingRepository repository;

  const GetBuildingsUseCase(this.repository);

  Future<List<BuildingModel>> call() {
    return repository.getBuildings();
  }
}
