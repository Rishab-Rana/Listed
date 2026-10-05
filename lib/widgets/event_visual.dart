import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/event_item.dart';

class EventVisual extends StatelessWidget {
  final EventItem event;
  final BorderRadius borderRadius;

  const EventVisual({super.key, required this.event, this.borderRadius = BorderRadius.zero});

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: event.gradient,
        ),
      ),
    );

    if (event.coverImageUrl == null) return fallback;

    return ClipRRect(
      borderRadius: borderRadius,
      child: CachedNetworkImage(
        imageUrl: event.coverImageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => fallback,
        errorWidget: (context, url, error) => fallback,
      ),
    );
  }
}