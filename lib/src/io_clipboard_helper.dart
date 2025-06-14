import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'types.dart';

/// Check if running on mobile platform
bool get isMobilePlatform => Platform.isAndroid || Platform.isIOS;

/// Check if running on desktop platform
bool get isDesktopPlatform => Platform.isWindows || Platform.isMacOS || Platform.isLinux;

/// Copy image on mobile platforms
Future<bool> copyImageOnMobile(ImageDataInfo imageData) async {
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

/// Copy raw image bytes on mobile platforms
Future<bool> copyImageBytesOnMobile(Uint8List fileData) async {
  try {
    // For mobile platforms, we need to use platform channels or plugins
    // Since Flutter doesn't have built-in image clipboard support for mobile,
    // we'll save to temp file and copy file path, or use plugins
    
    // Method 1: Try to use platform channels for direct image copying
    try {
      const platform = MethodChannel('image_clipboard_channel');
      final result = await platform.invokeMethod('copyImage', {
        'imageBytes': fileData,
        'width': 0, // Unknown dimensions
        'height': 0,
      });
      return result == true;
    } catch (e) {
      // Platform channel not available
    }
    
    // Method 2: Fallback - save to temp file and copy file path
    final tempPath = await saveImageBytesToTempFile(fileData);
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
Future<bool> copyImageOnDesktop(ImageDataInfo imageData) async {
  try {
    // For desktop platforms, we can try to use system clipboard
    // This might work on some platforms with proper plugins
    
    // Method 1: Try platform channel for desktop clipboard
    try {
      const platform = MethodChannel('desktop_clipboard_channel');
      final result = await platform.invokeMethod('copyImage', {
        'imageBytes': imageData.imageBytes,
        'width': imageData.width,
        'height': imageData.height,
      });
      return result == true;
    } catch (e) {
      // Platform channel not available
    }
    
    // Method 2: Fallback - save to temp file
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

/// Copy raw image bytes on desktop platforms
Future<bool> copyImageBytesOnDesktop(Uint8List fileData) async {
  try {
    // For desktop platforms, we can try to use system clipboard
    // This might work on some platforms with proper plugins
    
    // Method 1: Try platform channel for desktop clipboard
    try {
      const platform = MethodChannel('desktop_clipboard_channel');
      final result = await platform.invokeMethod('copyImage', {
        'imageBytes': fileData,
        'width': 0, // Unknown dimensions
        'height': 0,
      });
      return result == true;
    } catch (e) {
      // Platform channel not available
    }
    
    // Method 2: Fallback - save to temp file
    final tempPath = await saveImageBytesToTempFile(fileData);
    if (tempPath != null) {
      await Clipboard.setData(ClipboardData(text: 'Image saved to: $tempPath'));
      return true;
    }
    
    return false;
  } catch (e) {
    return false;
  }
}

/// Save image to temp directory and return file path
Future<String?> saveImageToTempFile(ImageDataInfo imageData) async {
  try {
    final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.png';
    final tempDir = Directory.systemTemp;
    final filePath = '${tempDir.path}/$fileName';
    
    final file = File(filePath);
    await file.writeAsBytes(imageData.imageBytes);
    
    return filePath;
  } catch (e) {
    return null;
  }
}

/// Save image bytes to temp directory and return file path
Future<String?> saveImageBytesToTempFile(Uint8List fileData) async {
  try {
    final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.png';
    final tempDir = Directory.systemTemp;
    final filePath = '${tempDir.path}/$fileName';
    
    final file = File(filePath);
    await file.writeAsBytes(fileData);
    
    return filePath;
  } catch (e) {
    return null;
  }
}

/// Save image to downloads directory (mobile/desktop)
Future<String?> saveImageToDownloads(ImageDataInfo imageData) async {
  try {
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