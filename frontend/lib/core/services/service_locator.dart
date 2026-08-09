import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/network_info.dart';

class ServiceLocator {
  ServiceLocator._();

  static final NetworkInfo networkInfo = NetworkInfoImpl();

  static final ApiClient apiClient = ApiClient(baseUrl: ApiEndpoints.baseUrl);
}
