# Flutter CORS Image

[![pub package](https://img.shields.io/pub/v/flutter_cors_image.svg)](https://pub.dev/packages/flutter_cors_image)

A Flutter package that provides advanced image loading solutions for handling CORS issues, with modern hover icons, clipboard functionality, right-click context menus, and image data access.

## Features

This package provides comprehensive image loading solutions:

### CustomNetworkImage

This approach follows this strategy:
1. First, try to load the image using Flutter's normal `Image.network` widget
2. If that fails on web platforms, automatically fall back to using an HTML img tag
3. On native platforms, fall back to using `ExtendedImage` for additional compatibility

**New in v0.3.3**: Right-click context menu with native browser-like functionality for web platforms.

**New in v0.3.0**: Hover icons with customizable positioning, image data callbacks, and advanced clipboard/download functionality.

**New in v0.2.0**: Widget-based error handling with customizable error, reload, and open URL widgets. HTML errors now callback to Flutter for consistent UI across platforms.

## Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_cors_image: ^0.3.3
```

## Usage

Import the package:

```dart
import 'package:flutter_cors_image/flutter_cors_image.dart';
```

### Using Right-Click Context Menu (v0.3.3+):

```dart
CustomNetworkImage(
  url: 'https://example.com/image.jpg',
  width: 300,
  height: 200,
  fit: BoxFit.cover,
  
  // ✅ NEW v0.3.3: Right-click context menu (web only)
  enableContextMenu: true,
  
  // ✅ Handle context menu actions
  onContextMenuAction: (action) {
    print('Context menu action: $action');
    // Actions: copyImage, saveImage, openImageInNewTab, copyImageUrl, custom
  },
  
  // ✅ Custom context menu styling
  contextMenuBackgroundColor: Colors.grey[800],
  contextMenuTextColor: Colors.white,
  contextMenuElevation: 8.0,
  contextMenuBorderRadius: BorderRadius.circular(8),
)
```

### Custom Context Menu Items (v0.3.3+):

```dart
CustomNetworkImage(
  url: 'https://example.com/image.jpg',
  enableContextMenu: true,
  
  // ✅ NEW: Custom menu items with icons and actions
  customContextMenuItems: [
    ContextMenuItem(
      title: 'Download Image',
      icon: Icons.download,
      action: ContextMenuAction.saveImage,
    ),
    ContextMenuItem(
      title: 'Copy to Clipboard',
      icon: Icons.copy,
      action: ContextMenuAction.copyImage,
    ),
    ContextMenuItem(
      title: 'Share Image',
      icon: Icons.share,
      action: ContextMenuAction.custom,
      onTap: () {
        // Custom share functionality
        print('Share image action!');
      },
    ),
  ],
  
  // ✅ Custom styling
  contextMenuBackgroundColor: Colors.grey[800],
  contextMenuTextColor: Colors.white,
  contextMenuElevation: 12.0,
  contextMenuBorderRadius: BorderRadius.circular(12),
  contextMenuPadding: EdgeInsets.all(8),
)
```

### Using CustomNetworkImage with Hover Icons (v0.3.0+):

```dart
CustomNetworkImage(
  url: 'https://example.com/image.jpg',
  width: 300,
  height: 200,
  fit: BoxFit.cover,
  
  // ✅ v0.3.0: Hover icons for quick actions
  downloadIcon: Icon(Icons.download, color: Colors.white, size: 20),
  copyIcon: Icon(Icons.copy, color: Colors.white, size: 20),
  hoverIconPosition: HoverIconPosition.topRight,
  hoverIconLayout: HoverIconLayout.auto,
  hoverIconSpacing: 8.0,
  hoverIconPadding: EdgeInsets.all(8),
  
  // ✅ v0.3.3: Combine with context menu
  enableContextMenu: true,
  
  // ✅ v0.3.0: Get image data when loaded
  onImageLoaded: (ImageDataInfo imageData) {
    print('Image ready! Size: ${imageData.width}x${imageData.height}');
    // imageData.imageBytes contains raw PNG data for copying/saving
  },
  
  // ✅ Custom action callbacks
  onDownloadTap: () => print('Custom download action!'),
  onCopyTap: () => print('Custom copy action!'),
  onContextMenuAction: (action) => print('Context menu: $action'),
)
```

### Advanced Hover Icon Styling:

```dart
CustomNetworkImage(
  url: 'https://example.com/image.jpg',
  width: 400,
  height: 300,
  
  // Custom styled download icon
  downloadIcon: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.blue[400]!, Colors.blue[600]!],
      ),
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
    ),
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.download, color: Colors.white, size: 16),
        SizedBox(width: 4),
        Text('Download', style: TextStyle(color: Colors.white, fontSize: 12)),
      ],
    ),
  ),
  
  // Custom styled copy icon
  copyIcon: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.green[400]!, Colors.green[600]!],
      ),
      borderRadius: BorderRadius.circular(8),
    ),
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.copy, color: Colors.white, size: 16),
        SizedBox(width: 4),
        Text('Copy', style: TextStyle(color: Colors.white, fontSize: 12)),
      ],
    ),
  ),
  
  hoverIconPosition: HoverIconPosition.bottomRight,
  hoverIconLayout: HoverIconLayout.row,
)
```

### Using Image Data for Copy/Download Operations (v0.3.0+):

```dart
class ImageCopyExample extends StatefulWidget {
  @override
  _ImageCopyExampleState createState() => _ImageCopyExampleState();
}

class _ImageCopyExampleState extends State<ImageCopyExample> {
  ImageDataInfo? _imageData;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomNetworkImage(
          url: 'https://example.com/image.jpg',
          onImageLoaded: (imageData) {
            setState(() => _imageData = imageData);
          },
        ),
        
        if (_imageData != null) ...[
          ElevatedButton(
            onPressed: () async {
              final success = await ImageClipboardHelper.downloadImage(_imageData!);
              // Downloads PNG file to computer
            },
            child: Text('Download Image'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await ImageClipboardHelper.copyImageToClipboard(_imageData!);
              // Copies image to clipboard for Ctrl+V pasting
            },
            child: Text('Copy to Clipboard'),
          ),
        ],
      ],
    );
  }
}
```

### Using CustomNetworkImage with Error Handling (v0.2.0+):

```dart
CustomNetworkImage(
  url: 'https://example.com/image.jpg',
  width: 300,
  height: 200,
  fit: BoxFit.cover,
  // NEW v0.2.0: Widget-based error handling
  errorWidget: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.error, color: Colors.red),
      SizedBox(width: 8),
      Text('Image failed to load'),
    ],
  ),
  reloadWidget: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.refresh),
      SizedBox(width: 8),
      Text('Reload Image'),
    ],
  ),
  openUrlWidget: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.open_in_new),
      SizedBox(width: 8),
      Text('Open in New Tab'),
    ],
  ),
)
```

## Hover Icons & Positioning (v0.3.0+)

### Available Positions

```dart
enum HoverIconPosition {
  topLeft,      // Icons in top-left corner
  topRight,     // Icons in top-right corner (default)
  bottomLeft,   // Icons in bottom-left corner
  bottomRight,  // Icons in bottom-right corner
  topCenter,    // Icons centered at top
  bottomCenter, // Icons centered at bottom
}
```

### Layout Options

```dart
enum HoverIconLayout {
  auto,    // Smart layout: vertical for corners, horizontal for center
  row,     // Always horizontal layout
  column,  // Always vertical layout
}
```

### Customization Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `downloadIcon` | `Widget?` | `null` | Custom download icon widget |
| `copyIcon` | `Widget?` | `null` | Custom copy icon widget |
| `hoverIconPosition` | `HoverIconPosition` | `topRight` | Position of hover icons |
| `hoverIconLayout` | `HoverIconLayout` | `auto` | Layout direction (row/column) |
| `enableHoverIcons` | `bool` | `true` | Enable/disable hover functionality |
| `hoverIconSpacing` | `double` | `8.0` | Space between icons |
| `hoverIconPadding` | `EdgeInsetsGeometry` | `EdgeInsets.zero` | Padding around icons |
| `onDownloadTap` | `VoidCallback?` | `null` | Custom download action |
| `onCopyTap` | `VoidCallback?` | `null` | Custom copy action |

## Image Data Access (v0.3.0+)

### ImageDataInfo Class

```dart
class ImageDataInfo {
  final Uint8List imageBytes;  // Raw PNG image data
  final int width;             // Image width in pixels
  final int height;            // Image height in pixels
  final String url;            // Original image URL
}
```

### Clipboard & Download Methods

```dart
// Copy image to system clipboard (for Ctrl+V pasting)
bool success = await ImageClipboardHelper.copyImageToClipboard(imageData);

// Download image as PNG file
bool success = await ImageClipboardHelper.downloadImage(imageData);
```

### Platform Support

| Platform | Clipboard Copy | File Download |
|----------|----------------|---------------|
| **Web** | ✅ Modern Clipboard API | ✅ Blob download |
| **Mobile** | ⚠️ Basic support* | ✅ Temp directory |
| **Desktop** | ⚠️ File path copy | ✅ Temp directory |

*For enhanced mobile clipboard support, consider adding plugins like `clipboard_manager` or `pasteboard`.

## Widget-based Error Handling (v0.2.0+)

The `CustomNetworkImage` widget supports flexible widget-based error handling:

| Parameter | Type | Description |
|-----------|------|-------------|
| `errorWidget` | `Widget?` | Custom widget to show when image fails to load |
| `reloadWidget` | `Widget?` | Custom widget for retry functionality |
| `openUrlWidget` | `Widget?` | Custom widget for opening image URL in new tab |

### Examples for Different UI Styles:

```dart
// Material Design Style
CustomNetworkImage(
  url: imageUrl,
  errorWidget: Container(
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.red.shade50,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.error_outline, color: Colors.red),
        SizedBox(width: 8),
        Text('Failed to load image', style: TextStyle(color: Colors.red)),
      ],
    ),
  ),
  reloadWidget: ElevatedButton.icon(
    onPressed: null, // Handled automatically
    icon: Icon(Icons.refresh),
    label: Text('Retry'),
  ),
  openUrlWidget: TextButton.icon(
    onPressed: null, // Handled automatically
    icon: Icon(Icons.open_in_new),
    label: Text('Open URL'),
  ),
)

// Icon-only (minimal)
CustomNetworkImage(
  url: imageUrl,
  errorWidget: Icon(Icons.broken_image, size: 48, color: Colors.grey),
  reloadWidget: Icon(Icons.refresh, size: 24),
  openUrlWidget: Icon(Icons.open_in_new, size: 24),
)
```

## Right-Click Context Menu (v0.3.3+)

### Available Context Menu Actions

```dart
enum ContextMenuAction {
  copyImage,           // Copy image to system clipboard
  saveImage,           // Save image with file picker dialog
  openImageInNewTab,   // Open image URL in new browser tab
  copyImageUrl,        // Copy image URL to clipboard
  custom,              // Custom action with onTap callback
}
```

### Context Menu Customization

```dart
CustomNetworkImage(
  url: imageUrl,
  enableContextMenu: true,
  
  // Custom menu items
  customContextMenuItems: [
    ContextMenuItem(
      title: 'Download HD',
      icon: Icons.hd,
      action: ContextMenuAction.custom,
      onTap: () => downloadHDVersion(),
    ),
    ContextMenuItem(
      title: 'Set as Wallpaper',
      icon: Icons.wallpaper,
      action: ContextMenuAction.custom,
      onTap: () => setAsWallpaper(),
    ),
  ],
  
  // Styling options
  contextMenuBackgroundColor: Colors.black87,
  contextMenuTextColor: Colors.white,
  contextMenuElevation: 16.0,
  contextMenuBorderRadius: BorderRadius.circular(12),
  contextMenuPadding: EdgeInsets.symmetric(vertical: 8),
  
  // Action handler
  onContextMenuAction: (action) {
    switch (action) {
      case ContextMenuAction.copyImage:
        // Image automatically copied to clipboard
        showSnackBar('Image copied to clipboard!');
        break;
      case ContextMenuAction.saveImage:
        // Save dialog automatically shown
        showSnackBar('Save dialog opened');
        break;
      // ... handle other actions
    }
  },
)
```

### Context Menu Features

| Feature | Description |
|---------|-------------|
| **Smart Positioning** | Automatically adjusts position to stay on screen |
| **Browser Integration** | Uses File System Access API for native save dialogs |
| **Toast Notifications** | Shows success/failure feedback for actions |
| **Clipboard Support** | Copies images and URLs to system clipboard |
| **Custom Actions** | Add your own menu items with custom callbacks |
| **Styling Control** | Full control over colors, elevation, and spacing |
| **State Awareness** | Works during loading, loaded, error, and HTML fallback states |

### Platform Support

| Platform | Context Menu | Save Dialog | Clipboard Copy |
|----------|--------------|-------------|----------------|
| **Web** | ✅ Full support | ✅ File System Access API | ✅ Clipboard API |
| **Desktop** | ⚠️ Limited | ⚠️ Downloads folder | ⚠️ Basic support |
| **Mobile** | ❌ Not applicable | ❌ Not applicable | ❌ Not applicable |

*Note: Context menus are primarily designed for web platforms where right-click functionality is standard.*

## Migration Guide

### v0.2.x → v0.3.0

#### **No Breaking Changes**
All v0.2.x code continues to work unchanged. New features are additive and optional.

#### **Gradual Enhancement**
Add new features progressively:

```dart
// Step 1: Start with basic image loading (existing code works)
CustomNetworkImage(
  url: imageUrl,
  width: 300,
  height: 200,
)

// Step 2: Add image data callback
CustomNetworkImage(
  url: imageUrl,
  width: 300,
  height: 200,
  onImageLoaded: (imageData) {
    // Now you have access to image bytes, dimensions, etc.
  },
)

// Step 3: Add hover icons
CustomNetworkImage(
  url: imageUrl,
  width: 300,
  height: 200,
  onImageLoaded: (imageData) => _imageData = imageData,
  downloadIcon: Icon(Icons.download, color: Colors.white),
  copyIcon: Icon(Icons.copy, color: Colors.white),
)

// Step 4: Customize positioning and styling
CustomNetworkImage(
  url: imageUrl,
  width: 300,
  height: 200,
  onImageLoaded: (imageData) => _imageData = imageData,
  downloadIcon: _buildStyledDownloadIcon(),
  copyIcon: _buildStyledCopyIcon(),
  hoverIconPosition: HoverIconPosition.bottomRight,
  hoverIconLayout: HoverIconLayout.row,
  hoverIconSpacing: 12.0,
  hoverIconPadding: EdgeInsets.all(8),
)
```

### v0.1.x → v0.3.0

Update your dependency and replace deprecated parameters:

```dart
// OLD (deprecated but still works)
CustomNetworkImage(
  url: imageUrl,
  errorText: 'Image failed to load',
  reloadText: 'Reload Image',
  openUrlText: 'Open in New Tab',
)

// NEW (recommended)
CustomNetworkImage(
  url: imageUrl,
  errorWidget: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.error, color: Colors.red),
      SizedBox(width: 8),
      Text('Image failed to load'),
    ],
  ),
  reloadWidget: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.refresh),
      SizedBox(width: 8),
      Text('Reload Image'),
    ],
  ),
  openUrlWidget: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.open_in_new),
      SizedBox(width: 8),
      Text('Open in New Tab'),
    ],
  ),
  
  // ✅ Add new features
  downloadIcon: Icon(Icons.download, color: Colors.white),
  copyIcon: Icon(Icons.copy, color: Colors.white),
  onImageLoaded: (imageData) {
    // Access to image data for copy/download operations
  },
)
```

### v0.3.2 → v0.3.3

#### **No Breaking Changes**
All v0.3.2 code continues to work unchanged. Context menu is an optional feature.

#### **Adding Context Menu**
```dart
// Existing code (still works)
CustomNetworkImage(
  url: imageUrl,
  downloadIcon: Icon(Icons.download),
  copyIcon: Icon(Icons.copy),
)

// Enhanced with context menu
CustomNetworkImage(
  url: imageUrl,
  downloadIcon: Icon(Icons.download),
  copyIcon: Icon(Icons.copy),
  
  // ✅ Add context menu
  enableContextMenu: true,
  onContextMenuAction: (action) {
    print('Context action: $action');
  },
)
```

## Complete Example

Here's a comprehensive example showing all v0.3.0 features:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_cors_image/flutter_cors_image.dart';

class AdvancedImageExample extends StatefulWidget {
  @override
  _AdvancedImageExampleState createState() => _AdvancedImageExampleState();
}

class _AdvancedImageExampleState extends State<AdvancedImageExample> {
  ImageDataInfo? _imageData;
  HoverIconPosition _position = HoverIconPosition.topRight;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flutter CORS Image v0.3.0')),
      body: Column(
        children: [
          // Position selector
          Wrap(
            children: HoverIconPosition.values.map((pos) {
              return ChoiceChip(
                label: Text(pos.name),
                selected: _position == pos,
                onSelected: (selected) {
                  if (selected) setState(() => _position = pos);
                },
              );
            }).toList(),
          ),
          
          // Main image with hover icons
          Expanded(
            child: Center(
              child: CustomNetworkImage(
                url: 'https://example.com/image.jpg',
                width: 400,
                height: 300,
                fit: BoxFit.cover,
                
                // Styled hover icons
                downloadIcon: _buildDownloadIcon(),
                copyIcon: _buildCopyIcon(),
                hoverIconPosition: _position,
                hoverIconLayout: HoverIconLayout.auto,
                hoverIconSpacing: 8.0,
                hoverIconPadding: EdgeInsets.all(8),
                
                // Image data callback
                onImageLoaded: (imageData) {
                  setState(() => _imageData = imageData);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Image loaded! Hover to see icons')),
                  );
                },
                
                // Custom actions
                onDownloadTap: () => _handleDownload(),
                onCopyTap: () => _handleCopy(),
                
                // Error handling
                errorWidget: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error, color: Colors.red, size: 48),
                      Text('Failed to load image'),
                    ],
                  ),
                ),
                
                // Loading state
                customLoadingBuilder: (context, child, progress) {
                  return Container(
                    width: 400,
                    height: 300,
                    color: Colors.grey[200],
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(value: progress?.progress),
                          if (progress?.progress != null)
                            Text('${(progress!.progress! * 100).toInt()}%'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          // Manual action buttons
          if (_imageData != null) ...[
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _handleDownload,
                    icon: Icon(Icons.download),
                    label: Text('Download'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _handleCopy,
                    icon: Icon(Icons.copy),
                    label: Text('Copy'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildDownloadIcon() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blue, Colors.blueAccent]),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 3)],
      ),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.download, color: Colors.white, size: 16),
          SizedBox(width: 4),
          Text('Download', style: TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
  
  Widget _buildCopyIcon() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.green, Colors.greenAccent]),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 3)],
      ),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.copy, color: Colors.white, size: 16),
          SizedBox(width: 4),
          Text('Copy', style: TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
  
  Future<void> _handleDownload() async {
    if (_imageData == null) return;
    
    final success = await ImageClipboardHelper.downloadImage(_imageData!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Image downloaded!' : 'Download failed'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }
  
  Future<void> _handleCopy() async {
    if (_imageData == null) return;
    
    final success = await ImageClipboardHelper.copyImageToClipboard(_imageData!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success 
          ? 'Image copied! Press Ctrl+V to paste.' 
          : 'Copy failed'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }
}
```

## License

MIT
