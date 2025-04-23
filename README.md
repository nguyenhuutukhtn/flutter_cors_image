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

### 2. ProxyNetworkImage (Recommended for CORS issues)

This is a more robust solution that:
1. Uses an iframe to load the image directly, completely bypassing CORS restrictions
2. Works reliably with images that have unusual formats or server configurations
3. Falls back to a standard Image.network on non-web platforms

## Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_cors_image: ^0.1.0
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
            
            // CustomNetworkImage
            Text('CustomNetworkImage'),
            CustomNetworkImage(
              url: 'https://example.com/image-with-cors-issues.jpg',
              width: 300,
              height: 200,
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
