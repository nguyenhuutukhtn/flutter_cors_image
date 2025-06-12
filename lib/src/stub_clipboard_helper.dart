// Stub implementation for non-web platforms
import 'custom_network_image.dart';

/// Stub implementation - this should never be called on non-web platforms
Future<bool> copyImageToClipboardWeb(ImageDataInfo imageData) async {
  throw UnimplementedError('Web clipboard copying not available on this platform');
}

/// Stub implementation - this should never be called on non-web platforms
Future<bool> downloadImageWeb(ImageDataInfo imageData) async {
  throw UnimplementedError('Web download not available on this platform');
} 