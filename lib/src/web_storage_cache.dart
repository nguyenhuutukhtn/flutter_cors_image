import 'dart:async';
import 'types.dart';

// Import web libraries conditionally
import 'web_storage_cache_stub.dart' if (dart.library.html) 'web_storage_cache_web.dart';

/// Web storage cache manager interface
abstract class WebStorageCache {
  static WebStorageCache? _instance;
  
  /// Get singleton instance
  static WebStorageCache get instance {
    _instance ??= createWebStorageCache();
    return _instance!;
  }
  
  /// Get cached image data by URL
  Future<CachedImageData?> getCachedImage(String url, WebStorageCacheConfig config);
  
  /// Cache image data
  Future<bool> cacheImage(ImageDataInfo imageData, String contentType, WebStorageCacheConfig config);
  
  /// Clear all cached images
  Future<void> clearCache();
  
  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStats();
  
  /// Clean up expired cache entries manually
  Future<int> cleanupExpiredEntries({int? customExpirationHours});
} 