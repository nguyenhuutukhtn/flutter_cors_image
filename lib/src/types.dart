import 'dart:typed_data';
import 'package:flutter/material.dart';

/// Custom loading state for tracking image loading progress
enum ImageLoadingState {
  initial,
  loading,
  loaded,
  failed,
}

/// Position for hover icons
enum HoverIconPosition {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  topCenter,
  bottomCenter,
}

/// Layout direction for hover icons
enum HoverIconLayout {
  auto,    // Automatic based on position (vertical for corners, horizontal for center)
  row,     // Always horizontal
  column,  // Always vertical
}

/// Context menu actions for right-click functionality
enum ContextMenuAction {
  copyImage,
  saveImage,
  openImageInNewTab,
  copyImageUrl,
  custom,
}

/// Context menu item configuration
class ContextMenuItem {
  final String title;
  final IconData? icon;
  final ContextMenuAction action;
  final VoidCallback? onTap;

  const ContextMenuItem({
    required this.title,
    this.icon,
    required this.action,
    this.onTap,
  });
}

/// Custom loading progress information
class CustomImageProgress {
  final int cumulativeBytesLoaded;
  final int? expectedTotalBytes;
  final double? progress;

  const CustomImageProgress({
    required this.cumulativeBytesLoaded,
    this.expectedTotalBytes,
    this.progress,
  });
}

/// Image data callback information
class ImageDataInfo {
  final Uint8List imageBytes;
  final int width;
  final int height;
  final String url;

  const ImageDataInfo({
    required this.imageBytes,
    required this.width,
    required this.height,
    required this.url,
  });
} 