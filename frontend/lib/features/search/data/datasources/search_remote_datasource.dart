import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/models/room_search_result_model.dart';
import '../../../../core/network/dio_client.dart';

abstract class SearchRemoteDataSource {
  Future<List<RoomSearchResultModel>> searchRooms(String query);
}

class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  final Dio _dio = DioClient.dio;

  @override
  Future<List<RoomSearchResultModel>> searchRooms(String query) async {
    final response = await _dio.get(
      ApiConstants.roomSearch,
      queryParameters: {"q": query},
    );

    final raw = response.data;
    final List<dynamic> data = raw is List
        ? raw
        : (raw is Map ? (raw['value'] as List<dynamic>? ?? []) : []);

    return data
        .map((e) => RoomSearchResultModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
