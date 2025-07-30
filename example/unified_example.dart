import 'package:flutter/material.dart';
import 'main.dart' as main_example;
import 'tap_example.dart' as tap_example;
import 'zoom_example.dart' as zoom_example;
import 'context_menu_demo.dart' as context_menu;
import 'simple_usage_example.dart' as advanced_example;
import 'web_storage_cache_demo.dart' as cache_demo;
import 'listview_cache_demo.dart' as listview_demo;
import 'local_file_example.dart' as local_file_example;
import 'package:flutter_cors_image/flutter_cors_image.dart';

void main() {
  runApp(const UnifiedExampleApp());
}

class UnifiedExampleApp extends StatelessWidget {
  const UnifiedExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter CORS Image - Complete Examples',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const UnifiedExampleScreen(),
    );
  }
}

class UnifiedExampleScreen extends StatefulWidget {
  const UnifiedExampleScreen({Key? key}) : super(key: key);

  @override
  State<UnifiedExampleScreen> createState() => _UnifiedExampleScreenState();
}

class _UnifiedExampleScreenState extends State<UnifiedExampleScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 9, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter CORS Image - Complete Examples'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.home), text: 'Basic Usage'),
            Tab(icon: Icon(Icons.touch_app), text: 'Tap Events'),
            Tab(icon: Icon(Icons.zoom_in), text: 'Zoom Support'),
            Tab(icon: Icon(Icons.menu), text: 'Context Menu'),
            Tab(icon: Icon(Icons.storage), text: 'Web Cache'),
            Tab(icon: Icon(Icons.list), text: 'ListView Test'),
            Tab(icon: Icon(Icons.folder), text: 'Local Files'),
            Tab(icon: Icon(Icons.settings), text: 'Advanced'),
            Tab(icon: Icon(Icons.bug_report), text: 'Bug Tests'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          main_example.ExampleScreen(),
          tap_example.TapExampleScreen(),
          zoom_example.ZoomExampleScreen(),
          context_menu.ContextMenuDemoPage(),
          cache_demo.WebStorageCacheDemoPage(),
          listview_demo.ListViewCacheDemoPage(),
          local_file_example.LocalFileExampleScreen(),
          advanced_example.ComprehensiveImageExample(),
          BugTestScreen(),
        ],
      ),
    );
  }
}

/// Screen to test the two identified bugs:
/// 1. GIF images cannot load
/// 2. HTML fallback styling doesn't match Flutter styling
class BugTestScreen extends StatefulWidget {
  const BugTestScreen({Key? key}) : super(key: key);

  @override
  State<BugTestScreen> createState() => _BugTestScreenState();
}

class _BugTestScreenState extends State<BugTestScreen> {
  BoxFit _selectedBoxFit = BoxFit.cover;
  double _borderRadius = 12.0;
  bool _showComparison = false;

  // Test URLs for different scenarios
  final String _gifUrl = 'https://media.giphy.com/media/3oEjI6SIIHBdRxXI40/giphy.gif';
  final String _regularImageUrl = 'https://picsum.photos/400/300?random=1';
  // This URL is more likely to trigger CORS issues and force HTML fallback
  final String _corsImageUrl = 'https://cdn-cs-uat.s3.ap-southeast-1.amazonaws.com/longterm/2025/07/30/media/dbc0c1cbef4d4c9dc95e0bcb022a4a5a';
  // Alternative CORS-triggering URLs if the above doesn't work:
  // final String _corsImageUrl = 'https://www.w3schools.com/css/img_5terre.jpg';
  // final String _corsImageUrl = 'https://httpbin.org/image/jpeg';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Card(
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.bug_report, color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Bug Test Suite',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This tab tests two known bugs:\n'
                      '• Bug 1: GIF images cannot load properly\n'
                      '• Bug 2: HTML fallback styling doesn\'t match Flutter styling',
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Controls
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Test Controls',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // BoxFit selector
                    Text('BoxFit: ${_selectedBoxFit.toString().split('.').last}'),
                    Wrap(
                      spacing: 8,
                      children: BoxFit.values.map((fit) {
                        return ChoiceChip(
                          label: Text(fit.toString().split('.').last),
                          selected: _selectedBoxFit == fit,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedBoxFit = fit);
                            }
                          },
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Border radius slider
                    Text('Border Radius: ${_borderRadius.toStringAsFixed(1)}px'),
                    Slider(
                      value: _borderRadius,
                      min: 0,
                      max: 50,
                      divisions: 50,
                      onChanged: (value) => setState(() => _borderRadius = value),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Show comparison toggle
                    SwitchListTile(
                      title: const Text('Show Flutter vs HTML Comparison'),
                      subtitle: const Text('Compare Flutter Image.network vs CustomNetworkImage HTML fallback'),
                      value: _showComparison,
                      onChanged: (value) => setState(() => _showComparison = value),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Bug 1: GIF Loading Test
            _buildBugTestSection(
              title: 'Bug 1: GIF Loading Issues',
              description: 'GIF images may fail to load due to codec decoding issues',
              color: Colors.orange,
              child: Column(
                children: [
                  _buildImageTestRow(
                    'Animated GIF Test',
                    _gifUrl,
                    expectedIssue: 'May fail to decode animated GIF frames',
                  ),
                  const SizedBox(height: 16),
                  _buildImageTestRow(
                    'Regular Image (Control)',
                    _regularImageUrl,
                    expectedIssue: 'Should work fine',
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Bug 2: HTML Fallback Styling Test
            _buildBugTestSection(
              title: 'Bug 2: HTML Fallback Styling Issues',
              description: 'HTML fallback doesn\'t respect Flutter BoxFit and border radius',
              color: Colors.purple,
              child: Column(
                children: [
                  _buildImageTestRow(
                    'CORS Image (Triggers HTML Fallback)',
                    _corsImageUrl,
                    expectedIssue: 'HTML fallback may ignore BoxFit and border radius',
                  ),
                  
                  if (_showComparison) ...[
                    const SizedBox(height: 24),
                    _buildComparisonSection(),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
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
                          'Testing Instructions',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '1. Test different BoxFit values and observe how they work\n'
                      '2. Adjust border radius to see styling differences\n'
                      '3. Watch for:\n'
                      '   • GIF images failing to load (showing error state)\n'
                      '   • HTML fallback images ignoring BoxFit and border radius\n'
                      '   • Different behavior between Flutter and HTML rendering\n'
                      '4. Check browser developer tools for HTML fallback usage:\n'
                      '   • Look for <div> elements with <img> tags inside\n'
                      '   • HTML fallback images will have "object-fit: contain" hardcoded\n'
                      '5. Try refreshing to see different loading behaviors\n'
                      '6. If CORS image loads normally, try the alternative URLs in comments',
                    ),
                  ],
                ),
              ),
            ),
            
            // Debug info
            Card(
              color: Colors.yellow.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.bug_report, color: Colors.orange.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Debug Info: Why BoxFit May Not Work',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'HTML Fallback Bug Explanation:\n'
                      '• When Flutter image loading fails, the CustomNetworkImage falls back to HTML\n'
                      '• The HTML <img> element uses hardcoded CSS: object-fit: contain;\n'
                      '• This ignores Flutter\'s BoxFit parameter (cover, fill, etc.)\n'
                      '• Border radius is also not applied to the HTML <img> element\n'
                      '• Location: web_image_loader.dart lines 400 & 421\n\n'
                      'To see this bug:\n'
                      '1. The image must fail Flutter loading and use HTML fallback\n'
                      '2. Check browser DevTools for <img> elements with object-fit: contain\n'
                      '3. Try changing BoxFit - HTML version won\'t change its appearance',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBugTestSection({
    required String title,
    required String description,
    required Color color,
    required Widget child,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  color: color,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildImageTestRow(String title, String url, {String? expectedIssue}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (expectedIssue != null) ...[
          const SizedBox(height: 4),
          Text(
            'Expected: $expectedIssue',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(_borderRadius),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_borderRadius),
            child: CustomNetworkImage(
              url: url,
              width: double.infinity,
              height: 200,
              fit: _selectedBoxFit,
              
              // Enhanced error handling to see the bugs clearly
              errorWidget: Container(
                color: Colors.red.shade100,
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, color: Colors.red.shade700, size: 48),
                    const SizedBox(height: 8),
                    Text(
                      'Failed to Load',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'This may be due to the GIF loading bug',
                      style: TextStyle(
                        color: Colors.red.shade600,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              // Custom loading builder
              customLoadingBuilder: (context, child, progress) {
                return Container(
                  color: Colors.grey.shade100,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: progress?.progress,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          progress?.progress != null 
                            ? '${(progress!.progress! * 100).toInt()}%'
                            : 'Loading...',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonSection() {
    return Card(
      color: Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Flutter vs HTML Comparison',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Compare how Flutter Image.network and CustomNetworkImage HTML fallback handle the same styling',
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                // Flutter Image.network
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Flutter Image.network',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue.shade300),
                          borderRadius: BorderRadius.circular(_borderRadius),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(_borderRadius),
                          child: Image.network(
                            _regularImageUrl,
                            width: double.infinity,
                            height: 150,
                            fit: _selectedBoxFit,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.blue.shade100,
                                child: const Center(
                                  child: Text('Flutter Error'),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // CustomNetworkImage (HTML fallback)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CustomNetworkImage (HTML)',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.purple.shade300),
                          borderRadius: BorderRadius.circular(_borderRadius),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(_borderRadius),
                          child: CustomNetworkImage(
                            url: _corsImageUrl, // This should trigger HTML fallback
                            width: double.infinity,
                            height: 150,
                            fit: _selectedBoxFit,
                            errorWidget: Container(
                              color: Colors.purple.shade100,
                              child: const Center(
                                child: Text('Custom Error'),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange.shade700),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Notice: The HTML fallback (right) may not respect the BoxFit and border radius settings like the Flutter version (left)',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 