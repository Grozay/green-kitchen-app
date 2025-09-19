import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../apis/endpoint.dart';
import '../models/user.dart';

// ApiService handles all HTTP requests
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final http.Client _client = http.Client();
  String? _authToken;

  // Initialize service and load stored token
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
  }

  // Get stored auth token
  Future<String?> getAuthToken() async {
    if (_authToken == null) {
      final prefs = await SharedPreferences.getInstance();
      _authToken = prefs.getString('auth_token');
    }
    return _authToken;
  }

  // Store auth token
  Future<void> setAuthToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Clear auth token
  Future<void> clearAuthToken() async {
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Get default headers
  Map<String, String> _getHeaders({bool includeAuth = true}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth && _authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }

  // Handle HTTP response
  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final responseBody = response.body;

    if (statusCode >= 200 && statusCode < 300) {
      if (responseBody.isEmpty) {
        return {'success': true};
      }
      try {
        return json.decode(responseBody);
      } catch (e) {
        // If JSON parsing fails, return the plain text response
        return responseBody;
      }
    } else {
      try {
        final errorData = json.decode(responseBody);
        throw ApiError.fromJson(errorData);
      } catch (e) {
        throw ApiError(
          message: 'HTTP $statusCode: ${response.reasonPhrase}',
          statusCode: statusCode,
        );
      }
    }
  }

  // GET request
  Future<dynamic> get(String url, {bool includeAuth = true}) async {
    try {
      final response = await _client
          .get(
            Uri.parse(url),
            headers: _getHeaders(includeAuth: includeAuth),
          )
          .timeout(ApiEndpoints.connectionTimeout);

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiError) {
        rethrow;
      }
      throw ApiError(message: 'Network error: ${e.toString()}');
    }
  }

  // POST request
  Future<dynamic> post(String url, {dynamic body, bool includeAuth = true}) async {
    try {
      final response = await _client
          .post(
            Uri.parse(url),
            headers: _getHeaders(includeAuth: includeAuth),
            body: body != null ? json.encode(body) : null,
          )
          .timeout(ApiEndpoints.connectionTimeout);

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiError) {
        rethrow;
      }
      throw ApiError(message: 'Network error: ${e.toString()}');
    }
  }

  // PUT request
  Future<dynamic> put(String url, {dynamic body, bool includeAuth = true}) async {
    try {
      final response = await _client
          .put(
            Uri.parse(url),
            headers: _getHeaders(includeAuth: includeAuth),
            body: body != null ? json.encode(body) : null,
          )
          .timeout(ApiEndpoints.connectionTimeout);

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiError) {
        rethrow;
      }
      throw ApiError(message: 'Network error: ${e.toString()}');
    }
  }

  // DELETE request - Add API response with text no JSON
  Future<dynamic> delete(String url) async {
    try {
      final response = await http.delete(Uri.parse(url), headers: _getHeaders());

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          return null;
        }
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return response.body;
        }
      } else {
        throw ApiError(statusCode: response.statusCode, message: response.body);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Dispose client
  void dispose() {
    _client.close();
  }
}