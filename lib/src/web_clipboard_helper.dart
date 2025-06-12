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
      final success = await _copyWithClipboardAPI(imageData);
      if (success) return true;
    }
    
    // Method 2: Try alternative canvas-based approach
    final canvasSuccess = await _copyWithCanvasMethod(imageData);
    if (canvasSuccess) return true;
    
    // Method 3: Fallback for older browsers
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
    // Create blob from image bytes with explicit MIME type
    final blob = html.Blob([imageData.imageBytes], 'image/png');
    
    // Simple JavaScript approach that's more reliable
    final success = await _simpleClipboardCopy(blob);
    
    if (success) {
      print('Image copied to clipboard successfully!');
      return true;
    } else {
      print('ClipboardAPI method failed, trying fallback...');
      return false;
    }
    
  } catch (e) {
    print('ClipboardAPI method failed: $e');
    return false;
  }
}

/// Simple clipboard copy using direct JavaScript
Future<bool> _simpleClipboardCopy(html.Blob blob) async {
  try {
    final completer = Completer<bool>();
    
    // Use a simpler approach that's less prone to errors
    final script = html.ScriptElement();
    script.text = '''
      window.copyImageToClipboard = async function(blob) {
        try {
          const clipboardItem = new ClipboardItem({ 'image/png': blob });
          await navigator.clipboard.write([clipboardItem]);
          return true;
        } catch (e) {
          console.error('Clipboard copy failed:', e);
          return false;
        }
      };
    ''';
    
    html.document.head!.append(script);
    
    // Call the function
    final jsBlob = js.JsObject.fromBrowserObject(blob);
    final promise = js.context.callMethod('copyImageToClipboard', [jsBlob]);
    
    // Handle the promise
    final thenCallback = js.allowInterop((result) {
      completer.complete(result == true);
      script.remove(); // Clean up
    });
    
    final catchCallback = js.allowInterop((error) {
      print('Simple clipboard copy failed: $error');
      completer.complete(false);
      script.remove(); // Clean up
    });
    
    if (promise != null) {
      promise.callMethod('then', [thenCallback]).callMethod('catch', [catchCallback]);
    } else {
      // Promise not supported
      completer.complete(false);
      script.remove();
    }
    
    return await completer.future;
    
  } catch (e) {
    print('Simple clipboard copy error: $e');
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

/// Alternative canvas-based copying method
Future<bool> _copyWithCanvasMethod(ImageDataInfo imageData) async {
  try {
    print('Trying canvas-based clipboard copy...');
    
    // Create canvas and draw image
    final canvas = html.CanvasElement(width: imageData.width, height: imageData.height);
    final ctx = canvas.context2D;
    
    // Create ImageData and put it on canvas
    final imageDataJs = ctx.createImageData(imageData.width, imageData.height);
    final data = imageDataJs.data;
    
    // Convert PNG bytes to RGBA format for canvas
    // This is a simplified approach - for full PNG decoding, we'd need a proper decoder
    // For now, let's use the blob approach which should work better
    
    final blob = html.Blob([imageData.imageBytes], 'image/png');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final img = html.ImageElement();
    
    final completer = Completer<bool>();
    
    img.onLoad.listen((_) async {
      try {
        // Draw image to canvas
        ctx.clearRect(0, 0, imageData.width, imageData.height);
        ctx.drawImageScaled(img, 0, 0, imageData.width, imageData.height);
        
        // Try to copy canvas content to clipboard
        final success = await _copyCanvasToClipboard(canvas);
        html.Url.revokeObjectUrl(url);
        completer.complete(success);
        
      } catch (e) {
        html.Url.revokeObjectUrl(url);
        completer.complete(false);
      }
    });
    
    img.onError.listen((_) {
      html.Url.revokeObjectUrl(url);
      completer.complete(false);
    });
    
    img.src = url;
    return await completer.future;
    
  } catch (e) {
    print('Canvas method failed: $e');
    return false;
  }
}

/// Copy canvas content to clipboard
Future<bool> _copyCanvasToClipboard(html.CanvasElement canvas) async {
  try {
    // Convert canvas to blob
    final completer = Completer<html.Blob?>();
    
    canvas.toBlob().then((blob) {
      completer.complete(blob);
    }).catchError((error) {
      completer.complete(null);
    });
    
    final blob = await completer.future;
    if (blob == null) return false;
    
    // Use the simple JavaScript method to copy
    return await _simpleClipboardCopy(blob);
    
  } catch (e) {
    print('Canvas to clipboard failed: $e');
    return false;
  }
} 