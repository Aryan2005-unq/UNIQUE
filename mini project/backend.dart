import 'dart:convert';
import 'package:http/http.dart' as http;

class MeshyAPI {
  final String apiKey = 'YOUR_API_KEY'; // Replace with your API key
  final String baseUrl = 'https://api.meshy.ai/v1';

  // Create a new Image to 3D task
  Future<String?> createImageTo3DTask(String imageUrl, {bool enablePbr = true, String surfaceMode = 'hard'}) async {
    final url = Uri.parse('$baseUrl/image-to-3d');
    
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'image_url': imageUrl,
        'enable_pbr': enablePbr,
        'surface_mode': surfaceMode,
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final taskId = jsonResponse['result'];
      print('Task Created. Task ID: $taskId');
      return taskId;
    } else {
      print('Failed to create task: ${response.body}');
      return null;
    }
  }

  // Retrieve the Image to 3D task status
  Future<Map<String, dynamic>?> getImageTo3DTaskStatus(String taskId) async {
    final url = Uri.parse('$baseUrl/image-to-3d/$taskId');
    
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $apiKey',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      print('Task Status: ${jsonResponse['status']}');
      return jsonResponse;
    } else {
      print('Failed to retrieve task status: ${response.body}');
      return null;
    }
  }

  // Download the 3D model when task is completed
  Future<void> downloadModel(String modelUrl, String filePath) async {
    final response = await http.get(Uri.parse(modelUrl));
    
    if (response.statusCode == 200) {
      // Save the model to the local file system
      // This is platform-specific. For Flutter, you can use path_provider or similar packages to save the file.
      print('Model downloaded successfully at $filePath');
    } else {
      print('Failed to download the model: ${response.body}');
    }
  }
}

void main() async {
  final meshyAPI = MeshyAPI();

  // Step 1: Create a new Image to 3D task
  String? taskId = await meshyAPI.createImageTo3DTask(
    'https://example.com/your-image.jpg', // Replace with a valid image URL
    enablePbr: true,
    surfaceMode: 'hard',
  );

  // Step 2: Check the status of the task periodically
  if (taskId != null) {
    bool taskCompleted = false;
    
    while (!taskCompleted) {
      await Future.delayed(Duration(seconds: 5)); // Wait 5 seconds between each status check

      final taskStatus = await meshyAPI.getImageTo3DTaskStatus(taskId);
      
      if (taskStatus != null && taskStatus['status'] == 'SUCCEEDED') {
        print('Task completed successfully!');
        
        // Get the GLB model URL and download it
        final modelUrls = taskStatus['model_urls'];
        final glbModelUrl = modelUrls['glb']; // You can also get FBX or USDZ URLs

        await meshyAPI.downloadModel(glbModelUrl, '/path/to/save/model.glb');
        taskCompleted = true;
      } else if (taskStatus != null && taskStatus['status'] == 'FAILED') {
        print('Task failed. Error: ${taskStatus['task_error']['message']}');
        taskCompleted = true;
      } else {
        print('Task in progress...');
      }
    }
  }
}
