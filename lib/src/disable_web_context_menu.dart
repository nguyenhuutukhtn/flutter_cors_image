import 'dart:js_interop';
import 'package:web/web.dart' as html;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';



/// Global context menu handler using simple bounds checking
class _GlobalContextMenuHandler {
  static html.EventListener? _contextMenuListener;
  static int _activeImageWidgets = 0;
  static final Set<_DisableWebContextMenuState> _activeWidgets = {};
  
  static void enable() {
    if (_contextMenuListener != null) return;
    
    _contextMenuListener = (html.Event event) {
      if (event.type == 'contextmenu') {
        if (event is html.MouseEvent) {
          final mouseEvent = event as html.MouseEvent;
          final clickPoint = Offset(mouseEvent.clientX.toDouble(), mouseEvent.clientY.toDouble());
          
          // Simple approach: check each widget's bounds directly
          _DisableWebContextMenuState? targetWidget;
          
          for (final widget in _activeWidgets) {
            if (widget._isPointInBounds(clickPoint)) {
              targetWidget = widget;
              break; // Found the first matching widget
            }
          }
          
          if (targetWidget != null) {
            // Over image - prevent and show custom menu
            event.preventDefault();
            event.stopPropagation();
            
            // Trigger custom context menu
            targetWidget._triggerContextMenu(clickPoint);
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
  
  static void addWidget(_DisableWebContextMenuState widget) {
    _activeWidgets.add(widget);
    _activeImageWidgets++;
    
    if (_activeImageWidgets == 1) {
      enable();
    }
  }
  
  static void removeWidget(_DisableWebContextMenuState widget) {
    _activeWidgets.remove(widget);
    _activeImageWidgets--;
    
    if (_activeImageWidgets <= 0) {
      _activeImageWidgets = 0;
      disable();
    }
  }
}

/// Widget that registers itself for context menu handling
class DisableWebContextMenu extends StatefulWidget {
  const DisableWebContextMenu({
    super.key,
    required this.child,
    required this.identifier,
    this.onContextMenu,
    this.enabled = true, // PERFORMANCE: Allow disabling registration
  });

  final String identifier;
  final Widget child;
  final Function(Offset position)? onContextMenu;
  final bool enabled; // PERFORMANCE: Control whether to register global handlers

  @override
  State<DisableWebContextMenu> createState() => _DisableWebContextMenuState();
}

class _DisableWebContextMenuState extends State<DisableWebContextMenu> {
  bool _isRegistered = false;

  @override
  void initState() {
    super.initState();
    _updateRegistration();
  }

  @override
  void didUpdateWidget(DisableWebContextMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled != widget.enabled) {
      _updateRegistration();
    }
  }

  void _updateRegistration() {
    // PERFORMANCE FIX: Only register when enabled and on web
    if (kIsWeb && widget.enabled && !_isRegistered) {
      _GlobalContextMenuHandler.addWidget(this);
      _isRegistered = true;
    } else if ((!kIsWeb || !widget.enabled) && _isRegistered) {
      _GlobalContextMenuHandler.removeWidget(this);
      _isRegistered = false;
    }
  }

  @override
  void dispose() {
    if (_isRegistered) {
      _GlobalContextMenuHandler.removeWidget(this);
    }
    super.dispose();
  }
  
  /// Simple bounds check - only called when context menu is triggered
  bool _isPointInBounds(Offset point) {
    if (!mounted) return false;
    
    try {
      final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox?.hasSize == true) {
        final position = renderBox!.localToGlobal(Offset.zero);
        final size = renderBox.size;
        final bounds = Rect.fromLTWH(position.dx, position.dy, size.width, size.height);
        return bounds.contains(point);
      }
    } catch (e) {
      // Ignore errors
    }
    
    return false;
  }
  
  /// Trigger the context menu callback
  void _triggerContextMenu(Offset position) {
    if (widget.onContextMenu != null) {
      widget.onContextMenu!(position);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
} 