# Flutter CORS Image

[![pub package](https://img.shields.io/pub/v/flutter_cors_image.svg)](https://pub.dev/packages/flutter_cors_image)

A Flutter package that provides image loading solutions for handling CORS issues and problematic images on web platforms.

## Features

This package offers two different approaches to solve image loading issues:

### 1. CustomNetworkImage

This approach follows this strategy:
1. First, try to load the image using Flutter's normal `Image.network` widget
2. If that fails on web platforms, automatically fall back to using an HTML img tag
3. On native platforms, fall back to using `ExtendedImage` for additional compatibility

**New in v0.2.0**: Widget-based error handling with customizable error, reload, and open URL widgets. HTML errors now callback to Flutter for consistent UI across platforms.

### 2. ProxyNetworkImage (Recommended for CORS issues)

This is a more robust solution that:
1. Uses an iframe to load the image directly, completely bypassing CORS restrictions
2. Works reliably with images that have unusual formats or server configurations
3. Falls back to a standard Image.network on non-web platforms

## Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_cors_image: ^0.2.0
```

## Usage

Import the package:

```dart
import 'package:flutter_cors_image/flutter_cors_image.dart';
```

### Using CustomNetworkImage (v0.2.0+ Recommended):

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

### Using CustomNetworkImage with Backward Compatibility:

⚠️ **Deprecated in v0.2.0** (still works but shows warnings):

```dart
CustomNetworkImage(
  url: 'https://example.com/image.jpg',
  width: 300,
  height: 200,
  fit: BoxFit.cover,
  // DEPRECATED: Use widget parameters instead
  errorText: 'Imagen no disponible', // Spanish
  reloadText: 'Recargar imagen',
  openUrlText: 'Abrir en nueva pestaña',
)
```

### Using ProxyNetworkImage (Recommended for CORS issues):

```dart
ProxyNetworkImage(
  url: 'https://example.com/image-with-cors-issues.jpg',
  width: 300,
  height: 200,
  fit: BoxFit.cover,
)
```

Both widgets support all standard parameters from Image.network:

```dart
ProxyNetworkImage(
  url: 'https://example.com/image.jpg',
  width: 300,
  height: 200,
  fit: BoxFit.cover,
  // Standard Image.network parameters
  headers: {'Authorization': 'Bearer token'},
  cacheWidth: 600,
  cacheHeight: 400,
  scale: 1.0,
  // ...and more
)
```

## Widget-based Error Handling (v0.2.0+)

The `CustomNetworkImage` widget now supports flexible widget-based error handling:

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

// Cupertino Style
CustomNetworkImage(
  url: imageUrl,
  errorWidget: Container(
    padding: EdgeInsets.all(8),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(CupertinoIcons.exclamationmark_triangle, color: CupertinoColors.systemRed),
        SizedBox(height: 4),
        Text('Image Error', style: TextStyle(fontSize: 12)),
      ],
    ),
  ),
  reloadWidget: CupertinoButton(
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(CupertinoIcons.refresh),
        SizedBox(width: 4),
        Text('Reload'),
      ],
    ),
    onPressed: null, // Handled automatically
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

## Migration Guide v0.1.x → v0.2.0

### Breaking Changes
- HTML errors now callback to Flutter instead of showing HTML-based error UI
- String-based error parameters are deprecated (but still work)

### Migration Steps

**Step 1**: Update your dependency
```yaml
dependencies:
  flutter_cors_image: ^0.2.0
```

**Step 2**: Replace deprecated string parameters with widgets

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
)
```

**Step 3**: Test your app
- Deprecated parameters will show warnings but continue to work
- New widget parameters provide more flexibility and better integration

## Example

Here's an example comparing both approaches:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_cors_image/flutter_cors_image.dart';

class ExampleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter CORS Image v0.2.0 Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ProxyNetworkImage (recommended)
            Text('ProxyNetworkImage (Recommended)'),
            ProxyNetworkImage(
              url: 'https://example.com/image-with-cors-issues.jpg',
              width: 300,
              height: 200,
            ),
            
            SizedBox(height: 20),
            
            // CustomNetworkImage with new widget-based error handling
            Text('CustomNetworkImage v0.2.0'),
            CustomNetworkImage(
              url: 'https://example.com/image-with-cors-issues.jpg',
              width: 300,
              height: 200,
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
                    Text('Custom Error Widget'),
                  ],
                ),
              ),
              reloadWidget: ElevatedButton.icon(
                onPressed: null,
                icon: Icon(Icons.refresh),
                label: Text('Custom Reload'),
              ),
              openUrlWidget: TextButton.icon(
                onPressed: null,
                icon: Icon(Icons.open_in_new),
                label: Text('Custom Open'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Real-world Example

The ProxyNetworkImage works with images like:
- `https://example.com/image-with-cors-issues.jpg`

Which typically fails with standard Flutter Image.network due to CORS restrictions.

## License

MIT
