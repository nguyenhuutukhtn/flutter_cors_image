import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart' show Matrix4;

/// Stub implementation for non-web platforms
/// All functions throw UnsupportedError since they are web-only

Future<Uint8List?> fetchImageBytesWithCors(String imageUrl, {Function(double)? onProgress}) async {
  throw UnsupportedError('fetchImageBytesWithCors is only supported on web platforms');
}

void cleanupCorsFunction(String imageUrl) {
  throw UnsupportedError('cleanupCorsFunction is only supported on web platforms');
}

void setHtmlImageTapCallback(String viewId, Function callback) {
  throw UnsupportedError('setHtmlImageTapCallback is only supported on web platforms');
}

void setHtmlImageErrorCallback(String viewId, Function callback) {
  throw UnsupportedError('setHtmlImageErrorCallback is only supported on web platforms');
}

void setHtmlImageSuccessCallback(String viewId, Function callback) {
  throw UnsupportedError('setHtmlImageSuccessCallback is only supported on web platforms');
}

void updateHtmlImageTransform(String viewId, Matrix4 matrix) {
  throw UnsupportedError('updateHtmlImageTransform is only supported on web platforms');
}

void registerHtmlImageFactory(String viewId, String url) {
  throw UnsupportedError('registerHtmlImageFactory is only supported on web platforms');
}

void removeHtmlImageTapCallback(String viewId) {
  throw UnsupportedError('removeHtmlImageTapCallback is only supported on web platforms');
}

void removeHtmlImageErrorCallback(String viewId) {
  throw UnsupportedError('removeHtmlImageErrorCallback is only supported on web platforms');
}

void removeHtmlImageSuccessCallback(String viewId) {
  throw UnsupportedError('removeHtmlImageSuccessCallback is only supported on web platforms');
}

void cleanupHtmlElement(String viewId) {
  throw UnsupportedError('cleanupHtmlElement is only supported on web platforms');
} 