import 'package:flutter/material.dart';

class GeoPredIALogo extends StatelessWidget {
  final double size;

  const GeoPredIALogo({
    super.key,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/geopredia_logo.jpg',
      width: size * (1220 / 401),
      height: size,
      fit: BoxFit.contain,
      semanticLabel: 'GeoPredIA',
    );
  }
}
