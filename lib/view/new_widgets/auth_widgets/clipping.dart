import 'package:flutter/cupertino.dart';

class Clipping extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width / 3, 0);
    path.quadraticBezierTo(
      size.width / 6,
      0,
      size.width / 6,
      size.height / 3,
    );
    path.lineTo(size.width / 6, size.height * 2 / 3);
    path.quadraticBezierTo(
      size.width / 6,
      size.height,
      0,
      size.height,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
