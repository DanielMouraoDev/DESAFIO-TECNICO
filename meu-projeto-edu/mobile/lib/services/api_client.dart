import 'dart:io' show Platform;
import 'package:dio/dio.dart';

class ApiClient {
  static const _androidBaseUrl = 'http://10.0.2.2:8000/api';
  static const _desktopBaseUrl = 'http://localhost:8000/api';
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
    if (Platform.isAndroid) {
      return _androidBaseUrl;
    }
    return _desktopBaseUrl;
  }

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

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await _dio.post('/login', data: {
      'username': username,
      'password': password,
    });
    final data = response.data as Map<String, dynamic>;
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
    final data = response.data as Map<String, dynamic>;
    if (data.containsKey('tokens')) {
      final tokens = data['tokens'] as Map<String, dynamic>;
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
