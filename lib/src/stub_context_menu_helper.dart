// Stub implementations for non-web platforms
// These functions do nothing on non-web platforms

/// Enable context menu prevention (stub - does nothing on non-web)
void enableContextMenuPrevention() {
  // No-op on non-web platforms
}

/// Disable context menu prevention (stub - does nothing on non-web)
void disableContextMenuPrevention() {
  // No-op on non-web platforms
}

/// Check if context menu prevention is active (stub - always false on non-web)
bool isContextMenuPreventionActive() {
  return false;
}

/// Toggle context menu prevention (stub - does nothing on non-web)
void toggleContextMenuPrevention() {
  // No-op on non-web platforms
}

/// Download image from URL (stub - always returns false on non-web)
Future<bool> downloadImageFromUrl(String imageUrl) async {
  // No-op on non-web platforms
  return false;
}

/// Open URL in new tab (stub - does nothing on non-web)
void openUrlInNewTab(String url) {
  // No-op on non-web platforms
} 