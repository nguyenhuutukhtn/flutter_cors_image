import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart' show Matrix4, VoidCallback;

/// Stub implementation for fetchImageBytesWithCors (not available on non-web platforms)
Future<Uint8List?> fetchImageBytesWithCors(String imageUrl, {Function(double)? onProgress}) async {
  // Not available on non-web platforms
  return null;
}

/// Stub implementation for cleanupCorsFunction (not available on non-web platforms)
void cleanupCorsFunction(String imageUrl) {
  // Not available on non-web platforms
}

/// Stub implementation for registerHtmlImageFactory (not available on non-web platforms)
void registerHtmlImageFactory(String viewType, String url) {
  // Not available on non-web platforms
}

/// Stub implementation for setHtmlImageTapCallback (not available on non-web platforms)
void setHtmlImageTapCallback(String viewType, VoidCallback callback) {
  // Not available on non-web platforms
}

/// Stub implementation for removeHtmlImageTapCallback (not available on non-web platforms)
void removeHtmlImageTapCallback(String viewType) {
  // Not available on non-web platforms
}

/// Stub implementation for setHtmlImageErrorCallback (not available on non-web platforms)
void setHtmlImageErrorCallback(String viewType, VoidCallback callback) {
  // Not available on non-web platforms
}

/// Stub implementation for removeHtmlImageErrorCallback (not available on non-web platforms)
void removeHtmlImageErrorCallback(String viewType) {
  // Not available on non-web platforms
}

/// Stub implementation for setHtmlImageSuccessCallback (not available on non-web platforms)
void setHtmlImageSuccessCallback(String viewType, VoidCallback callback) {
  // Not available on non-web platforms
}

/// Stub implementation for removeHtmlImageSuccessCallback (not available on non-web platforms)
void removeHtmlImageSuccessCallback(String viewType) {
  // Not available on non-web platforms
}

/// Stub implementation for cleanupHtmlElement (not available on non-web platforms)
void cleanupHtmlElement(String viewType) {
  // Not available on non-web platforms
}

/// Stub implementation for updateHtmlImageTransform (not available on non-web platforms)
void updateHtmlImageTransform(String viewType, Matrix4 transform) {
  // Not available on non-web platforms
}

/// Stub implementation for createFileReader (not available on non-web platforms)
dynamic createFileReader() {
  // Not available on non-web platforms
  return null;
}

/// Stub implementation for setFileReaderCallbacks (not available on non-web platforms)
void setFileReaderCallbacks(
  dynamic reader,
  {required Function(Uint8List?) onLoad,
  required Function(String) onError}
) {
  // Not available on non-web platforms
}

/// Stub implementation for readFileAsArrayBuffer (not available on non-web platforms)
void readFileAsArrayBuffer(dynamic reader, dynamic file) {
  // Not available on non-web platforms
}

/// Stub implementation for readBlobAsUint8List (not available on non-web platforms)
Future<Uint8List?> readBlobAsUint8List(dynamic blob) async {
  // Not available on non-web platforms
  return null;
}

/// Stub implementation for createDataUrlFromBytes (not available on non-web platforms)
String createDataUrlFromBytes(Uint8List bytes) {
  // Not available on non-web platforms
  return 'data:image/png;base64,';
} 