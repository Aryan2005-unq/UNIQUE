import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:io';
import '../utils/constants.dart';

class MeshyService {
  late final Dio _dio;

  MeshyService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      headers: {
        'Authorization': 'Bearer ${AppConstants.apiKey}',
        'Content-Type': 'application/json',
      },
    ));
  }

  Future<String> createTask(File imageFile) async {
    try {
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      String dataUri = 'data:image/jpeg;base64,$base64Image';

      final response = await _dio.post('/image-to-3d', data: {
        'image_url': dataUri,
        'enable_pbr': true,
        'should_remesh': true,
        'should_texture': true,
      });

      return response.data['result'];
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> checkStatus(String taskId) async {
    try {
      final response = await _dio.get('/image-to-3d/$taskId');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      final response = error.response;
      if (response != null) {
        return Exception('API Error: ${response.statusCode} - ${response.data}');
      }
      return Exception('Network Error: ${error.message}');
    }
    return Exception('Unexpected Error: $error');
  }
}