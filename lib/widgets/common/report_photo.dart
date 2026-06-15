import 'dart:convert';
import 'package:flutter/material.dart';

class ReportPhoto extends StatelessWidget {
  final String photo;
  final double? height;
  final BoxFit fit;

  const ReportPhoto(this.photo, {super.key, this.height, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    if (photo.startsWith('data:image')) {
      final parts = photo.split(',');
      if (parts.length >= 2) {
        try {
          final bytes = base64Decode(parts[1]);
          return Image.memory(bytes, height: height, width: double.infinity, fit: fit,
              errorBuilder: (_, _, _) => _fallback);
        } catch (_) {
          return _fallback;
        }
      }
    }
    return Image.network(photo, height: height, width: double.infinity, fit: fit,
        errorBuilder: (_, _, _) => _fallback);
  }

  Widget get _fallback => Container(
    height: height ?? 200,
    color: Colors.grey.shade200,
    child: const Center(child: Icon(Icons.broken_image)),
  );
}