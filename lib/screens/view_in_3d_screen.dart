import 'package:flutter/material.dart';

class ViewIn3DScreen extends StatelessWidget {
  const ViewIn3DScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("3D Viewer"),
      ),
      body: const Center(
        child: Text("3D Model Display Here"),
      ),
    );
  }
}
