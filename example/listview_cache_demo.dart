import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cors_image/flutter_cors_image.dart';

class ListViewCacheDemoPage extends StatefulWidget {
  const ListViewCacheDemoPage({Key? key}) : super(key: key);

  @override
  State<ListViewCacheDemoPage> createState() => _ListViewCacheDemoPageState();
}

class _ListViewCacheDemoPageState extends State<ListViewCacheDemoPage> {
  Map<String, dynamic> _cacheStats = {};
  bool _cacheEnabled = true;
  int _cacheExpirationHours = 168; // 7 days
  int _maxCacheSizeMB = 100; // 100MB for demo
  
  // Generate a long list of images for ListView testing
  List<String> get _longImageList {
    List<String> longList = [];
    
    // Add Picsum photos with different IDs
    for (int i = 1; i <= 50; i++) {
      longList.add('https://picsum.photos/400/300?random=$i');
    }
    
    // Add some Unsplash images
    final unsplashIds = [
      '1506905925346-21bda4d32df4',
      '1518837695005-2083093ee35b', 
      '1501594907352-04cda38ebc29',
      '1472214103451-9374bd1c798e',
      '1441974231531-c6227db76b6e',
      '1469474968028-56623f02e42e',
      '1470071459604-8b5ce755e9c7',
      '1441716844420-e7f8e2e0e1a3',
      '1449824913935-59a10b8d2000',
      '1470225620780-dbd8e8cbb6d4',
    ];
    
    for (int i = 0; i < unsplashIds.length; i++) {
      longList.add('https://images.unsplash.com/photo-${unsplashIds[i]}?w=400&h=300&fit=crop');
    }
    
    return longList;
  }

  @override
  void initState() {
    super.initState();
    _loadCacheStats();
  }

  Future<void> _loadCacheStats() async {
    try {
      final stats = await WebStorageCache.instance.getCacheStats();
      if (mounted) {
        setState(() {
          _cacheStats = stats;
        });
      }
    } catch (e) {
      print('Error loading cache stats: $e');
    }
  }

  Future<void> _clearCache() async {
    try {
      await WebStorageCache.instance.clearCache();
      await _loadCacheStats();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cache cleared successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error clearing cache: $e')),
        );
      }
    }
  }

  WebStorageCacheConfig get _currentConfig => WebStorageCacheConfig(
    enabled: _cacheEnabled,
    cacheExpirationHours: _cacheExpirationHours,
    maxCacheSize: _maxCacheSizeMB * 1024 * 1024, // Convert MB to bytes
  );

  @override
  Widget build(BuildContext context) {
    final longList = _longImageList;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('ListView Cache Test'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Header
          Container(
            color: Colors.green.shade50,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'ListView Performance Test (${longList.length} images)',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                const Text('Scroll up/down rapidly to test caching performance'),
              ],
            ),
          ),
          
          // ListView
          Expanded(
            child: ListView.builder(
              itemCount: longList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: SizedBox(
                    width: 80,
                    height: 60,
                    child: CustomNetworkImage(
                      url: longList[index],
                      fit: BoxFit.cover,
                      webStorageCacheConfig: const WebStorageCacheConfig(
                        enabled: true,
                        maxCacheSize: 100 * 1024 * 1024, // 100MB
                      ),
                    ),
                  ),
                  title: Text('Image #${index + 1}'),
                  subtitle: Text(longList[index], maxLines: 1, overflow: TextOverflow.ellipsis),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 