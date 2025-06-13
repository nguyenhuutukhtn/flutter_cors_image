import 'package:flutter/material.dart';
import 'package:flutter_cors_image/flutter_cors_image.dart';

/// Demo showing the right-click context menu functionality
/// This feature only works on web platforms
void main() {
  runApp(const ContextMenuDemoApp());
}

class ContextMenuDemoApp extends StatelessWidget {
  const ContextMenuDemoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Context Menu Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ContextMenuDemoPage(),
    );
  }
}

class ContextMenuDemoPage extends StatefulWidget {
  const ContextMenuDemoPage({Key? key}) : super(key: key);

  @override
  State<ContextMenuDemoPage> createState() => _ContextMenuDemoPageState();
}

class _ContextMenuDemoPageState extends State<ContextMenuDemoPage> {
  String _lastAction = 'None';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Right-Click Context Menu Demo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Right-click on the images below to see the context menu:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // Basic context menu example
            const Text('1. Default Context Menu:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            CustomNetworkImage(
              url: 'https://picsum.photos/300/200?random=1',
              width: 300,
              height: 200,
              enableContextMenu: true,
              onContextMenuAction: (action) {
                setState(() {
                  _lastAction = action.toString().split('.').last;
                });
                
                // Show feedback
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Context menu action: ${action.toString().split('.').last}'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 20),
            
            // Custom context menu example
            const Text('2. Custom Context Menu:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            CustomNetworkImage(
              url: 'https://picsum.photos/300/200?random=2',
              width: 300,
              height: 200,
              enableContextMenu: true,
              customContextMenuItems: [
                ContextMenuItem(
                  title: 'Download Image',
                  icon: Icons.download,
                  action: ContextMenuAction.saveImage,
                ),
                ContextMenuItem(
                  title: 'Copy to Clipboard',
                  icon: Icons.copy,
                  action: ContextMenuAction.copyImage,
                ),
                ContextMenuItem(
                  title: 'Custom Action',
                  icon: Icons.star,
                  action: ContextMenuAction.custom,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Custom action executed!')),
                    );
                  },
                ),
              ],
              contextMenuBackgroundColor: Colors.grey[800],
              contextMenuTextColor: Colors.white,
              onContextMenuAction: (action) {
                setState(() {
                  _lastAction = action.toString().split('.').last;
                });
              },
            ),
            
            const SizedBox(height: 20),
            
            // Context menu disabled example
            const Text('3. Context Menu Disabled:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            CustomNetworkImage(
              url: 'https://picsum.photos/300/200?random=3',
              width: 300,
              height: 200,
              enableContextMenu: false, // Context menu disabled
            ),
            
            const SizedBox(height: 30),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Last Action Performed:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _lastAction,
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber[200]!),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.orange),
                      SizedBox(width: 8),
                      Text(
                        'Note:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Right-click context menu only works on web platforms\n'
                    '• Context menu appears only when images load successfully via Flutter\n'
                    '• When images fall back to HTML, they use browser\'s native context menu\n'
                    '• Browser\'s default context menu is prevented only when hovering over images\n'
                    '• Normal browser context menu works everywhere else (text, links, etc.)\n'
                    '• You can customize menu items, colors, and actions',
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