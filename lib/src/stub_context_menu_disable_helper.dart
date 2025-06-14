import 'package:flutter/widgets.dart';

/// Stub interface for widgets that handle context menu disabling
abstract class DisableWebContextMenuHandler {
  bool isPointInBounds(Offset point);
  void triggerContextMenu(Offset position);
}

/// Register a widget for context menu handling (stub - no-op on non-web)
void registerContextMenuWidget(DisableWebContextMenuHandler widget) {
  // No-op on non-web platforms
}

/// Unregister a widget from context menu handling (stub - no-op on non-web)
void unregisterContextMenuWidget(DisableWebContextMenuHandler widget) {
  // No-op on non-web platforms
}