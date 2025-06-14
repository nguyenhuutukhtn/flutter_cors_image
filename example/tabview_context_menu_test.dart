import 'package:flutter/material.dart';
import 'package:flutter_cors_image/flutter_cors_image.dart';

/// Focused test for context menu in TabView
void main() {
  runApp(const TabViewContextMenuTestApp());
}

class TabViewContextMenuTestApp extends StatelessWidget {
  const TabViewContextMenuTestApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TabView Context Menu Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const TabViewContextMenuTestScreen(),
    );
  }
}

class TabViewContextMenuTestScreen extends StatefulWidget {
  const TabViewContextMenuTestScreen({Key? key}) : super(key: key);

  @override
  State<TabViewContextMenuTestScreen> createState() => _TabViewContextMenuTestScreenState();
}

class _TabViewContextMenuTestScreenState extends State<TabViewContextMenuTestScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _lastAction = 'None';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        title: const Text('TabView Context Menu Test'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.image), text: 'Tab 1'),
            Tab(icon: Icon(Icons.photo), text: 'Tab 2'),
            Tab(icon: Icon(Icons.picture_in_picture), text: 'Tab 3'),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue[50],
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Test Instructions:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                      const Text(
                        'Right-click on images in each tab. Browser\'s default context menu should NOT appear, only our custom menu.',
                        style: TextStyle(fontSize: 12),
                      ),
                      Text(
                        'Last Action: $_lastAction',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTabContent('Tab 1', 'https://picsum.photos/300/200?random=1'),
                _buildTabContent('Tab 2', 'https://picsum.photos/300/200?random=2'),
                _buildTabContent('Tab 3', 'https://picsum.photos/300/200?random=3'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(String tabName, String imageUrl) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '$tabName - Context Menu Test',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          
          Text(
            'Right-click the image below:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 10),
          
          // Test image with context menu
          CustomNetworkImage(
            url: imageUrl,
            width: 300,
            height: 200,
            enableContextMenu: true,
            onContextMenuAction: (action) {
              setState(() {
                _lastAction = '$tabName: ${action.toString().split('.').last}';
              });
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$tabName - Context menu action: ${action.toString().split('.').last}'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          
          const SizedBox(height: 20),
          
          // Test with custom menu items
          Text(
            'Custom Context Menu:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 10),
          
          CustomNetworkImage(
            url: imageUrl.replaceAll('random=', 'random=custom'),
            width: 250,
            height: 150,
            enableContextMenu: true,
            customContextMenuItems: [
              ContextMenuItem(
                title: '$tabName Action',
                icon: Icons.star,
                action: ContextMenuAction.custom,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Custom action from $tabName')),
                  );
                },
              ),
              const ContextMenuItem(
                title: 'Download',
                icon: Icons.download,
                action: ContextMenuAction.saveImage,
              ),
            ],
            contextMenuBackgroundColor: Colors.grey[800],
            contextMenuTextColor: Colors.white,
            onContextMenuAction: (action) {
              setState(() {
                _lastAction = '$tabName Custom: ${action.toString().split('.').last}';
              });
            },
          ),
          
          const SizedBox(height: 20),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$tabName Status:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  '✅ Context menu should work in this tab\n'
                  '❌ Browser default menu should NOT appear\n'
                  '🔄 Try switching tabs and test again',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 