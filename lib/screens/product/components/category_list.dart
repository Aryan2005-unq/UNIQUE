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

class _CategoryListState extends State<CategoryList> with SingleTickerProviderStateMixin {
  int selectedIndex = 0;
  late AnimationController _animationController;
  
  final List<Map<String, dynamic>> categories = [
    {'name': 'All', 'icon': 'assets/icons/all.svg'},
    {'name': 'Sofa', 'icon': 'assets/icons/sofa.svg'},
    {'name': 'Table', 'icon': 'assets/icons/table.svg'},
    {'name': 'Cupboard', 'icon': 'assets/icons/cupboard.svg'},
    {'name': 'Armchair', 'icon': 'assets/icons/armchair.svg'},
  ];
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(vertical: kDefaultPadding / 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimaryColor, kPrimaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding / 2),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) => GestureDetector(
          onTap: () {
            _animationController.forward(from: 0.0);
            setState(() => selectedIndex = index);
            widget.onCategorySelected(categories[index]['name']);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(
              horizontal: kDefaultPadding / 2,
              vertical: kDefaultPadding / 4,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: kDefaultPadding / 2,
              vertical: kDefaultPadding / 4,
            ),
            decoration: BoxDecoration(
              color: index == selectedIndex 
                  ? Colors.white.withOpacity(0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: index == selectedIndex
                    ? Colors.white
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
                  height: 28,
                  width: 28,
                  color: Colors.white,
                ),
                const SizedBox(height: 6),
                Text(
                  categories[index]['name'],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: index == selectedIndex 
                        ? FontWeight.bold
                        : FontWeight.normal,
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