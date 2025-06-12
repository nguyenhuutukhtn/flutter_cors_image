import 'package:flutter/material.dart';
import 'package:flutter_cors_image/flutter_cors_image.dart';
import 'package:flutter_cors_image/src/image_clipboard_helper.dart';

class ComprehensiveImageExample extends StatefulWidget {
  @override
  _ComprehensiveImageExampleState createState() => _ComprehensiveImageExampleState();
}

class _ComprehensiveImageExampleState extends State<ComprehensiveImageExample> {
  ImageDataInfo? _imageData;
  HoverIconPosition _selectedPosition = HoverIconPosition.topRight;
  HoverIconLayout _selectedLayout = HoverIconLayout.auto;
  bool _enableHoverIcons = true;
  double _iconSpacing = 8.0;
  double _iconPadding = 8.0;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complete Hover Icons Demo'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Control Panel
            _buildControlPanel(),
            
            SizedBox(height: 20),
            
            // Main Image with Hover Icons
            _buildMainImageDemo(),
            
            SizedBox(height: 20),
            
            // Status and Actions
            _buildStatusSection(),
            
            SizedBox(height: 20),
            
            // Position Examples Grid
            _buildPositionExamples(),
            
            SizedBox(height: 20),
            
            // Layout Examples
            _buildLayoutExamples(),
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
            Text('🖼️ Main Demo Image', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Hover over the image to see icons in action!', style: TextStyle(color: Colors.grey[600])),
            Text('• Download icon: Saves PNG file to your computer', style: TextStyle(color: Colors.blue[600], fontSize: 12)),
            Text('• Copy icon: Copies image to clipboard for pasting (Ctrl+V)', style: TextStyle(color: Colors.green[600], fontSize: 12)),
            SizedBox(height: 12),
            
            Center(
              child: CustomNetworkImage(
                url: 'https://cdn-cs-dev.s3.ap-southeast-1.amazonaws.com/2025/6/12/image/37238509fdda717430ad94a638989f15',
                width: 400,
                height: 300,
                fit: BoxFit.cover,
                
                // ✅ Hover Icons with Current Settings
                downloadIcon: _buildDownloadIcon(),
                copyIcon: _buildCopyIcon(),
                hoverIconPosition: _selectedPosition,
                hoverIconLayout: _selectedLayout,
                hoverIconSpacing: _iconSpacing,
                hoverIconPadding: EdgeInsets.all(_iconPadding),
                enableHoverIcons: _enableHoverIcons,
                
                // ✅ Custom Callbacks
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
                
                // ✅ Image Data Callback
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
  
  Widget _buildStatusSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📊 Status & Manual Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            
            if (_imageData != null) ...[
              Text('✅ Image Ready!', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              Text('Size: ${_imageData!.width}x${_imageData!.height}'),
              Text('File Size: ${(_imageData!.imageBytes.length / 1024).toStringAsFixed(1)} KB'),
              SizedBox(height: 12),
              
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _handleDownload,
                    icon: Icon(Icons.download),
                    label: Text('Manual Download'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  ),
                  SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _handleCopy,
                    icon: Icon(Icons.copy),
                    label: Text('Manual Copy'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                ],
              ),
            ] else ...[
              Text('⏳ Waiting for image to load...', style: TextStyle(color: Colors.orange)),
            ],
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
  
  Widget _buildLayoutExamples() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🎯 Layout Examples', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            
            Row(
              children: HoverIconLayout.values.map((layout) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      children: [
                        Text(layout.name, style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        AspectRatio(
                          aspectRatio: 1.5,
                          child: CustomNetworkImage(
                            url: 'https://cdn-cs-dev.s3.ap-southeast-1.amazonaws.com/2025/6/12/image/37238509fdda717430ad94a638989f15',
                            fit: BoxFit.cover,
                            
                            downloadIcon: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.download, color: Colors.white, size: 12),
                            ),
                            copyIcon: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.copy, color: Colors.white, size: 12),
                            ),
                            
                            hoverIconPosition: HoverIconPosition.topRight,
                            hoverIconLayout: layout,
                            hoverIconPadding: EdgeInsets.all(8),
                            hoverIconSpacing: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
  
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
    title: 'Complete Hover Icons Demo',
    home: ComprehensiveImageExample(),
    debugShowCheckedModeBanner: false,
  ));
}