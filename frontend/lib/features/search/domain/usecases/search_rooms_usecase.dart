import '../../../../core/models/room_search_result_model.dart';
import '../repositories/search_repository.dart';

class SearchRoomsUseCase {
  final SearchRepository repository;

  const SearchRoomsUseCase(this.repository);

  Future<List<RoomSearchResultModel>> call(String query) {
    return repository.searchRooms(query);
  }
}
