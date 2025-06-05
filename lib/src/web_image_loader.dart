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
/// 
/// [errorText] - Custom error message text. If null, only icon will be shown.
/// [reloadText] - Custom reload button text. If null, only icon will be shown.
/// [openUrlText] - Custom open URL button text. If null, only icon will be shown.
void registerHtmlImageFactory(
  String viewId, 
  String url, {
  String? errorText,
  String? reloadText,
  String? openUrlText,
}) {
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
              _showErrorPlaceholder(div, url, viewId, errorText: errorText, reloadText: reloadText, openUrlText: openUrlText);
            });
            
            div.append(directImgElement);
        });
        
        div.append(imgElement);
      } catch (e) {
        print('Error creating HTML image element: $e');
        _showErrorPlaceholder(div, url, viewId, errorText: errorText, reloadText: reloadText, openUrlText: openUrlText);
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
/// 
/// [errorText] - Custom error message text. If null, only icon will be shown.
/// [reloadText] - Custom reload button text. If null, only icon will be shown.
/// [openUrlText] - Custom open URL button text. If null, only icon will be shown.
void _showErrorPlaceholder(
  html.Element container, 
  String url, 
  String viewId, {
  String? errorText,
  String? reloadText,
  String? openUrlText,
}) {
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
    ..style.backgroundColor = '#f0f0f0'
    ..style.padding = '16px'
    ..style.boxSizing = 'border-box';
    
  // Error icon with optional text
  final errorMessage = errorText?.isNotEmpty == true ? '⚠️ $errorText' : '⚠️';
  final iconDiv = html.DivElement()
    ..style.fontSize = '24px'
    ..style.color = '#d32f2f'
    ..style.marginBottom = '16px'
    ..style.textAlign = 'center'
    ..innerText = errorMessage;
  
  // Buttons container
  final buttonsContainer = html.DivElement()
    ..style.display = 'flex'
    ..style.flexDirection = 'column'
    ..style.gap = '8px'
    ..style.alignItems = 'center';
  
  // Reload button with icon + text
  final reloadButtonText = reloadText?.isNotEmpty == true ? '🔄 $reloadText' : '🔄';
  final reloadButton = html.ButtonElement()
    ..innerText = reloadButtonText
    ..style.padding = '8px 16px'
    ..style.backgroundColor = '#1976d2'
    ..style.color = 'white'
    ..style.border = 'none'
    ..style.borderRadius = '4px'
    ..style.cursor = 'pointer'
    ..style.fontSize = '14px'
    ..style.fontFamily = 'system-ui, -apple-system, sans-serif';
  
  // Open URL button with icon + text
  final openUrlButtonText = openUrlText?.isNotEmpty == true ? '🔗 $openUrlText' : '🔗';
  final openUrlButton = html.ButtonElement()
    ..innerText = openUrlButtonText
    ..style.padding = '8px 16px'
    ..style.backgroundColor = '#388e3c'
    ..style.color = 'white'
    ..style.border = 'none'
    ..style.borderRadius = '4px'
    ..style.cursor = 'pointer'
    ..style.fontSize = '14px'
    ..style.fontFamily = 'system-ui, -apple-system, sans-serif';
  
  // Add hover effects
  reloadButton.onMouseEnter.listen((_) {
    reloadButton.style.backgroundColor = '#1565c0';
  });
  reloadButton.onMouseLeave.listen((_) {
    reloadButton.style.backgroundColor = '#1976d2';
  });
  
  openUrlButton.onMouseEnter.listen((_) {
    openUrlButton.style.backgroundColor = '#2e7d32';
  });
  openUrlButton.onMouseLeave.listen((_) {
    openUrlButton.style.backgroundColor = '#388e3c';
  });
  
  // Add click handlers
  reloadButton.onClick.listen((event) {
    event.stopPropagation();
    event.preventDefault();
    _reloadImage(container, url, viewId, errorText: errorText, reloadText: reloadText, openUrlText: openUrlText);
  });
  
  openUrlButton.onClick.listen((event) {
    event.stopPropagation();
    event.preventDefault();
    html.window.open(url, '_blank');
  });
  
  // Assemble the error UI
  buttonsContainer.append(reloadButton);
  buttonsContainer.append(openUrlButton);
  
  errorDiv.append(iconDiv);
  errorDiv.append(buttonsContainer);
  container.append(errorDiv);
}

/// Reload the image by re-creating the image elements
void _reloadImage(
  html.Element container, 
  String url, 
  String viewId, {
  String? errorText,
  String? reloadText,
  String? openUrlText,
}) {
  // Clear container
  container.children.clear();
  
  // Show loading indicator
  final loadingDiv = html.DivElement()
    ..style.display = 'flex'
    ..style.alignItems = 'center'
    ..style.justifyContent = 'center'
    ..style.width = '100%'
    ..style.height = '100%'
    ..style.backgroundColor = '#f0f0f0'
    ..innerText = '🔄'
    ..style.color = '#666'
    ..style.fontSize = '24px';
  
  container.append(loadingDiv);
  
  // Try loading the image again
  try {
    // First try direct image with CORS settings
    final imgElement = html.ImageElement()
      ..src = url
      ..crossOrigin = 'anonymous'  // Try with CORS
      ..style.objectFit = 'contain'
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.maxWidth = '100%'
      ..style.maxHeight = '100%'
      ..style.pointerEvents = 'none';
      
    // Add error handler to show fallback UI
    imgElement.onError.listen((event) {
      print('HTML image reload error, trying direct embed...');
      
      // If CORS fails, remove the crossOrigin attribute and try again
      imgElement.remove();
      
      // Create img without CORS attribute as last resort
      final directImgElement = html.ImageElement()
        ..src = url
        ..style.objectFit = 'contain'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.maxWidth = '100%'
        ..style.maxHeight = '100%'
        ..style.pointerEvents = 'none';
        
        // Handle error in the last resort approach
        directImgElement.onError.listen((_) {
          directImgElement.remove();
          _showErrorPlaceholder(container, url, viewId, errorText: errorText, reloadText: reloadText, openUrlText: openUrlText);
        });
        
        // On successful load, replace loading with image
        directImgElement.onLoad.listen((_) {
          container.children.clear();
          container.append(directImgElement);
        });
        
        container.children.clear();
        container.append(directImgElement);
    });
    
    // On successful load, replace loading with image
    imgElement.onLoad.listen((_) {
      container.children.clear();
      container.append(imgElement);
    });
    
    container.children.clear();
    container.append(imgElement);
  } catch (e) {
    print('Error reloading HTML image element: $e');
    _showErrorPlaceholder(container, url, viewId, errorText: errorText, reloadText: reloadText, openUrlText: openUrlText);
  }
} 