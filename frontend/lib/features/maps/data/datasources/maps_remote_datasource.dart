import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/models/floor_model.dart';
import '../../../../core/models/node_model.dart';
import '../../../../core/models/route_model.dart';
import '../../../../core/network/dio_client.dart';

abstract class MapsRemoteDataSource {
  Future<List<FloorModel>> getFloorsByBuilding(int buildingId);
  Future<List<NodeModel>> getNodesByFloor(int floorId);
  Future<RouteModel> getRoute(int startNodeId, int endNodeId);
}

class MapsRemoteDataSourceImpl implements MapsRemoteDataSource {
  final Dio _dio = DioClient.dio;

  @override
  Future<List<FloorModel>> getFloorsByBuilding(int buildingId) async {
    final response = await _dio.get(
      "${ApiConstants.floors}/building/$buildingId",
    );

    final raw = response.data;
    final List<dynamic> data = raw is List
        ? raw
        : (raw is Map ? (raw['value'] as List<dynamic>? ?? []) : []);
    final floors = data
        .map((e) => FloorModel.fromJson(e as Map<String, dynamic>))
        .toList();

    floors.sort((a, b) => a.floorNumber.compareTo(b.floorNumber));
    return floors;
  }

  @override
  Future<List<NodeModel>> getNodesByFloor(int floorId) async {
    final response = await _dio.get(
      "${ApiConstants.nodes}/floor/$floorId",
    );

    final raw = response.data;
    final List<dynamic> data = raw is List
        ? raw
        : (raw is Map ? (raw['value'] as List<dynamic>? ?? []) : []);
    return data
        .map((e) => NodeModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<RouteModel> getRoute(int startNodeId, int endNodeId) async {
    final response = await _dio.get(
      ApiConstants.navigationRoute,
      queryParameters: {
        "start_node_id": startNodeId,
        "end_node_id": endNodeId,
      },
    );

    return RouteModel.fromJson(response.data as Map<String, dynamic>);
  }
}
