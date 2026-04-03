import 'package:flutter/material.dart';

class OnboardPage extends StatelessWidget {
  final String imagePath;
  const OnboardPage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
    );
  }
}
