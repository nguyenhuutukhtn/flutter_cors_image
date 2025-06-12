# Changelog

## 0.3.1 - Clipboard Fix Release

### 🐛 Bug Fixes
* **Fixed Clipboard Copying Issue**: Resolved critical bug where clipboard copying failed with "DataError: Failed to read or decode ClipboardItemData for type image/png"
  * **Root Cause**: Complex JavaScript object manipulation wasn't reliable across browsers
  * **Solution**: Implemented simplified JavaScript approach using direct script injection
  * **New Method**: Created `_simpleClipboardCopy()` with cleaner function definition in global scope
  * **Better Error Handling**: Added proper cleanup and graceful fallback to alternative methods
  * **Multi-Method Fallback**: Now tries 3 different approaches if one fails

### 🔧 Technical Changes
* **Simplified Clipboard API**: More reliable ClipboardItem creation using direct JavaScript functions
* **Enhanced Fallback System**: Canvas-based approach as secondary method, legacy fallback as tertiary
* **Improved Error Logging**: Better debugging information to identify which copy method succeeds
* **Resource Management**: Proper cleanup of created script elements to prevent memory leaks

### 🧪 Validation
* ✅ Copy icon click now successfully copies images to clipboard
* ✅ Ctrl+V pasting works correctly in external applications
* ✅ Multiple fallback methods ensure compatibility across different browsers
* ✅ Proper error messages and graceful degradation when clipboard access is restricted

---

## 0.3.0 - Major Feature Release: Hover Icons & Image Data Access

### 🚀 New Major Features

#### **Image Data Callback System**
* **NEW**: `onImageLoaded` callback provides immediate access to image data when loading completes
* **NEW**: `ImageDataInfo` class contains image bytes, dimensions, and URL for copy/download operations
* **Feature**: No waiting required - image data available instantly after load for clipboard/download functionality

#### **Hover Icons with Smart Positioning**
* **NEW**: `downloadIcon` and `copyIcon` parameters for custom action icons that appear on hover
* **NEW**: 6 positioning options via `HoverIconPosition` enum:
  * `topLeft`, `topRight`, `bottomLeft`, `bottomRight`, `topCenter`, `bottomCenter`
* **NEW**: 3 layout modes via `HoverIconLayout` enum:
  * `auto` - Smart layout based on position
  * `row` - Always horizontal arrangement
  * `column` - Always vertical arrangement
* **NEW**: Customizable spacing (`hoverIconSpacing`) and padding (`hoverIconPadding`)
* **NEW**: `enableHoverIcons` toggle for full control

#### **Advanced Clipboard & Download System**
* **NEW**: Separate `downloadImage()` and `copyImageToClipboard()` methods with distinct behaviors:
  * **Download**: Saves PNG file to computer (web: Downloads folder, mobile: temp directory)
  * **Copy**: Copies image to system clipboard for pasting with Ctrl+V
* **NEW**: Cross-platform clipboard support using modern Clipboard API on web
* **NEW**: Custom action callbacks: `onDownloadTap` and `onCopyTap` for overriding default behaviors

#### **Enhanced User Experience**
* **NEW**: Smart hover detection with smooth icon transitions (web/desktop only)
* **NEW**: Material design click feedback with `InkWell` integration
* **NEW**: Comprehensive example app showcasing all features with live controls
* **NEW**: Real-time customization via control panel (position, layout, spacing, padding)

### 🎨 Usage Examples

#### **Basic Hover Icons**
```dart
CustomNetworkImage(
  url: 'https://example.com/image.jpg',
  
  // ✅ NEW: Hover icons for quick actions
  downloadIcon: Icon(Icons.download, color: Colors.white, size: 20),
  copyIcon: Icon(Icons.copy, color: Colors.white, size: 20),
  hoverIconPosition: HoverIconPosition.topRight,
  
  // ✅ NEW: Get image data when loaded
  onImageLoaded: (ImageDataInfo imageData) {
    print('Image ready! Size: ${imageData.width}x${imageData.height}');
    // imageData.imageBytes contains raw PNG data for copying/saving
  },
)
```

#### **Advanced Styled Icons**
```dart
CustomNetworkImage(
  url: imageUrl,
  downloadIcon: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [Colors.blue, Colors.blueAccent]),
      borderRadius: BorderRadius.circular(8),
      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
    ),
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.download, color: Colors.white, size: 16),
        SizedBox(width: 4),
        Text('Download', style: TextStyle(color: Colors.white)),
      ],
    ),
  ),
  hoverIconPosition: HoverIconPosition.bottomRight,
  hoverIconLayout: HoverIconLayout.row,
  
  // ✅ Custom action callbacks
  onDownloadTap: () => customDownloadHandler(),
  onCopyTap: () => customCopyHandler(),
)
```

#### **Using Image Data for Copy Operations**
```dart
ImageDataInfo? _imageData;

CustomNetworkImage(
  url: imageUrl,
  onImageLoaded: (imageData) {
    setState(() => _imageData = imageData);
  },
)

// Later, copy to clipboard
ElevatedButton(
  onPressed: () async {
    if (_imageData != null) {
      final success = await ImageClipboardHelper.copyImageToClipboard(_imageData!);
      // Image is now in clipboard, ready for Ctrl+V pasting!
    }
  },
  child: Text('Copy Image'),
)
```

### 🛠️ Technical Implementation

#### **New Classes & Enums**
```dart
// Image data container
class ImageDataInfo {
  final Uint8List imageBytes;  // Raw PNG data
  final int width, height;     // Dimensions
  final String url;           // Original URL
}

// Icon positioning
enum HoverIconPosition {
  topLeft, topRight, bottomLeft, bottomRight, topCenter, bottomCenter
}

// Layout direction
enum HoverIconLayout {
  auto, row, column
}
```

#### **New Helper Methods**
```dart
// Clipboard & Download
ImageClipboardHelper.copyImageToClipboard(imageData)  // Clipboard copy
ImageClipboardHelper.downloadImage(imageData)         // File download

// Platform-specific implementations
copyImageToClipboardWeb(imageData)  // Web Clipboard API
downloadImageWeb(imageData)          // Web file download
```

### 🔧 Platform Support
* **Web**: Full clipboard copying + file downloads using modern Clipboard API and blob downloads
* **Mobile**: Temp file saving + basic clipboard support (extensible with plugins)
* **Desktop**: File path copying + temp file saving

### 📱 Responsive Design
* **Hover icons**: Auto-enabled on web/desktop, disabled on mobile (no hover support)
* **Touch support**: Icons work with touch on platforms that support hover simulation
* **Adaptive layouts**: Smart icon positioning based on screen real estate

### 🧪 Comprehensive Testing
* **Interactive example app** with live controls for all parameters
* **Position examples grid** showing all 6 positions
* **Layout comparison** demonstrating row vs column vs auto layouts
* **Real-time customization** via sliders and toggles

### 🔄 Backward Compatibility
* **100% backward compatible** - existing code continues to work unchanged
* **Optional features** - all new parameters have sensible defaults
* **Progressive enhancement** - add hover icons gradually to existing implementations

---

## 0.2.1 - Bug Fix Release

### 🐛 Bug Fixes
* **Alternative to Buggy Flutter loadingBuilder**: Implemented custom loading state management to replace Flutter's problematic `loadingBuilder`
  * Replaced `loadingBuilder` parameter with `customLoadingBuilder` that uses `CustomImageProgress`
  * Added reliable progress tracking via `ImageStream` and `ImageStreamListener`
  * Fixed memory leaks and inconsistent progress reporting issues
  * Added proper resource cleanup with `_cleanupImageStream()` method

### 🚀 New Features
* **Custom Loading Progress Tracking**: New `CustomImageProgress` class provides reliable loading progress information
* **Enhanced Loading State Management**: Added `ImageLoadingState` enum for better loading state control
* **Improved Resource Management**: Automatic cleanup of image streams and listeners to prevent memory leaks

### 🔄 Migration Guide
```dart
// OLD (buggy Flutter loadingBuilder)
CustomNetworkImage(
  url: imageUrl,
  loadingBuilder: (context, child, loadingProgress) {
    if (loadingProgress == null) return child;
    return CircularProgressIndicator(
      value: loadingProgress.cumulativeBytesLoaded / 
             loadingProgress.expectedTotalBytes!,
    );
  },
)

// NEW (reliable customLoadingBuilder)
CustomNetworkImage(
  url: imageUrl,
  customLoadingBuilder: (context, child, progress) {
    if (progress == null) return child;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(value: progress.progress),
        if (progress.progress != null)
          Text('${(progress.progress! * 100).toInt()}%'),
      ],
    );
  },
)
```

### 🛠️ Technical Changes
* Manual image loading progress tracking via `onChunk` callback
* Proper state management for loading, loaded, and failed states
* Enhanced error handling integration with existing fallback mechanisms
* Backward compatibility maintained for existing error handling features

## 0.2.0 - BREAKING CHANGES

### 🚀 New Features
* **Widget-based Error Handling**: Introduced new widget parameters for more flexible error UI customization:
  * `errorWidget` - Custom widget to show when image fails to load
  * `reloadWidget` - Custom widget for retry functionality  
  * `openUrlWidget` - Custom widget for opening image URL in new tab
* **Flutter-based Error UI**: HTML errors now callback to Flutter for consistent error handling across platforms
* **Enhanced Error Flow**: When HTML image loading fails, errors are now handled in Flutter using the new widget parameters

### ⚠️ Breaking Changes
* **HTML Error Handling**: HTML errors no longer show HTML-based error UI. Instead, they trigger Flutter callbacks for consistent widget-based error handling.
* **Deprecated Parameters**: The following string-based parameters are now deprecated and will be removed in v1.0.0:
  * `errorText` → Use `errorWidget` instead
  * `reloadText` → Use `reloadWidget` instead  
  * `openUrlText` → Use `openUrlWidget` instead

### 🔄 Migration Guide
```dart
// OLD (deprecated but still works)
CustomNetworkImage(
  url: imageUrl,
  errorText: 'Image failed to load',
  reloadText: 'Reload Image',
  openUrlText: 'Open in New Tab',
)

// NEW (recommended)
CustomNetworkImage(
  url: imageUrl,
  errorWidget: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.error, color: Colors.red),
      SizedBox(width: 8),
      Text('Image failed to load'),
    ],
  ),
  reloadWidget: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.refresh),
      SizedBox(width: 8),
      Text('Reload Image'),
    ],
  ),
  openUrlWidget: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.open_in_new),
      SizedBox(width: 8),
      Text('Open in New Tab'),
    ],
  ),
)
```

### 🛠️ Technical Changes
* Added HTML error callback mechanism for Flutter integration
* Removed HTML-based error UI generation from `web_image_loader.dart`
* Enhanced `CustomNetworkImage` state management for error handling
* Improved backward compatibility with automatic fallback from deprecated parameters

### 📚 Documentation
* Updated examples to demonstrate new widget-based error handling
* Added migration guide in example app
* Updated README with v0.2.0 usage patterns

## 0.1.9
* Fixed: Resolved issue where error placeholder was not being displayed correctly
* Fixed: Resolved issue where error placeholder was not being displayed correctly

## 0.1.8
* Fixed: Resolved issue where error placeholder was not being displayed correctly
* Fixed: Resolved issue where error placeholder was not being displayed correctly
## 0.1.7
* Added: Internationalization support for error handling - supports custom text for error messages and buttons
* Enhanced: Error placeholder now includes reload and "open in new tab" functionality when HTML image loading fails
* Added: `errorText`, `reloadText`, and `openUrlText` parameters to CustomNetworkImage for multilingual support
* Improved: Error UI can show only icons when no text is provided (icon-only mode for universal understanding)
* Added: Reload button to retry failed images without page refresh
* Added: "Open in new tab" button to view the problematic image URL directly

## 0.1.6
* Fixed: Resolved tap event conflicts in ListViews with mixed HTML fallback and normal images
* Update README.md
## 0.1.5

* Fixed: Resolved tap event conflicts in ListViews with mixed HTML fallback and normal images
* Added: Per-image tap callback tracking to prevent event confusion
* Added: uniqueId parameter to CustomNetworkImage for better control in lists
* Improved: Event propagation handling with stopPropagation() to isolate tap events
* Added: Proper cleanup of resources when widgets are disposed

## 0.1.4

* Fixed: Dramatically improved smoothness of panning/dragging in InteractiveViewer with HTML fallback images
* Added: Animation controller for continuous transformation updates during gestures
* Improved: Full matrix transformation for more accurate CSS transforms
* Fixed: Pointer events handling for smoother gesture recognition

## 0.1.3

* Fixed: InteractiveViewer zoom functionality now works with HTML fallback images
* Added: TransformationController support for CustomNetworkImage
* Improved: Object-fit set to 'contain' for better zooming behavior
* Fixed: Proper transformation handling for HTML elements

## 0.1.2

* Fixed: GestureDetector tap events now work correctly with problematic images using HTML fallback
* Added: onTap callback property to CustomNetworkImage for easier tap handling
* Improved: Visual feedback with cursor pointer on HTML fallback images

## 0.1.1

* Updated intl dependency to support a wider range of versions (>=0.19.0 <0.21.0)
* Improved compatibility with projects that depend on intl 0.19.0

## 0.1.0

* Initial release with image loading solution:
  * CustomNetworkImage: Uses HTML img tag as fallback
* Support for all standard Image.network parameters
* Full web platform support for problematic images
* Example app showing how to use the approach 