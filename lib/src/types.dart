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

/// Result of copy operations with detailed status information
class CopyResult {
  final bool isSuccess;
  final bool isWaiting;
  final String? message;

  const CopyResult._({
    required this.isSuccess,
    required this.isWaiting,
    this.message,
  });

  /// Create a successful copy result
  factory CopyResult.success([String? message]) => CopyResult._(
    isSuccess: true,
    isWaiting: false,
    message: message ?? 'Image copied successfully',
  );

  /// Create a failed copy result
  factory CopyResult.failed(String message) => CopyResult._(
    isSuccess: false,
    isWaiting: false,
    message: message,
  );

  /// Create a waiting copy result (image still loading)
  factory CopyResult.waiting(String message) => CopyResult._(
    isSuccess: false,
    isWaiting: true,
    message: message,
  );

  /// Whether the operation was successful
  bool get isFailure => !isSuccess && !isWaiting;
}

/// Status of copy functionality availability
class CopyAvailabilityStatus {
  final bool isAvailable;
  final bool isWaiting;
  final String message;

  const CopyAvailabilityStatus._({
    required this.isAvailable,
    required this.isWaiting,
    required this.message,
  });

  /// Copy functionality is available
  factory CopyAvailabilityStatus.available(String message) => CopyAvailabilityStatus._(
    isAvailable: true,
    isWaiting: false,
    message: message,
  );

  /// Copy functionality is unavailable
  factory CopyAvailabilityStatus.unavailable(String message) => CopyAvailabilityStatus._(
    isAvailable: false,
    isWaiting: false,
    message: message,
  );

  /// Copy functionality is waiting (e.g., image still loading)
  factory CopyAvailabilityStatus.waiting(String message) => CopyAvailabilityStatus._(
    isAvailable: false,
    isWaiting: true,
    message: message,
  );

  /// Whether copy is unavailable (not waiting, just unavailable)
  bool get isUnavailable => !isAvailable && !isWaiting;
} 