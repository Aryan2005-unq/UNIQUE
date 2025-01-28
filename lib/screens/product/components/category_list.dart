import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../constants.dart';

class CategoryList extends StatefulWidget {
  final Function(String) onCategorySelected;

  const CategoryList({
    Key? key,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  _CategoryListState createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  int selectedIndex = 0;
  final List<Map<String, dynamic>> categories = [
    {
      'name': 'All',
      'icon': 'assets/icons/all.svg',
    },
    {
      'name': 'Sofa',
      'icon': 'assets/icons/sofa.svg',
    },
    {
      'name': 'Cupboard',
      'icon': 'assets/icons/cupboard.svg',
    },
    {
      'name': 'Armchair',
      'icon': 'assets/icons/armchair.svg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      margin: EdgeInsets.symmetric(vertical: kDefaultPadding / 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) => GestureDetector(
          onTap: () {
            setState(() => selectedIndex = index);
            widget.onCategorySelected(categories[index]['name']);
          },
          child: Container(
            margin: EdgeInsets.only(
              left: kDefaultPadding,
              right: index == categories.length - 1 ? kDefaultPadding : 0,
            ),
            padding: EdgeInsets.symmetric(
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
                      ? kSecondaryColor 
                      : Colors.white,
                ),
                SizedBox(height: 4),
                Text(
                  categories[index]['name'],
                  style: TextStyle(
                    color: index == selectedIndex 
                        ? kSecondaryColor 
                        : Colors.white,
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