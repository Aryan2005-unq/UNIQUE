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
      _taskId = await _meshyService.createTask(File(image.path));
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