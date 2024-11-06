import 'package:flutter/material.dart';

import '../constants.dart';

class Generate3DButton extends StatelessWidget {
  const Generate3DButton({
    Key? key,
    required this.onPressed, 
  }) : super(key: key);

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(kDefaultPadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            const Color.fromARGB(255, 18, 83, 136),    
            const Color.fromARGB(255, 72, 145, 179),   
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, 
          shadowColor: Colors.blue.withOpacity(0.3), 
          padding: EdgeInsets.symmetric(
            horizontal: kDefaultPadding * 1.5,
            vertical: kDefaultPadding / 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), 
          ),
        ),
        child: Text(
          'Generate 3D',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}
