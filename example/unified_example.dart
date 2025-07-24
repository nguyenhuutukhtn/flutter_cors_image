import 'package:flutter/material.dart';
import 'main.dart' as main_example;
import 'tap_example.dart' as tap_example;
import 'zoom_example.dart' as zoom_example;
import 'context_menu_demo.dart' as context_menu;
import 'simple_usage_example.dart' as advanced_example;
import 'web_storage_cache_demo.dart' as cache_demo;
import 'listview_cache_demo.dart' as listview_demo;
import 'local_file_example.dart' as local_file_example;

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
    _tabController = TabController(length: 8, vsync: this);
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
        ],
      ),
    );
  }
} 