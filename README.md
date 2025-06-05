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

**New in v0.1.7**: Enhanced error handling with reload and "open in new tab" buttons, plus full internationalization support.

### 2. ProxyNetworkImage (Recommended for CORS issues)

This is a more robust solution that:
1. Uses an iframe to load the image directly, completely bypassing CORS restrictions
2. Works reliably with images that have unusual formats or server configurations
3. Falls back to a standard Image.network on non-web platforms

## Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_cors_image: ^0.1.7
```

## Usage

Import the package:

```dart
import 'package:flutter_cors_image/flutter_cors_image.dart';
```

### Using CustomNetworkImage:

```dart
CustomNetworkImage(
  url: 'https://example.com/image.jpg',
  width: 300,
  height: 200,
  fit: BoxFit.cover,
)
```

### Using CustomNetworkImage with Internationalization:

```dart
CustomNetworkImage(
  url: 'https://example.com/image.jpg',
  width: 300,
  height: 200,
  fit: BoxFit.cover,
  // Internationalization support
  errorText: 'Imagen no disponible', // Spanish
  reloadText: 'Recargar imagen',
  openUrlText: 'Abrir en nueva pestaña',
)
```

### Icon-only Error Display:

For universal language support, you can omit the text parameters to show only icons:

```dart
CustomNetworkImage(
  url: 'https://example.com/image.jpg',
  width: 300,
  height: 200,
  fit: BoxFit.cover,
  // No text parameters = icon-only mode
  // Shows: ⚠️ (error), 🔄 (reload button), 🔗 (open URL button)
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

## Internationalization Support

The `CustomNetworkImage` widget now supports full internationalization for error handling:

| Parameter | Type | Description |
|-----------|------|-------------|
| `errorText` | `String?` | Custom error message text. Shows "⚠️ [errorText]" or just "⚠️" if null |
| `reloadText` | `String?` | Custom reload button text. Shows "🔄 [reloadText]" or just "🔄" if null |
| `openUrlText` | `String?` | Custom "open in new tab" button text. Shows "🔗 [openUrlText]" or just "🔗" if null |

### Examples for Different Languages:

```dart
// English
CustomNetworkImage(
  url: imageUrl,
  errorText: 'Image failed to load',  // Shows: ⚠️ Image failed to load
  reloadText: 'Reload Image',         // Button: 🔄 Reload Image
  openUrlText: 'Open in New Tab',     // Button: 🔗 Open in New Tab
)

// Spanish
CustomNetworkImage(
  url: imageUrl,
  errorText: 'Error al cargar imagen',      // Shows: ⚠️ Error al cargar imagen
  reloadText: 'Recargar imagen',            // Button: 🔄 Recargar imagen
  openUrlText: 'Abrir en nueva pestaña',    // Button: 🔗 Abrir en nueva pestaña
)

// French
CustomNetworkImage(
  url: imageUrl,
  errorText: 'Échec du chargement de l\'image',    // Shows: ⚠️ Échec du chargement de l'image
  reloadText: 'Recharger l\'image',                // Button: 🔄 Recharger l'image
  openUrlText: 'Ouvrir dans un nouvel onglet',     // Button: 🔗 Ouvrir dans un nouvel onglet
)

// Icon-only (universal)
CustomNetworkImage(
  url: imageUrl,
  // No text parameters - shows only icons: ⚠️, 🔄, 🔗
)
```

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
        title: Text('Flutter CORS Image Example'),
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
            
            // CustomNetworkImage with internationalization
            Text('CustomNetworkImage with i18n'),
            CustomNetworkImage(
              url: 'https://example.com/image-with-cors-issues.jpg',
              width: 300,
              height: 200,
              errorText: 'Image failed to load',
              reloadText: 'Retry',
              openUrlText: 'Open Image',
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
