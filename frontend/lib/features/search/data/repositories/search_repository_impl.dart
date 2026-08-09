import '../../../../core/models/room_search_result_model.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/search_remote_datasource.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  const SearchRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<List<RoomSearchResultModel>> searchRooms(String query) async {
    if (!await networkInfo.isConnected) {
      throw Exception('No internet connection');
    }

    return remoteDataSource.searchRooms(query);
  }
}
