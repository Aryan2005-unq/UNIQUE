import 'package:flutter/material.dart';
import '../../../constants.dart';
import 'package:furnitapp/screens/model_viewer_screen.dart';

class ViewIn3DButton extends StatelessWidget {
  final String modelUrl;

  const ViewIn3DButton({
    super.key,
    required this.modelUrl,
  });

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
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ModelViewerScreen(
                  modelUrl: modelUrl,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
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
