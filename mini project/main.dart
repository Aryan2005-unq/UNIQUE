import 'package:flutter/material.dart';
import 'sample_products_screen.dart'; // Import the sample products screen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image to 3D Model',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SampleProductsScreen(), // Set the home screen to SampleProductsScreen
    );
  }
}
