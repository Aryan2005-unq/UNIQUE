import 'package:flutter/material.dart';
import 'model_viewer_screen.dart'; // Import the model viewer screen

class ProductDetailScreen extends StatelessWidget {
  final String imagePath;

  const ProductDetailScreen({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Detail'),
      ),
      body: Column(
        children: [
          Image.asset(imagePath, height: 200, width: double.infinity, fit: BoxFit.cover),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Navigate to 3D Model Viewer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ModelViewerScreen(imagePath: imagePath),
                ),
              );
            },
            child: Text('View 3D Model'),
          ),
        ],
      ),
    );
  }
}
