import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/dashboard_model.dart';

class DashboardRepository {
  final ApiClient _apiClient = ApiClient();

  /// Fetch dashboard metrics, quotation status distribution, trend and recent quotations
  Future<DashboardData> getDashboardData() async {
    final response = await _apiClient.get(
      ApiConstants.dashboard,
      includeAuth: true,
    );

    final dashboardResponse = DashboardResponse.fromJson(response);
    if (dashboardResponse.data != null) {
      return dashboardResponse.data!;
    }
    throw Exception('No data returned from dashboard API');
  }
}
