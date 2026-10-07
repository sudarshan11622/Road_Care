import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

Widget reportImage(
  String path, {
  required double width,
  required double height,
  BoxFit fit = BoxFit.cover,
}) {
  if (path.startsWith('assets/')) {
    return Image.asset(path, width: width, height: height, fit: fit);
  }

  return Image.network(
    path,
    width: width,
    height: height,
    fit: fit,
    errorBuilder: (_, __, ___) => _missingImage(width, height),
  );
}

Widget _missingImage(double width, double height) {
  return Container(
    width: width,
    height: height,
    color: AppTheme.surface,
    child: const Icon(Icons.image_not_supported_outlined, color: AppTheme.muted),
  );
}