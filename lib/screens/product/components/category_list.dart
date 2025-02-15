import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../constants.dart';

class CategoryList extends StatefulWidget {
  final Function(String) onCategorySelected;

  const CategoryList({
    super.key,
    required this.onCategorySelected,
  });

  @override
  _CategoryListState createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  int selectedIndex = 0;
  final List<Map<String, dynamic>> categories = [
    {'name': 'All', 'icon': 'assets/icons/all.svg'},
    {'name': 'Sofa', 'icon': 'assets/icons/sofa.svg'},
    {'name': 'Cupboard', 'icon': 'assets/icons/cupboard.svg'},
    {'name': 'Armchair', 'icon': 'assets/icons/armchair.svg'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(vertical: kDefaultPadding / 2),
      decoration: BoxDecoration(
        color: Colors.blue, // Solid blue background
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding / 2), // Side spacing
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) => GestureDetector(
          onTap: () {
            setState(() => selectedIndex = index);
            widget.onCategorySelected(categories[index]['name']);
          },
          child: Container(
            margin: const EdgeInsets.symmetric(  // Equal spacing between items
              horizontal: kDefaultPadding / 2,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: kDefaultPadding / 2,
              vertical: kDefaultPadding / 4,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: index == selectedIndex
                    ? kSecondaryColor
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  categories[index]['icon'],
                  height: 32,
                  width: 32,
                  color: index == selectedIndex
                      ? kSecondaryColor // Selected state color
                      : Colors.black, // Default black icons
                ),
                const SizedBox(height: 4),
                Text(
                  categories[index]['name'],
                  style: TextStyle(
                    color: index == selectedIndex
                        ? kSecondaryColor // Selected text color
                        : Colors.black, // Default black text
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}