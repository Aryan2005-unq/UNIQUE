import 'package:flutter/material.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class ARCoreModelViewer extends StatefulWidget {
  final String modelPath;

  const ARCoreModelViewer({super.key, required this.modelPath});

  @override
  _ARCoreModelViewerState createState() => _ARCoreModelViewerState();
}

class _ARCoreModelViewerState extends State<ARCoreModelViewer> {
  ArCoreController? arCoreController;

  @override
  void dispose() {
    arCoreController?.dispose();
    super.dispose();
  }

  void _onArCoreViewCreated(ArCoreController controller) {
    arCoreController = controller;
    _addModel(arCoreController!);
  }

  void _addModel(ArCoreController controller) {
    final modelNode = ArCoreReferenceNode(
      name: 'product_model',
      object3DFileName: widget.modelPath,
      position: vector.Vector3(0, 0, -1.5),  // Adjust position as needed
      scale: vector.Vector3(0.5, 0.5, 0.5),  // Adjust scale
      rotation: vector.Vector4(0, 0, 0, 0),
    );

    controller.addArCoreNode(modelNode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AR Model Viewer')),
      body: ArCoreView(
        onArCoreViewCreated: _onArCoreViewCreated,
        enableTapRecognizer: true,
      ),
    );
  }
}