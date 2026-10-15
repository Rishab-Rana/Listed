import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class VenueVisual extends StatelessWidget {
  final String? imageUrl;
  final BorderRadius borderRadius;

  const VenueVisual({
    super.key,
    this.imageUrl,
    this.borderRadius = BorderRadius.zero,
  });

  @override
  Widget build(BuildContext context) {
    const fallback = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFFE63888), Color(0xFF4A2166)]),
      ),
      child: Center(child: Icon(Icons.location_on_outlined, color: Colors.white70, size: 30)),
    );
    return ClipRRect(
      borderRadius: borderRadius,
      child: imageUrl == null || imageUrl!.trim().isEmpty
          ? fallback
          : CachedNetworkImage(
              imageUrl: imageUrl!,
              fit: BoxFit.cover,
              placeholder: (_, __) => fallback,
              errorWidget: (_, __, ___) => fallback,
            ),
    );
  }
}
