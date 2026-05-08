import 'dart:io' show Platform;
import 'package:dio/dio.dart';

class ApiClient {
  static String get _baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api';
    }
    return 'http://localhost:8000/api';
  }

  final Dio _dio;

  ApiClient([Dio? dio]) : _dio = dio ?? Dio(BaseOptions(baseUrl: _baseUrl)) {
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await _dio.post('/login', data: {
      'username': username,
      'password': password,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    final response = await _dio.post('/register', data: {
      'username': username,
      'email': email,
      'password': password,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createCourse(Map<String, dynamic> payload) async {
    final response = await _dio.post('/courses', data: payload);
    return response.data as Map<String, dynamic>;
  }
}
