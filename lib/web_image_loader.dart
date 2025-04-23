import 'dart:html' as html;
// Import UI correctly for web
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart' show Matrix4;

/// Global callback map to handle taps for specific view IDs
final Map<String, Function> _htmlImageTapCallbacks = {};

/// Mapping of viewIds to their HTML div elements for transformation
final Map<String, html.Element> _htmlElements = {};

/// Sets the tap callback function for a specific HTML image
void setHtmlImageTapCallback(String viewId, Function callback) {
  _htmlImageTapCallbacks[viewId] = callback;
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
          
        // Add error handler to show fallback UI
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
            
            // Handle error in the last resort approach
            directImgElement.onError.listen((_) {
              directImgElement.remove();
              _showErrorPlaceholder(div);
            });
            
            div.append(directImgElement);
        });
        
        div.append(imgElement);
      } catch (e) {
        print('Error creating HTML image element: $e');
        _showErrorPlaceholder(div);
      }
      
      return div;
    },
  );
}

/// Remove a tap callback when no longer needed
void removeHtmlImageTapCallback(String viewId) {
  _htmlImageTapCallbacks.remove(viewId);
}

/// Cleanup HTML elements when no longer needed
void cleanupHtmlElement(String viewId) {
  _htmlElements.remove(viewId);
}

/// Show an error placeholder when all image loading attempts fail
void _showErrorPlaceholder(html.Element container) {
  // Clear container
  container.children.clear();
  
  // Create error message
  final errorDiv = html.DivElement()
    ..style.display = 'flex'
    ..style.flexDirection = 'column'
    ..style.alignItems = 'center'
    ..style.justifyContent = 'center'
    ..style.width = '100%'
    ..style.height = '100%'
    ..style.backgroundColor = '#f0f0f0';
    
  // Error icon
  final iconDiv = html.DivElement()
    ..style.fontSize = '36px'
    ..style.color = '#d32f2f'
    ..style.marginBottom = '8px'
    ..innerText = '⚠️';
    
  // Error text
  final textDiv = html.DivElement()
    ..style.color = '#444'
    ..style.textAlign = 'center'
    ..style.padding = '0 8px'
    ..innerText = 'Image failed to load';
    
  errorDiv.append(iconDiv);
  errorDiv.append(textDiv);
  container.append(errorDiv);
} 