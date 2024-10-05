import 'package:flutter/material.dart';
import 'package:flutter_gl/flutter_gl.dart';
import 'dart:typed_data';

class Product3DViewScreen extends StatefulWidget {
  final String productName;
  final String imagePath;
  final String modelPath; // Path to the 3D model file

  Product3DViewScreen({
    required this.productName,
    required this.imagePath,
    required this.modelPath,
  });

  @override
  _Product3DViewScreenState createState() => _Product3DViewScreenState();
}

class _Product3DViewScreenState extends State<Product3DViewScreen> {
  late FlutterGlPlugin flutterGlPlugin;
  late dynamic renderer;
  late Size screenSize;
  late int fboId;
  late int _program;
  late int _shaderVertex;
  late int _shaderFragment;
  late int _vertexBuffer;
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await init3DViewer();
    });
  }

  Future<void> init3DViewer() async {
    flutterGlPlugin = FlutterGlPlugin();
    screenSize = MediaQuery.of(context).size;

    await flutterGlPlugin.initialize(
      options: {
        "antialias": true,
        "width": screenSize.width.toInt(),
        "height": screenSize.height.toInt(),
        "glVersion": 3,
      },
    );

    setState(() {
      isInitialized = true;
    });

    flutterGlPlugin.makeContextCurrent();
    fboId = flutterGlPlugin.fboId!;
    renderer = flutterGlPlugin.gl;

    // Initialize the shaders and 3D model rendering logic here
    loadShaders();
    loadModel(widget.modelPath);
  }

  void loadShaders() {
    // Compile vertex and fragment shaders
    // You would need to add proper shader code here, depending on the model format
  }

  void loadModel(String modelPath) {
    // Load the 3D model from the specified path
    // Use model loading logic appropriate for the model format
  }

  @override
  void dispose() {
    flutterGlPlugin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.productName),
      ),
      body: isInitialized
          ? Stack(
              children: [
                Container(
                  width: screenSize.width,
                  height: screenSize.height,
                  child: Texture(textureId: flutterGlPlugin.textureId!),
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: ElevatedButton(
                    onPressed: () {
                      // Implement rotation, movement logic here
                    },
                    child: Text("Move / Rotate"),
                  ),
                ),
              ],
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
