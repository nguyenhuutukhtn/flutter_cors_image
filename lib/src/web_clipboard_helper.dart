// Web-specific clipboard implementation
import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;
import 'types.dart';

/// Copy image to clipboard on web for pasting in other applications
Future<bool> copyImageToClipboardWeb(ImageDataInfo imageData) async {
  print('🔍 PROD DEBUG: copyImageToClipboardWeb called');
  print('🔍 PROD DEBUG: imageData: ${imageData.imageBytes.length} bytes, ${imageData.width}x${imageData.height}');
  
  try {
    // Method 1: Use modern Clipboard API with ClipboardItem
    final supportsClipboard = _supportsClipboardAPI();
    print('🔍 PROD DEBUG: Browser supports Clipboard API: $supportsClipboard');
    
    if (supportsClipboard) {
      print('🔍 PROD DEBUG: Trying modern Clipboard API method');
      final success = await _copyWithClipboardAPI(imageData);
      print('🔍 PROD DEBUG: Clipboard API result: $success');
      if (success) return true;
    }
    
    // Method 2: Try alternative canvas-based approach
    print('🔍 PROD DEBUG: Trying canvas-based method');
    final canvasSuccess = await _copyWithCanvasMethod(imageData);
    print('🔍 PROD DEBUG: Canvas method result: $canvasSuccess');
    if (canvasSuccess) return true;
    
    // Method 3: Fallback for older browsers
    print('🔍 PROD DEBUG: Trying fallback method');
    final fallbackResult = await _copyWithFallback(imageData);
    print('🔍 PROD DEBUG: Fallback method result: $fallbackResult');
    return fallbackResult;
    
  } catch (e) {
    print('❌ PROD DEBUG: copyImageToClipboardWeb exception: $e');
    print('❌ PROD DEBUG: Exception stack trace: ${StackTrace.current}');
    return false;
  }
}

/// Download image as file on web (separate from clipboard copying)
Future<bool> downloadImageWeb(ImageDataInfo imageData) async {
  print('🔍 PROD DEBUG: downloadImageWeb called');
  print('🔍 PROD DEBUG: imageData: ${imageData.imageBytes.length} bytes, ${imageData.width}x${imageData.height}');
  
  try {
    // Create a blob from the image bytes
    print('🔍 PROD DEBUG: Creating blob from image bytes');
    final blob = html.Blob([imageData.imageBytes], 'image/png');
    print('🔍 PROD DEBUG: Blob created: ${blob.size} bytes, type: ${blob.type}');
    
    // Create a URL for the blob
    print('🔍 PROD DEBUG: Creating object URL from blob');
    final url = html.Url.createObjectUrlFromBlob(blob);
    print('🔍 PROD DEBUG: Object URL created: $url');
    
    // Create a download link
    final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.png';
    print('🔍 PROD DEBUG: Creating download anchor with filename: $fileName');
    final anchor = html.AnchorElement(href: url);
    anchor.download = fileName;
    
    // Append to body, click, and remove
    print('🔍 PROD DEBUG: Appending anchor to body and triggering click');
    html.document.body!.append(anchor);
    anchor.click();
    anchor.remove();
    
    // Clean up the URL
    print('🔍 PROD DEBUG: Cleaning up object URL');
    html.Url.revokeObjectUrl(url);
    
    print('✅ PROD DEBUG: Download completed successfully');
    return true;
    
  } catch (e) {
    print('❌ PROD DEBUG: downloadImageWeb exception: $e');
    print('❌ PROD DEBUG: Exception stack trace: ${StackTrace.current}');
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
  print('🔍 PROD DEBUG: _copyWithClipboardAPI called');
  
  try {
    // Create blob from image bytes with explicit MIME type
    print('🔍 PROD DEBUG: Creating blob for clipboard API');
    final blob = html.Blob([imageData.imageBytes], 'image/png');
    print('🔍 PROD DEBUG: Blob created: ${blob.size} bytes, type: ${blob.type}');
    
    // Simple JavaScript approach that's more reliable
    print('🔍 PROD DEBUG: Calling _simpleClipboardCopy');
    final success = await _simpleClipboardCopy(blob);
    print('🔍 PROD DEBUG: _simpleClipboardCopy result: $success');
    
    if (success) {
      return true;
    } else {
      return false;
    }
    
  } catch (e) {
    print('❌ PROD DEBUG: _copyWithClipboardAPI exception: $e');
    print('❌ PROD DEBUG: Exception stack trace: ${StackTrace.current}');
    return false;
  }
}

/// Simple clipboard copy using direct JavaScript
Future<bool> _simpleClipboardCopy(html.Blob blob) async {
  print('🔍 PROD DEBUG: _simpleClipboardCopy called with blob: ${blob.size} bytes');
  
  try {
    final completer = Completer<bool>();
    
    // Use a simpler approach that's less prone to errors
    print('🔍 PROD DEBUG: Creating JavaScript function for clipboard copy');
    final script = html.document.createElement('script');
    script.text = '''
      window.copyImageToClipboard = async function(blob) {
        try {
          console.log('🔍 JS DEBUG: copyImageToClipboard called with blob:', blob.size, 'bytes');
          const clipboardItem = new ClipboardItem({ 'image/png': blob });
          console.log('🔍 JS DEBUG: ClipboardItem created');
          await navigator.clipboard.write([clipboardItem]);
          console.log('✅ JS DEBUG: Clipboard write successful');
          return true;
        } catch (e) {
          console.error('❌ JS DEBUG: Clipboard copy failed:', e);
          return false;
        }
      };
    ''';
    
    html.document.head!.append(script);
    print('🔍 PROD DEBUG: JavaScript function injected');
    
    // Call the function
    print('🔍 PROD DEBUG: Converting blob to JS object');
    final jsBlob = js.JsObject.fromBrowserObject(blob);
    print('🔍 PROD DEBUG: Calling copyImageToClipboard JavaScript function');
    final promise = js.context.callMethod('copyImageToClipboard', [jsBlob]);
    print('🔍 PROD DEBUG: JavaScript function called, promise: ${promise != null}');
    
    // Handle the promise
    final thenCallback = js.allowInterop((result) {
      print('🔍 PROD DEBUG: JavaScript promise resolved with result: $result');
      completer.complete(result == true);
      script.remove(); // Clean up
    });
    
    final catchCallback = js.allowInterop((error) {
      print('❌ PROD DEBUG: JavaScript promise rejected with error: $error');
      completer.complete(false);
      script.remove(); // Clean up
    });
    
    if (promise != null) {
      promise.callMethod('then', [thenCallback]).callMethod('catch', [catchCallback]);
    } else {
      // Promise not supported
      print('❌ PROD DEBUG: Promise not supported by browser');
      completer.complete(false);
      script.remove();
    }
    
    final result = await completer.future;
    print('🔍 PROD DEBUG: _simpleClipboardCopy final result: $result');
    return result;
    
  } catch (e) {
    print('❌ PROD DEBUG: _simpleClipboardCopy exception: $e');
    print('❌ PROD DEBUG: Exception stack trace: ${StackTrace.current}');
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
Future<bool> _copyWithCanvasMethod(ImageDataInfo imageData) async {
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