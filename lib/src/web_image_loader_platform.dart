// Conditional export for cross-platform compatibility
// Uses package:web implementation on web platforms and stubs elsewhere

export 'web_image_loader_stub.dart'
    if (dart.library.js_interop) 'web_image_loader.dart'; 