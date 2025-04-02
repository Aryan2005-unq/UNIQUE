import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../constants.dart';

class ModelViewerScreen extends StatefulWidget {
  final String modelUrl;

  const ModelViewerScreen({
    super.key,
    required this.modelUrl,
  });

  @override
  State<ModelViewerScreen> createState() => _ModelViewerScreenState();
}

class _ModelViewerScreenState extends State<ModelViewerScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  bool _hasError = false;
  late AnimationController _controller;
  final GlobalKey _modelViewerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _controller.forward();

    // Simulated loading delay - in a real app, this could be actual network status monitoring
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getModelPath() {
    if (widget.modelUrl.startsWith('assets/')) {
      return 'file:///android_asset/flutter_assets/${widget.modelUrl}';
    }
    return widget.modelUrl;
  }

  void _handleModelError() {
    setState(() {
      _hasError = true;
      _isLoading = false;
    });
  }

  void _retryLoading() {
    setState(() {
      _hasError = false;
      _isLoading = true;
    });

    // Simulated loading retry
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          // In a real implementation, you would check the actual status here
          // This is just a placeholder that simulates retry success
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('3D Model Viewer'),
        elevation: 0,
      ),
      body: Stack(
        children: [
          FadeTransition(
            opacity: _controller,
            child: ModelViewer(
              key: _modelViewerKey,
              backgroundColor: Theme.of(context).colorScheme.background,
              src: _getModelPath(),
              alt: '3D Model',
              ar: true,
              autoRotate: true,
              cameraControls: true,
              disableZoom: false,
            ),
          ),
          if (_isLoading)
            Container(
              color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Loading 3D Model...',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
          if (_hasError)
            Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load 3D model',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _retryLoading,
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
