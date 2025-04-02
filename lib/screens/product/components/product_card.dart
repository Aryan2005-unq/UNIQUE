import 'package:flutter/material.dart';
import 'package:furnitapp/models/product.dart';

import '../../../constants.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.itemIndex,
    required this.product,
    required this.press,
  });

  final int itemIndex;
  final Product product;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    // Use layout builder for responsive sizing
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      final cardHeight = width * 0.35;
      final imageSize = cardHeight * 1.15;

      return Container(
        margin: const EdgeInsets.symmetric(
          horizontal: kDefaultPadding,
          vertical: kDefaultPadding / 2,
        ),
        height: cardHeight,
        child: InkWell(
          onTap: press,
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              // Card background
              Container(
                height: cardHeight * 0.85,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  color: itemIndex.isEven ? kBlueColor : kSecondaryColor,
                  boxShadow: const [kDefaultShadow],
                ),
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
              ),
              // Product image with loading indicator
              Positioned(
                top: 0,
                right: 0,
                child: Hero(
                  tag: '${product.id}',
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: kDefaultPadding),
                    height: imageSize,
                    width: width * 0.4,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        Image.asset(
                          product.image,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.image_not_supported,
                                color: Colors.red,
                                size: 50,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Product title and price
              Positioned(
                bottom: 0,
                left: 0,
                child: SizedBox(
                  height: cardHeight * 0.85,
                  width: width - (width * 0.4) - 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: kDefaultPadding),
                        child: Text(
                          product.title,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: kDefaultPadding * 1.5,
                          vertical: kDefaultPadding / 4,
                        ),
                        decoration: BoxDecoration(
                          color: kSecondaryColor,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(22),
                            topRight: Radius.circular(22),
                          ),
                        ),
                        child: Text(
                          "Rs.${product.price}",
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
