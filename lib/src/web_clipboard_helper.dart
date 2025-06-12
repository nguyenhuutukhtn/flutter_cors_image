// Web-specific clipboard implementation
import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;
import 'custom_network_image.dart';

/// Copy image to clipboard on web for pasting in other applications
Future<bool> copyImageToClipboardWeb(ImageDataInfo imageData) async {
  try {
    print('Copying image to clipboard...');
    
    // Method 1: Use modern Clipboard API with ClipboardItem
    if (_supportsClipboardAPI()) {
      return await _copyWithClipboardAPI(imageData);
    }
    
    // Method 2: Fallback for older browsers
    return await _copyWithFallback(imageData);
    
  } catch (e) {
    print('Error copying image to clipboard: $e');
    return false;
  }
}

/// Download image as file on web (separate from clipboard copying)
Future<bool> downloadImageWeb(ImageDataInfo imageData) async {
  try {
    print('Downloading image as PNG file...');
    
    // Create a blob from the image bytes
    final blob = html.Blob([imageData.imageBytes], 'image/png');
    
    // Create a URL for the blob
    final url = html.Url.createObjectUrlFromBlob(blob);
    
    // Create a download link
    final anchor = html.AnchorElement(href: url);
    anchor.download = 'image_${DateTime.now().millisecondsSinceEpoch}.png';
    
    // Append to body, click, and remove
    html.document.body!.append(anchor);
    anchor.click();
    anchor.remove();
    
    // Clean up the URL
    html.Url.revokeObjectUrl(url);
    
    print('Image download initiated successfully');
    return true;
    
  } catch (e) {
    print('Error downloading image on web: $e');
    return false;
  }
}

/// Check if browser supports modern Clipboard API
bool _supportsClipboardAPI() {
  try {
    return js.context.hasProperty('navigator') &&
           js.context['navigator'].hasProperty('clipboard') &&
           js.context['navigator']['clipboard'].hasProperty('write');
  } catch (e) {
    return false;
  }
}

/// Copy using modern Clipboard API (works in most modern browsers)
Future<bool> _copyWithClipboardAPI(ImageDataInfo imageData) async {
  try {
    // Create blob from image bytes
    final blob = html.Blob([imageData.imageBytes], 'image/png');
    
    // Use JavaScript to create ClipboardItem and copy
    final jsBlob = js.JsObject.fromBrowserObject(blob);
    
    // Create ClipboardItem using JS
    final clipboardData = js.JsObject(js.context['Object']);
    clipboardData['image/png'] = jsBlob;
    
    final clipboardItem = js.JsObject(js.context['ClipboardItem'], [clipboardData]);
    final clipboardItems = js.JsArray.from([clipboardItem]);
    
    // Write to clipboard
    final promise = js.context['navigator']['clipboard'].callMethod('write', [clipboardItems]);
    
    // Convert JS Promise to Dart Future
    await _promiseToFuture(promise);
    
    print('Image copied to clipboard successfully!');
    return true;
    
  } catch (e) {
    print('ClipboardAPI method failed: $e');
    return false;
  }
}

/// Copy with fallback method (canvas approach)
Future<bool> _copyWithFallback(ImageDataInfo imageData) async {
  try {
    print('Using fallback clipboard method...');
    
    // Create a canvas element
    final canvas = html.CanvasElement();
    canvas.width = imageData.width;
    canvas.height = imageData.height;
    
    final ctx = canvas.context2D;
    
    // Create image element from blob
    final blob = html.Blob([imageData.imageBytes], 'image/png');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final img = html.ImageElement();
    
    // Wait for image to load
    await img.onLoad.first;
    img.src = url;
    
    // Draw image to canvas
    ctx.drawImageScaled(img, 0, 0, imageData.width, imageData.height);
    
    // Convert canvas to blob
    final canvasBlob = await _canvasToBlob(canvas);
    
    if (canvasBlob != null) {
      // Try to copy canvas blob
      final jsBlob = js.JsObject.fromBrowserObject(canvasBlob);
      final clipboardData = js.JsObject(js.context['Object']);
      clipboardData['image/png'] = jsBlob;
      
      final clipboardItem = js.JsObject(js.context['ClipboardItem'], [clipboardData]);
      final promise = js.context['navigator']['clipboard'].callMethod('write', [js.JsArray.from([clipboardItem])]);
      
      await _promiseToFuture(promise);
      
      // Clean up
      html.Url.revokeObjectUrl(url);
      
      print('Image copied via fallback method!');
      return true;
    }
    
    // Clean up
    html.Url.revokeObjectUrl(url);
    return false;
    
  } catch (e) {
    print('Fallback method failed: $e');
    return false;
  }
}

/// Convert canvas to blob
Future<html.Blob?> _canvasToBlob(html.CanvasElement canvas) async {
  try {
    final completer = Completer<html.Blob?>();
    
    // Use the correct toBlob method signature
    canvas.toBlob().then((html.Blob blob) {
      completer.complete(blob);
    }).catchError((error) {
      completer.complete(null);
    });
    
    return await completer.future;
  } catch (e) {
    print('Canvas to blob conversion failed: $e');
    return null;
  }
}

/// Convert JavaScript Promise to Dart Future
Future<void> _promiseToFuture(dynamic jsPromise) async {
  final completer = Completer<void>();
  
  // Handle promise resolution
  final thenCallback = js.allowInterop((result) {
    completer.complete();
  });
  
  // Handle promise rejection
  final catchCallback = js.allowInterop((error) {
    completer.completeError('Promise rejected: $error');
  });
  
  jsPromise.callMethod('then', [thenCallback]).callMethod('catch', [catchCallback]);
  
  return completer.future;
} 