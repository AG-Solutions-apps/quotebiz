import 'dart:io';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/settings_model.dart';

class SettingsRepository {
  final ApiClient _apiClient = ApiClient();

  /// Fetch user profile (GET /panel-fetch-profile)
  Future<UserProfile> fetchProfile() async {
    final response = await _apiClient.get(
      ApiConstants.panelFetchProfile,
      includeAuth: true,
    );

    if (response is Map && response['profile'] != null) {
      return UserProfile.fromJson(response['profile']);
    }
    throw Exception('Failed to load user profile');
  }

  /// Fetch branch settings (GET /panel-fetch-branch)
  Future<BranchSettings> fetchBranch() async {
    final response = await _apiClient.get(
      ApiConstants.panelFetchBranch,
      includeAuth: true,
    );

    if (response is Map && response['data'] != null) {
      return BranchSettings.fromJson(response['data']);
    }
    throw Exception('Failed to load branch settings');
  }

  /// Update branch settings (PUT /panel-update-branch with Multipart/JSON support)
  Future<dynamic> updateBranch({
    required String branchName,
    required String branchAddress,
    String? branchGst,
    required String branchMobileNo,
    required String branchEmailId,
    String branchCurrency = 'INR',
    String branchTaxRate = '18',
    required String branchFooter,
    String? branchLogo,
    String? branchSign,
    String? branchTC,
    File? logoFile,
    File? signFile,
  }) async {
    // If user uploaded new physical image files, send multipart request
    if (logoFile != null || signFile != null) {
      final fields = <String, String>{
        'branch_name': branchName.trim(),
        'branch_address': branchAddress.trim(),
        'branch_mobile_no': branchMobileNo.trim(),
        'branch_email_id': branchEmailId.trim(),
        'branch_currency': branchCurrency.trim(),
        'branch_tax_rate': branchTaxRate.trim(),
        'branch_footer': branchFooter.trim(),
        '_method': 'PUT', // For standard Laravel multipart PUT route
      };

      if (branchGst != null && branchGst.trim().isNotEmpty) {
        fields['branch_gst'] = branchGst.trim();
      }
      if (branchTC != null && branchTC.trim().isNotEmpty) {
        fields['branch_t_c'] = branchTC.trim();
      }
      if (branchLogo != null && branchLogo.trim().isNotEmpty && logoFile == null) {
        fields['branch_logo'] = branchLogo.trim();
      }
      if (branchSign != null && branchSign.trim().isNotEmpty && signFile == null) {
        fields['branch_sign'] = branchSign.trim();
      }

      final files = <String, File>{};
      if (logoFile != null) {
        files['branch_logo'] = logoFile;
      }
      if (signFile != null) {
        files['branch_sign'] = signFile;
      }

      try {
        // Standard Laravel multipart PUT via POST + _method: 'PUT'
        return await _apiClient.multipart(
          ApiConstants.panelUpdateBranch,
          method: 'POST',
          fields: fields,
          files: files,
          includeAuth: true,
        );
      } catch (e) {
        // Fallback to direct PUT multipart
        return await _apiClient.multipart(
          ApiConstants.panelUpdateBranch,
          method: 'PUT',
          fields: fields,
          files: files,
          includeAuth: true,
        );
      }
    }

    // Standard JSON PUT if no new files picked
    final body = {
      'branch_name': branchName.trim(),
      'branch_address': branchAddress.trim(),
      'branch_gst': (branchGst != null && branchGst.trim().isNotEmpty) ? branchGst.trim() : null,
      'branch_mobile_no': branchMobileNo.trim(),
      'branch_email_id': branchEmailId.trim(),
      'branch_currency': branchCurrency.trim(),
      'branch_tax_rate': branchTaxRate.trim(),
      'branch_footer': branchFooter.trim(),
      'branch_logo': (branchLogo != null && branchLogo.trim().isNotEmpty) ? branchLogo.trim() : null,
      'branch_sign': (branchSign != null && branchSign.trim().isNotEmpty) ? branchSign.trim() : null,
      'branch_t_c': (branchTC != null && branchTC.trim().isNotEmpty) ? branchTC.trim() : null,
    };

    final response = await _apiClient.put(
      ApiConstants.panelUpdateBranch,
      body: body,
      includeAuth: true,
    );

    return response;
  }
}
