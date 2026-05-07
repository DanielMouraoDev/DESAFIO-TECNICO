import 'package:dio/dio.dart';

class ApiClient {
  final Dio _dio;

  ApiClient([Dio? dio]) : _dio = dio ?? Dio(BaseOptions(baseUrl: 'https://your-backend.example.com')) {
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
  }

  Future<Map<String, dynamic>> createCourse(Map<String, dynamic> payload) async {
    final response = await _dio.post('/api/courses', data: payload);
    return response.data as Map<String, dynamic>;
  }
}
