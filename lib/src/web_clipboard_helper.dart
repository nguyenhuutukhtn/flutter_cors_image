// Web-specific clipboard implementation
import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;
import 'types.dart';

/// Copy image to clipboard on web platform
Future<bool> copyImageToClipboardWeb(ImageDataInfo imageData) async {
  try {
    // Check if the browser supports the Clipboard API
    final supportsClipboard = js.context.hasProperty('navigator') &&
        js.context['navigator'].hasProperty('clipboard');
    
    if (supportsClipboard) {
      // Try modern Clipboard API method
      final success = await _copyWithClipboardAPI(imageData);
      if (success) return true;
      
      // Try canvas-based method
      final canvasSuccess = await _copyWithCanvas(imageData);
      if (canvasSuccess) return true;
      
      // Try fallback method
      final fallbackResult = await _copyWithFallback(imageData);
      return fallbackResult;
    }
    
    return false;
  } catch (e) {
    return false;
  }
}

/// Download image as file on web (separate from clipboard copying)
Future<bool> downloadImageWeb(ImageDataInfo imageData) async {

  
  try {
    // Create a blob from the image bytes
    final blob = html.Blob([imageData.imageBytes], 'image/png');
    
    // Create a URL for the blob
    final url = html.Url.createObjectUrlFromBlob(blob);
    
    // Create a download link
    final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.png';
    final anchor = html.AnchorElement(href: url);
    anchor.download = fileName;
    
    // Append to body, click, and remove
    html.document.body!.append(anchor);
    anchor.click();
    anchor.remove();
    
    // Clean up the URL
    html.Url.revokeObjectUrl(url);
    return true;
    
  } catch (e) {
    return false;
  }
}

/// Check if browser supports modern Clipboard API
// bool _supportsClipboardAPI() {
//   try {
//     return js.context.hasProperty('navigator') &&
//            js.context['navigator'].hasProperty('clipboard') &&
//            js.context['navigator']['clipboard'].hasProperty('write');
//   } catch (e) {
//     return false;
//   }
// }

/// Copy using modern Clipboard API (works in most modern browsers)
Future<bool> _copyWithClipboardAPI(ImageDataInfo imageData) async {
  try {
    // Create blob from image bytes with explicit MIME type
    final blob = html.Blob([imageData.imageBytes], 'image/png');
    
    // Simple JavaScript approach that's more reliable
    final success = await _simpleClipboardCopy(blob);
    
    return success;
    
  } catch (e) {
    return false;
  }
}

/// Simple clipboard copy using direct JavaScript
Future<bool> _simpleClipboardCopy(html.Blob blob) async {
  try {
    final completer = Completer<bool>();
    
    // Use a simpler approach that's less prone to errors
    final script = html.document.createElement('script');
    script.text = '''
      window.copyImageToClipboard = async function(blob) {
        try {
          const clipboardItem = new ClipboardItem({ 'image/png': blob });
          await navigator.clipboard.write([clipboardItem]);
          return true;
        } catch (e) {
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
    
    final result = await completer.future;
    return result;
    
  } catch (e) {
    return false;
  }
}

/// Copy with fallback method (canvas approach)
Future<bool> _copyWithFallback(ImageDataInfo imageData) async {
  try {
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
      
      return true;
    }
    
    // Clean up
    html.Url.revokeObjectUrl(url);
    return false;
    
  } catch (e) {
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
Future<bool> _copyWithCanvas(ImageDataInfo imageData) async {
  try {
    // Create canvas and draw image
    final canvas = html.CanvasElement(width: imageData.width, height: imageData.height);
    final ctx = canvas.context2D;
    
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
    return false;
  }
} 