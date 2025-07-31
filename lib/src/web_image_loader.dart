import 'package:web/web.dart' as web;
import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
// Import UI correctly for web
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart' show Matrix4, BoxFit;
import 'dart:typed_data';

/// Global callback map to handle taps for specific view IDs
final Map<String, Function> _htmlImageTapCallbacks = {};

/// Global callback map to handle HTML image errors for specific view IDs
final Map<String, Function> _htmlImageErrorCallbacks = {};

/// Global callback map to handle HTML image success for specific view IDs  
final Map<String, Function> _htmlImageSuccessCallbacks = {};

/// Mapping of viewIds to their HTML div elements for transformation
final Map<String, web.HTMLElement> _htmlElements = {};

/// Mapping of viewIds to their timeout timers for cleanup
final Map<String, Timer> _timeoutTimers = {};

/// External JavaScript declarations for global window operations
@JS('window')
external JSObject get windowObject;

/// Helper function to check if a property exists on window
bool hasWindowProperty(String name) {
  return windowObject.hasProperty(name.toJS).toDart;
}

/// Helper function to get a property from window
JSAny? getWindowProperty(String name) {
  return windowObject.getProperty(name.toJS);
}

/// Helper function to set a property on window
void setWindowProperty(String name, JSAny value) {
  windowObject.setProperty(name.toJS, value);
}

/// Helper function to delete a property from window
void deleteWindowProperty(String name) {
  windowObject.delete(name.toJS);
}

/// Helper function to map Flutter BoxFit to CSS object-fit
String _mapBoxFitToCss(BoxFit? boxFit) {
  switch (boxFit) {
    case BoxFit.fill:
      return 'fill';
    case BoxFit.contain:
      return 'contain';
    case BoxFit.cover:
      return 'cover';
    case BoxFit.fitWidth:
      return 'scale-down'; // Closest equivalent - scales down to fit width
    case BoxFit.fitHeight:
      return 'scale-down'; // Closest equivalent - scales down to fit height
    case BoxFit.none:
      return 'none';
    case BoxFit.scaleDown:
      return 'scale-down';
    default:
      return 'contain';
  }
}

/// Fetch image bytes with CORS workaround for web platforms
Future<Uint8List?> fetchImageBytesWithCors(String imageUrl, {Function(double)? onProgress}) async {
  try {
    // Use fetch API with multiple fallback strategies to avoid preflight requests
    final completer = Completer<Uint8List?>();
    
    // Check if the function already exists in window to avoid duplicate scripts
    final functionName = 'fetchImageBytes${imageUrl.hashCode}';
    final existingFunction = getWindowProperty(functionName);
    
    if (existingFunction == null || existingFunction.isUndefinedOrNull) {
      final script = web.document.createElement('script') as web.HTMLScriptElement;
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
      
      web.document.head!.appendChild(script);
    }
    
    // Create progress callback using dart:js_interop
    JSFunction? progressCallback;
    if (onProgress != null) {
      progressCallback = ((double progress) {
        onProgress(progress);
      }).toJS;
    }
    
    // Call the function using proper js_interop
    final jsFunction = getWindowProperty(functionName);
    
    if (jsFunction != null && !jsFunction.isUndefinedOrNull) {
      // Cast to JSFunction to use callAsFunction
      final function = jsFunction as JSFunction;
      final promise = function.callAsFunction(
        windowObject,
        progressCallback,
      );
      
      if (promise != null) {
        try {
          // Convert JS Promise to Dart Future
          final promiseObject = promise as JSPromise<JSAny?>;
          final result = await promiseObject.toDart;
          
          if (result != null && !result.isUndefinedOrNull) {
            try {
              // Extract data from the result object using js_interop_unsafe
              final jsResult = result as JSObject;
              final jsArrayProperty = jsResult.getProperty('data'.toJS);
              final sizeProperty = jsResult.getProperty('size'.toJS);
              
              if (jsArrayProperty != null && sizeProperty != null) {
                final jsArray = jsArrayProperty as JSObject;
                final length = (sizeProperty as JSNumber).toDartInt;
                
                // Create Dart Uint8List and copy data
                final dartList = Uint8List(length);
                for (int i = 0; i < length; i++) {
                  final value = jsArray.getProperty(i.toJS) as JSNumber;
                  dartList[i] = value.toDartInt;
                }
                
                completer.complete(dartList);
              } else {
                completer.complete(null);
              }
              
            } catch (conversionError) {
              completer.complete(null);
            }
          } else {
            completer.complete(null);
          }
        } catch (promiseError) {
          completer.complete(null);
        }
      } else {
        completer.complete(null);
      }
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
    if (hasWindowProperty(functionName)) {
      deleteWindowProperty(functionName);
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

/// Updates the styling of an existing HTML image element
void updateHtmlImageStyling(
  String viewId, {
  BoxFit? boxFit,
  double? borderRadius,
}) {
  final element = _htmlElements[viewId];
  if (element == null) return;
  
  // Find the img element(s) within the div
  final images = element.querySelectorAll('img');
  for (int i = 0; i < images.length; i++) {
    final img = images.item(i) as web.HTMLImageElement?;
    if (img != null) {
      // Update object-fit if BoxFit is provided
      img.style.objectFit = _mapBoxFitToCss(boxFit);
    }
  }
  
  // Update border radius on the container div if provided
  if (borderRadius != null && borderRadius >= 0) {
    if (borderRadius > 0) {
      element.style.borderRadius = '${borderRadius}px';
    } else {
      element.style.borderRadius = '';
    }
  }
}

/// Registers an HTML view factory for displaying images
/// This is used only on web platform
/// 
/// In v0.2.0+, HTML errors are handled via callbacks to Flutter widgets
/// Updated to support Flutter styling parameters: BoxFit and border radius
void registerHtmlImageFactory(
  String viewId, 
  String url, {
  BoxFit boxFit = BoxFit.contain,
  double borderRadius = 0.0,
  double? width,
  double? height,
}) {
  // Register a web platform view factory
  ui_web.platformViewRegistry.registerViewFactory(
    viewId,
    (int viewIdParam) {
      // Create a div to hold the image using package:web
      final div = web.document.createElement('div') as web.HTMLDivElement;
      div.style.width = '100%';
      div.style.height = '100%';
      div.style.display = 'flex';
      div.style.alignItems = 'center';
      div.style.justifyContent = 'center';
      div.style.cursor = 'auto';
      div.style.overflow = 'hidden';
      div.style.transformOrigin = 'center center';
      div.style.transition = 'transform 0.01s linear'; // Add a very slight transition for smoother updates
      div.style.objectFit = _mapBoxFitToCss(boxFit);
      
      // Apply border radius if specified
      if (borderRadius > 0) {
        div.style.borderRadius = '${borderRadius}px';
      }
        
      // Store the element for later transformation
      _htmlElements[viewId] = div;
        
      // Add click event to the div using package:web event handling
      div.addEventListener('click', ((web.Event event) {
        // Stop event propagation to prevent triggering other elements' click events
        event.stopPropagation();
        event.preventDefault();
        
        // If a callback is registered for this specific viewId, invoke it
        if (_htmlImageTapCallbacks.containsKey(viewId)) {
          _htmlImageTapCallbacks[viewId]!();
        }
      }).toJS);

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
        
      // Map BoxFit to CSS object-fit
      final cssObjectFit = _mapBoxFitToCss(boxFit);
      
      try {
        // First try direct image with CORS settings using package:web
        final imgElement = web.document.createElement('img') as web.HTMLImageElement;
        imgElement.src = url;
        imgElement.crossOrigin = 'anonymous';  // Try with CORS
        imgElement.style.objectFit = cssObjectFit;  // Use mapped BoxFit value
        imgElement.style.width = '100%';
        imgElement.style.height = '100%';
        imgElement.style.maxWidth = '100%';
        imgElement.style.maxHeight = '100%';
        imgElement.style.pointerEvents = 'auto'; // Prevent image from interfering with gestures

        // Clear timeout on successful load using package:web event handling
        imgElement.addEventListener('load', ((web.Event event) {
          clearTimeoutForViewId();
          triggerSuccessCallback();
        }).toJS);
          
        // Add error handler to try fallback without CORS
        imgElement.addEventListener('error', ((web.Event event) {
          // If CORS fails, remove the image and try again without CORS
          imgElement.remove();
          
          // Create img without CORS attribute as last resort
          final directImgElement = web.document.createElement('img') as web.HTMLImageElement;
          directImgElement.src = url;
          directImgElement.style.objectFit = cssObjectFit;  // Use mapped BoxFit value
          directImgElement.style.width = '100%';
          directImgElement.style.height = '100%';
          directImgElement.style.maxWidth = '100%';
          directImgElement.style.maxHeight = '100%';
          directImgElement.style.pointerEvents = 'auto'; // Prevent image from interfering with gestures

          // Clear timeout on successful load of direct image
          directImgElement.addEventListener('load', ((web.Event event) {
            clearTimeoutForViewId();
            triggerSuccessCallback();
          }).toJS);
            
          // Handle error in the last resort approach - trigger Flutter callback
          directImgElement.addEventListener('error', ((web.Event event) {
            directImgElement.remove();
            clearTimeoutForViewId();
            // NEW v0.2.0: Trigger Flutter callback instead of showing HTML error
            triggerErrorCallback();
          }).toJS);
            
          div.appendChild(directImgElement);
        }).toJS);
        
        div.appendChild(imgElement);
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

/// Create a FileReader object for reading web files
dynamic createFileReader() {
  return web.FileReader();
}

/// Set up FileReader callbacks
void setFileReaderCallbacks(
  dynamic reader,
  {required Function(Uint8List?) onLoad,
  required Function(String) onError}
) {
  final webReader = reader as web.FileReader;
  
  webReader.addEventListener('load', ((web.Event event) {
    try {
      final result = webReader.result;
      if (result != null) {
        // For FileReader.readAsArrayBuffer, result is an ArrayBuffer
        // Use dynamic typing to avoid web API type issues
        try {
          final buffer = result as dynamic;
          final dartBuffer = buffer.toDart;
          final bytes = dartBuffer.asUint8List();
          onLoad(bytes);
        } catch (e) {
          // Fallback: convert as List<int>
          final bytes = Uint8List.fromList(List<int>.from(result as List));
          onLoad(bytes);
        }
      } else {
        onLoad(null);
      }
    } catch (e) {
      onError(e.toString());
    }
  }).toJS);
  
  webReader.addEventListener('error', ((web.Event event) {
    onError('FileReader error');
  }).toJS);
}

/// Read a web File as array buffer
void readFileAsArrayBuffer(dynamic reader, dynamic file) {
  final webReader = reader as web.FileReader;
  final webFile = file as web.File;
  webReader.readAsArrayBuffer(webFile);
}

/// Read a web Blob as Uint8List
Future<Uint8List?> readBlobAsUint8List(dynamic blob) async {
  try {
    final webBlob = blob as web.Blob;
    final jsArrayBuffer = await webBlob.arrayBuffer().toDart;
    // Use dynamic typing to avoid web API type issues
    final dartBuffer = (jsArrayBuffer as dynamic).toDart;
    return dartBuffer.asUint8List();
  } catch (e) {
    return null;
  }
}

/// Create a data URL from image bytes
String createDataUrlFromBytes(Uint8List bytes) {
  // Convert bytes to base64
  final base64String = web.window.btoa(
    String.fromCharCodes(bytes)
  );
  
  // Create data URL (assuming JPEG/PNG format)
  return 'data:image/png;base64,$base64String';
}

