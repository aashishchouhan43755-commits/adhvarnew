import '../../../../core/models/room_search_result_model.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/search_remote_datasource.dart';
import 'search_offline_repository_impl.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  const SearchRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<List<RoomSearchResultModel>> searchRooms(String query) async {
    try {
      if (!await networkInfo.isConnected) {
        return const SearchOfflineRepositoryImpl().searchRooms(query);
      }
      return await remoteDataSource.searchRooms(query);
    } catch (_) {
      return const SearchOfflineRepositoryImpl().searchRooms(query);
    }
  }
}
