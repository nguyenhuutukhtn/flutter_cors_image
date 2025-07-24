import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_cors_image/flutter_cors_image.dart';
import 'dart:typed_data';

// Web-only imports for file picker
import 'dart:html' as html if (dart.library.html) '';

class LocalFileExampleScreen extends StatefulWidget {
  const LocalFileExampleScreen({Key? key}) : super(key: key);

  @override
  State<LocalFileExampleScreen> createState() => _LocalFileExampleScreenState();
}

class _LocalFileExampleScreenState extends State<LocalFileExampleScreen> {
  Uint8List? _selectedImageBytes;
  dynamic _selectedWebFile;
  String? _selectedFileName;
  bool _isLoading = false;
  String? _loadingError;
  ImageDataInfo? _loadedImageData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local File Image Example'),
        // subtitle: const Text('Test baseline JPEG and other local files'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Instructions
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📁 Local File Image Testing',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This example demonstrates loading images from local files (bytes, File, Blob) '
                      'with automatic HTML fallback for problematic formats like baseline JPEG.',
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '🔍 Test Cases:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const Text('• Baseline JPEG images that fail in Flutter web'),
                    const Text('• Progressive JPEG images'),
                    const Text('• PNG images with transparency'),
                    const Text('• WebP images'),
                    const Text('• Large images that might cause memory issues'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // File picker section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Select Local Image File',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    
                    // File picker buttons
                    if (kIsWeb) ...[
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _pickImageFile,
                              icon: const Icon(Icons.folder_open),
                              label: const Text('Pick Image File'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _pickImageWithDragDrop,
                              icon: const Icon(Icons.drag_handle),
                              label: const Text('Enable Drag & Drop'),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.info_outline, color: Colors.orange),
                            SizedBox(height: 8),
                            Text(
                              'File picker is currently only available on web platform.\n'
                              'On mobile/desktop, you can use CustomNetworkImage with localFileBytes parameter.',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    if (_selectedFileName != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.green, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Selected: $_selectedFileName',
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            if (_selectedImageBytes != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Size: ${(_selectedImageBytes!.length / 1024).toStringAsFixed(1)} KB',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                    
                    if (_loadingError != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.error_outline, color: Colors.red, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Error loading file:',
                                  style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(_loadingError!, style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _loadingError = null;
                                });
                              },
                              icon: const Icon(Icons.close),
                              label: const Text('Dismiss'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade100,
                                foregroundColor: Colors.red.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Image display section
            if (_selectedImageBytes != null || _selectedWebFile != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Image Preview',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      
                      // Image display with fallback testing
                      Container(
                        height: 400,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CustomNetworkImage(
                            // Use localFileBytes or webFile
                            localFileBytes: _selectedImageBytes,
                            webFile: _selectedWebFile,
                            
                            width: double.infinity,
                            height: 400,
                            fit: BoxFit.contain,
                            
                            // Enable hover icons for testing
                            downloadIcon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.download, color: Colors.white, size: 16),
                                  SizedBox(width: 4),
                                  Text('Save', style: TextStyle(color: Colors.white, fontSize: 12)),
                                ],
                              ),
                            ),
                            
                            copyIcon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.copy, color: Colors.white, size: 16),
                                  SizedBox(width: 4),
                                  Text('Copy', style: TextStyle(color: Colors.white, fontSize: 12)),
                                ],
                              ),
                            ),
                            
                            hoverIconPosition: HoverIconPosition.topRight,
                            
                            // Enable context menu
                            enableContextMenu: true,
                            
                            // Custom loading widget
                            customLoadingBuilder: (context, child, progress) {
                              return Container(
                                height: 400,
                                color: Colors.grey.shade100,
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircularProgressIndicator(
                                        value: progress?.progress,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        progress?.progress != null
                                            ? 'Loading... ${(progress!.progress! * 100).toInt()}%'
                                            : 'Loading local file...',
                                      ),
                                      if (_selectedFileName != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          _selectedFileName!,
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                            
                            // Error widget
                            errorWidget: Container(
                              padding: const EdgeInsets.all(16),
                              color: Colors.red.shade50,
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.error_outline, color: Colors.red, size: 48),
                                  SizedBox(height: 12),
                                  Text(
                                    'Failed to load local image',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'This might be a baseline JPEG or unsupported format.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Image loaded callback
                            onImageLoaded: (imageData) {
                              setState(() {
                                _loadedImageData = imageData;
                                _loadingError = null;
                              });
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Image loaded successfully! ${imageData.width}x${imageData.height}',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      
                      // Image information
                      if (_loadedImageData != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '✅ Image Information:',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              Text('Dimensions: ${_loadedImageData!.width} × ${_loadedImageData!.height}'),
                              Text('File size: ${(_loadedImageData!.imageBytes.length / 1024).toStringAsFixed(1)} KB'),
                              Text('Display name: ${_loadedImageData!.url}'),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        final imageData = _loadedImageData;
                                        if (imageData == null) return;
                                        
                                        try {
                                          await ImageClipboardHelper.downloadImage(imageData);
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Image downloaded successfully!'),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Download failed: $e'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      icon: const Icon(Icons.download),
                                      label: const Text('Download'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        final imageData = _loadedImageData;
                                        if (imageData == null) return;
                                        
                                        try {
                                          await ImageClipboardHelper.copyImageToClipboard(imageData);
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Image copied to clipboard!'),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Copy failed: $e'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      icon: const Icon(Icons.copy),
                                      label: const Text('Copy'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 20),
            
            // Example usage code
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Example Usage',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '''// For local file bytes
CustomNetworkImage(
  localFileBytes: yourUint8ListBytes,
  width: 300,
  height: 200,
  fit: BoxFit.contain,
)

// For web File object
CustomNetworkImage(
  webFile: yourHtmlFileObject,
  width: 300,
  height: 200,
  fit: BoxFit.contain,
)

// For web Blob object
CustomNetworkImage(
  webBlob: yourBlobObject,
  width: 300,
  height: 200,
  fit: BoxFit.contain,
)''',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Web-only file picker implementation
  Future<void> _pickImageFile() async {
    if (!kIsWeb) return;
    
    setState(() {
      _isLoading = true;
      _loadingError = null;
    });
    
    try {
      // Create file input element
      final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
      uploadInput.accept = 'image/*';
      uploadInput.click();
      
      await uploadInput.onChange.first;
      
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        final file = files[0];
        
        // Read file as bytes
        final reader = html.FileReader();
        reader.readAsArrayBuffer(file);
        
        await reader.onLoad.first;
        
        final result = reader.result as List<int>;
        final bytes = Uint8List.fromList(result);
        
        setState(() {
          _selectedImageBytes = bytes;
          _selectedWebFile = file;
          _selectedFileName = file.name;
          _loadedImageData = null; // Reset previous data
        });
      }
    } catch (e) {
      setState(() {
        _loadingError = 'Failed to pick file: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Placeholder for drag & drop functionality
  Future<void> _pickImageWithDragDrop() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Drag & drop functionality coming soon! Use "Pick Image File" for now.'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}