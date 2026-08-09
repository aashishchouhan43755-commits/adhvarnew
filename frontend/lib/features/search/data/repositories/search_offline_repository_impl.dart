import '../../../../core/models/room_search_result_model.dart';
import '../../../../core/offline/offline_adhvar_data.dart';
import '../../domain/repositories/search_repository.dart';

/// Serves room search results from the in-memory offline dataset instead
/// of a remote API. Used so the app runs as a standalone prototype with
/// no backend server required. Swap the provider back to
/// [SearchRepositoryImpl] (data/repositories/search_repository_impl.dart)
/// to use the real FastAPI backend instead.
class SearchOfflineRepositoryImpl implements SearchRepository {
  const SearchOfflineRepositoryImpl();

  @override
  Future<List<RoomSearchResultModel>> searchRooms(String query) async {
    return OfflineAdhvarData.searchRooms(query);
  }
}
