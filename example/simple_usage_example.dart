import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_cors_image/flutter_cors_image.dart';
import 'package:flutter_cors_image/src/image_clipboard_helper.dart';
import 'package:flutter_cors_image/src/custom_network_image_controller.dart';
import 'package:flutter_cors_image/src/types.dart';
import 'dart:typed_data';



class ComprehensiveImageExample extends StatefulWidget {
  const ComprehensiveImageExample({super.key});

  @override
  _ComprehensiveImageExampleState createState() => _ComprehensiveImageExampleState();
}

class _ComprehensiveImageExampleState extends State<ComprehensiveImageExample> {
  // NEW: Controllers for external image management
  late CustomNetworkImageController _mainController;
  late CustomNetworkImageController _exampleController;
  late CustomNetworkImageController _gridController1;
  late CustomNetworkImageController _gridController2;
  
  ImageDataInfo? _imageData;
  HoverIconPosition _selectedPosition = HoverIconPosition.topRight;
  HoverIconLayout _selectedLayout = HoverIconLayout.auto;
  bool _enableHoverIcons = true;
  double _iconSpacing = 8.0;
  double _iconPadding = 8.0;
  
  // Controller status tracking
  String _controllerStatus = 'Not initialized';
  String _lastAction = 'None';
  
  @override
  void initState() {
    super.initState();
    
    // Initialize controllers
    _mainController = CustomNetworkImageController();
    _exampleController = CustomNetworkImageController();
    _gridController1 = CustomNetworkImageController();
    _gridController2 = CustomNetworkImageController();
    
    // Listen to main controller changes
    _mainController.addListener(_onControllerStateChanged);
  }
  
  @override
  void dispose() {
    // Dispose controllers
    _mainController.removeListener(_onControllerStateChanged);
    _mainController.dispose();
    _exampleController.dispose();
    _gridController1.dispose();
    _gridController2.dispose();
    super.dispose();
  }
  
  void _onControllerStateChanged() {
    // Use post-frame callback to avoid setState during build
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _controllerStatus = _getControllerStatusText();
          _imageData = _mainController.imageData;
        });
      }
    });
  }
  
  String _getControllerStatusText() {
    if (_mainController.isLoading) {
      final progress = _mainController.loadingProgress;
      if (progress?.progress != null) {
        return 'Loading: ${(progress!.progress! * 100).toInt()}%';
      }
      return 'Loading...';
    } else if (_mainController.isLoaded) {
      return 'Loaded successfully';
    } else if (_mainController.isFailed) {
      return 'Failed: ${_mainController.errorMessage ?? "Unknown error"}';
    }
    return 'Initial state';
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Heavy Image Copy & Clipboard Demo'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // NEW: Heavy Image Info Panel
            _buildHeavyImageInfoPanel(),
            
            const SizedBox(height: 20),
            
            // NEW: Copy Bytes Example
            _buildCopyBytesExample(),
            
            const SizedBox(height: 20),
            
            // Controller Status Panel
            _buildControllerStatusPanel(),
            
            const SizedBox(height: 20),
            
            // Control Panel
            _buildControlPanel(),
            
            const SizedBox(height: 20),
            
            // Main Heavy Image Demo
            _buildHeavyImageDemo(),
            
            const SizedBox(height: 20),
            
            // Controller Actions
            _buildControllerActionsPanel(),
            
            const SizedBox(height: 20),
            
            // Multiple Heavy Controllers Example
            _buildMultipleHeavyControllersExample(),
            
            const SizedBox(height: 20),
            
            // Position Examples Grid
            _buildPositionExamples(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeavyImageInfoPanel() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🏋️ Heavy Image Testing', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            
            const Text('This demo uses high-resolution images (4K-8K) that are several MBs each:'),
            const SizedBox(height: 8),
            const Text('• Main Image: 4K (3840x2160) - ~3-5 MB', style: TextStyle(color: Colors.blue)),
            const Text('• Grid Images: 4K (3840x2160) - ~2-4 MB each', style: TextStyle(color: Colors.green)),
            const Text('• Multiple Controllers: 6K (6000x4000) - ~5-8 MB each', style: TextStyle(color: Colors.purple)),
            const SizedBox(height: 8),
            const Text('💡 This tests clipboard performance with large image data', style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('⚠️ Download and copy operations may take a few seconds due to image size', style: TextStyle(color: Colors.orange)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCopyBytesExample() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📋 Copy Bytes Example', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text('Demonstrates copyImageBytesToClipboard with raw Uint8List data'),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        // Simulate raw image bytes (you would get this from camera, file picker, etc.)
                        if (_imageData != null) {
                          final rawBytes = _imageData!.imageBytes;
                          final width = _imageData!.width;
                          final height = _imageData!.height;
                          
                          print('🔍 DEBUG: Copying raw bytes: ${rawBytes.length} bytes, ${width}x${height}');
                          
                          final success = await ImageClipboardHelper.copyImageBytesToClipboard(
                            rawBytes,
                            width: width,
                            height: height,
                          );
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(success 
                                ? '✅ Raw bytes copied! Size: ${(rawBytes.length / 1024 / 1024).toStringAsFixed(1)} MB'
                                : '❌ Failed to copy raw bytes'),
                              backgroundColor: success ? Colors.green : Colors.red,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('❌ No image data available. Load an image first.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } catch (e) {
                        print('❌ DEBUG: Copy bytes error: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.content_copy),
                    label: const Text('Copy Raw Bytes'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      // Simulate creating custom image bytes (e.g., from canvas or image processing)
                      try {
                        // Create a simple 2x2 pixel PNG manually (minimal example)
                        final customBytes = _createSampleImageBytes();
                        
                        final success = await ImageClipboardHelper.copyImageBytesToClipboard(
                          customBytes,
                          width: 100,
                          height: 100,
                        );
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success 
                              ? '✅ Custom bytes copied! (100x100px sample)'
                              : '❌ Failed to copy custom bytes'),
                            backgroundColor: success ? Colors.green : Colors.red,
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.brush),
                    label: const Text('Copy Custom Bytes'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            const Text(
              'Use copyImageBytesToClipboard() when working with:\n'
              '• Camera captures • File picker results • Image processing output\n'
              '• Canvas drawings • Generated images • Screenshot data',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
  
  // Helper method to create sample image bytes
  Uint8List _createSampleImageBytes() {
    // This is a minimal PNG header + simple image data
    // In real usage, you'd get bytes from camera, file picker, image processing, etc.
    final List<int> pngData = [
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // PNG signature
      // This is a simplified example - in reality you'd have proper PNG data
      // For testing purposes, we'll reuse existing image data if available
    ];
    
    // If we have existing image data, return a portion of it for testing
    if (_imageData != null) {
      return _imageData!.imageBytes.sublist(0, 
        _imageData!.imageBytes.length < 1000 ? _imageData!.imageBytes.length : 1000);
    }
    
    return Uint8List.fromList(pngData);
  }
  
  Widget _buildControllerStatusPanel() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📊 Controller Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status: $_controllerStatus', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('Last Action: $_lastAction'),
                      Text('Has Image Data: ${_mainController.hasImageData}'),
                      Text('Is Loading: ${_mainController.isLoading}'),
                      Text('Is Loaded: ${_mainController.isLoaded}'),
                      Text('Is Failed: ${_mainController.isFailed}'),
                    ],
                  ),
                ),
                if (_imageData != null) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Size: ${_imageData!.width}x${_imageData!.height}'),
                      Text('File Size: ${(_imageData!.imageBytes.length / 1024).toStringAsFixed(1)} KB'),
                    ],
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildControllerActionsPanel() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🎮 Controller Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Control the image externally using the controller', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 12),
            
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    setState(() => _lastAction = 'Reload');
                    _mainController.reload();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reload Image'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                ),
                
                ElevatedButton.icon(
                  onPressed: _mainController.hasImageData ? () async {
                    setState(() => _lastAction = 'Download');
                    try {
                      final success = await _mainController.downloadImage();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success ? '📥 Download initiated!' : '❌ Download failed'),
                          backgroundColor: success ? Colors.green : Colors.red,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                      );
                    }
                  } : null,
                  icon: const Icon(Icons.download),
                  label: const Text('Download'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
                
                ElevatedButton.icon(
                  onPressed: _mainController.hasImageData ? () async {
                    setState(() => _lastAction = 'Copy');
                    try {
                      final success = await _mainController.copyImageToClipboard();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success ? '📋 Copied to clipboard! (Ctrl+V to paste)' : '❌ Copy failed'),
                          backgroundColor: success ? Colors.green : Colors.red,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                      );
                    }
                  } : null,
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
                
                ElevatedButton.icon(
                  onPressed: () async {
                    setState(() => _lastAction = 'Wait for Load');
                    try {
                      final imageData = await _mainController.waitForLoad(timeout: const Duration(seconds: 10));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('✅ Image loaded: ${imageData.width}x${imageData.height}'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Wait failed: $e'), backgroundColor: Colors.red),
                      );
                    }
                  },
                  icon: const Icon(Icons.hourglass_empty),
                  label: const Text('Wait for Load'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMultipleHeavyControllersExample() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🔄 Multiple Heavy Controllers (6K Images)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Ultra-high resolution images with separate controllers', style: TextStyle(color: Colors.grey[600])),
            const Text('⚠️ These are 6K (6000x4000) images - ~5-8 MB each', style: TextStyle(color: Colors.red, fontSize: 12)),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text('Heavy Controller 1', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      AspectRatio(
                        aspectRatio: 1.5,
                        child: CustomNetworkImage(
                          url: 'https://picsum.photos/6000/4000?random=ultra1', // 6K image
                          controller: _gridController1,
                          fit: BoxFit.cover,
                          downloadIcon: const Icon(Icons.download, color: Colors.white, size: 12),
                          copyIcon: const Icon(Icons.copy, color: Colors.white, size: 12),
                          hoverIconPosition: HoverIconPosition.topLeft,
                          hoverIconPadding: const EdgeInsets.all(4),
                          onImageLoaded: (imageData) {
                            print('🔍 DEBUG: Heavy Controller 1 loaded: ${(imageData.imageBytes.length / 1024 / 1024).toStringAsFixed(1)} MB');
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('6K (6000x4000)', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            onPressed: () => _gridController1.reload(),
                            icon: const Icon(Icons.refresh, size: 16),
                            tooltip: 'Reload',
                          ),
                          IconButton(
                            onPressed: _gridController1.hasImageData ? () => _gridController1.downloadImage() : null,
                            icon: const Icon(Icons.download, size: 16),
                            tooltip: 'Download',
                          ),
                          IconButton(
                            onPressed: _gridController1.hasImageData ? () => _gridController1.copyImageToClipboard() : null,
                            icon: const Icon(Icons.copy, size: 16),
                            tooltip: 'Copy',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      const Text('Heavy Controller 2', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      AspectRatio(
                        aspectRatio: 1.5,
                        child: CustomNetworkImage(
                          url: 'https://picsum.photos/6000/4000?random=ultra2', // 6K image
                          controller: _gridController2,
                          fit: BoxFit.cover,
                          downloadIcon: const Icon(Icons.download, color: Colors.white, size: 12),
                          copyIcon: const Icon(Icons.copy, color: Colors.white, size: 12),
                          hoverIconPosition: HoverIconPosition.bottomRight,
                          hoverIconPadding: const EdgeInsets.all(4),
                          onImageLoaded: (imageData) {
                            print('🔍 DEBUG: Heavy Controller 2 loaded: ${(imageData.imageBytes.length / 1024 / 1024).toStringAsFixed(1)} MB');
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('6K (6000x4000)', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            onPressed: () => _gridController2.reload(),
                            icon: const Icon(Icons.refresh, size: 16),
                            tooltip: 'Reload',
                          ),
                          IconButton(
                            onPressed: _gridController2.hasImageData ? () => _gridController2.downloadImage() : null,
                            icon: const Icon(Icons.download, size: 16),
                            tooltip: 'Download',
                          ),
                          IconButton(
                            onPressed: _gridController2.hasImageData ? () => _gridController2.copyImageToClipboard() : null,
                            icon: const Icon(Icons.copy, size: 16),
                            tooltip: 'Copy',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildControlPanel() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🎛️ Control Panel', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            
            // Position Selector
            const Text('Icon Position:', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: HoverIconPosition.values.map((position) {
                return ChoiceChip(
                  label: Text(position.name),
                  selected: _selectedPosition == position,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedPosition = position);
                  },
                );
              }).toList(),
            ),
            
            const SizedBox(height: 12),
            
            // Layout Selector
            const Text('Icon Layout:', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: HoverIconLayout.values.map((layout) {
                return ChoiceChip(
                  label: Text(layout.name),
                  selected: _selectedLayout == layout,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedLayout = layout);
                  },
                );
              }).toList(),
            ),
            
            const SizedBox(height: 12),
            
            // Settings
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Icon Spacing: ${_iconSpacing.toInt()}px'),
                      Slider(
                        value: _iconSpacing,
                        min: 0,
                        max: 20,
                        divisions: 20,
                        onChanged: (value) => setState(() => _iconSpacing = value),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Icon Padding: ${_iconPadding.toInt()}px'),
                      Slider(
                        value: _iconPadding,
                        min: 0,
                        max: 20,
                        divisions: 20,
                        onChanged: (value) => setState(() => _iconPadding = value),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            SwitchListTile(
              title: const Text('Enable Hover Icons'),
              value: _enableHoverIcons,
              onChanged: (value) => setState(() => _enableHoverIcons = value),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeavyImageDemo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🖼️ Heavy Image Demo (4K Resolution)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('High-resolution image for testing large file copy/download performance', style: TextStyle(color: Colors.grey[600])),
            Text('• This image is 4K (3840x2160) and several MBs in size', style: TextStyle(color: Colors.blue[600], fontSize: 12)),
            Text('• Copy/download operations will take longer due to file size', style: TextStyle(color: Colors.orange[600], fontSize: 12)),
            Text('• Monitor the debug console for detailed performance info', style: TextStyle(color: Colors.purple[600], fontSize: 12)),
            const SizedBox(height: 12),
            
            Center(
              child: CustomNetworkImage(
                url: 'https://picsum.photos/3840/2160?random=heavy', // 4K image
                width: 400,
                height: 300,
                fit: BoxFit.cover,
                
                // ✅ NEW: Controller for external management
                controller: _mainController,
                
                // ✅ Hover Icons with Current Settings
                downloadIcon: _buildDownloadIcon(),
                copyIcon: _buildCopyIcon(),
                hoverIconPosition: _selectedPosition,
                hoverIconLayout: _selectedLayout,
                hoverIconSpacing: _iconSpacing,
                hoverIconPadding: EdgeInsets.all(_iconPadding),
                enableHoverIcons: _enableHoverIcons,
                
                // ✅ Custom Callbacks (still work alongside controller)
                onDownloadTap: () {
                  print('🔍 DEBUG: onDownloadTap called (hover icon clicked)');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🔥 Custom Download Action Triggered!'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                  _handleDownload();
                },
                onCopyTap: () {
                  print('🔍 DEBUG: onCopyTap called (hover icon clicked)');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🔥 Custom Copy Action Triggered!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _handleCopy();
                },
                
                // ✅ Image Data Callback (still works with controller)
                onImageLoaded: (ImageDataInfo imageData) {
                  print('🔍 DEBUG: onImageLoaded called');
                  print('🔍 DEBUG: Heavy image data: ${imageData.imageBytes.length} bytes (${(imageData.imageBytes.length / 1024 / 1024).toStringAsFixed(1)} MB), ${imageData.width}x${imageData.height}');
                  setState(() => _imageData = imageData);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✅ Heavy image loaded! ${(imageData.imageBytes.length / 1024 / 1024).toStringAsFixed(1)} MB - Hover to see ${_selectedPosition.name} icons'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                
                // Custom loading with file size info
                customLoadingBuilder: (context, child, progress) {
                  return Container(
                    width: 400,
                    height: 300,
                    color: Colors.grey[200],
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(value: progress?.progress),
                          const SizedBox(height: 8),
                          Text(
                            progress?.progress != null 
                              ? 'Loading Heavy Image ${(progress!.progress! * 100).toInt()}%'
                              : 'Loading Heavy Image...',
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '4K Resolution (~3-5 MB)',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPositionExamples() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📍 Position Examples', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Hover over images to see icons in different positions', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            const SizedBox(height: 12),
            
            // Use ListView.builder for better performance with many images
            SizedBox(
              height: 320, // Fixed height for the grid area
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                itemCount: HoverIconPosition.values.length,
                itemBuilder: (context, index) {
                  final position = HoverIconPosition.values[index];
                  return _buildPositionExample(position, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPositionExample(HoverIconPosition position, int index) {
    // Use heavy 4K images for position examples
    final heavyImageUrls = [
      'https://picsum.photos/4000/3000?random=pos1', // 4K images
      'https://picsum.photos/4000/3000?random=pos2', 
      'https://picsum.photos/4000/3000?random=pos3',
      'https://picsum.photos/4000/3000?random=pos4',
      'https://picsum.photos/4000/3000?random=pos5',
      'https://picsum.photos/4000/3000?random=pos6',
    ];
    
    return Column(
      children: [
        Text(position.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 4),
        Expanded(
          child: CustomNetworkImage(
            url: heavyImageUrls[index % heavyImageUrls.length],
            fit: BoxFit.cover,
            
            downloadIcon: const Icon(Icons.download, color: Colors.white, size: 14),
            copyIcon: const Icon(Icons.copy, color: Colors.white, size: 14),
            hoverIconPosition: position,
            hoverIconPadding: const EdgeInsets.all(6),
            hoverIconSpacing: 4,
            
            onImageLoaded: (imageData) {
              print('🔍 DEBUG: Position ${position.name} loaded: ${(imageData.imageBytes.length / 1024 / 1024).toStringAsFixed(1)} MB');
            },
          ),
        ),
        const SizedBox(height: 2),
        const Text('4K', style: TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
  
  Widget _buildDownloadIcon() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[400]!, Colors.blue[600]!],
        ),
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.download, color: Colors.white, size: 16),
          SizedBox(width: 4),
          Text('Download', style: TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
  
  Widget _buildCopyIcon() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[400]!, Colors.green[600]!],
        ),
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.copy, color: Colors.white, size: 16),
          SizedBox(width: 4),
          Text('Copy', style: TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
  
  // LEGACY: Keep these methods for the custom callbacks
  Future<void> _handleDownload() async {
    print('🔍 DEBUG: _handleDownload called');
    print('🔍 DEBUG: _imageData is null: ${_imageData == null}');
    
    if (_imageData == null) {
      print('❌ DEBUG: No image data available for download');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ No image data available. Wait for image to load.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    print('🔍 DEBUG: Image data available: ${_imageData!.imageBytes.length} bytes, ${_imageData!.width}x${_imageData!.height}');
    
    try {
      print('🔍 DEBUG: Calling ImageClipboardHelper.downloadImage...');
      final success = await ImageClipboardHelper.downloadImage(_imageData!);
      print('🔍 DEBUG: Download result: $success');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? '📥 Image downloaded successfully!' : '❌ Download failed'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      print('❌ DEBUG: Download error: $e');
      print('❌ DEBUG: Download stack trace: ${StackTrace.current}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Future<void> _handleCopy() async {
    print('🔍 DEBUG: _handleCopy called');
    print('🔍 DEBUG: _imageData is null: ${_imageData == null}');
    
    if (_imageData == null) {
      print('❌ DEBUG: No image data available for copy');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ No image data available. Wait for image to load.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    print('🔍 DEBUG: Image data available: ${_imageData!.imageBytes.length} bytes, ${_imageData!.width}x${_imageData!.height}');
    
    try {
      print('🔍 DEBUG: Calling ImageClipboardHelper.copyImageToClipboard...');
      final success = await ImageClipboardHelper.copyImageToClipboard(_imageData!);
      print('🔍 DEBUG: Copy result: $success');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? '📋 Image copied to clipboard! Press Ctrl+V to paste.' : '❌ Copy failed'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      print('❌ DEBUG: Copy error: $e');
      print('❌ DEBUG: Copy stack trace: ${StackTrace.current}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Copy error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

void main() {
  runApp(MaterialApp(
    title: 'Controller + Hover Icons Demo',
    home: ComprehensiveImageExample(),
    debugShowCheckedModeBanner: false,
  ));
}