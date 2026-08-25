import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/auth_model.dart';
import '../../models/panel_status_model.dart';

class SessionManager {
  static const String _keyToken = 'auth_token';
  static const String _keyTokenExpires = 'token_expires_at';
  static const String _keyUser = 'auth_user';
  static const String _keyCompany = 'auth_company';
  static const String _keyPanelStatus = 'panel_status';

  // Token
  static Future<void> saveToken(String token, {String? expiresAt}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    if (expiresAt != null) {
      await prefs.setString(_keyTokenExpires, expiresAt);
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  static Future<bool> hasValidToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Auth User Data
  static Future<void> saveAuthData(LoginResponse response) async {
    final prefs = await SharedPreferences.getInstance();
    if (response.userInfo?.token != null) {
      await prefs.setString(_keyToken, response.userInfo!.token!);
    }
    if (response.userInfo?.tokenExpiresAt != null) {
      await prefs.setString(_keyTokenExpires, response.userInfo!.tokenExpiresAt!);
    }
    if (response.userInfo?.user != null) {
      await prefs.setString(_keyUser, jsonEncode(response.userInfo!.user!.toJson()));
    }
    if (response.companyDetails != null) {
      await prefs.setString(_keyCompany, jsonEncode(response.companyDetails!.toJson()));
    }
  }

  static Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_keyUser);
    if (userJson != null) {
      try {
        return User.fromJson(jsonDecode(userJson));
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  static Future<CompanyDetails?> getCompanyDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final companyJson = prefs.getString(_keyCompany);
    if (companyJson != null) {
      try {
        return CompanyDetails.fromJson(jsonDecode(companyJson));
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  // Panel Status Cache
  static Future<void> savePanelStatus(PanelStatusResponse panelStatus) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPanelStatus, jsonEncode(panelStatus.toJson()));
  }

  static Future<PanelStatusResponse?> getSavedPanelStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyPanelStatus);
    if (raw != null) {
      try {
        return PanelStatusResponse.fromJson(jsonDecode(raw));
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  // Clear Session / Logout
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyTokenExpires);
    await prefs.remove(_keyUser);
    await prefs.remove(_keyCompany);
  }
}
