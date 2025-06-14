import 'dart:typed_data';
import 'types.dart';

/// Check if running on mobile platform (stub - always returns false on web)
bool get isMobilePlatform => false;

/// Check if running on desktop platform (stub - always returns false on web)
bool get isDesktopPlatform => false;

/// Copy image on mobile platforms (stub - always returns false on web)
Future<bool> copyImageOnMobile(ImageDataInfo imageData) async {
  return false;
}

/// Copy raw image bytes on mobile platforms (stub - always returns false on web)
Future<bool> copyImageBytesOnMobile(Uint8List fileData) async {
  return false;
}

/// Copy image on desktop platforms (stub - always returns false on web)
Future<bool> copyImageOnDesktop(ImageDataInfo imageData) async {
  return false;
}

/// Copy raw image bytes on desktop platforms (stub - always returns false on web)
Future<bool> copyImageBytesOnDesktop(Uint8List fileData) async {
  return false;
}

/// Save image to temp directory (stub - always returns null on web)
Future<String?> saveImageToTempFile(ImageDataInfo imageData) async {
  return null;
}

/// Save image bytes to temp directory (stub - always returns null on web)
Future<String?> saveImageBytesToTempFile(Uint8List fileData) async {
  return null;
}

/// Save image to downloads directory (stub - always returns null on web)
Future<String?> saveImageToDownloads(ImageDataInfo imageData) async {
  return null;
} 