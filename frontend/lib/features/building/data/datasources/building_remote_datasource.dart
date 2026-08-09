import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/models/building_model.dart';
import '../../../../core/network/dio_client.dart';

abstract class BuildingRemoteDataSource {
  Future<List<BuildingModel>> getBuildings();

  Future<BuildingModel> getBuildingById(int buildingId);
}

class BuildingRemoteDataSourceImpl implements BuildingRemoteDataSource {
  final Dio _dio = DioClient.dio;

  @override
  Future<List<BuildingModel>> getBuildings() async {
    final response = await _dio.get(ApiConstants.buildings);

    // Backend returns { "value": [...], "Count": N }
    final data = response.data;
    final List<dynamic> list = data is List
        ? data
        : (data is Map ? (data['value'] as List<dynamic>? ?? []) : []);

    return list
        .map((e) => BuildingModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<BuildingModel> getBuildingById(int buildingId) async {
    final response = await _dio.get("${ApiConstants.buildings}/$buildingId");

    return BuildingModel.fromJson(response.data as Map<String, dynamic>);
  }
}
