import 'package:flutter/material.dart';
import 'package:flutter_cors_image/flutter_cors_image.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter CORS Image Example v0.2.0',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const ExampleScreen(),
    );
  }
}

class ExampleScreen extends StatelessWidget {
  const ExampleScreen({Key? key}) : super(key: key);

  // Example of an image that might have CORS issues
  static const String problematicImageUrl = 
    'https://cdn-cs-prod.s3.ap-southeast-1.amazonaws.com/20250422/image/57ae968a8a876c76aa04a406f6869cdb';
  
  // Example of a regular image
  static const String regularImageUrl = 
    'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8f/Example_image.svg/600px-Example_image.svg.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter CORS Image v0.2.0 Examples'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: NEW v0.2.0 - CustomNetworkImage with Widget-based Error Handling
            const Text(
              'NEW v0.2.0: CustomNetworkImage with Widget-based Error Handling',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Uses custom widgets for error, reload, and open URL actions:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Center(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomNetworkImage(
                  url: problematicImageUrl + 'aaaas',
                  width: 300,
                  height: 200,
                  fit: BoxFit.cover,
                  // NEW v0.2.0: Widget-based error handling
                  errorBackgroundColor: Colors.red.shade100, // Custom background color
                  errorWidget: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Custom Error Widget',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  reloadWidget: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Custom Reload',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  openUrlWidget: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.open_in_new, color: Colors.green.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Custom Open URL',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Section 2: Backward Compatibility - Deprecated String Parameters
            const Text(
              'Backward Compatibility: Deprecated String Parameters',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Still works but shows deprecation warnings (will be removed in v1.0.0):',
              style: TextStyle(fontSize: 14, color: Colors.orange),
            ),
            const SizedBox(height: 16),
            Center(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomNetworkImage(
                  // url: problematicImageUrl,
                  url: 'https://example.com/image-with-cors-issues.jpg',
                  width: 300,
                  height: 200,
                  fit: BoxFit.cover,
                  // Custom background for error widget
                  errorBackgroundColor: Colors.orange.shade100,
                  // DEPRECATED: These parameters still work but show warnings
                  errorText: 'Legacy Error Text',
                  reloadText: 'Legacy Reload',
                  openUrlText: 'Legacy Open URL',
                  customLoadingBuilder: (context, child, event) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Section 3: Regular Image for comparison
            const Text(
              'Regular Image (using CustomNetworkImage)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Works with both regular and problematic images:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Center(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomNetworkImage(
                  url: regularImageUrl,
                  width: 300,
                  height: 200,
                  fit: BoxFit.contain,
                  customLoadingBuilder: (context, child, event) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Text('Error loading image'),
                    );
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Section 4: Migration Guide
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Migration Guide v0.1.x → v0.2.0',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'OLD (deprecated):',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.orange.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'CustomNetworkImage(\n'
                      '  url: imageUrl,\n'
                      '  errorText: "Image failed",\n'
                      '  reloadText: "Reload",\n'
                      '  openUrlText: "Open URL",\n'
                      ')',
                      style: TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'NEW (recommended):',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'CustomNetworkImage(\n'
                      '  url: imageUrl,\n'
                      '  errorBackgroundColor: Colors.red.shade100,\n'
                      '  errorWidget: Row(children: [...]),\n'
                      '  reloadWidget: Row(children: [...]),\n'
                      '  openUrlWidget: Row(children: [...]),\n'
                      ')',
                      style: TextStyle(fontFamily: 'monospace'),
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