import '../../../../core/models/room_search_result_model.dart';

abstract class SearchRepository {
  /// Search rooms by name, room number, or room type.
  Future<List<RoomSearchResultModel>> searchRooms(String query);
}
