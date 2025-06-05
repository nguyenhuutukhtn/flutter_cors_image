import 'package:flutter/material.dart' show Matrix4;

/// Stub implementation for non-web platforms
/// This is a no-op as HTML functionality is not used on native platforms
void registerHtmlImageFactory(String viewId, String url) {
  // No-op implementation for non-web platforms
}

/// Stub implementation of the tap callback setter for non-web platforms
void setHtmlImageTapCallback(String viewId, Function callback) {
  // No-op implementation for non-web platforms
}

/// Stub implementation of the transform updater for non-web platforms
void updateHtmlImageTransform(String viewId, Matrix4 matrix) {
  // No-op implementation for non-web platforms
}

/// Stub implementation for removing tap callbacks
void removeHtmlImageTapCallback(String viewId) {
  // No-op implementation for non-web platforms
}

/// Cleanup HTML elements when no longer needed
/// This is a stub implementation for non-web platforms
void cleanupHtmlElement(String viewId) {
  // This is a stub - only used on web platforms
}

/// Sets the error callback function for a specific HTML image
/// This is a stub implementation for non-web platforms
void setHtmlImageErrorCallback(String viewId, Function callback) {
  // This is a stub - only used on web platforms
}

/// Remove an error callback when no longer needed
/// This is a stub implementation for non-web platforms
void removeHtmlImageErrorCallback(String viewId) {
  // This is a stub - only used on web platforms
}

/// Opens a URL in a new tab/window (web only)
/// This is a stub implementation for non-web platforms
void openUrlInNewTab(String url) {
  // This is a stub - only used on web platforms
}

/// Sets the success callback function for a specific HTML image
/// This is a stub implementation for non-web platforms
void setHtmlImageSuccessCallback(String viewId, Function callback) {
  // This is a stub - only used on web platforms
}

/// Remove a success callback when no longer needed
/// This is a stub implementation for non-web platforms
void removeHtmlImageSuccessCallback(String viewId) {
  // This is a stub - only used on web platforms
} 