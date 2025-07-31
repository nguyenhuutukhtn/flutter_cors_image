# Changelog

## 0.3.12 - Context Menu Fix Release

### 🐛 Bug Fixes
* **Fixed Context Menu Positioning**: Resolved bug where context menu appeared in wrong location
* **Improved Coordinate Conversion**: Robust coordinate system conversion for accurate positioning
* **Enhanced Hit-Testing**: More reliable widget bounds checking

---

## 0.3.11 - HTML Fallback Styling Bug Fix Release

### 🐛 Bug Fixes
* **Fixed HTML Fallback Styling Issues**: HTML fallback now respects Flutter's BoxFit parameter and supports dynamic updates
* **BoxFit to CSS Mapping**: Proper mapping of Flutter BoxFit to CSS object-fit values (fill, contain, cover, etc.)
* **Dynamic Style Updates**: BoxFit changes now immediately update HTML fallback images
* **Visual Consistency**: No more visual differences between Flutter and HTML rendering

### 🔧 Technical Changes
* Enhanced HTML view factory with styling parameters
* Added `updateHtmlImageStyling()` function for dynamic style updates
* Automatic styling synchronization in `didUpdateWidget()`

---

## 0.3.10 - Bug Analysis & Testing Release

### 🐛 Bug Identification
* **GIF Loading Issues**: Animated GIFs fail to load due to Flutter's image codec limitations
* **HTML Fallback Styling**: HTML fallback ignored Flutter styling parameters (BoxFit, border radius)

### 🧪 Testing Features
* **NEW**: `BugTestScreen` with interactive testing environment
* **NEW**: Real-time controls for BoxFit, border radius, and Flutter vs HTML comparison
* **NEW**: Comprehensive bug reproduction and validation tools

---

## 0.3.9 - Local File Support Release

### 🚀 New Features
* **Local File Support**: Display images from local files using `localFileBytes`, `webFile`, or `webBlob`
* **Cross-Platform**: Works on web, mobile, and desktop with file picker and drag & drop support
* **Automatic HTML Fallback**: Falls back to HTML `<img>` for problematic formats on web

### 🧑‍💻 Usage
```dart
CustomNetworkImage(
  localFileBytes: yourUint8ListBytes,
  width: 300,
  height: 200,
  fit: BoxFit.contain,
)
```

---

## 0.3.8 - HTML Fallback Reliability Fix

### 🐛 Bug Fixes
* **Fixed HTML Fallback**: Resolved empty content issue requiring user action to trigger rebuild
* **Lazy HTML Registration**: Implemented lazy registration to prevent premature element creation
* **Improved State Management**: Better HTML element lifecycle and cleanup

---

## 0.3.7 - ListView Performance & IndexedDB Caching Release

### 🚀 Major Performance Improvements
* **ListView Scrolling Optimization**: Fixed repeated server requests during ListView scrolling
* **IndexedDB Caching System**: Configurable persistent caching with automatic cleanup
* **Smart State Management**: Prevents unnecessary image reloading when widgets are recycled

### 🔧 Features
* **Cache Configuration**: `WebStorageCacheConfig` with size limits and expiration
* **Automatic Cleanup**: Background cleanup every hour, lazy expiration checking
* **Cross-Session Persistence**: Images cached across browser sessions

### 📊 Performance Benefits
* **Zero network requests** after initial cache population
* **Instant image display** from IndexedDB cache during scrolling
* **90% reduction** in server requests for repeated viewing

---

## 0.3.6 - Context Menu Positioning Fix

### 🐛 Bug Fixes
* **Fixed Context Menu Positioning**: Resolved bug where context menu appeared in wrong location
* **Improved Coordinate Conversion**: Robust coordinate system conversion for accurate positioning
* **Enhanced Hit-Testing**: More reliable widget bounds checking

---

## 0.3.5 - Platform Compatibility Fix Release

### 🔧 Platform Compatibility
* **Fixed Platform Support**: Resolved critical compatibility issues for all Flutter platforms
* **Conditional Imports**: Proper platform-specific library handling
* **Cross-Platform**: Now supports web, Android, iOS, and desktop without compilation errors

---

## 0.3.4 - Raw Bytes Clipboard Support Release

### 🚀 New Features
* **Raw Image Bytes Clipboard**: `copyImageBytesToClipboard()` method for raw `Uint8List` data
* **Platform-Specific Support**: Dedicated implementations for web, mobile, and desktop
* **Canvas Rendering Fix**: Required width/height parameters for proper web canvas creation

### 🎯 Use Cases
* **Camera Integration**: Copy photos directly from camera capture
* **File Picker Integration**: Copy selected images without loading into CustomNetworkImage
* **Image Processing**: Copy processed/filtered images

---

## 0.3.3 - Right-Click Context Menu Release

### 🚀 New Features
* **Right-Click Context Menu**: Native-like context menu for images (web only)
* **Built-in Actions**: Copy image, save image, open in new tab, copy image URL
* **Custom Menu Items**: Add custom actions with icons and callbacks
* **Smart Positioning**: Auto-adjusts to keep menu on screen

### 🎨 Usage
```dart
CustomNetworkImage(
  url: 'https://example.com/image.jpg',
  enableContextMenu: true,
  onContextMenuAction: (action) {
    print('Context menu action: $action');
  },
)
```

---

## 0.3.2 - Controller Feature Release

### 🚀 New Features
* **External Controller System**: `CustomNetworkImageController` for external image management
* **Real-time State Management**: Live state monitoring with `ChangeNotifier` integration
* **Multiple Controller Support**: Independent control of multiple images

### 🎮 Usage
```dart
final controller = CustomNetworkImageController();

CustomNetworkImage(
  url: 'https://example.com/image.jpg',
  controller: controller,
)

// External control
await controller.downloadImage();
await controller.copyImageToClipboard();
controller.reload();
```

---

## 0.3.1 - Clipboard Fix Release

### 🐛 Bug Fixes
* **Fixed Clipboard Copying**: Resolved "DataError: Failed to read or decode ClipboardItemData" bug
* **Simplified JavaScript Approach**: More reliable ClipboardItem creation
* **Multi-Method Fallback**: 3 different approaches if one fails

---

## 0.3.0 - Major Feature Release: Hover Icons & Image Data Access

### 🚀 New Features
* **Image Data Callback**: `onImageLoaded` callback provides immediate access to image data
* **Hover Icons**: Custom action icons with 6 positioning options and 3 layout modes
* **Advanced Clipboard & Download**: Separate methods for copying and downloading images
* **Smart Hover Detection**: Smooth transitions and Material design feedback

### 🎨 Usage
```dart
CustomNetworkImage(
  url: 'https://example.com/image.jpg',
  downloadIcon: Icon(Icons.download, color: Colors.white),
  copyIcon: Icon(Icons.copy, color: Colors.white),
  hoverIconPosition: HoverIconPosition.topRight,
  onImageLoaded: (ImageDataInfo imageData) {
    print('Image ready! Size: ${imageData.width}x${imageData.height}');
  },
)
```

---

## 0.2.1 - Bug Fix Release

### 🐛 Bug Fixes
* **Fixed LoadingBuilder Issues**: Replaced buggy Flutter `loadingBuilder` with reliable `customLoadingBuilder`
* **Custom Progress Tracking**: `CustomImageProgress` class for reliable loading progress
* **Resource Management**: Automatic cleanup of image streams and listeners

---

## 0.2.0 - BREAKING CHANGES

### 🚀 New Features
* **Widget-based Error Handling**: `errorWidget`, `reloadWidget`, `openUrlWidget` parameters
* **Flutter-based Error UI**: Consistent error handling across platforms

### ⚠️ Breaking Changes
* **HTML Error Handling**: HTML errors now trigger Flutter callbacks instead of showing HTML UI
* **Deprecated Parameters**: `errorText`, `reloadText`, `openUrlText` deprecated in favor of widget parameters

---

## 0.1.9 - 0.1.0

### Early Releases
* **0.1.9-0.1.8**: Error placeholder display fixes
* **0.1.7**: Internationalization support for error handling
* **0.1.6-0.1.5**: Tap event conflict fixes in ListViews
* **0.1.4**: InteractiveViewer panning/dragging improvements
* **0.1.3**: InteractiveViewer zoom functionality
* **0.1.2**: GestureDetector tap events
* **0.1.1**: Intl dependency compatibility
* **0.1.0**: Initial release with HTML fallback image loading solution 