import 'dart:html' as html;
import 'dart:async';
// Import UI correctly for web
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart' show Matrix4;

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
          print('Triggering HTML error callback for $viewId');
          _htmlImageErrorCallbacks[viewId]!();
        }
      }

      // Helper function to trigger success callback
      void triggerSuccessCallback() {
        if (_htmlImageSuccessCallbacks.containsKey(viewId)) {
          print('Triggering HTML success callback for $viewId');
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
        print('HTML image loading timeout, triggering error callback');
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
          print('HTML image loaded successfully');
          triggerSuccessCallback();
        });
          
        // Add error handler to try fallback without CORS
        imgElement.onError.listen((event) {
          print('HTML image load error, trying direct embed...');
          
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
            print('Direct HTML image loaded successfully');
            triggerSuccessCallback();
          });
            
          // Handle error in the last resort approach - trigger Flutter callback
          directImgElement.onError.listen((_) {
            print('Direct HTML image also failed, triggering error callback');
            directImgElement.remove();
            clearTimeoutForViewId();
            // NEW v0.2.0: Trigger Flutter callback instead of showing HTML error
            triggerErrorCallback();
          });
            
          div.append(directImgElement);
        });
        
        div.append(imgElement);
      } catch (e) {
        print('Error creating HTML image element: $e');
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

/// Opens a URL in a new tab/window (web only)
void openUrlInNewTab(String url) {
  html.window.open(url, '_blank');
} 