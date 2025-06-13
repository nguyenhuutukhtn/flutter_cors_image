import 'dart:html' as html;
import 'dart:async';

/// Global flag to track if context menu prevention is active
bool _isContextMenuPreventionActive = false;

/// Global stream subscription for context menu events
StreamSubscription<html.MouseEvent>? _contextMenuSubscription;

/// Set of widget IDs that should have context menu prevented
final Set<String> _preventedWidgetIds = <String>{};

/// Enable context menu prevention for specific widget areas only
/// This will only prevent browser's default context menu on Flutter canvas elements
void enableContextMenuPrevention() {
  if (_isContextMenuPreventionActive) return;
  
  _isContextMenuPreventionActive = true;
  
  // Listen for context menu events and prevent them only on Flutter canvas
  _contextMenuSubscription = html.document.onContextMenu.listen((event) {
    final target = event.target;
    
    // Only prevent context menu if the target is a Flutter canvas element
    if (target is html.CanvasElement || 
        target is html.Element && target.tagName == 'CANVAS') {
      event.preventDefault();
      event.stopPropagation();
    }
    // Allow normal context menu for all other elements (text, links, etc.)
  });
}

/// Add a specific widget ID to the prevention list
void addWidgetToContextMenuPrevention(String widgetId) {
  _preventedWidgetIds.add(widgetId);
}

/// Remove a specific widget ID from the prevention list
void removeWidgetFromContextMenuPrevention(String widgetId) {
  _preventedWidgetIds.remove(widgetId);
}

/// Disable context menu prevention
/// This will restore browser's default context menu behavior
void disableContextMenuPrevention() {
  if (!_isContextMenuPreventionActive) return;
  
  _isContextMenuPreventionActive = false;
  
  // Cancel the subscription
  _contextMenuSubscription?.cancel();
  _contextMenuSubscription = null;
  
  // Clear all prevented widget IDs
  _preventedWidgetIds.clear();
}

/// Check if context menu prevention is currently active
bool isContextMenuPreventionActive() {
  return _isContextMenuPreventionActive;
}

/// Toggle context menu prevention
void toggleContextMenuPrevention() {
  if (_isContextMenuPreventionActive) {
    disableContextMenuPrevention();
  } else {
    enableContextMenuPrevention();
  }
}

/// Enable context menu prevention for a specific widget
/// This is a more targeted approach than global prevention
void enableContextMenuPreventionForWidget(String widgetId) {
  addWidgetToContextMenuPrevention(widgetId);
  
  // Ensure global prevention is active
  if (!_isContextMenuPreventionActive) {
    enableContextMenuPrevention();
  }
}

/// Disable context menu prevention for a specific widget
void disableContextMenuPreventionForWidget(String widgetId) {
  removeWidgetFromContextMenuPrevention(widgetId);
  
  // If no widgets need prevention, disable global prevention
  if (_preventedWidgetIds.isEmpty && _isContextMenuPreventionActive) {
    disableContextMenuPrevention();
  }
} 