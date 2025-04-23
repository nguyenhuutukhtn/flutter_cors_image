// Export the proxy_network_image with the right implementation based on platform
// Use the web implementation on web, and the stub implementation on other platforms
export 'proxy_network_image.dart' if (dart.library.io) 'proxy_network_image_stub.dart'; 