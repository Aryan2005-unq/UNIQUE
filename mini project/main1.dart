import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'View Sample Products',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SampleProductsScreen(),
    );
  }
}

// SampleProductsScreen (Home screen)
class SampleProductsScreen extends StatelessWidget {
  final List<String> sampleProducts = [
    'product1.jpg',
    'product2.jpg',
    'product3.jpg', // These are your local image file names
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sample Products'),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Display 2 items per row
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: sampleProducts.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailScreen(
                    imageName: sampleProducts[index],
                  ),
                ),
              );
            },
            child: Card(
              child: Image.asset(
                'assets/${sampleProducts[index]}',
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ProductDetailScreen (Details screen for each product)
class ProductDetailScreen extends StatelessWidget {
  final String imageName;

  ProductDetailScreen({required this.imageName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/$imageName', height: 300, width: 300),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // In future, implement 3D model viewing here
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('3D model rendering coming soon!')),
                );
              },
              child: Text('View 3D Model'),
            ),
          ],
        ),
      ),
    );
  }
}
