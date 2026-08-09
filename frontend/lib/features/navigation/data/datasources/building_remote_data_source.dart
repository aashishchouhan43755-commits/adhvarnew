import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import 'package:frontend/core/models/building_model.dart';

class BuildingRemoteDataSource {
  final Dio _dio = DioClient.dio;

  Future<List<BuildingModel>> getBuildings() async {
    final response = await _dio.get(ApiConstants.buildings);

    final List data = response.data;

    return data.map((e) => BuildingModel.fromJson(e)).toList();
  }

  Future<BuildingModel> getBuilding(int id) async {
    final response = await _dio.get("${ApiConstants.buildings}/$id");

    return BuildingModel.fromJson(response.data);
  }

  Future<BuildingModel> createBuilding({
    required String name,
    required String code,
    String? description,
  }) async {
    final response = await _dio.post(
      ApiConstants.buildings,
      data: {"name": name, "code": code, "description": description},
    );

    return BuildingModel.fromJson(response.data);
  }

  Future<BuildingModel> updateBuilding({
    required int id,
    required String name,
    required String code,
    String? description,
  }) async {
    final response = await _dio.put(
      "${ApiConstants.buildings}/$id",
      data: {"name": name, "code": code, "description": description},
    );

    return BuildingModel.fromJson(response.data);
  }

  Future<void> deleteBuilding(int id) async {
    await _dio.delete("${ApiConstants.buildings}/$id");
  }
}
