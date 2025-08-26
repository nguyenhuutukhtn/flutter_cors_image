import 'package:flutter/material.dart';
import 'package:flutter_cors_image/flutter_cors_image.dart';

void main() {
  runApp(const MaterialApp(
    home: TapExampleScreen(),
  ));
}

class TapExampleScreen extends StatefulWidget {
  const TapExampleScreen({Key? key}) : super(key: key);

  @override
  State<TapExampleScreen> createState() => _TapExampleScreenState();
}

class _TapExampleScreenState extends State<TapExampleScreen> {
  // Error image that needs HTML fallback
  static const String errorImageUrl = 'https://cdn-cs-prod.s3.ap-southeast-1.amazonaws.com/20250422/image/57ae968a8a876c76aa04a406f6869cdb';
  
  // Normal image that should load normally
  static const String normalImageUrl = 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8f/Example_image.svg/600px-Example_image.svg.png';

  int normalTapCount = 0;
  int problemTapCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tap Event Example'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Problem Image with Tap Support',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        problemTapCount++;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Problem image tapped! Count: $problemTapCount')),
                      );
                    },
                    child:  CustomNetworkImage(
                      url: errorImageUrl,
                      width: 300,
                      height: 300,
                      onImageLoaded: (imageData) {
                        print('Image loaded: ${imageData.imageBytes?.length} width: ${imageData.width} height: ${imageData.height}');
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Tap count: $problemTapCount',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Normal Image',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        normalTapCount++;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Normal image tapped! Count: $normalTapCount')),
                      );
                    },
                    child: const CustomNetworkImage(
                      url: normalImageUrl,
                      width: 300,
                      height: 300,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Tap count: $normalTapCount',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Using onTap Callback Directly',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomNetworkImage(
                    url: errorImageUrl,
                    width: 300,
                    height: 300,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Using built-in onTap callback!')),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: 300,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('GestureDetector Support:', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('• Works with both normal and problematic images'),
                      Text('• HTML fallback image maintains tap functionality'),
                      Text('• Built-in onTap callback for easier use'),
                      Text('• Cursor changes to pointer on hovering'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 

