import 'dart:html' as html;
// Import UI correctly for web
import 'dart:ui_web' as ui_web;

/// Registers an HTML view factory for displaying images
/// This is used only on web platform
void registerHtmlImageFactory(String viewId, String url) {
  // Register a web platform view factory
  ui_web.platformViewRegistry.registerViewFactory(
    viewId,
    (int viewId) {
      // Create a div to hold the image
      final div = html.DivElement()
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.display = 'flex'
        ..style.alignItems = 'center'
        ..style.justifyContent = 'center';
        
      try {
        // First try direct image with CORS settings
        final imgElement = html.ImageElement()
          ..src = url
          ..crossOrigin = 'anonymous'  // Try with CORS
          ..style.objectFit = 'cover'
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.maxWidth = '100%'
          ..style.maxHeight = '100%';
          
        // Add error handler to show fallback UI
        imgElement.onError.listen((event) {
          print('HTML image load error, trying direct embed...');
          
          // If CORS fails, remove the crossOrigin attribute and try again
          imgElement.remove();
          
          // Create img without CORS attribute as last resort
          final directImgElement = html.ImageElement()
            ..src = url
            ..style.objectFit = 'cover'
            ..style.width = '100%'
            ..style.height = '100%'
            ..style.maxWidth = '100%'
            ..style.maxHeight = '100%';
            
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