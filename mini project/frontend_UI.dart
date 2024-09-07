import 'package:flutter/material.dart';
import 'meshy_api.dart'; // Import the MeshyAPI class we defined earlier

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image to 3D Converter',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ImageTo3DConverter(),
    );
  }
}

class ImageTo3DConverter extends StatefulWidget {
  @override
  _ImageTo3DConverterState createState() => _ImageTo3DConverterState();
}

class _ImageTo3DConverterState extends State<ImageTo3DConverter> {
  final TextEditingController _imageUrlController = TextEditingController();
  final MeshyAPI meshyAPI = MeshyAPI();
  String? _taskId;
  String? _statusMessage = 'Enter an image URL and press "Convert to 3D"';
  bool _isLoading = false;
  String? _downloadUrl;

  // Start the task to generate 3D model
  Future<void> _create3DModel() async {
    setState(() {
      _isLoading = true;
      _statusMessage = "Creating task...";
    });

    final imageUrl = _imageUrlController.text.trim();
    if (imageUrl.isNotEmpty) {
      final taskId = await meshyAPI.createImageTo3DTask(imageUrl);

      if (taskId != null) {
        setState(() {
          _taskId = taskId;
          _statusMessage = 'Task created. Checking progress...';
        });
        _checkTaskStatus(taskId);
      } else {
        setState(() {
          _statusMessage = 'Failed to create task.';
        });
      }
    } else {
      setState(() {
        _statusMessage = 'Please enter a valid image URL.';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Periodically check task status
  Future<void> _checkTaskStatus(String taskId) async {
    setState(() {
      _isLoading = true;
    });

    bool taskCompleted = false;
    while (!taskCompleted) {
      await Future.delayed(Duration(seconds: 5)); // Wait for 5 seconds between each status check

      final taskStatus = await meshyAPI.getImageTo3DTaskStatus(taskId);
      if (taskStatus != null) {
        setState(() {
          _statusMessage = 'Task Status: ${taskStatus['status']}';
        });

        if (taskStatus['status'] == 'SUCCEEDED') {
          setState(() {
            _downloadUrl = taskStatus['model_urls']['glb']; // Get GLB URL for download
            _statusMessage = 'Task completed! Click the link below to download the model.';
          });
          taskCompleted = true;
        } else if (taskStatus['status'] == 'FAILED') {
          setState(() {
            _statusMessage = 'Task failed. Error: ${taskStatus['task_error']['message']}';
          });
          taskCompleted = true;
        }
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image to 3D Converter'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _imageUrlController,
              decoration: InputDecoration(
                labelText: 'Enter Image URL',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _create3DModel,
              child: Text(_isLoading ? 'Processing...' : 'Convert to 3D'),
            ),
            SizedBox(height: 20),
            Text(_statusMessage ?? ''),
            SizedBox(height: 20),
            if (_downloadUrl != null)
              Column(
                children: [
                  Text('Model ready!'),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      // Handle model download
                    },
                    child: Text('Download 3D Model'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
