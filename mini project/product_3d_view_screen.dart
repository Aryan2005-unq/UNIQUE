import 'package:flutter/material.dart';
import 'package:flutter_gl/flutter_gl.dart';

class ModelViewerScreen extends StatefulWidget {
  final String imagePath;

  const ModelViewerScreen({required this.imagePath});

  @override
  _ModelViewerScreenState createState() => _ModelViewerScreenState();
}

class _ModelViewerScreenState extends State<ModelViewerScreen> {
  late FlutterGlPlugin _glPlugin;

  @override
  void initState() {
    super.initState();
    _glPlugin = FlutterGlPlugin();
    // Initialize and load your 3D model here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('3D Model Viewer'),
      ),
      body: Center(
        child: Text('3D model rendering will be implemented here.'),
      ),
    );
  }

  @override
  void dispose() {
    _glPlugin.dispose();
    super.dispose();
  }
}
