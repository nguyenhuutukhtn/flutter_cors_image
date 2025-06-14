import 'package:flutter/material.dart';
import 'package:flutter_cors_image/flutter_cors_image.dart';

/// Simple test to debug context menu prevention
void main() {
  runApp(const SimpleContextMenuTestApp());
}

class SimpleContextMenuTestApp extends StatelessWidget {
  const SimpleContextMenuTestApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Context Menu Test',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SimpleContextMenuTestScreen(),
    );
  }
}

class SimpleContextMenuTestScreen extends StatefulWidget {
  const SimpleContextMenuTestScreen({Key? key}) : super(key: key);

  @override
  State<SimpleContextMenuTestScreen> createState() => _SimpleContextMenuTestScreenState();
}

class _SimpleContextMenuTestScreenState extends State<SimpleContextMenuTestScreen> {
  String _lastAction = 'None';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Context Menu Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.red[50],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🔍 DEBUG TEST',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Right-click on the image below. Check browser console for debug logs.',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Expected: Only custom Flutter menu, NO browser menu',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Last Action: $_lastAction',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            const Text(
              'Test Image with Context Menu:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            
            // Simple test image
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomNetworkImage(
                url: 'https://picsum.photos/400/300?random=1',
                width: 400,
                height: 300,
                enableContextMenu: true,
                onContextMenuAction: (action) {
                  setState(() {
                    _lastAction = action.toString().split('.').last;
                  });
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Context menu action: ${action.toString().split('.').last}'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.blue[50],
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📋 Test Instructions:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('1. Right-click on the image above'),
                  Text('2. Check browser console for debug logs'),
                  Text('3. Verify only Flutter menu appears (no browser menu)'),
                  Text('4. Try right-clicking on this text (should show browser menu)'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 