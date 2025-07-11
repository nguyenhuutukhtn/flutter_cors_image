import 'package:flutter/material.dart';
import 'package:flutter_cors_image/flutter_cors_image.dart';

void main() {
  runApp(const MaterialApp(
    home: ZoomExampleScreen(),
  ));
}

class ZoomExampleScreen extends StatefulWidget {
  const ZoomExampleScreen({Key? key}) : super(key: key);

  @override
  State<ZoomExampleScreen> createState() => _ZoomExampleScreenState();
}

class _ZoomExampleScreenState extends State<ZoomExampleScreen> {
  // Error image that needs HTML fallback
  // static const String errorImageUrl = 'https://cdn-cs-prod.s3.ap-southeast-1.amazonaws.com/20250422/image/57ae968a8a876c76aa04a406f6869cdb';
  static const String errorImageUrl = 'https://cdn-cs-staging.s3.ap-southeast-1.amazonaws.com/cs/2025/07/11/image/5ea36f6065e1868ddd5de38f3b766eda';
  
  // Normal image that should load normally
  static const String normalImageUrl = 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8f/Example_image.svg/600px-Example_image.svg.png';

  // Transformation controllers for each image
  final TransformationController problemImageController = TransformationController();
  final TransformationController normalImageController = TransformationController();

  bool _isZoomedProblem = false;
  bool _isZoomedNormal = false;

  @override
  void dispose() {
    problemImageController.dispose();
    normalImageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zoom Support Example'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Problem Image with Zoom Support',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  height: 300,
                  width: 300,
                  child: MouseRegion(
                    cursor: _isZoomedProblem 
                        ? SystemMouseCursors.zoomOut 
                        : SystemMouseCursors.zoomIn,
                    child: GestureDetector(
                      onTapUp: (details) => _handleZoomToggle(
                        details, 
                        problemImageController, 
                        () => setState(() => _isZoomedProblem = !_isZoomedProblem),
                      ),
                      child: InteractiveViewer(
                        transformationController: problemImageController,
                        minScale: 0.9,
                        maxScale: 4.0,
                        boundaryMargin: const EdgeInsets.all(100),
                        onInteractionEnd: (_) => setState(() {
                          _isZoomedProblem = problemImageController.value != Matrix4.identity();
                        }),
                        child: CustomNetworkImage(
                          url: errorImageUrl,
                          fit: BoxFit.contain,
                          transformationController: problemImageController,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Status: ${_isZoomedProblem ? 'Zoomed' : 'Normal'}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _isZoomedProblem ? Colors.blue : Colors.black,
                    ),
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
                  height: 300,
                  width: 300,
                  child: MouseRegion(
                    cursor: _isZoomedNormal 
                        ? SystemMouseCursors.zoomOut 
                        : SystemMouseCursors.zoomIn,
                    child: GestureDetector(
                      onTapUp: (details) => _handleZoomToggle(
                        details, 
                        normalImageController, 
                        () => setState(() => _isZoomedNormal = !_isZoomedNormal),
                      ),
                      child: InteractiveViewer(
                        transformationController: normalImageController,
                        minScale: 0.9,
                        maxScale: 4.0,
                        boundaryMargin: const EdgeInsets.all(100),
                        onInteractionEnd: (_) => setState(() {
                          _isZoomedNormal = normalImageController.value != Matrix4.identity();
                        }),
                        child: CustomNetworkImage(
                          url: normalImageUrl,
                          fit: BoxFit.contain,
                          transformationController: normalImageController,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Status: ${_isZoomedNormal ? 'Zoomed' : 'Normal'}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _isZoomedNormal ? Colors.blue : Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ImagePreviewExample(),
                      ),
                    );
                  },
                  child: const Text('Open Image Preview Example'),
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
                      Text('Zoom Features:', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('• Works with both normal and problematic images'),
                      Text('• HTML fallback images support pinch zoom'),
                      Text('• Click to zoom in/out at the clicked location'),
                      Text('• Pinch or drag with touch/mouse to interact'),
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

  void _handleZoomToggle(
    TapUpDetails details,
    TransformationController controller,
    VoidCallback onToggle,
  ) {
    if (controller.value != Matrix4.identity()) {
      // Reset to original size
      controller.value = Matrix4.identity();
    } else {
      // Get the tap position
      final RenderBox box = context.findRenderObject() as RenderBox;
      final Offset localPosition = box.globalToLocal(details.globalPosition);
      
      // Calculate the focal point for zooming
      final double centerX = localPosition.dx;
      final double centerY = localPosition.dy;
      
      // Create transformation matrix
      final Matrix4 matrix = Matrix4.identity()
        ..translate(centerX, centerY)
        ..scale(2.0, 2.0)
        ..translate(-centerX, -centerY);
      
      controller.value = matrix;
    }
    onToggle();
  }
} 


class ImagePreviewExample extends StatefulWidget {
  const ImagePreviewExample({Key? key}) : super(key: key);

  @override
  _ImagePreviewExampleState createState() => _ImagePreviewExampleState();
}

class _ImagePreviewExampleState extends State<ImagePreviewExample> {
  final TransformationController controller = TransformationController();
  final CustomNetworkImageController _mainController = CustomNetworkImageController();
  static const String errorImageUrl = 'https://cdn-cs-staging.s3.ap-southeast-1.amazonaws.com/cs/2025/07/11/image/5ea36f6065e1868ddd5de38f3b766eda';

  @override
  void dispose() {
    controller.dispose();
    _mainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Preview Example'),
      ),
      body: _buildExtendedImage(errorImageUrl),
    );
  }

  Widget _buildExtendedImage(dynamic imageData) {
    final Widget image = CustomNetworkImage(
      url: imageData,
      fit: BoxFit.contain,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      filterQuality: FilterQuality.high,
      controller: _mainController,
      enableContextMenu: true,
    );

    return MouseRegion(
      cursor: _isZoomed() ? SystemMouseCursors.zoomOut : SystemMouseCursors.zoomIn,
      child: GestureDetector(
        onTapUp: _handleZoomToggle,
        child: InteractiveViewer(
          transformationController: controller,
          minScale: 0.9,
          maxScale: 4.0,
          boundaryMargin: const EdgeInsets.all(100),
          constrained: false,
          panEnabled: true,
          scaleEnabled: true,
          child: image,
          onInteractionEnd: (details) {
            setState(() {});
          },
        ),
      ),
    );
  }

  bool _isZoomed() {
    return controller.value != Matrix4.identity();
  }

  void _handleZoomToggle(TapUpDetails details) {
    if (_isZoomed()) {
      controller.value = Matrix4.identity();
    } else {
      final RenderBox box = context.findRenderObject() as RenderBox;
      final Offset localPosition = box.globalToLocal(details.globalPosition);
      
      final double centerX = localPosition.dx;
      final double centerY = localPosition.dy;
      
      final Matrix4 matrix = Matrix4.identity()
        ..translate(centerX, centerY)
        ..scale(2.0, 2.0)
        ..translate(-centerX, -centerY);
      
      controller.value = matrix;
    }
    setState(() {});
  }
} 