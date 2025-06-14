import 'dart:html' as html;
import 'dart:async';
// Import UI correctly for web
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart' show Matrix4;
import 'dart:js' as js show context, allowInterop, JsObject;
import 'dart:typed_data';

/// Global callback map to handle taps for specific view IDs
final Map<String, Function> _htmlImageTapCallbacks = {};

/// Global callback map to handle HTML image errors for specific view IDs
final Map<String, Function> _htmlImageErrorCallbacks = {};

/// Global callback map to handle HTML image success for specific view IDs  
final Map<String, Function> _htmlImageSuccessCallbacks = {};

/// Mapping of viewIds to their HTML div elements for transformation
final Map<String, html.Element> _htmlElements = {};

/// Mapping of viewIds to their timeout timers for cleanup
final Map<String, Timer> _timeoutTimers = {};

/// Fetch image bytes with CORS workaround for web platforms
Future<Uint8List?> fetchImageBytesWithCors(String imageUrl, {Function(double)? onProgress}) async {
  try {
    // Use fetch API with multiple fallback strategies to avoid preflight requests
    final completer = Completer<Uint8List?>();
    
    // Check if the function already exists in window to avoid duplicate scripts
    final functionName = 'fetchImageBytes${imageUrl.hashCode}';
    final existingFunction = js.context[functionName];
    
    if (existingFunction == null) {
      final script = html.document.createElement('script');
      script.text = '''
        window.$functionName = async function(progressCallback) {
          try {
            let response;
            let usedCors = false;
            
            // Strategy 1: Try simple fetch first (no preflight)
            try {
              response = await fetch('$imageUrl', {
                method: 'GET',
                cache: 'no-cache'
                // No custom headers to avoid preflight
              });
              
              if (response.ok && response.type !== 'opaque') {
                usedCors = true;
              }
            } catch (e) {
              response = null;
            }
            
            // Strategy 2: Try no-cors mode if simple fetch failed
            if (!response || !response.ok) {
              try {
                response = await fetch('$imageUrl', {
                  method: 'GET',
                  mode: 'no-cors',
                  cache: 'no-cache'
                });
                usedCors = false; // no-cors means we can't read the response
              } catch (e) {
                response = null;
              }
            }
            
            // Strategy 3: Try CORS mode as last resort
            if (!response || (!response.ok && response.type !== 'opaque')) {
              try {
                response = await fetch('$imageUrl', {
                  method: 'GET',
                  mode: 'cors',
                  cache: 'no-cache'
                });
                usedCors = true;
              } catch (e) {
                response = null;
              }
            }
            
            if (!response) {
              return null;
            }
            
            // If we got an opaque response (no-cors), we can't read the data
            // This is a limitation of no-cors mode
            if (response.type === 'opaque' || !usedCors) {
              return null;
            }
            
            if (!response.ok) {
              return null;
            }
            
            // Try to get content length for progress
            let contentLength = null;
            try {
              const contentLengthHeader = response.headers.get('Content-Length');
              if (contentLengthHeader) {
                contentLength = parseInt(contentLengthHeader, 10);
              }
            } catch (e) {
              // Ignore header reading errors
            }
            
            // Read the response as a stream if possible for progress tracking
            if (response.body && response.body.getReader && progressCallback && contentLength) {
              const reader = response.body.getReader();
              const chunks = [];
              let receivedLength = 0;
              
              try {
                while (true) {
                  const { done, value } = await reader.read();
                  
                  if (done) break;
                  
                  chunks.push(value);
                  receivedLength += value.length;
                  
                  // Report progress
                  if (progressCallback && contentLength > 0) {
                    const progress = receivedLength / contentLength;
                    progressCallback(Math.min(progress, 1.0));
                  }
                }
                
                // Combine chunks into single array
                const totalLength = chunks.reduce((acc, chunk) => acc + chunk.length, 0);
                const result = new Uint8Array(totalLength);
                let offset = 0;
                
                for (const chunk of chunks) {
                  result.set(chunk, offset);
                  offset += chunk.length;
                }
                
                // Convert to regular Array to avoid interop issues
                const regularArray = Array.from(result);
                return {
                  data: regularArray,
                  size: totalLength,
                  contentType: response.headers.get('Content-Type') || 'image/unknown'
                };
                
              } catch (streamError) {
                // Fall back to arrayBuffer if streaming fails
                try {
                  const arrayBuffer = await response.arrayBuffer();
                  const uint8Array = new Uint8Array(arrayBuffer);
                  const regularArray = Array.from(uint8Array);
                  return {
                    data: regularArray,
                    size: arrayBuffer.byteLength,
                    contentType: response.headers.get('Content-Type') || 'image/unknown'
                  };
                } catch (arrayBufferError) {
                  return null;
                }
              }
            } else {
              // No streaming support or no progress callback, use arrayBuffer directly
              try {
                const arrayBuffer = await response.arrayBuffer();
                const uint8Array = new Uint8Array(arrayBuffer);
                const regularArray = Array.from(uint8Array);
                return {
                  data: regularArray,
                  size: arrayBuffer.byteLength,
                  contentType: response.headers.get('Content-Type') || 'image/unknown'
                };
              } catch (arrayBufferError) {
                return null;
              }
            }
            
          } catch (error) {
            return null;
          }
        };
      ''';
      
      html.document.head!.append(script);
    }
    
    // Create progress callback
    final progressCallback = onProgress != null ? js.allowInterop((double progress) {
      onProgress(progress);
    }) : null;
    
    // Call the function
    final promise = js.context.callMethod(functionName, [progressCallback]);
    
    // Handle the promise
    final thenCallback = js.allowInterop((result) {
      if (result != null) {
        try {
          // Extract data from the result object
          final jsResult = result as js.JsObject;
          final jsArray = jsResult['data'] as js.JsObject;
          final length = jsArray['length'] as int;
          
          // Create Dart Uint8List and copy data
          final dartList = Uint8List(length);
          for (int i = 0; i < length; i++) {
            // Convert each element to int (JS numbers to Dart ints)
            final value = jsArray[i];
            if (value is num) {
              dartList[i] = value.toInt();
            } else {
              dartList[i] = int.parse(value.toString());
            }
          }
          
          completer.complete(dartList);
          
        } catch (conversionError) {
          completer.complete(null);
        }
      } else {
        completer.complete(null);
      }
    });
    
    final catchCallback = js.allowInterop((error) {
      completer.complete(null);
    });
    
    if (promise != null) {
      promise.callMethod('then', [thenCallback]).callMethod('catch', [catchCallback]);
    } else {
      completer.complete(null);
    }
    
    final result = await completer.future;
    return result;
    
  } catch (e) {
    return null;
  }
}

/// Clean up JavaScript function to prevent memory leaks
void cleanupCorsFunction(String imageUrl) {
  final functionName = 'fetchImageBytes${imageUrl.hashCode}';
  try {
    if (js.context[functionName] != null) {
      js.context.deleteProperty(functionName);
    }
  } catch (e) {
    // Ignore cleanup errors
  }
}

/// Sets the tap callback function for a specific HTML image
void setHtmlImageTapCallback(String viewId, Function callback) {
  _htmlImageTapCallbacks[viewId] = callback;
}

/// Sets the error callback function for a specific HTML image
void setHtmlImageErrorCallback(String viewId, Function callback) {
  _htmlImageErrorCallbacks[viewId] = callback;
}

/// Sets the success callback function for a specific HTML image
void setHtmlImageSuccessCallback(String viewId, Function callback) {
  _htmlImageSuccessCallbacks[viewId] = callback;
}

/// Applies a Flutter transformation matrix to an HTML image element
void updateHtmlImageTransform(String viewId, Matrix4 matrix) {
  final element = _htmlElements[viewId];
  if (element == null) return;
  
  // Extract all values from the 4x4 matrix
  // This captures more precise transformations including scale, translation, and any other transformations
  final values = [
    matrix.storage[0], matrix.storage[1], matrix.storage[4], 
    matrix.storage[5], matrix.storage[12], matrix.storage[13]
  ];
  
  // Apply the CSS transformation using the full matrix values
  // This format matches the CSS matrix() function: matrix(a, b, c, d, tx, ty)
  element.style.transform = 'matrix(${values[0]}, ${values[1]}, ${values[2]}, ${values[3]}, ${values[4]}, ${values[5]})';
  element.style.transformOrigin = 'center center';
}

/// Registers an HTML view factory for displaying images
/// This is used only on web platform
/// 
/// In v0.2.0+, HTML errors are handled via callbacks to Flutter widgets
void registerHtmlImageFactory(String viewId, String url) {
  // Register a web platform view factory
  ui_web.platformViewRegistry.registerViewFactory(
    viewId,
    (int viewIdParam) {
      // Create a div to hold the image
      final div = html.DivElement()
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.display = 'flex'
        ..style.alignItems = 'center'
        ..style.justifyContent = 'center'
        ..style.cursor = 'pointer'
        ..style.overflow = 'hidden'
        ..style.transformOrigin = 'center center'
        ..style.transition = 'transform 0.01s linear'; // Add a very slight transition for smoother updates
        
      // Store the element for later transformation
      _htmlElements[viewId] = div;
        
      // Add click event to the div with stopPropagation to prevent event bubbling
      div.addEventListener('click', (event) {
        // Stop event propagation to prevent triggering other elements' click events
        event.stopPropagation();
        event.preventDefault();
        
        // If a callback is registered for this specific viewId, invoke it
        if (_htmlImageTapCallbacks.containsKey(viewId)) {
          _htmlImageTapCallbacks[viewId]!();
        }
      });

      // Helper function to trigger error callback
      void triggerErrorCallback() {
        if (_htmlImageErrorCallbacks.containsKey(viewId)) {
          _htmlImageErrorCallbacks[viewId]!();
        }
      }

      // Helper function to trigger success callback
      void triggerSuccessCallback() {
        if (_htmlImageSuccessCallbacks.containsKey(viewId)) {
          _htmlImageSuccessCallbacks[viewId]!();
        }
      }

      // Helper function to clear timeout
      void clearTimeoutForViewId() {
        if (_timeoutTimers.containsKey(viewId)) {
          _timeoutTimers[viewId]!.cancel();
          _timeoutTimers.remove(viewId);
        }
      }

      // Set a timeout as fallback in case both image attempts fail silently
      _timeoutTimers[viewId] = Timer(const Duration(seconds: 2), () {
        triggerErrorCallback();
      });
        
      try {
        // First try direct image with CORS settings
        final imgElement = html.ImageElement()
          ..src = url
          ..crossOrigin = 'anonymous'  // Try with CORS
          ..style.objectFit = 'contain'  // Changed to contain for better zoom behavior
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.maxWidth = '100%'
          ..style.maxHeight = '100%'
          ..style.pointerEvents = 'none'; // Prevent image from interfering with gestures

        // Clear timeout on successful load
        imgElement.onLoad.listen((_) {
          clearTimeoutForViewId();
          triggerSuccessCallback();
        });
          
        // Add error handler to try fallback without CORS
        imgElement.onError.listen((event) {
          // If CORS fails, remove the crossOrigin attribute and try again
          imgElement.remove();
          
          // Create img without CORS attribute as last resort
          final directImgElement = html.ImageElement()
            ..src = url
            ..style.objectFit = 'contain'  // Changed to contain for better zoom behavior
            ..style.width = '100%'
            ..style.height = '100%'
            ..style.maxWidth = '100%'
            ..style.maxHeight = '100%'
            ..style.pointerEvents = 'none'; // Prevent image from interfering with gestures

          // Clear timeout on successful load of direct image
          directImgElement.onLoad.listen((_) {
            clearTimeoutForViewId();
            triggerSuccessCallback();
          });
            
          // Handle error in the last resort approach - trigger Flutter callback
          directImgElement.onError.listen((_) {
            directImgElement.remove();
            clearTimeoutForViewId();
            // NEW v0.2.0: Trigger Flutter callback instead of showing HTML error
            triggerErrorCallback();
          });
            
          div.append(directImgElement);
        });
        
        div.append(imgElement);
      } catch (e) {
        clearTimeoutForViewId();
        // NEW v0.2.0: Trigger Flutter callback instead of showing HTML error
        triggerErrorCallback();
      }
      
      return div;
    },
  );
}

/// Remove a tap callback when no longer needed
void removeHtmlImageTapCallback(String viewId) {
  _htmlImageTapCallbacks.remove(viewId);
}

/// Remove an error callback when no longer needed
void removeHtmlImageErrorCallback(String viewId) {
  _htmlImageErrorCallbacks.remove(viewId);
}

/// Remove a success callback when no longer needed
void removeHtmlImageSuccessCallback(String viewId) {
  _htmlImageSuccessCallbacks.remove(viewId);
}

/// Cleanup HTML elements when no longer needed
void cleanupHtmlElement(String viewId) {
  // Cancel and remove any associated timer
  if (_timeoutTimers.containsKey(viewId)) {
    _timeoutTimers[viewId]!.cancel();
    _timeoutTimers.remove(viewId);
  }
  _htmlElements.remove(viewId);
}

