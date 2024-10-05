import 'package:flutter/material.dart';
import 'product_detail_screen.dart'; // Import the product detail screen

class SampleProductsScreen extends StatelessWidget {
  final List<String> sampleProducts = [
    'assets/images/image_name1.jpg', // Replace with your image file names
    'assets/images/image_name2.jpg',
    'assets/images/image_name3.jpg',
    // Add more images as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Sample Products'),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1,
        ),
        itemCount: sampleProducts.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailScreen(imagePath: sampleProducts[index]),
                ),
              );
            },
            child: Image.asset(
              sampleProducts[index],
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }
}
