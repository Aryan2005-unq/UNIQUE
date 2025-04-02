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

  Future<String> createTask(
    File imageFile, {
    bool? isPBREnabled = true,
    String? texturePrompt,
    String? aiModel,
    String topology = 'quad',
    int targetPolycount = 30000,
  }) async {
    try {
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      String dataUri = 'data:image/jpeg;base64,$base64Image';

      final Map<String, dynamic> requestData = {
        'image_url': dataUri,
        'enable_pbr': isPBREnabled,
        'should_remesh': true,
        'should_texture': true,
        'topology': topology,
        'target_polycount': targetPolycount,
      };

      // Add optional parameters if provided
      if (texturePrompt != null && texturePrompt.isNotEmpty) {
        requestData['texture_prompt'] = texturePrompt;
      }

      if (aiModel != null && aiModel.isNotEmpty) {
        requestData['ai_model'] = aiModel;
      }

      final response = await _dio.post('/image-to-3d', data: requestData);

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
        return Exception(
            'API Error: ${response.statusCode} - ${response.data}');
      }
      return Exception('Network Error: ${error.message}');
    }
    return Exception('Unexpected Error: $error');
  }
}
