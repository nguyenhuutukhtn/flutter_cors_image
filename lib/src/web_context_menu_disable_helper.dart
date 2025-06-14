import 'dart:js_interop';
import 'package:web/web.dart' as html;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Global context menu handler using simple bounds checking
class GlobalContextMenuHandler {
  static html.EventListener? _contextMenuListener;
  static int _activeImageWidgets = 0;
  static final Set<DisableWebContextMenuHandler> _activeWidgets = {};
  
  static void enable() {
    if (_contextMenuListener != null) return;
    
    _contextMenuListener = (html.Event event) {
      if (event.type == 'contextmenu') {
        if (event is html.MouseEvent) {
          final mouseEvent = event;
          final clickPoint = Offset(mouseEvent.clientX.toDouble(), mouseEvent.clientY.toDouble());
          
          // Simple approach: check each widget's bounds directly
          DisableWebContextMenuHandler? targetWidget;
          
          for (final widget in _activeWidgets) {
            if (widget.isPointInBounds(clickPoint)) {
              targetWidget = widget;
              break; // Found the first matching widget
            }
          }
          
          if (targetWidget != null) {
            // Over image - prevent and show custom menu
            event.preventDefault();
            event.stopPropagation();
            
            // Trigger custom context menu
            targetWidget.triggerContextMenu(clickPoint);
          }
          // If no widget found, allow native context menu (don't prevent)
        }
      }
    }.toJS;
    
    html.document.addEventListener('contextmenu', _contextMenuListener!, true.toJS);
  }
  
  static void disable() {
    if (_contextMenuListener == null) return;
    
    html.document.removeEventListener('contextmenu', _contextMenuListener!, true.toJS);
    _contextMenuListener = null;
    _activeWidgets.clear();
  }
  
  static void addWidget(DisableWebContextMenuHandler widget) {
    _activeWidgets.add(widget);
    _activeImageWidgets++;
    
    if (_activeImageWidgets == 1) {
      enable();
    }
  }
  
  static void removeWidget(DisableWebContextMenuHandler widget) {
    _activeWidgets.remove(widget);
    _activeImageWidgets--;
    
    if (_activeImageWidgets <= 0) {
      _activeImageWidgets = 0;
      disable();
    }
  }
}

/// Interface for widgets that handle context menu disabling
abstract class DisableWebContextMenuHandler {
  bool isPointInBounds(Offset point);
  void triggerContextMenu(Offset position);
}

/// Register a widget for context menu handling
void registerContextMenuWidget(DisableWebContextMenuHandler widget) {
  if (kIsWeb) {
    GlobalContextMenuHandler.addWidget(widget);
  }
}

/// Unregister a widget from context menu handling
void unregisterContextMenuWidget(DisableWebContextMenuHandler widget) {
  if (kIsWeb) {
    GlobalContextMenuHandler.removeWidget(widget);
  }
} 