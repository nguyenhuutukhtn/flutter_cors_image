import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

// Conditional import for web-specific functionality
import 'types.dart';
import 'web_clipboard_helper.dart' if (dart.library.io) 'stub_clipboard_helper.dart';
// Conditional import for io-specific functionality  
import 'io_clipboard_helper.dart' if (dart.library.html) 'stub_io_clipboard_helper.dart';

/// Helper class for copying images to clipboard
class ImageClipboardHelper {
  
  /// Copy image data to clipboard (for pasting with Ctrl+V)
  /// This copies actual image data that can be pasted as images, not text
  static Future<bool> copyImageToClipboard(ImageDataInfo imageData) async {
    try {
      if (kIsWeb) {
        // Use web-specific clipboard method
        final result = await copyImageToClipboardWeb(imageData);
        return result;
      } else if (isMobilePlatform) {
        // Use mobile clipboard method
        return await copyImageOnMobile(imageData);
      } else {
        // Use desktop clipboard method
        return await copyImageOnDesktop(imageData);
      }
    } catch (e) {
      return false;
    }
  }

  /// Copy raw image bytes to clipboard (for pasting with Ctrl+V)
  /// This copies actual image data that can be pasted as images, not text
  /// Takes raw Uint8List data instead of ImageDataInfo wrapper
  /// Requires width and height for proper canvas rendering on web
  static Future<bool> copyImageBytesToClipboard(
    Uint8List fileData, {
    required int width,
    required int height,
  }) async {
    try {
      // Create a basic ImageDataInfo wrapper for compatibility with existing methods
      final imageData = ImageDataInfo(
        url: '',
        imageBytes: fileData,
        width: width,
        height: height,
      );

      if (kIsWeb) {
        // On web, use the Clipboard API for actual clipboard copying
        return await copyImageToClipboardWeb(imageData);
      } else if (isMobilePlatform) {
        // On mobile, use platform-specific methods
        return await copyImageBytesOnMobile(fileData);
      } else {
        // On desktop, try to copy as image data
        return await copyImageBytesOnDesktop(fileData);
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
        final result = await _downloadImageOnWeb(imageData);
        return result;
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
      
      return await saveImageToDownloads(imageData);
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
            Text('Data Size: ${(imageData.imageBytes?.length ?? 0 / 1024).toStringAsFixed(1)} KB'),
          ],
        ),
      ),
    );
  }
} 