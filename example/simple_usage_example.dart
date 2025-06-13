import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_cors_image/flutter_cors_image.dart';
import 'package:flutter_cors_image/src/image_clipboard_helper.dart';
import 'package:flutter_cors_image/src/custom_network_image_controller.dart';
import 'package:flutter_cors_image/src/types.dart';

class ComprehensiveImageExample extends StatefulWidget {
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
        title: Text('Controller + Hover Icons Demo'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // NEW: Controller Status Panel
            _buildControllerStatusPanel(),
            
            SizedBox(height: 20),
            
            // Control Panel
            _buildControlPanel(),
            
            SizedBox(height: 20),
            
            // Main Image with Controller
            _buildMainImageDemo(),
            
            SizedBox(height: 20),
            
            // Controller Actions
            _buildControllerActionsPanel(),
            
            SizedBox(height: 20),
            
            // Multiple Controllers Example
            _buildMultipleControllersExample(),
            
            SizedBox(height: 20),
            
            // Position Examples Grid
            _buildPositionExamples(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildControllerStatusPanel() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📊 Controller Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status: $_controllerStatus', style: TextStyle(fontWeight: FontWeight.bold)),
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
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🎮 Controller Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Control the image externally using the controller', style: TextStyle(color: Colors.grey[600])),
            SizedBox(height: 12),
            
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    setState(() => _lastAction = 'Reload');
                    _mainController.reload();
                  },
                  icon: Icon(Icons.refresh),
                  label: Text('Reload Image'),
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
                  icon: Icon(Icons.download),
                  label: Text('Download'),
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
                  icon: Icon(Icons.copy),
                  label: Text('Copy'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
                
                ElevatedButton.icon(
                  onPressed: () async {
                    setState(() => _lastAction = 'Wait for Load');
                    try {
                      final imageData = await _mainController.waitForLoad(timeout: Duration(seconds: 10));
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
                  icon: Icon(Icons.hourglass_empty),
                  label: Text('Wait for Load'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMultipleControllersExample() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🔄 Multiple Controllers Example', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Different images with separate controllers', style: TextStyle(color: Colors.grey[600])),
            SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text('Controller 1', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      AspectRatio(
                        aspectRatio: 1.5,
                        child: CustomNetworkImage(
                          url: 'https://cdn-cs-dev.s3.ap-southeast-1.amazonaws.com/2025/6/12/image/37238509fdda717430ad94a638989f15',
                          controller: _gridController1,
                          fit: BoxFit.cover,
                          downloadIcon: Icon(Icons.download, color: Colors.white, size: 12),
                          copyIcon: Icon(Icons.copy, color: Colors.white, size: 12),
                          hoverIconPosition: HoverIconPosition.topLeft,
                          hoverIconPadding: EdgeInsets.all(4),
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            onPressed: () => _gridController1.reload(),
                            icon: Icon(Icons.refresh, size: 16),
                            tooltip: 'Reload',
                          ),
                          IconButton(
                            onPressed: _gridController1.hasImageData ? () => _gridController1.downloadImage() : null,
                            icon: Icon(Icons.download, size: 16),
                            tooltip: 'Download',
                          ),
                          IconButton(
                            onPressed: _gridController1.hasImageData ? () => _gridController1.copyImageToClipboard() : null,
                            icon: Icon(Icons.copy, size: 16),
                            tooltip: 'Copy',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      Text('Controller 2', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      AspectRatio(
                        aspectRatio: 1.5,
                        child: CustomNetworkImage(
                          url: 'https://cdn-cs-dev.s3.ap-southeast-1.amazonaws.com/2025/6/12/image/37238509fdda717430ad94a638989f15',
                          controller: _gridController2,
                          fit: BoxFit.cover,
                          downloadIcon: Icon(Icons.download, color: Colors.white, size: 12),
                          copyIcon: Icon(Icons.copy, color: Colors.white, size: 12),
                          hoverIconPosition: HoverIconPosition.bottomRight,
                          hoverIconPadding: EdgeInsets.all(4),
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            onPressed: () => _gridController2.reload(),
                            icon: Icon(Icons.refresh, size: 16),
                            tooltip: 'Reload',
                          ),
                          IconButton(
                            onPressed: _gridController2.hasImageData ? () => _gridController2.downloadImage() : null,
                            icon: Icon(Icons.download, size: 16),
                            tooltip: 'Download',
                          ),
                          IconButton(
                            onPressed: _gridController2.hasImageData ? () => _gridController2.copyImageToClipboard() : null,
                            icon: Icon(Icons.copy, size: 16),
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
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🎛️ Control Panel', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            
            // Position Selector
            Text('Icon Position:', style: TextStyle(fontWeight: FontWeight.bold)),
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
            
            SizedBox(height: 12),
            
            // Layout Selector
            Text('Icon Layout:', style: TextStyle(fontWeight: FontWeight.bold)),
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
            
            SizedBox(height: 12),
            
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
                SizedBox(width: 16),
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
              title: Text('Enable Hover Icons'),
              value: _enableHoverIcons,
              onChanged: (value) => setState(() => _enableHoverIcons = value),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMainImageDemo() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🖼️ Main Demo Image with Controller', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Hover over the image to see icons in action!', style: TextStyle(color: Colors.grey[600])),
            Text('• Download icon: Saves PNG file to your computer', style: TextStyle(color: Colors.blue[600], fontSize: 12)),
            Text('• Copy icon: Copies image to clipboard for pasting (Ctrl+V)', style: TextStyle(color: Colors.green[600], fontSize: 12)),
            Text('• Controller: External control available via buttons below', style: TextStyle(color: Colors.purple[600], fontSize: 12)),
            SizedBox(height: 12),
            
            Center(
              child: CustomNetworkImage(
                url: 'https://cdn-cs-dev.s3.ap-southeast-1.amazonaws.com/2025/6/12/image/37238509fdda717430ad94a638989f15',
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('🔥 Custom Download Action Triggered!'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                  _handleDownload();
                },
                onCopyTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('🔥 Custom Copy Action Triggered!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _handleCopy();
                },
                
                // ✅ Image Data Callback (still works with controller)
                onImageLoaded: (ImageDataInfo imageData) {
                  setState(() => _imageData = imageData);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✅ Image loaded! Hover to see ${_selectedPosition.name} icons'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                
                // Custom loading
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
                          SizedBox(height: 8),
                          Text(
                            progress?.progress != null 
                              ? 'Loading ${(progress!.progress! * 100).toInt()}%'
                              : 'Loading...',
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
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📍 Position Examples', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: HoverIconPosition.values.map((position) {
                return _buildPositionExample(position);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPositionExample(HoverIconPosition position) {
    return Column(
      children: [
        Text(position.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        SizedBox(height: 4),
        Expanded(
          child: CustomNetworkImage(
            url: 'https://cdn-cs-dev.s3.ap-southeast-1.amazonaws.com/2025/6/12/image/37238509fdda717430ad94a638989f15',
            fit: BoxFit.cover,
            
            downloadIcon: Icon(Icons.download, color: Colors.white, size: 14),
            copyIcon: Icon(Icons.copy, color: Colors.white, size: 14),
            hoverIconPosition: position,
            hoverIconPadding: EdgeInsets.all(6),
            hoverIconSpacing: 4,
            
            onImageLoaded: (imageData) {
              print('Example image loaded for $position');
            },
          ),
        ),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
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
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
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
    if (_imageData == null) return;
    
    try {
      final success = await ImageClipboardHelper.downloadImage(_imageData!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? '📥 Image downloaded successfully!' : '❌ Download failed'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Future<void> _handleCopy() async {
    if (_imageData == null) return;
    
    try {
      final success = await ImageClipboardHelper.copyImageToClipboard(_imageData!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? '📋 Image copied to clipboard! Press Ctrl+V to paste.' : '❌ Copy failed'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
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