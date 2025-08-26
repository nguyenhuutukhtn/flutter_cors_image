import 'dart:convert';
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
  final Uint8List? imageBytes;
  final int width;
  final int height;
  final String url;

  const ImageDataInfo({
    this.imageBytes,
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

/// Web storage caching configuration
class WebStorageCacheConfig {
  /// Maximum cache size in bytes (default: 100MB)
  final int maxCacheSize;
  
  /// Cache expiration time in hours (default: 168 hours = 7 days)
  final int cacheExpirationHours;
  
  /// Whether to enable web storage caching (default: true on web)
  final bool enabled;
  
  /// Cache version for invalidating old caches when format changes
  final int cacheVersion;

  const WebStorageCacheConfig({
    this.maxCacheSize = 100 * 1024 * 1024, // 100MB
    this.cacheExpirationHours = 168, // 7 days
    this.enabled = true,
    this.cacheVersion = 1,
  });
}

/// Cached image data with metadata
class CachedImageData {
  final Uint8List imageBytes;
  final int width;
  final int height;
  final String url;
  final String contentType;
  final DateTime cachedAt;
  final int cacheVersion;

  const CachedImageData({
    required this.imageBytes,
    required this.width,
    required this.height,
    required this.url,
    required this.contentType,
    required this.cachedAt,
    required this.cacheVersion,
  });

  /// Convert to ImageDataInfo
  ImageDataInfo toImageDataInfo() {
    return ImageDataInfo(
      imageBytes: imageBytes,
      width: width,
      height: height,
      url: url,
    );
  }

  /// Check if cache entry is expired
  bool isExpired(int expirationHours) {
    final now = DateTime.now();
    final expirationTime = cachedAt.add(Duration(hours: expirationHours));
    return now.isAfter(expirationTime);
  }

  /// Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'imageBytes': imageBytes,
      'width': width,
      'height': height,
      'url': url,
      'contentType': contentType,
      'cachedAt': cachedAt.millisecondsSinceEpoch,
      'cacheVersion': cacheVersion,
    };
  }

  /// Create from Map (for web storage with base64 decoding)
  factory CachedImageData.fromMap(Map<String, dynamic> map) {
    // Handle both base64 string (localStorage) and Uint8List (in-memory)
    final imageBytes = map['imageBytes'] is String 
        ? base64Decode(map['imageBytes'] as String)
        : map['imageBytes'] as Uint8List;
        
    return CachedImageData(
      imageBytes: imageBytes,
      width: map['width'] as int,
      height: map['height'] as int,
      url: map['url'] as String,
      contentType: map['contentType'] as String,
      cachedAt: DateTime.fromMillisecondsSinceEpoch(map['cachedAt'] as int),
      cacheVersion: map['cacheVersion'] as int,
    );
  }
} 