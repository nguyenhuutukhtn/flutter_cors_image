import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cors_image/flutter_cors_image.dart';

class WebStorageCacheDemoPage extends StatefulWidget {
  const WebStorageCacheDemoPage({Key? key}) : super(key: key);

  @override
  State<WebStorageCacheDemoPage> createState() => _WebStorageCacheDemoPageState();
}

class _WebStorageCacheDemoPageState extends State<WebStorageCacheDemoPage> with TickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic> _cacheStats = {};
  bool _cacheEnabled = true;
  int _cacheExpirationHours = 168; // 7 days
  int _maxCacheSizeMB = 50; // 50MB for demo
  
  // Sample images for testing
  final List<String> _sampleImages = [
    'https://picsum.photos/300/200?random=1',
    'https://picsum.photos/300/200?random=2',
    'https://picsum.photos/300/200?random=3',
    'https://picsum.photos/300/200?random=4',
    'https://picsum.photos/300/200?random=5',
    'https://picsum.photos/300/200?random=6',
    'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=300&h=200&fit=crop',
    'https://images.unsplash.com/photo-1518837695005-2083093ee35b?w=300&h=200&fit=crop',
    'https://images.unsplash.com/photo-1501594907352-04cda38ebc29?w=300&h=200&fit=crop',
    'https://images.unsplash.com/photo-1472214103451-9374bd1c798e?w=300&h=200&fit=crop',
  ];

  // Generate a long list of images for ListView testing
  List<String> get _longImageList {
    List<String> longList = [];
    for (int i = 1; i <= 100; i++) {
      longList.add('https://picsum.photos/400/300?random=$i');
    }
    // Add some Unsplash images with different sizes
    for (int i = 1; i <= 20; i++) {
      longList.add('https://images.unsplash.com/photo-150${i.toString().padLeft(2, '0')}594907352-04cda38ebc29?w=400&h=300&fit=crop&random=$i');
    }
    return longList;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadCacheStats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('IndexedDB Cache Demo'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Grid', icon: Icon(Icons.grid_view)),
            Tab(text: 'ListView', icon: Icon(Icons.list)),
            Tab(text: 'Config', icon: Icon(Icons.settings)),
            Tab(text: 'Stats', icon: Icon(Icons.analytics)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGridView(),
          _buildListView(),
          _buildConfigView(),
          _buildStatsView(),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Instructions
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Grid View Test',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Scroll through the images below to load them\n'
                    '• Refresh the page (F5) and scroll again\n'
                    '• Notice images load instantly from IndexedDB cache\n'
                    '• Check Network tab - no requests after refresh!',
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Sample Images Grid
          Text(
            'Sample Images (${_sampleImages.length})',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _sampleImages.length,
            itemBuilder: (context, index) {
              return Card(
                clipBehavior: Clip.antiAlias,
                child: CustomNetworkImage(
                  url: _sampleImages[index],
                  fit: BoxFit.cover,
                  webStorageCacheConfig: _currentConfig,
                  customLoadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey.shade200,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 8),
                            Text(
                              loadingProgress.progress != null 
                                ? '${(loadingProgress.progress! * 100).toInt()}%'
                                : 'Loading...',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  errorWidget: Container(
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error, color: Colors.red),
                          SizedBox(height: 4),
                          Text('Failed to load', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  onImageLoaded: (imageData) {
                    // Refresh stats when image is loaded and cached
                    Future.delayed(const Duration(milliseconds: 100), _loadCacheStats);
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    final longList = _longImageList;
    
    return Column(
      children: [
        // Instructions
        Container(
          width: double.infinity,
          color: Colors.orange.shade50,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.speed, color: Colors.orange.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'ListView Scrolling Test (${longList.length} images)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                '🚀 ORIGINAL PROBLEM: ListView scrolling caused repeated server requests\n'
                '✅ SOLUTION: IndexedDB caching prevents server stress during scrolling\n'
                '📊 TEST: Scroll up/down rapidly - images load from cache instantly!',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        
        // ListView with long list of images
        Expanded(
          child: ListView.builder(
            itemCount: longList.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                height: 200,
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: Row(
                    children: [
                      // Image
                      SizedBox(
                        width: 250,
                        child: CustomNetworkImage(
                          url: longList[index],
                          fit: BoxFit.cover,
                          webStorageCacheConfig: _currentConfig,
                          customLoadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey.shade100,
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        value: loadingProgress.progress,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      loadingProgress.progress != null 
                                        ? '${(loadingProgress.progress! * 100).toInt()}%'
                                        : 'Loading...',
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          errorWidget: Container(
                            color: Colors.grey.shade300,
                            child: const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.error, color: Colors.red, size: 20),
                                  SizedBox(height: 4),
                                  Text('Error', style: TextStyle(fontSize: 10)),
                                ],
                              ),
                            ),
                          ),
                          onImageLoaded: (imageData) {
                            // Refresh stats when image is loaded and cached
                            Future.delayed(const Duration(milliseconds: 500), _loadCacheStats);
                          },
                        ),
                      ),
                      
                      // Content
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Image #${index + 1}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'URL: ${longList[index]}',
                                style: Theme.of(context).textTheme.bodySmall,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Cached in IndexedDB',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildConfigView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Platform Info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Platform Information',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Platform: ${kIsWeb ? "Web" : "Mobile"}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    kIsWeb 
                      ? '✅ IndexedDB caching is available on this platform'
                      : '❌ IndexedDB caching is only available on web platforms',
                    style: TextStyle(
                      color: kIsWeb ? Colors.green : Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Cache Configuration
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cache Configuration',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  
                  SwitchListTile(
                    title: const Text('Enable IndexedDB Cache'),
                    subtitle: const Text('Cache images in browser IndexedDB storage'),
                    value: _cacheEnabled,
                    onChanged: (value) {
                      setState(() {
                        _cacheEnabled = value;
                      });
                    },
                  ),
                  
                  const Divider(),
                  
                  Text('Cache Expiration: $_cacheExpirationHours hours'),
                  const SizedBox(height: 8),
                  Slider(
                    value: _cacheExpirationHours.toDouble(),
                    min: 1,
                    max: 720, // 30 days
                    divisions: 20,
                    label: '$_cacheExpirationHours hours (${(_cacheExpirationHours / 24).toStringAsFixed(1)} days)',
                    onChanged: (value) {
                      setState(() {
                        _cacheExpirationHours = value.round();
                      });
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Text('Max Cache Size: $_maxCacheSizeMB MB'),
                  const SizedBox(height: 8),
                  Slider(
                    value: _maxCacheSizeMB.toDouble(),
                    min: 1,
                    max: 200, // 200MB
                    divisions: 20,
                    label: '$_maxCacheSizeMB MB',
                    onChanged: (value) {
                      setState(() {
                        _maxCacheSizeMB = value.round();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Code Example
          Card(
            child: ExpansionTile(
              title: const Text('Code Example'),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey.shade100,
                  child: const Text(
                    '''// Basic usage with IndexedDB caching
CustomNetworkImage(
  url: 'https://example.com/image.jpg',
  webStorageCacheConfig: WebStorageCacheConfig(
    enabled: true,
    cacheExpirationHours: 168, // 7 days
    maxCacheSize: 50 * 1024 * 1024, // 50MB
  ),
  onImageLoaded: (imageData) {
    print('Image cached: \${imageData.url}');
  },
)

// Get cache statistics
final stats = await WebStorageCache.instance.getCacheStats();
print('Cached images: \${stats['count']}');
print('Cache size: \${stats['totalSizeMB']} MB');

// Clear cache
await WebStorageCache.instance.clearCache();''',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cache Stats
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Cache Statistics',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: _loadCacheStats,
                            tooltip: 'Refresh stats',
                          ),
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: _clearCache,
                            tooltip: 'Clear cache',
                            color: Colors.red,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  if (_cacheStats.isNotEmpty) ...[
                    _buildStatRow('Cache Enabled', '${_cacheStats['enabled'] ?? false}', 
                        _cacheStats['enabled'] == true ? Colors.green : Colors.red),
                    if (_cacheStats['enabled'] == true) ...[
                      const SizedBox(height: 8),
                      _buildStatRow('Cached Images', '${_cacheStats['count'] ?? 0}', Colors.blue),
                      const SizedBox(height: 8),
                      _buildStatRow('Total Cache Size', '${_cacheStats['totalSizeMB'] ?? '0'} MB', Colors.purple),
                      const SizedBox(height: 8),
                      _buildStatRow('Storage Platform', '${_cacheStats['platform'] ?? 'unknown'}', Colors.orange),
                      const SizedBox(height: 8),
                      _buildStatRow('Max Cache Size', '${_maxCacheSizeMB} MB', Colors.grey),
                    ],
                  ] else
                    const Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 8),
                          Text('Loading cache statistics...'),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Performance Info
          Card(
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.speed, color: Colors.green.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Performance Benefits',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '✅ Prevents server stress from repeated requests\n'
                    '✅ Instant image loading from IndexedDB cache\n'
                    '✅ Works across browser sessions (persistent)\n'
                    '✅ Automatic cache size management\n'
                    '✅ Configurable expiration times\n'
                    '✅ ListView scrolling performance optimized',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
} 