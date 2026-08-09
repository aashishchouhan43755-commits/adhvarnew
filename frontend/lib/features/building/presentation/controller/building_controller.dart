import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/building_model.dart';
import '../providers/building_provider.dart';

class BuildingController {
  BuildingController(this.ref);

  final Ref ref;

  Future<void> loadBuildings() async {
    await ref.read(buildingProvider.notifier).loadBuildings();
  }

  AsyncValue<List<BuildingModel>> get buildings {
    return ref.watch(buildingProvider);
  }

  Future<BuildingModel?> getBuildingById(int id) async {
    return await ref
        .read(buildingProvider.notifier)
        .getBuildingById(ref as WidgetRef, id);
  }

  Future<void> refresh() async {
    await loadBuildings();
  }
}

final buildingControllerProvider = Provider<BuildingController>(
  (ref) => BuildingController(ref),
);
