import 'dart:io' show Platform;
import 'package:dio/dio.dart';

class ApiClient {
  static const _envBaseUrl = String.fromEnvironment('API_BASE_URL');
  static const _androidBaseUrl = 'http://10.0.2.2:8000/api';
  // Use 127.0.0.1 instead of localhost to avoid IPv6 (::1) resolution issues on Windows.
  static const _desktopBaseUrl = 'http://127.0.0.1:8000/api';
  static String? _accessToken;
  static String? _refreshToken;

  static void setTokens({required String accessToken, String? refreshToken}) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  static void clearTokens() {
    _accessToken = null;
    _refreshToken = null;
  }

  static String get _baseUrl {
    if (_envBaseUrl.isNotEmpty) {
      return _envBaseUrl;
    }
    if (Platform.isAndroid) {
      return _androidBaseUrl;
    }
    return _desktopBaseUrl;
  }

  static String get baseUrl => _baseUrl;

  final Dio _dio;

  ApiClient([Dio? dio]) : _dio = dio ?? Dio(BaseOptions(baseUrl: _baseUrl)) {
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_accessToken != null) {
            options.headers['Authorization'] = 'Bearer $_accessToken';
          }
          handler.next(options);
        },
      ),
    );
  }

  Map<String, dynamic> _asMap(dynamic data, {required String endpoint}) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    throw Exception(
      'Invalid response format from $endpoint. '
      'Expected JSON object, got: ${data.runtimeType}. Body: $data',
    );
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await _dio.post('/login', data: {
      'username': username,
      'password': password,
    });
    final data = _asMap(response.data, endpoint: '/login');
    if (data.containsKey('access')) {
      setTokens(
        accessToken: data['access'] as String,
        refreshToken: data['refresh'] as String?,
      );
    }
    return data;
  }

  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    final response = await _dio.post('/register', data: {
      'username': username,
      'email': email,
      'password': password,
    });
    final data = _asMap(response.data, endpoint: '/register');
    if (data.containsKey('tokens')) {
      final tokens = _asMap(data['tokens'], endpoint: '/register.tokens');
      setTokens(
        accessToken: tokens['access'] as String,
        refreshToken: tokens['refresh'] as String?,
      );
    }
    return data;
  }

  Future<List<Map<String, dynamic>>> fetchCourses() async {
    final response = await _dio.get('/courses');
    return (response.data as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> createCourse(Map<String, dynamic> payload) async {
    final response = await _dio.post('/courses', data: payload);
    return response.data as Map<String, dynamic>;
  }
}
