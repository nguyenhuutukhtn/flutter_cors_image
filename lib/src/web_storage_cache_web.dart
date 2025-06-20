import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';
import 'package:web/web.dart' as web;
import 'package:flutter/foundation.dart';
import 'types.dart';
import 'web_storage_cache.dart';

/// Web implementation using IndexedDB for image caching
class WebStorageCacheWeb extends WebStorageCache {
  static const String _dbName = 'flutter_cors_image_cache';
  static const int _dbVersion = 1;
  static const String _storeName = 'images';
  
  static Completer<web.IDBDatabase>? _dbCompleter;
  static web.IDBDatabase? _db;
  
  // Proactive cleanup timer
  static Timer? _cleanupTimer;
  static const Duration _cleanupInterval = Duration(minutes: 30); // Run cleanup every hour
  
  /// Initialize IndexedDB database
  Future<web.IDBDatabase> _initDB() async {
    if (_db != null) return _db!;
    
    if (_dbCompleter != null) {
      return _dbCompleter!.future;
    }
    
    _dbCompleter = Completer<web.IDBDatabase>();
    
    try {
      final request = web.window.indexedDB!.open(_dbName, _dbVersion);
      
      request.onupgradeneeded = (web.IDBVersionChangeEvent event) {
        final db = (event.target as web.IDBOpenDBRequest).result as web.IDBDatabase;
        
        // Create object store if it doesn't exist
        if (!db.objectStoreNames.contains(_storeName)) {
          final store = db.createObjectStore(_storeName, web.IDBObjectStoreParameters(keyPath: 'url'.toJS));
          
          // Create index for cache management (by timestamp)
          store.createIndex('cachedAt', 'cachedAt'.toJS);
        }
      }.toJS;
      
      request.onsuccess = (web.Event event) {
        _db = (event.target as web.IDBOpenDBRequest).result as web.IDBDatabase;
        _dbCompleter!.complete(_db!);
        
        // Start proactive cleanup timer when DB is ready
        _startProactiveCleanup();
      }.toJS;
      
      request.onerror = (web.Event event) {
        _dbCompleter!.completeError('Failed to open IndexedDB: ${request.error}');
        _dbCompleter = null;
      }.toJS;
      
      return _dbCompleter!.future;
    } catch (e) {
      _dbCompleter!.completeError('IndexedDB initialization error: $e');
      _dbCompleter = null;
      rethrow;
    }
  }
  
  @override
  Future<CachedImageData?> getCachedImage(String url, WebStorageCacheConfig config) async {
    if (!kIsWeb || !config.enabled) return null;
    
    try {
      final db = await _initDB();
      final transaction = db.transaction(_storeName.toJS, 'readonly');
      final store = transaction.objectStore(_storeName);
      
      final completer = Completer<CachedImageData?>();
      final request = store.get(url.toJS);
      
      request.onsuccess = (web.Event event) {
        final result = (event.target as web.IDBRequest).result;
        
        if (result != null && !result.isUndefinedOrNull) {
          try {
            final jsResult = result as JSObject;
            final cachedData = _jsObjectToCachedImageData(jsResult);
            
            // Check if cache is expired or wrong version
            if (cachedData.isExpired(config.cacheExpirationHours) || 
                cachedData.cacheVersion != config.cacheVersion) {
              // Delete expired/invalid cache entry
              _deleteCachedImage(url);
              completer.complete(null);
            } else {
              completer.complete(cachedData);
            }
          } catch (e) {
            completer.complete(null);
          }
        } else {
          completer.complete(null);
        }
      }.toJS;
      
      request.onerror = (web.Event event) {
        completer.complete(null);
      }.toJS;
      
      return completer.future;
    } catch (e) {
      return null;
    }
  }
  
  @override
  Future<bool> cacheImage(ImageDataInfo imageData, String contentType, WebStorageCacheConfig config) async {
    if (!kIsWeb || !config.enabled) return false;
    
    try {
      final db = await _initDB();
      
      // Check cache size before adding
      final currentSize = await _getCurrentCacheSize();
      if (currentSize + imageData.imageBytes.length > config.maxCacheSize) {
        // Clean up old entries to make space
        await _cleanupOldEntries(config.maxCacheSize - imageData.imageBytes.length);
      }
      
      final cachedData = CachedImageData(
        imageBytes: imageData.imageBytes,
        width: imageData.width,
        height: imageData.height,
        url: imageData.url,
        contentType: contentType,
        cachedAt: DateTime.now(),
        cacheVersion: config.cacheVersion,
      );
      
      final transaction = db.transaction(_storeName.toJS, 'readwrite');
      final store = transaction.objectStore(_storeName);
      
      final completer = Completer<bool>();
      final request = store.put(_cachedImageDataToJSObject(cachedData));
      
      request.onsuccess = (web.Event event) {
        completer.complete(true);
      }.toJS;
      
      request.onerror = (web.Event event) {
        completer.complete(false);
      }.toJS;
      
      return completer.future;
    } catch (e) {
      return false;
    }
  }
  
  @override
  Future<void> clearCache() async {
    if (!kIsWeb) return;
    
    try {
      final db = await _initDB();
      final transaction = db.transaction(_storeName.toJS, 'readwrite');
      final store = transaction.objectStore(_storeName);
      
      final completer = Completer<void>();
      final request = store.clear();
      
      request.onsuccess = (web.Event event) {
        completer.complete();
      }.toJS;
      
      request.onerror = (web.Event event) {
        completer.complete();
      }.toJS;
      
      return completer.future;
    } catch (e) {
      // Ignore clear errors
    }
  }
  
  @override
  Future<Map<String, dynamic>> getCacheStats() async {
    if (!kIsWeb) return {'enabled': false};
    
    try {
      final db = await _initDB();
      final transaction = db.transaction(_storeName.toJS, 'readonly');
      final store = transaction.objectStore(_storeName);
      
      final completer = Completer<Map<String, dynamic>>();
      final request = store.getAll();
      
      request.onsuccess = (web.Event event) {
        final results = (event.target as web.IDBRequest).result as JSArray;
        int totalSize = 0;
        int count = results.length.toInt();
        
        for (int i = 0; i < count; i++) {
          final item = results[i] as JSObject;
          final imageBytes = item.getProperty('imageBytes'.toJS) as JSUint8Array;
          totalSize += imageBytes.toDart.length;
        }
        
        completer.complete({
          'enabled': true,
          'count': count,
          'totalSize': totalSize,
          'totalSizeMB': (totalSize / (1024 * 1024)).toStringAsFixed(2),
          'platform': 'web-IndexedDB',
        });
      }.toJS;
      
      request.onerror = (web.Event event) {
        completer.complete({'enabled': false});
      }.toJS;
      
      return completer.future;
    } catch (e) {
      return {'enabled': false};
    }
  }
  
  /// Delete cached image by URL
  Future<void> _deleteCachedImage(String url) async {
    try {
      final db = await _initDB();
      final transaction = db.transaction(_storeName.toJS, 'readwrite');
      final store = transaction.objectStore(_storeName);
      store.delete(url.toJS);
    } catch (e) {
      // Ignore delete errors
    }
  }
  
  /// Get current cache size in bytes
  Future<int> _getCurrentCacheSize() async {
    try {
      final db = await _initDB();
      final transaction = db.transaction(_storeName.toJS, 'readonly');
      final store = transaction.objectStore(_storeName);
      
      final completer = Completer<int>();
      final request = store.getAll();
      
      request.onsuccess = (web.Event event) {
        final results = (event.target as web.IDBRequest).result as JSArray;
        int totalSize = 0;
        final count = results.length.toInt();
        
        for (int i = 0; i < count; i++) {
          final item = results[i] as JSObject;
          final imageBytes = item.getProperty('imageBytes'.toJS) as JSUint8Array;
          totalSize += imageBytes.toDart.length;
        }
        
        completer.complete(totalSize);
      }.toJS;
      
      request.onerror = (web.Event event) {
        completer.complete(0);
      }.toJS;
      
      return completer.future;
    } catch (e) {
      return 0;
    }
  }
  
  /// Clean up old cache entries to make space
  Future<void> _cleanupOldEntries(int targetFreeSpace) async {
    try {
      final db = await _initDB();
      final transaction = db.transaction(_storeName.toJS, 'readwrite');
      final store = transaction.objectStore(_storeName);
      final index = store.index('cachedAt');
      
      final completer = Completer<void>();
      final request = index.openCursor();
      
      int freedSpace = 0;
      
      request.onsuccess = (web.Event event) {
        final cursor = (event.target as web.IDBRequest).result as web.IDBCursorWithValue?;
        
        if (cursor != null && freedSpace < targetFreeSpace) {
          final data = cursor.value as JSObject;
          final imageBytes = data.getProperty('imageBytes'.toJS) as JSUint8Array;
          
          freedSpace += imageBytes.toDart.length;
          cursor.delete();
          cursor.continue_();
        } else {
          completer.complete();
        }
      }.toJS;
      
      request.onerror = (web.Event event) {
        completer.complete();
      }.toJS;
      
      return completer.future;
    } catch (e) {
      // Ignore cleanup errors
    }
  }
  
  /// Convert JSObject to CachedImageData
  CachedImageData _jsObjectToCachedImageData(JSObject jsObject) {
    final imageBytes = jsObject.getProperty('imageBytes'.toJS) as JSUint8Array;
    final width = (jsObject.getProperty('width'.toJS) as JSNumber).toDartInt;
    final height = (jsObject.getProperty('height'.toJS) as JSNumber).toDartInt;
    final url = (jsObject.getProperty('url'.toJS) as JSString).toDart;
    final contentType = (jsObject.getProperty('contentType'.toJS) as JSString).toDart;
    final cachedAt = DateTime.fromMillisecondsSinceEpoch(
      (jsObject.getProperty('cachedAt'.toJS) as JSNumber).toDartInt
    );
    final cacheVersion = (jsObject.getProperty('cacheVersion'.toJS) as JSNumber).toDartInt;
    
    // Convert JSUint8Array to Uint8List using toDart extension
    final dartBytes = imageBytes.toDart;
    
    return CachedImageData(
      imageBytes: dartBytes,
      width: width,
      height: height,
      url: url,
      contentType: contentType,
      cachedAt: cachedAt,
      cacheVersion: cacheVersion,
    );
  }
  
  /// Convert CachedImageData to JSObject for IndexedDB storage
  JSObject _cachedImageDataToJSObject(CachedImageData data) {
    final jsObject = JSObject();
    
    // Convert Uint8List to JSUint8Array
    final jsBytes = data.imageBytes.toJS;
    
    jsObject.setProperty('url'.toJS, data.url.toJS);
    jsObject.setProperty('imageBytes'.toJS, jsBytes);
    jsObject.setProperty('width'.toJS, data.width.toJS);
    jsObject.setProperty('height'.toJS, data.height.toJS);
    jsObject.setProperty('contentType'.toJS, data.contentType.toJS);
    jsObject.setProperty('cachedAt'.toJS, data.cachedAt.millisecondsSinceEpoch.toJS);
    jsObject.setProperty('cacheVersion'.toJS, data.cacheVersion.toJS);
    
    return jsObject;
  }
  
  /// Start proactive cleanup timer to automatically remove expired entries
  static void _startProactiveCleanup() {
    // Cancel existing timer if any
    _cleanupTimer?.cancel();
    
    // Start periodic cleanup
    _cleanupTimer = Timer.periodic(_cleanupInterval, (timer) {
      _performProactiveCleanup();
    });
    
    // Also run cleanup immediately
    _performProactiveCleanup();
  }
  
  /// Perform proactive cleanup of expired entries
  static void _performProactiveCleanup() async {
    if (!kIsWeb || _db == null) return;
    
    try {
      final transaction = _db!.transaction(_storeName.toJS, 'readwrite');
      final store = transaction.objectStore(_storeName);
      final request = store.getAll();
      
      request.onsuccess = (web.Event event) {
        final results = (event.target as web.IDBRequest).result as JSArray;
        final now = DateTime.now();
        
        for (int i = 0; i < results.length.toInt(); i++) {
          final item = results[i] as JSObject;
          final cachedAtMs = (item.getProperty('cachedAt'.toJS) as JSNumber).toDartInt;
          final cacheVersion = (item.getProperty('cacheVersion'.toJS) as JSNumber).toDartInt;
          final url = (item.getProperty('url'.toJS) as JSString).toDart;
          
          final cachedAt = DateTime.fromMillisecondsSinceEpoch(cachedAtMs);
          
          // Check if expired (using default 7 days expiration for proactive cleanup)
          final isExpired = now.difference(cachedAt).inHours > 168; // 7 days
          
          // Check if old cache version (cleanup old versions)
          final isOldVersion = cacheVersion < 1; // Current version is 1
          
          if (isExpired || isOldVersion) {
            // Delete expired/old version entry
            final deleteTransaction = _db!.transaction(_storeName.toJS, 'readwrite');
            final deleteStore = deleteTransaction.objectStore(_storeName);
            deleteStore.delete(url.toJS);
            
            if (kDebugMode) {
              print('[WebStorageCache] 🧹 Cleaned up ${isExpired ? 'expired' : 'old version'} cache entry: $url');
            }
          }
        }
      }.toJS;
      
      request.onerror = (web.Event event) {
        // Ignore cleanup errors
      }.toJS;
    } catch (e) {
      // Ignore cleanup errors
      if (kDebugMode) {
        print('[WebStorageCache] Proactive cleanup error: $e');
      }
    }
  }
  
  /// Stop proactive cleanup (useful for testing or disposal)
  static void stopProactiveCleanup() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
  }
  
  @override
  Future<int> cleanupExpiredEntries({int? customExpirationHours}) async {
    if (!kIsWeb) return 0;
    
    try {
      final db = await _initDB();
      final transaction = db.transaction(_storeName.toJS, 'readwrite');
      final store = transaction.objectStore(_storeName);
      
      final completer = Completer<int>();
      final request = store.getAll();
      
      request.onsuccess = (web.Event event) async {
        final results = (event.target as web.IDBRequest).result as JSArray;
        final now = DateTime.now();
        final expirationHours = customExpirationHours ?? 168; // Default 7 days
        int cleanedCount = 0;
        
        for (int i = 0; i < results.length.toInt(); i++) {
          final item = results[i] as JSObject;
          final cachedAtMs = (item.getProperty('cachedAt'.toJS) as JSNumber).toDartInt;
          final cacheVersion = (item.getProperty('cacheVersion'.toJS) as JSNumber).toDartInt;
          final url = (item.getProperty('url'.toJS) as JSString).toDart;
          
          final cachedAt = DateTime.fromMillisecondsSinceEpoch(cachedAtMs);
          
          // Check if expired
          final isExpired = now.difference(cachedAt).inHours > expirationHours;
          
          // Check if old cache version
          final isOldVersion = cacheVersion < 1; // Current version is 1
          
          if (isExpired || isOldVersion) {
            // Delete expired/old version entry
            final deleteTransaction = db.transaction(_storeName.toJS, 'readwrite');
            final deleteStore = deleteTransaction.objectStore(_storeName);
            deleteStore.delete(url.toJS);
            cleanedCount++;
            
            if (kDebugMode) {
              print('[WebStorageCache] 🧹 Manual cleanup: ${isExpired ? 'expired' : 'old version'} cache entry: $url');
            }
          }
        }
        
        completer.complete(cleanedCount);
      }.toJS;
      
      request.onerror = (web.Event event) {
        completer.complete(0);
      }.toJS;
      
      return completer.future;
    } catch (e) {
      if (kDebugMode) {
        print('[WebStorageCache] Manual cleanup error: $e');
      }
      return 0;
    }
  }
}

/// Factory function for web platforms
WebStorageCache createWebStorageCache() => WebStorageCacheWeb(); 