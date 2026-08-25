import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../services/session_manager.dart';
import 'api_exceptions.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final http.Client _client = http.Client();

  /// Build URI using universal Base URL and endpoint
  Uri _buildUri(String endpoint, [Map<String, dynamic>? queryParameters]) {
    final path = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final fullUrl = '${ApiConstants.baseUrl}$path';

    if (queryParameters != null && queryParameters.isNotEmpty) {
      final uri = Uri.parse(fullUrl);
      return uri.replace(queryParameters: queryParameters.map((k, v) => MapEntry(k, v.toString())));
    }

    return Uri.parse(fullUrl);
  }

  /// Default headers with optional Auth Bearer Token
  Future<Map<String, String>> _getHeaders({
    bool includeAuth = true,
    Map<String, String>? customHeaders,
  }) async {
    final headers = <String, String>{
      ApiConstants.headerContentType: ApiConstants.jsonType,
      ApiConstants.headerAccept: ApiConstants.jsonType,
    };

    if (includeAuth) {
      final token = await SessionManager.getToken();
      if (token != null && token.isNotEmpty) {
        headers[ApiConstants.headerAuthorization] = 'Bearer $token';
      }
    }

    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }

    return headers;
  }

  /// Universal GET request
  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    bool includeAuth = true,
    Map<String, String>? customHeaders,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      final headers = await _getHeaders(includeAuth: includeAuth, customHeaders: customHeaders);

      final response = await _client.get(uri, headers: headers);
      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('Unable to connect to server. Please check your internet connection.');
    } on http.ClientException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error occurred: $e');
    }
  }

  /// Universal POST request
  Future<dynamic> post(
    String endpoint, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    bool includeAuth = true,
    Map<String, String>? customHeaders,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      final headers = await _getHeaders(includeAuth: includeAuth, customHeaders: customHeaders);

      final response = await _client.post(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('Unable to connect to server. Please check your internet connection.');
    } on http.ClientException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error occurred: $e');
    }
  }

  /// Universal PUT request
  Future<dynamic> put(
    String endpoint, {
    dynamic body,
    bool includeAuth = true,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final headers = await _getHeaders(includeAuth: includeAuth);

      final response = await _client.put(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('No Internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error occurred: $e');
    }
  }

  /// Universal Multipart request (supporting file uploads for POST and PUT)
  Future<dynamic> multipart(
    String endpoint, {
    String method = 'POST',
    Map<String, String>? fields,
    Map<String, File>? files,
    bool includeAuth = true,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final request = http.MultipartRequest(method, uri);

      if (includeAuth) {
        final token = await SessionManager.getToken();
        if (token != null && token.isNotEmpty) {
          request.headers[ApiConstants.headerAuthorization] = 'Bearer $token';
        }
      }
      request.headers[ApiConstants.headerAccept] = ApiConstants.jsonType;

      if (fields != null) {
        request.fields.addAll(fields);
      }

      if (files != null) {
        for (var entry in files.entries) {
          final file = entry.value;
          if (await file.exists()) {
            final multipartFile = await http.MultipartFile.fromPath(
              entry.key,
              file.path,
            );
            request.files.add(multipartFile);
          }
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('No Internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error occurred: $e');
    }
  }

  /// Universal DELETE request
  Future<dynamic> delete(
    String endpoint, {
    bool includeAuth = true,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final headers = await _getHeaders(includeAuth: includeAuth);

      final response = await _client.delete(uri, headers: headers);
      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('No Internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error occurred: $e');
    }
  }

  /// Response Handler
  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    dynamic jsonBody;

    try {
      if (response.body.isNotEmpty) {
        jsonBody = jsonDecode(response.body);
      }
    } catch (_) {
      jsonBody = response.body;
    }

    if (statusCode >= 200 && statusCode < 300) {
      if (jsonBody is Map) {
        // Handle in-body error codes like {"code": 400, "message": "enter the username"}
        final code = jsonBody['code'];
        final int? parsedCode = code is int ? code : int.tryParse('$code');
        if (parsedCode != null && parsedCode != 200 && parsedCode != 201) {
          final message = jsonBody['message']?.toString() ??
              jsonBody['error']?.toString() ??
              'Request failed ($parsedCode)';
          throw ApiException(message, statusCode: parsedCode, data: jsonBody);
        }
      }
      return jsonBody;
    }

    if (statusCode == 401) {
      final message = jsonBody is Map && jsonBody['message'] != null
          ? jsonBody['message'].toString()
          : 'Unauthorized or session expired';
      throw UnauthorizedException(message);
    }

    if (jsonBody is Map && jsonBody['message'] != null) {
      throw ApiException(jsonBody['message'].toString(), statusCode: statusCode, data: jsonBody);
    }

    throw ApiException('Server error with status code $statusCode', statusCode: statusCode, data: jsonBody);
  }
}
