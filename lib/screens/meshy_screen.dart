import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import '../services/meshy_service.dart';
import 'model_viewer_screen.dart';

class MeshyScreen extends StatefulWidget {
  const MeshyScreen({super.key});

  @override
  State<MeshyScreen> createState() => _MeshyScreenState();
}

class _MeshyScreenState extends State<MeshyScreen> {
  final MeshyService _meshyService = MeshyService();
  bool _isLoading = false;
  String _status = '';
  String? _taskId;
  Timer? _pollTimer;
  Map<String, dynamic>? _result;
  bool _isCartoonMode = false;
  bool _structuralAccuracyMode = false;

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _processImage() async {
    try {
      setState(() => _isLoading = true);

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null) {
        setState(() {
          _status = 'No image selected';
          _isLoading = false;
        });
        return;
      }

      setState(() => _status = 'Creating 3D model...');

      // Use the enhanced MeshyService with parameters based on image type
      if (_isCartoonMode) {
        _taskId = await _meshyService.createTask(File(image.path),
            texturePrompt:
                "Vibrant cartoon character with accurate colors and smooth texture",
            topology: "quad",
            targetPolycount: 30000,
            isPBREnabled: true);
      } else if (_structuralAccuracyMode) {
        // For furniture with better structural accuracy (preview mode)
        _taskId = await _meshyService.createTask(
          File(image.path),
          topology: "triangle", // Triangle mesh for better structural details
          targetPolycount: 80000, // Higher poly count for more detail
          isPBREnabled: true,
          texturePrompt:
              "Accurate furniture model with precise structure and proportions",
          // Not using meshy-4 (hard surface mode) to get the default preview behavior
        );
      } else {
        // Original furniture mode (hard surface)
        _taskId = await _meshyService.createTask(File(image.path),
            topology: "quad",
            targetPolycount: 30000,
            isPBREnabled: true,
            aiModel: "meshy-4" // Explicitly set to hard surface mode
            );
      }

      _startPolling();
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 5),
      (timer) async {
        if (_taskId == null) return;

        try {
          final result = await _meshyService.checkStatus(_taskId!);
          setState(() => _result = result);

          switch (result['status']) {
            case 'SUCCEEDED':
              timer.cancel();
              setState(() {
                _status = 'Complete! Click "View in 3D" to see your model';
                _isLoading = false;
              });
              break;
            case 'FAILED':
              timer.cancel();
              setState(() {
                _status = 'Failed: ${result['task_error']['message']}';
                _isLoading = false;
              });
              break;
            case 'IN_PROGRESS':
              setState(() => _status = 'Processing: ${result['progress']}%');
              break;
            default:
              setState(() => _status = 'Status: ${result['status']}');
          }
        } catch (e) {
          timer.cancel();
          setState(() {
            _status = 'Error: $e';
            _isLoading = false;
          });
        }
      },
    );
  }

  void _viewIn3D() {
    if (_result != null && _result!['model_url'] != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ModelViewerScreen(
            modelUrl: _result!['model_url'],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('3D Generator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Mode selection switches
            SwitchListTile(
              title: const Text('Cartoon/Character Mode'),
              subtitle: const Text(
                  'Enable for better results with cartoon characters'),
              value: _isCartoonMode,
              onChanged: (bool value) {
                setState(() {
                  _isCartoonMode = value;
                  // Disable structural accuracy mode if cartoon mode is enabled
                  if (value) {
                    _structuralAccuracyMode = false;
                  }
                });
              },
            ),
            SwitchListTile(
              title: const Text('Structural Accuracy Mode'),
              subtitle: const Text(
                  'Enable for furniture models with better structural accuracy'),
              value: _structuralAccuracyMode,
              onChanged: _isCartoonMode
                  ? null // Disable when cartoon mode is on
                  : (bool value) {
                      setState(() {
                        _structuralAccuracyMode = value;
                      });
                    },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _processImage,
              child: const Text('Select Image'),
            ),
            const SizedBox(height: 16),
            if (_isLoading) const LinearProgressIndicator(),
            const SizedBox(height: 16),
            Text(_status, style: Theme.of(context).textTheme.bodyLarge),
            if (_result != null && _result!['status'] == 'SUCCEEDED') ...[
              const SizedBox(height: 16),
              if (_result!['thumbnail_url'] != null)
                Image.network(
                  _result!['thumbnail_url'],
                  height: 200,
                  fit: BoxFit.contain,
                ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _viewIn3D,
                icon: const Icon(Icons.view_in_ar),
                label: const Text('View in 3D'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
