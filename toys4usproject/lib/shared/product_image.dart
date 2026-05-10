import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  final String imagePath;
  final double height;
  final double? width;
  final BoxFit fit;

  const ProductImage({
    super.key,
    required this.imagePath,
    this.height = 200,
    this.width,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      height: height,
      width: width,
      color: Colors.grey.shade200,
      child: const Icon(
        Icons.image_not_supported_outlined,
        size: 42,
        color: Colors.grey,
      ),
    );

    if (imagePath.isEmpty) return fallback;

    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (_, __, ___) => fallback,
      );
    }

    return Image.asset(
      imagePath,
      height: height,
      width: width,
      fit: fit,
      errorBuilder: (_, __, ___) => fallback,
    );
  }
}