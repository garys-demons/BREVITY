import 'dart:convert';
import 'dart:io';

import 'package:brevity/utils/logger.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:image_picker/image_picker.dart';

class ApiService {
  // Update this URL to match your backend
  static const String baseUrl = 'https://brevity-backend-khaki.vercel.app/api';
  //static const String baseUrl = 'http://10.0.2.2:5000/api';

  // For Android emulator: http://10.0.2.2:5000/api
  // For iOS simulator: http://localhost:5000/api
  // For production: https://your-domain.com/api

  // Singleton instance
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // HTTP client with timeout
  static final http.Client _client = http.Client();
  static const Duration _timeout = Duration(seconds: 30);

  // Token management
  String? _accessToken;
  String? _refreshToken;

  /// Initialize tokens from storage
  Future<void> initializeTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('accessToken'); // Changed from 'access_token' to match AuthService
    _refreshToken = prefs.getString('refresh_token');
  }

  /// Save tokens to storage
  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', accessToken); // Changed from 'access_token' to match AuthService
    await prefs.setString('refresh_token', refreshToken);
  }

  /// Clear tokens from storage
  Future<void> _clearTokens() async {
    _accessToken = null;
    _refreshToken = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken'); // Changed from 'access_token' to match AuthService
    await prefs.remove('refresh_token');
  }

  /// Get auth headers
  Map<String, String> _getHeaders({bool includeAuth = false}) {
    final headers = <String, String>{'Content-Type': 'application/json'};

    if (includeAuth && _accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }

    return headers;
  }

  /// Handle API response
  ApiResponse _handleResponse(http.Response response) {
    final Map<String, dynamic> data = json.decode(response.body);

    return ApiResponse(
      success: data['success'] ?? false,
      message: data['message'] ?? 'Unknown error',
      data: data['data'],
      statusCode: response.statusCode,
      errors: data['errors'],
    );
  }

  /// Make HTTP request with error handling
  Future<ApiResponse> _makeRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    bool requireAuth = false,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      late http.Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await _client
              .get(uri, headers: _getHeaders(includeAuth: requireAuth))
              .timeout(_timeout);
          break;
        case 'POST':
          response = await _client
              .post(
                uri,
                headers: _getHeaders(includeAuth: requireAuth),
                body: body != null ? json.encode(body) : null,
              )
              .timeout(_timeout);
          break;
        case 'PUT':
          response = await _client
              .put(
                uri,
                headers: _getHeaders(includeAuth: requireAuth),
                body: body != null ? json.encode(body) : null,
              )
              .timeout(_timeout);
          break;
        case 'DELETE':
          response = await _client
              .delete(uri, headers: _getHeaders(includeAuth: requireAuth))
              .timeout(_timeout);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: _getErrorMessage(e),
        statusCode: 0,
      );
    }
  }

  /// Get user-friendly error message
  String _getErrorMessage(dynamic error) {
    if (error is SocketException) {
      return 'No internet connection. Please check your network.';
    } else if (error is http.ClientException) {
      return 'Network error. Please try again.';
    } else if (error.toString().contains('timeout')) {
      return 'Request timeout. Please try again.';
    } else {
      return 'Something went wrong. Please try again.';
    }
  }

  /// Authentication Methods ///

  /// Register new user
  Future<ApiResponse> register({
    required String displayName,
    required String email,
    required String password,
    File? profileImage,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/auth/register');
      final request = http.MultipartRequest('POST', uri);

      // Add form fields
      request.fields['displayName'] = displayName;
      request.fields['email'] = email;
      request.fields['password'] = password;

      // Add profile image if provided
      if (profileImage != null) {
        final multipartFile = await http.MultipartFile.fromPath(
          'profileImage',
          profileImage.path,
        );
        request.files.add(multipartFile);
      }

      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);
      final apiResponse = _handleResponse(response);

      // Save tokens on successful registration
      if (apiResponse.success && apiResponse.data != null) {
        final data = apiResponse.data as Map<String, dynamic>;
        await _saveTokens(
          data['accessToken'] as String,
          data['refreshToken'] as String,
        );
      }

      return apiResponse;
    } catch (e) {
      return ApiResponse(
        success: false,
        message: _getErrorMessage(e),
        statusCode: 0,
      );
    }
  }

  /// Login user
  Future<ApiResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _makeRequest(
      'POST',
      '/auth/login',
      body: {'email': email, 'password': password},
    );

    // Save tokens on successful login
    if (response.success && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      await _saveTokens(
        data['accessToken'] as String,
        data['refreshToken'] as String,
      );
    }

    return response;
  }

  /// Logout user
  Future<ApiResponse> logout() async {
    final response = await _makeRequest(
      'POST',
      '/auth/logout',
      body: {'refreshToken': _refreshToken},
      requireAuth: true,
    );

    if (response.success) {
      await _clearTokens();
    }

    return response;
  }

  /// Get current user
  Future<ApiResponse> getCurrentUser() async {
    return await _makeRequest('GET', '/auth/me', requireAuth: true);
  }

  /// User Profile Methods ///

  /// Update user profile
  Future<ApiResponse> updateProfile({
    String? displayName,
    Map<String, dynamic>? preferences,
    File? profileImage,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/users/profile');
      final request = http.MultipartRequest('PUT', uri);

      // Add auth header
      if (_accessToken != null) {
        request.headers['Authorization'] = 'Bearer $_accessToken';
      }

      // Add form fields
      if (displayName != null) {
        request.fields['displayName'] = displayName;
      }
      if (preferences != null) {
        request.fields['preferences'] = json.encode(preferences);
      }

      // Add profile image if provided
      if (profileImage != null) {
        final multipartFile = await http.MultipartFile.fromPath(
          'profileImage',
          profileImage.path,
        );
        request.files.add(multipartFile);
      }

      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: _getErrorMessage(e),
        statusCode: 0,
      );
    }
  }

  /// Delete profile image
  Future<ApiResponse> deleteProfileImage() async {
    return await _makeRequest(
      'DELETE',
      '/users/profile/image',
      requireAuth: true,
    );
  }

  /// Utility Methods ///

  /// Check if user is authenticated
  bool get isAuthenticated => _accessToken != null;

  /// Get access token
  String? get accessToken => _accessToken;

  /// Check backend health
  Future<ApiResponse> checkHealth() async {
    return await _makeRequest('GET', '/health');
  }

  /// Dispose resources
  void dispose() {
    _client.close();
  }
}

/// API Response model
class ApiResponse {
  final bool success;
  final String message;
  final dynamic data;
  final int statusCode;
  final List<dynamic>? errors;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    required this.statusCode,
    this.errors,
  });

  @override
  String toString() {
    return 'ApiResponse(success: $success, message: $message, statusCode: $statusCode)';
  }
}

/// User model for API responses
class ApiUser {
  final String id;
  final String displayName;
  final String email;
  final bool emailVerified;
  final ProfileImage? profileImage;
  final UserPreferences preferences;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLogin;

  ApiUser({
    required this.id,
    required this.displayName,
    required this.email,
    required this.emailVerified,
    this.profileImage,
    required this.preferences,
    required this.createdAt,
    required this.updatedAt,
    this.lastLogin,
  });

  factory ApiUser.fromJson(Map<String, dynamic> json) {
    return ApiUser(
      id: json['_id'] as String,
      displayName: json['displayName'] as String,
      email: json['email'] as String,
      emailVerified: json['emailVerified'] as bool? ?? false,
      profileImage:
          json['profileImage'] != null
              ? ProfileImage.fromJson(json['profileImage'])
              : null,
      preferences: UserPreferences.fromJson(json['preferences'] ?? {}),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      lastLogin:
          json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'displayName': displayName,
      'email': email,
      'emailVerified': emailVerified,
      'profileImage': profileImage?.toJson(),
      'preferences': preferences.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }
}

/// Profile Image model
class ProfileImage {
  final String url;
  final String publicId;

  ProfileImage({required this.url, required this.publicId});

  factory ProfileImage.fromJson(Map<String, dynamic> json) {
    return ProfileImage(
      url: json['url'] as String,
      publicId: json['publicId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'url': url, 'publicId': publicId};
  }
}

/// User Preferences model
class UserPreferences {
  final List<String> categories;
  final String language;

  UserPreferences({required this.categories, required this.language});

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      categories: List<String>.from(json['categories'] ?? []),
      language: json['language'] as String? ?? 'en',
    );
  }

  Map<String, dynamic> toJson() {
    return {'categories': categories, 'language': language};
  }
}

/// Updated AuthService to use ApiService
class AuthService {
  final ApiService _apiService = ApiService();

  // Singleton instance
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  /// Initialize service
  Future<void> initialize() async {
    await _apiService.initializeTokens();
  }

  /// Register with email and password
  Future<ApiUser?> signUpWithEmail({
    required String email,
    required String password,
    required String userName,
    File? profileImage,
  }) async {
    try {
      final response = await _apiService.register(
        displayName: userName,
        email: email,
        password: password,
        profileImage: profileImage,
      );

      if (response.success && response.data != null) {
        final userData = response.data['user'] as Map<String, dynamic>;
        return ApiUser.fromJson(userData);
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  /// Login with email and password
  Future<ApiUser?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.login(
        email: email,
        password: password,
      );

      if (response.success && response.data != null) {
        final userData = response.data['user'] as Map<String, dynamic>;
        return ApiUser.fromJson(userData);
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _apiService.logout();
    } catch (e) {
      // Continue with local logout even if API call fails
      Log.e('Logout API call failed: $e');
    }
  }

  /// Get current user
  Future<ApiUser?> getCurrentUser() async {
    try {
      final response = await _apiService.getCurrentUser();

      if (response.success && response.data != null) {
        final userData = response.data['user'] as Map<String, dynamic>;
        return ApiUser.fromJson(userData);
      }
      return null;
    } catch (e) {
      Log.e('Get current user failed: $e');
      return null;
    }
  }

  /// Update user profile
  Future<ApiUser?> updateProfile({
    String? displayName,
    Map<String, dynamic>? preferences,
    File? profileImage,
  }) async {
    try {
      final response = await _apiService.updateProfile(
        displayName: displayName,
        preferences: preferences,
        profileImage: profileImage,
      );

      if (response.success && response.data != null) {
        final userData = response.data['user'] as Map<String, dynamic>;
        return ApiUser.fromJson(userData);
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      throw Exception('Profile update failed: ${e.toString()}');
    }
  }

  /// Delete profile image
  Future<void> deleteProfileImage() async {
    try {
      final response = await _apiService.deleteProfileImage();

      if (!response.success) {
        throw Exception(response.message);
      }
    } catch (e) {
      throw Exception('Delete profile image failed: ${e.toString()}');
    }
  }

  /// Check if user is authenticated
  bool get isAuthenticated => _apiService.isAuthenticated;

  /// Stream for auth state changes (simplified version)
  Stream<ApiUser?> get authStateChanges async* {
    // Initial state
    yield await getCurrentUser();

    // Note: For real-time auth state changes, you might want to implement
    // a more sophisticated solution with StreamController
  }
}
