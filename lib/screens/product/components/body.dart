import 'package:flutter/material.dart';
import 'package:furnitapp/components/generate_3d_button.dart';
import 'package:furnitapp/constants.dart';
import 'package:furnitapp/models/product.dart';
import 'package:furnitapp/screens/details/details_screen.dart';
import 'package:furnitapp/screens/meshy_screen.dart';

import 'category_list.dart';
import 'product_card.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  String _selectedCategory = 'All';

  List<Product> get _filteredProducts {
    return _selectedCategory == 'All'
        ? products
        : products.where((p) => p.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: <Widget>[
          Generate3DButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MeshyScreen(),
                ),
              );
            },
          ),
          CategoryList(
            onCategorySelected: (category) {
              setState(() => _selectedCategory = category);
            },
          ),
          const SizedBox(height: kDefaultPadding / 2),
          Expanded(
            child: Stack(
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(top: 70),
                  decoration: const BoxDecoration(
                    color: kBackgroundColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                ),
                ListView.builder(
                  itemCount: _filteredProducts.length,
                  itemBuilder: (context, index) => ProductCard(
                    itemIndex: index,
                    product: _filteredProducts[index],
                    press: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailsScreen(
                            product: _filteredProducts[index],
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}