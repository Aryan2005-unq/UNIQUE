import 'package:flutter/material.dart';
import '../../../constants.dart';

class ViewIn3DButton extends StatelessWidget {
  const ViewIn3DButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(kDefaultPadding),
      padding: const EdgeInsets.symmetric(
        horizontal: kDefaultPadding,
        vertical: kDefaultPadding / 2,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFCBF1E),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Center(
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent, // Keeps the button background transparent
            shadowColor: Colors.transparent,
          ),
          child: const Text(
            "View in 3D",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
