import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
// Conditional import for web-specific context menu functionality
import 'web_context_menu_disable_helper.dart' if (dart.library.io) 'stub_context_menu_disable_helper.dart';

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

class _DisableWebContextMenuState extends State<DisableWebContextMenu> implements DisableWebContextMenuHandler {
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
    if (widget.enabled && !_isRegistered) {
      registerContextMenuWidget(this);
      _isRegistered = true;
    } else if (!widget.enabled && _isRegistered) {
      unregisterContextMenuWidget(this);
      _isRegistered = false;
    }
  }

  @override
  void dispose() {
    if (_isRegistered) {
      unregisterContextMenuWidget(this);
    }
    super.dispose();
  }
  
  /// Simple bounds check - only called when context menu is triggered
  @override
  bool isPointInBounds(Offset point) {
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
  @override
  void triggerContextMenu(Offset position) {
    if (widget.onContextMenu != null) {
      widget.onContextMenu!(position);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
} 