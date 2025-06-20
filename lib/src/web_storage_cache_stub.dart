import 'dart:async';
import 'types.dart';
import 'web_storage_cache.dart';

/// Stub implementation for non-web platforms
class WebStorageCacheStub extends WebStorageCache {
  @override
  Future<CachedImageData?> getCachedImage(String url, WebStorageCacheConfig config) async {
    return null; // No caching on non-web platforms
  }
  
  @override
  Future<bool> cacheImage(ImageDataInfo imageData, String contentType, WebStorageCacheConfig config) async {
    return false; // No caching on non-web platforms
  }
  
  @override
  Future<void> clearCache() async {
    // No-op on non-web platforms
  }
  
  @override
  Future<Map<String, dynamic>> getCacheStats() async {
    return {'enabled': false, 'platform': 'non-web'};
  }
  
  @override
  Future<int> cleanupExpiredEntries({int? customExpirationHours}) async {
    return 0; // No cleanup needed on non-web platforms
  }
}

/// Factory function for non-web platforms
WebStorageCache createWebStorageCache() => WebStorageCacheStub(); 