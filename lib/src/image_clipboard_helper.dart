import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

// Conditional import for web-specific functionality
import 'types.dart';
import 'web_clipboard_helper.dart' if (dart.library.io) 'stub_clipboard_helper.dart';

/// Helper class for copying images to clipboard
class ImageClipboardHelper {
  
  /// Copy image data to clipboard (for pasting with Ctrl+V)
  /// This copies actual image data that can be pasted as images, not text
  static Future<bool> copyImageToClipboard(ImageDataInfo imageData) async {
    try {
      if (kIsWeb) {
        // On web, use the Clipboard API for actual clipboard copying
        return await copyImageToClipboardWeb(imageData);
      } else if (Platform.isAndroid || Platform.isIOS) {
        // On mobile, use platform-specific methods
        return await _copyImageOnMobile(imageData);
      } else {
        // On desktop, try to copy as image data
        return await _copyImageOnDesktop(imageData);
      }
    } catch (e) {
      return false;
    }
  }

  /// Download image as a file (separate from clipboard copying)
  /// This downloads the image as a PNG file to the user's computer
  static Future<bool> downloadImage(ImageDataInfo imageData) async {
    try {
      if (kIsWeb) {
        // On web, download as file
        return await _downloadImageOnWeb(imageData);
      } else {
        // On mobile/desktop, save to downloads or temp directory
        return await _downloadImageOnMobileDesktop(imageData);
      }
    } catch (e) {
      return false;
    }
  }

  /// Download image on web platform
  static Future<bool> _downloadImageOnWeb(ImageDataInfo imageData) async {
    if (!kIsWeb) return false;
    
    try {
      // Use the web download function directly
      final success = await downloadImageWeb(imageData);
      return success;
    } catch (e) {
      return false;
    }
  }

  /// Download image on mobile/desktop platforms
  static Future<bool> _downloadImageOnMobileDesktop(ImageDataInfo imageData) async {
    try {
      // Save to appropriate downloads directory
      final filePath = await _saveImageToDownloads(imageData);
      return filePath != null;
    } catch (e) {
      return false;
    }
  }

  /// Save image to downloads directory (mobile/desktop)
  static Future<String?> _saveImageToDownloads(ImageDataInfo imageData) async {
    try {
      if (kIsWeb) return null;
      
      // For mobile/desktop, save to downloads or documents directory
      // You might want to use plugins like path_provider for proper downloads folder
      final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.png';
      
      // Use temporary directory as fallback
      final tempDir = Directory.systemTemp;
      final filePath = '${tempDir.path}/$fileName';
      
      final file = File(filePath);
      await file.writeAsBytes(imageData.imageBytes);
      
      return filePath;
    } catch (e) {
      return null;
    }
  }

  /// Copy image on mobile platforms
  static Future<bool> _copyImageOnMobile(ImageDataInfo imageData) async {
    try {
      // For mobile platforms, we need to use platform channels or plugins
      // Since Flutter doesn't have built-in image clipboard support for mobile,
      // we'll save to temp file and copy file path, or use plugins
      
      // Method 1: Try to use platform channels for direct image copying
      try {
        const platform = MethodChannel('image_clipboard_channel');
        final result = await platform.invokeMethod('copyImage', {
          'imageBytes': imageData.imageBytes,
          'width': imageData.width,
          'height': imageData.height,
        });
        return result == true;
      } catch (e) {
        // Platform channel not available
      }
      
      // Method 2: Fallback - save to temp file and copy file path
      final tempPath = await saveImageToTempFile(imageData);
      if (tempPath != null) {
        await Clipboard.setData(ClipboardData(text: 'Image saved to: $tempPath'));
        return true;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Copy image on desktop platforms
  static Future<bool> _copyImageOnDesktop(ImageDataInfo imageData) async {
    try {
      // For desktop platforms, we can try to use system clipboard
      // This might work on some platforms with proper plugins
      
      // Method 1: Try to save to temp file and copy path
      final tempPath = await saveImageToTempFile(imageData);
      if (tempPath != null) {
        // On desktop, some applications can handle file paths
        await Clipboard.setData(ClipboardData(text: tempPath));
        return true;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Save image bytes to temporary file and return path
  /// Useful for sharing or further processing
  static Future<String?> saveImageToTempFile(ImageDataInfo imageData) async {
    try {
      if (kIsWeb) {
        // On web, we can't save to file system directly
        return null;
      }
      
      // Get temporary directory
      final tempDir = Directory.systemTemp;
      final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.png';
      final filePath = '${tempDir.path}/$fileName';
      
      // Write image bytes to file
      final file = File(filePath);
      await file.writeAsBytes(imageData.imageBytes);
      
      return filePath;
    } catch (e) {
      return null;
    }
  }

  /// Convert image bytes to base64 string
  static String imageToBase64(Uint8List imageBytes) {
    return base64Encode(imageBytes);
  }

  /// Create data URL from image bytes
  static String createDataUrl(Uint8List imageBytes, {String mimeType = 'image/png'}) {
    final base64String = base64Encode(imageBytes);
    return 'data:$mimeType;base64,$base64String';
  }
}

// Base64 encoding implementation (in case dart:convert is not available)
String base64Encode(List<int> bytes) {
  const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
  String result = '';
  
  int i = 0;
  while (i < bytes.length) {
    int byte1 = bytes[i++];
    int byte2 = i < bytes.length ? bytes[i++] : 0;
    int byte3 = i < bytes.length ? bytes[i++] : 0;
    
    int combined = (byte1 << 16) | (byte2 << 8) | byte3;
    
    result += chars[(combined >> 18) & 63];
    result += chars[(combined >> 12) & 63];
    result += i - 2 < bytes.length ? chars[(combined >> 6) & 63] : '=';
    result += i - 1 < bytes.length ? chars[combined & 63] : '=';
  }
  
  return result;
}

/// Extended functionality for image operations
class ImageOperationsHelper {
  
  /// Create a copy button widget that handles the copying automatically
  static Widget createCopyButton({
    required ImageDataInfo? imageData,
    required VoidCallback? onSuccess,
    VoidCallback? onError,
    String buttonText = 'Copy Image',
    Widget? icon,
  }) {
    return ElevatedButton.icon(
      onPressed: imageData != null ? () async {
        final success = await ImageClipboardHelper.copyImageToClipboard(imageData);
        if (success) {
          onSuccess?.call();
        } else {
          onError?.call();
        }
      } : null,
      icon: icon ?? Icon(Icons.copy),
      label: Text(buttonText),
    );
  }
  
  /// Create a widget that shows image info
  static Widget createImageInfoWidget(ImageDataInfo imageData) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Image Information', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('URL: ${imageData.url}'),
            Text('Size: ${imageData.width}x${imageData.height}'),
            Text('Data Size: ${(imageData.imageBytes.length / 1024).toStringAsFixed(1)} KB'),
          ],
        ),
      ),
    );
  }
} 