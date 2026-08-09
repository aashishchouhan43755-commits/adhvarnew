import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_environment.dart';
import '../../../../core/models/room_search_result_model.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/search_remote_datasource.dart';
import '../../data/repositories/search_offline_repository_impl.dart';
import '../../data/repositories/search_repository_impl.dart';
import '../../domain/repositories/search_repository.dart';
import '../../domain/usecases/search_rooms_usecase.dart';

final searchRemoteDataSourceProvider = Provider<SearchRemoteDataSource>((
  ref,
) {
  return SearchRemoteDataSourceImpl();
});

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  if (AppEnvironment.useBackend) {
    return SearchRepositoryImpl(
      remoteDataSource: ref.read(searchRemoteDataSourceProvider),
      networkInfo: ref.read(networkInfoProvider),
    );
  }

  return const SearchOfflineRepositoryImpl();
});

final searchRoomsUseCaseProvider = Provider<SearchRoomsUseCase>((ref) {
  return SearchRoomsUseCase(ref.read(searchRepositoryProvider));
});

class SearchNotifier
    extends StateNotifier<AsyncValue<List<RoomSearchResultModel>>> {
  SearchNotifier(this._searchRoomsUseCase)
    : super(const AsyncValue.data([]));

  final SearchRoomsUseCase _searchRoomsUseCase;
  int _requestSequence = 0;

  Future<void> search(String query) async {
    final requestId = ++_requestSequence;

    if (query.trim().isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();

    try {
      final results = await _searchRoomsUseCase(query.trim());
      if (requestId == _requestSequence) {
        state = AsyncValue.data(results);
      }
    } catch (e, st) {
      if (requestId == _requestSequence) {
        state = AsyncValue.error(e, st);
      }
    }
  }

  void clear() {
    _requestSequence++;
    state = const AsyncValue.data([]);
  }
}

final searchProvider =
    StateNotifierProvider<
      SearchNotifier,
      AsyncValue<List<RoomSearchResultModel>>
    >((ref) => SearchNotifier(ref.read(searchRoomsUseCaseProvider)));
