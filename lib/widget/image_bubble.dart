// ignore_for_file: unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageBubble extends StatelessWidget {
  final String imageUrl;
  const ImageBubble({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        height: 180,
        width: 180,
        fit: BoxFit.cover,
        placeholder: (_, __) => const SizedBox(
          height: 180,
          child: Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
      ),
    );
  }
}
