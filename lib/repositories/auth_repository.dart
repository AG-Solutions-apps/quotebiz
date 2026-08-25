import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';
import '../core/services/session_manager.dart';
import '../models/auth_model.dart';
import '../models/panel_status_model.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient();

  /// Check panel status (executed at app startup before login)
  Future<PanelStatusResponse> checkPanelStatus() async {
    final response = await _apiClient.get(
      ApiConstants.panelCheckStatus,
      includeAuth: false,
    );

    final panelStatus = PanelStatusResponse.fromJson(response);
    await SessionManager.savePanelStatus(panelStatus);
    return panelStatus;
  }

  /// Perform login with username and password
  Future<LoginResponse> login({
    required String username,
    required String password,
  }) async {
    final cleanUsername = username.trim();
    final cleanPassword = password.trim();

    final body = {
      'username': cleanUsername,
      'email': cleanUsername,
      'password': cleanPassword,
    };

    final response = await _apiClient.post(
      ApiConstants.panelLogin,
      body: body,
      includeAuth: false,
    );

    if (response is Map) {
      final code = response['code'];
      final int? parsedCode = code is int ? code : int.tryParse('$code');
      if (parsedCode != null && parsedCode != 200 && parsedCode != 201) {
        throw ApiException(
          response['message']?.toString() ?? 'Login failed. Please check credentials.',
          statusCode: parsedCode,
        );
      }
    }

    final loginResponse = LoginResponse.fromJson(response);
    await SessionManager.saveAuthData(loginResponse);
    return loginResponse;
  }

  /// Register / Create Signup (POST /createsignup)
  Future<dynamic> register({
    required String branchShort,
    required String branchName,
    String? branchAddress,
    String? branchGst,
    required String branchMobileNo,
    required String branchEmailId,
    required String password,
  }) async {
    final body = {
      'branch_short': branchShort.trim(),
      'branch_name_short': branchShort.trim(),
      'branch_name': branchName.trim(),
      'branch_address': (branchAddress != null && branchAddress.trim().isNotEmpty)
          ? branchAddress.trim()
          : null,
      'branch_gst': (branchGst != null && branchGst.trim().isNotEmpty)
          ? branchGst.trim()
          : null,
      'branch_mobile_no': branchMobileNo.trim(),
      'branch_email_id': branchEmailId.trim(),
      'password': password.trim(),
    };

    final response = await _apiClient.post(
      ApiConstants.createSignup,
      body: body,
      includeAuth: false,
    );

    // If signup returns login token/info, save session or auto-login with credentials
    try {
      if (response is Map && (response['UserInfo'] != null || response['token'] != null)) {
        final loginResponse = LoginResponse.fromJson(Map<String, dynamic>.from(response));
        await SessionManager.saveAuthData(loginResponse);
      } else {
        await login(
          username: branchEmailId.trim(),
          password: password.trim(),
        );
      }
    } catch (_) {
      // If auto-login encounters an issue, proceed so screen can handle navigation
    }

    return response;
  }

  /// Logout and clear stored session
  Future<void> logout() async {
    await SessionManager.clearSession();
  }
}
