import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'types.dart';
import 'image_clipboard_helper.dart';
import 'text_clipboard_helper.dart';
import 'web_context_menu_helper.dart' if (dart.library.io) 'stub_context_menu_helper.dart';

/// Custom context menu widget for image actions
class ImageContextMenu extends StatelessWidget {
  final Offset position;
  final List<ContextMenuItem> items;
  final Color? backgroundColor;
  final Color? textColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final ImageDataInfo? imageData;
  final String imageUrl;
  final VoidCallback onDismiss;
  final Function(ContextMenuAction)? onAction;

  const ImageContextMenu({
    Key? key,
    required this.position,
    required this.items,
    required this.imageUrl,
    required this.onDismiss,
    this.backgroundColor,
    this.textColor,
    this.elevation,
    this.borderRadius,
    this.padding,
    this.imageData,
    this.onAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions to ensure menu fits
    final screenSize = MediaQuery.of(context).size;
    final menuWidth = 250.0;
    final estimatedMenuHeight = items.length * 48.0 + 16.0; // Rough estimate
    
    // Adjust position to keep menu on screen
    double left = position.dx;
    double top = position.dy;
    
    // Ensure menu doesn't go off right edge
    if (left + menuWidth > screenSize.width) {
      left = screenSize.width - menuWidth - 16;
    }
    
    // Ensure menu doesn't go off bottom edge
    if (top + estimatedMenuHeight > screenSize.height) {
      top = screenSize.height - estimatedMenuHeight - 16;
    }
    
    // Ensure menu doesn't go off left edge
    if (left < 0) left = 16;
    
    // Ensure menu doesn't go off top edge
    if (top < 0) top = 16;
    
    return Material(
      color: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Invisible overlay to capture taps outside the menu
          Positioned.fill(
            child: GestureDetector(
              onTap: onDismiss,
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          // The actual context menu
          Positioned(
            left: left,
            top: top,
            child: Material(
              elevation: elevation ?? 8.0,
              borderRadius: borderRadius ?? BorderRadius.circular(8.0),
              color: backgroundColor ?? Colors.white,
              child: Container(
                width: menuWidth,
                padding: padding ?? const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: items.map((item) => _buildMenuItem(context, item)).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, ContextMenuItem item) {
    return InkWell(
      onTap: () => _handleMenuItemTap(context, item),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.icon != null) ...[
              Icon(
                item.icon,
                size: 20,
                color: textColor ?? Colors.black87,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                item.title,
                style: TextStyle(
                  color: textColor ?? Colors.black87,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuItemTap(BuildContext context, ContextMenuItem item) async {
    // Store the context before dismissing the menu
    final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
    
    // Dismiss the menu first
    onDismiss();
    
    // Call the action callback
    if (onAction != null) {
      onAction!(item.action);
    }
    
    // Handle built-in actions
    switch (item.action) {
      case ContextMenuAction.copyImage:
        await _copyImage();
        _showMessageWithMessenger(scaffoldMessenger, 'Image copied to clipboard');
        break;
      case ContextMenuAction.saveImage:
        final success = await _saveImage();
        if (success) {
          _showMessageWithMessenger(scaffoldMessenger, '✅ Image saved successfully!');
        } else {
          _showMessageWithMessenger(scaffoldMessenger, '❌ Failed to save image');
        }
        break;
      case ContextMenuAction.openImageInNewTab:
        await _openImageInNewTab();
        _showMessageWithMessenger(scaffoldMessenger, 'Opening image in new tab');
        break;
      case ContextMenuAction.copyImageUrl:
        await _copyImageUrl();
        _showMessageWithMessenger(scaffoldMessenger, 'Image URL copied to clipboard');
        break;
      case ContextMenuAction.custom:
        // Custom actions are handled by the onTap callback
        if (item.onTap != null) {
          item.onTap!();
        }
        break;
    }
  }
  
  
  /// Show a feedback message using a pre-obtained ScaffoldMessenger
  void _showMessageWithMessenger(ScaffoldMessengerState? scaffoldMessenger, String message) {
    try {
      if (scaffoldMessenger != null) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            backgroundColor: message.contains('✅') ? Colors.green : 
                           message.contains('❌') ? Colors.red : null,
          ),
        );
      } 
    } catch (e) {
      // ScaffoldMessenger is no longer valid, ignore the message
      if (kDebugMode) {
        print('Could not show message "$message" - ScaffoldMessenger error: $e');
      }
    }
  }

  Future<void> _copyImage() async {
    if (imageData != null) {
      try {
        await ImageClipboardHelper.copyImageToClipboard(imageData!);
      } catch (e) {
        if (kDebugMode) {
          print('Failed to copy image: $e');
        }
      }
    }
  }

  Future<bool> _saveImage() async {
    try {
      if (imageData != null) {

        final success = await ImageClipboardHelper.downloadImage(imageData!);
        if (!success) {
          final urlSuccess = await _downloadImageFromUrl();
          return urlSuccess;
        }
        return success;
      } else {
        // Fallback: download directly from URL
   
        final urlSuccess = await _downloadImageFromUrl();
        return urlSuccess;
      }
    } catch (e) {
 
      try {
        final fallbackSuccess = await _downloadImageFromUrl();
        return fallbackSuccess;
      } catch (fallbackError) {
        return false;
      }
    }
  }
  
  /// Fallback method to download image directly from URL when image data is not available
  Future<bool> _downloadImageFromUrl() async {
    return await downloadImageFromUrl(imageUrl);
  }

  Future<void> _openImageInNewTab() async {
    try {
      openUrlInNewTab(imageUrl);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to open image in new tab: $e');
      }
    }
  }

  Future<void> _copyImageUrl() async {
    try {
      await TextClipboardHelper.copyTextToClipboard(imageUrl);
    } catch (e) {
      if (kDebugMode){
        print('Failed to copy image URL: $e');
      }
    }
  }

  /// Default context menu items similar to browser image context menu
  static List<ContextMenuItem> get defaultItems => [
    const ContextMenuItem(
      title: 'Copy image',
      icon: Icons.copy,
      action: ContextMenuAction.copyImage,
    ),
    const ContextMenuItem(
      title: 'Save image as...',
      icon: Icons.download,
      action: ContextMenuAction.saveImage,
    ),
    const ContextMenuItem(
      title: 'Open image in new tab',
      icon: Icons.open_in_new,
      action: ContextMenuAction.openImageInNewTab,
    ),
    const ContextMenuItem(
      title: 'Copy image address',
      icon: Icons.link,
      action: ContextMenuAction.copyImageUrl,
    ),
  ];
} 