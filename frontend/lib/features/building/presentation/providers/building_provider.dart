import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_environment.dart';
import '../../../../core/models/building_model.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/building_remote_datasource.dart';
import '../../data/repositories/building_offline_repository_impl.dart';
import '../../data/repositories/building_repository_impl.dart';
import '../../domain/repositories/building_repository.dart';
import '../../domain/usecases/get_building_by_id_usecase.dart';
import '../../domain/usecases/get_buildings_usecase.dart';

final buildingRemoteDataSourceProvider = Provider<BuildingRemoteDataSource>((
  ref,
) {
  return BuildingRemoteDataSourceImpl();
});

final buildingRepositoryProvider = Provider<BuildingRepository>((ref) {
  if (AppEnvironment.useBackend) {
    return BuildingRepositoryImpl(
      remoteDataSource: ref.read(buildingRemoteDataSourceProvider),
      networkInfo: ref.read(networkInfoProvider),
    );
  }

  return const BuildingOfflineRepositoryImpl();
});

final getBuildingsUseCaseProvider = Provider<GetBuildingsUseCase>((ref) {
  return GetBuildingsUseCase(ref.read(buildingRepositoryProvider));
});

final getBuildingByIdUseCaseProvider = Provider<GetBuildingByIdUseCase>((ref) {
  return GetBuildingByIdUseCase(ref.read(buildingRepositoryProvider));
});

class BuildingNotifier extends StateNotifier<AsyncValue<List<BuildingModel>>> {
  BuildingNotifier(this._getBuildingsUseCase)
    : super(const AsyncValue.loading());

  final GetBuildingsUseCase _getBuildingsUseCase;

  Future<void> loadBuildings() async {
    state = const AsyncValue.loading();

    try {
      final buildings = await _getBuildingsUseCase();
      state = AsyncValue.data(buildings);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<BuildingModel?> getBuildingById(WidgetRef ref, int id) async {
    try {
      return await ref.read(getBuildingByIdUseCaseProvider)(id);
    } catch (_) {
      return null;
    }
  }
}

final buildingProvider =
    StateNotifierProvider<BuildingNotifier, AsyncValue<List<BuildingModel>>>(
      (ref) => BuildingNotifier(ref.read(getBuildingsUseCaseProvider)),
    );
