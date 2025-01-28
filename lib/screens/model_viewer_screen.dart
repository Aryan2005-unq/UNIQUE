import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class ModelViewerScreen extends StatelessWidget {
  final String modelUrl;
  
  const ModelViewerScreen({
    super.key, 
    required this.modelUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('3D Model Viewer'),
      ),
      body: ModelViewer(
        backgroundColor: const Color.fromARGB(0xFF, 0xEE, 0xEE, 0xEE),
        src: modelUrl,
        alt: '3D Model',
        ar: true,
        autoRotate: true,
        cameraControls: true,
        disableZoom: false,
      ),
    );
  }
}