import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/models/floor_model.dart';
import '../../../../core/network/dio_client.dart';

abstract class FloorRemoteDataSource {
  Future<List<FloorModel>> getFloors(int buildingId);

  Future<FloorModel> getFloorById(int floorId);
}

class FloorRemoteDataSourceImpl implements FloorRemoteDataSource {
  final Dio _dio = DioClient.dio;

  @override
  Future<List<FloorModel>> getFloors(int buildingId) async {
    final response = await _dio.get(
      "${ApiConstants.buildings}/$buildingId/floors",
    );

    final data = response.data;
    final List<dynamic> list = data is List
        ? data
        : (data is Map ? (data['value'] as List<dynamic>? ?? []) : []);

    return list
        .map((e) => FloorModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<FloorModel> getFloorById(int floorId) async {
    final response = await _dio.get("${ApiConstants.floors}/$floorId");

    return FloorModel.fromJson(response.data as Map<String, dynamic>);
  }
}
