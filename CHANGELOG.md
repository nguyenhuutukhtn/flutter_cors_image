# Changelog

## 0.3.12 - HTML Fallback Styling Bug Fix Release

### 🐛 Bug Fixes

#### **Fixed HTML Fallback Styling Issues**
* **FIXED**: HTML fallback now respects Flutter's BoxFit parameter
* **FIXED**: HTML fallback now supports dynamic BoxFit updates
* **Root Cause Fixed**: 
  - Removed hardcoded `object-fit: contain` from HTML `<img>` elements
  - Added proper mapping of Flutter BoxFit to CSS object-fit values
  - Implemented dynamic styling updates when BoxFit changes

#### **BoxFit to CSS object-fit Mapping**
```dart
BoxFit.fill → object-fit: fill
BoxFit.contain → object-fit: contain  
BoxFit.cover → object-fit: cover
BoxFit.fitWidth → object-fit: scale-down
BoxFit.fitHeight → object-fit: scale-down
BoxFit.none → object-fit: none
BoxFit.scaleDown → object-fit: scale-down
```

### 🔧 Technical Implementation

#### **Enhanced HTML View Factory**
* **NEW**: `registerHtmlImageFactory` now accepts styling parameters:
  - `boxFit`: Maps Flutter BoxFit to CSS object-fit
  - `borderRadius`: Applies border radius to container div
  - `width`/`height`: Image dimensions
* **NEW**: `updateHtmlImageStyling()` function for dynamic style updates
* **NEW**: Automatic styling synchronization in `didUpdateWidget()`

#### **Dynamic Style Updates**
* **FIXED**: BoxFit changes now immediately update HTML fallback images
* **FIXED**: HTML `<img>` elements now use correct CSS object-fit values
* **FIXED**: No more visual inconsistency between Flutter and HTML rendering

### 🧪 Testing Validation

#### **Bug Test Suite Verification**
* **✅ HTML Fallback Detection**: Browser DevTools shows `<img>` elements with dynamic object-fit
* **✅ BoxFit Mapping**: All BoxFit values now properly applied to HTML fallback
* **✅ Real-time Updates**: Changing BoxFit in UI immediately updates HTML styling
* **✅ Visual Consistency**: Flutter and HTML rendering now match styling

#### **Before vs After**
```html
<!-- BEFORE (Bug) -->
<img style="object-fit: contain; ..."> <!-- Always contain, ignores BoxFit -->

<!-- AFTER (Fixed) -->
<img style="object-fit: cover; ...">   <!-- When BoxFit.cover selected -->
<img style="object-fit: fill; ...">    <!-- When BoxFit.fill selected -->  
<img style="object-fit: none; ...">    <!-- When BoxFit.none selected -->
```

### 🎯 Usage Impact

#### **Seamless Experience**
* **Flutter Loading**: Uses native Flutter BoxFit rendering
* **HTML Fallback**: Uses equivalent CSS object-fit styling
* **Consistent Behavior**: No visual differences between Flutter and HTML modes
* **Dynamic Updates**: Changing BoxFit updates both Flutter and HTML rendering

#### **Example Verification**
```dart
CustomNetworkImage(
  url: corsImageUrl, // Triggers HTML fallback
  fit: BoxFit.cover, // Now properly applied to HTML <img>
  width: 300,
  height: 200,
)
// HTML output: <img style="object-fit: cover; ...">

// Change to BoxFit.contain
// HTML automatically updates: <img style="object-fit: contain; ...">
```

### 🔄 Backward Compatibility
* **100% backward compatible** - existing code automatically benefits from fix
* **No API changes** - same CustomNetworkImage parameters work as before  
* **Enhanced functionality** - HTML fallback now matches Flutter rendering quality

### 📱 Platform Support

| Platform | BoxFit Mapping | Dynamic Updates | Border Radius |
|----------|----------------|-----------------|---------------|
| **Web** | ✅ Full support | ✅ Real-time | ✅ CSS applied |
| **Mobile** | ✅ Native Flutter | ✅ Native Flutter | ✅ Native Flutter |
| **Desktop** | ✅ Native Flutter | ✅ Native Flutter | ✅ Native Flutter |

---

## 0.3.10 - Bug Analysis & Testing Release

### 🐛 Bug Identification & Analysis

#### **Bug 1: GIF Loading Issues**
* **IDENTIFIED**: GIF images fail to load due to `ui.instantiateImageCodec()` limitations with animated GIFs
* **Root Cause**: Flutter's image codec cannot properly decode animated GIF frames in certain contexts
* **Location**: `custom_network_image.dart:935` (web loading) and `custom_network_image.dart:686` (local file loading)
* **Impact**: Animated GIFs show error state instead of displaying properly

#### **Bug 2: HTML Fallback Styling Issues**
* **IDENTIFIED**: HTML fallback doesn't respect Flutter styling parameters (BoxFit, border radius)
* **Root Cause**: 
  - `web_image_loader.dart:400,421` uses hardcoded `objectFit = 'contain'` ignoring Flutter's BoxFit settings
  - No CSS `border-radius` applied to HTML `<img>` elements
  - HTML uses `width: 100%, height: 100%` without respecting Flutter's specific constraints
* **Impact**: Visual inconsistency between Flutter rendering and HTML fallback rendering

### 🧪 New Testing Features

#### **Comprehensive Bug Test Suite**
* **NEW**: `BugTestScreen` added to unified example app as "Bug Tests" tab
* **NEW**: Interactive testing environment with real-time controls:
  - BoxFit selector (cover, contain, fill, fitWidth, fitHeight, scaleDown, none)
  - Border radius slider (0-50px range)
  - Flutter vs HTML comparison toggle
* **NEW**: Dedicated test sections for each identified bug:
  - GIF loading test with animated GIF URL
  - HTML fallback styling test with CORS-triggering image URL
  - Side-by-side comparison of Flutter Image.network vs CustomNetworkImage

#### **Enhanced Testing Tools**
* **NEW**: Visual bug identification with color-coded sections
* **NEW**: Expected behavior descriptions for each test case
* **NEW**: Clear error states showing "Failed to Load" with bug attribution
* **NEW**: Custom loading builders with progress indicators
* **NEW**: Testing instructions with step-by-step validation guide

#### **Test URLs & Scenarios**
```dart
// Test URLs for reproducing bugs
final String _gifUrl = 'https://media.giphy.com/media/3oEjI6SIIHBdRxXI40/giphy.gif';
final String _corsImageUrl = 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4';
final String _regularImageUrl = 'https://picsum.photos/400/300?random=1';
```

### 🎯 Testing Instructions

#### **Bug Reproduction Steps**
1. **GIF Loading Bug**:
   - Navigate to "Bug Tests" tab in unified example
   - Observe animated GIF test case
   - Expected: GIF may fail to load and show error state
   - Actual: Error widget displays "This may be due to the GIF loading bug"

2. **HTML Fallback Styling Bug**:
   - Enable "Show Flutter vs HTML Comparison"
   - Adjust BoxFit settings (cover, contain, etc.)
   - Modify border radius slider
   - Expected: HTML version (right) ignores BoxFit and border radius
   - Actual: Visual differences between Flutter (left) and HTML fallback (right)

#### **Validation Checklist**
- [ ] GIF images show error state instead of animated content
- [ ] HTML fallback images ignore BoxFit parameter changes
- [ ] HTML fallback images don't apply border radius styling  
- [ ] Flutter Image.network respects all styling parameters correctly
- [ ] Browser developer tools show HTML `<img>` elements for fallback cases

### 🔧 Developer Experience Improvements

#### **Enhanced Example App**
* **NEW**: 9th tab "Bug Tests" in unified example application
* **NEW**: Interactive controls for real-time bug reproduction
* **NEW**: Visual indicators showing expected vs actual behavior
* **NEW**: Comprehensive testing instructions panel
* **NEW**: Color-coded bug sections (orange for GIF issues, purple for styling issues)

#### **Documentation Updates**
* **NEW**: Bug analysis documentation in changelog
* **NEW**: Root cause analysis for both identified issues
* **NEW**: Code location references for debugging
* **NEW**: Testing methodology and validation steps

### 📱 Platform Support

| Platform | GIF Bug Impact | HTML Styling Bug Impact | Testing Suite |
|----------|----------------|-------------------------|---------------|
| **Web** | ✅ Reproducible | ✅ Reproducible | ✅ Full support |
| **Mobile** | ✅ Reproducible | ❌ HTML not used | ⚠️ Limited testing |
| **Desktop** | ✅ Reproducible | ❌ HTML not used | ⚠️ Limited testing |

### 🔄 Backward Compatibility
* **100% backward compatible** - no breaking changes
* **Optional testing** - bug test suite is additional functionality
* **Existing functionality** - all previous features remain unchanged
* **Progressive debugging** - use test suite to identify issues in existing implementations

### 🎨 Usage Example

```dart
// Navigate to Bug Tests tab in unified example
UnifiedExampleApp() // Now includes BugTestScreen as 9th tab

// Or use directly for testing
BugTestScreen() // Comprehensive bug reproduction environment
```

### 🛠️ Future Fixes (Roadmap)
Based on this analysis, future releases will address:
1. **GIF Loading**: Implement proper animated GIF codec handling
2. **HTML Styling**: Pass Flutter BoxFit parameters to HTML CSS objectFit
3. **Border Radius**: Apply CSS border-radius to HTML fallback elements
4. **Constraint Handling**: Respect Flutter's width/height constraints in HTML

---

## 0.3.9 - Local File Support Release

### 🚀 New Features
* **Local File Support in CustomNetworkImage**: You can now display images from local files using the following parameters:
  * `localFileBytes` (Uint8List) — works on all platforms
  * `webFile` (web File object) — for Flutter web
  * `webBlob` (web Blob object) — for Flutter web
* **Automatic HTML Fallback**: On web, if Flutter fails to decode certain formats (e.g., baseline JPEG), the widget automatically falls back to HTML `<img>` for reliable display.
* **Cross-Platform**: Works on web, mobile, and desktop. On web, supports file picker and drag & drop (see example).
* **New Example**: See `example/local_file_example.dart` for a comprehensive demo and usage patterns.

### 🛠️ Technical Notes
* The widget tries to decode with Flutter first, then falls back to HTML if needed (especially for problematic JPEGs on web).
* All hover icons, context menu, and clipboard/download features work with local files as well.
* No breaking changes — all previous usage remains compatible.

### 🧑‍💻 Usage
```dart
// For local file bytes
CustomNetworkImage(
  localFileBytes: yourUint8ListBytes,
  width: 300,
  height: 200,
  fit: BoxFit.contain,
)

// For web File object
CustomNetworkImage(
  webFile: yourHtmlFileObject,
  width: 300,
  height: 200,
  fit: BoxFit.contain,
)

// For web Blob object
CustomNetworkImage(
  webBlob: yourBlobObject,
  width: 300,
  height: 200,
  fit: BoxFit.contain,
)
```

---

## 0.3.8 - HTML Fallback Reliability Fix

### 🐛 Bug Fixes
* **Fixed HTML Fallback**: Resolved issue where HTML fallback would show empty content requiring user action to trigger rebuild
* **Lazy HTML Registration**: Implemented lazy registration of HTML view factory to prevent premature element creation
* **Improved State Management**: Better handling of HTML element lifecycle and cleanup
* **Transformation Sync**: Enhanced transformation synchronization for HTML fallback elements

### 🛠️ Technical Changes
* HTML view factory now only registers when actually needed (lazy registration)
* Added defensive checks for HTML element readiness before applying transformations
* Improved cleanup of HTML resources to prevent memory leaks
* Better state management for HTML fallback loading and error states

### 🧪 Validation
* ✅ HTML fallback now shows immediately when native image loading fails
* ✅ No more empty states requiring user interaction
* ✅ Transformations apply correctly to HTML fallback elements
* ✅ Proper cleanup of HTML resources on widget disposal

## 0.3.7 - ListView Performance & IndexedDB Caching Release

### 🚀 Major Performance Improvements

#### **ListView Scrolling Optimization**
* **FIXED**: Resolved the original reported issue where ListView scrolling caused repeated server requests, stressing the server
* **NEW**: Comprehensive IndexedDB caching system prevents network requests during ListView scrolling
* **NEW**: Smart widget state management prevents unnecessary image reloading when widgets are recycled
* **NEW**: Added loading state guards to prevent duplicate network requests during cache checks

#### **Advanced IndexedDB Caching System**
* **NEW**: `WebStorageCacheConfig` class for configurable persistent caching in browser IndexedDB
* **NEW**: Automatic cache size management with configurable limits (default: 100MB)
* **NEW**: Cache expiration system with configurable timeouts (default: 7 days)
* **NEW**: **Automatic background cleanup** - expired entries removed every hour without user intervention
* **NEW**: **Lazy expiration checking** - expired entries removed when accessed
* **NEW**: **Manual cleanup API** - `cleanupExpiredEntries()` for on-demand cleanup
* **NEW**: Binary image storage in IndexedDB for better performance vs localStorage base64 encoding
* **NEW**: FIFO cache cleanup when storage quota is reached
* **NEW**: Cross-session persistence - images cached across browser sessions

#### **Enhanced Cache Flow**
* **Priority 1**: Check widget memory state (instant display if available)
* **Priority 2**: Check IndexedDB cache (fast retrieval from browser storage)
* **Priority 3**: Load from network and cache in IndexedDB (single request only)
* **Priority 4**: Display cached images instantly on subsequent loads

### 🎯 ListView Performance Testing

#### **New ListView Demo**
* **NEW**: `ListViewCacheDemoPage` - Comprehensive ListView scrolling test with 50+ images
* **NEW**: Added to unified example app as "ListView Test" tab
* **NEW**: Real-time cache statistics display
* **NEW**: Visual indicators showing IndexedDB caching status
* **NEW**: Performance comparison between first load vs cached loads

#### **Testing Features**
* **NEW**: Long list of 50+ images with different URLs for comprehensive testing
* **NEW**: Rapid scrolling performance validation
* **NEW**: Network tab monitoring instructions for zero-request verification
* **NEW**: Cache hit/miss logging with detailed debugging information
* **NEW**: Before/after refresh comparison demonstrations

### 🛠️ Technical Implementation

#### **Automatic Cache Expiration System**
```dart
// 🔄 AUTOMATIC: Background cleanup every hour
Timer.periodic(Duration(hours: 1), (timer) {
  _performProactiveCleanup(); // Removes expired entries automatically
});

// 🔍 LAZY: Expiration check on access
if (cachedData.isExpired(config.cacheExpirationHours)) {
  _deleteCachedImage(url); // Remove expired entry
  return null; // Force fresh load
}

// 🧹 MANUAL: On-demand cleanup
final cleanedCount = await WebStorageCache.instance.cleanupExpiredEntries(
  customExpirationHours: 48, // Custom expiration time
);
```

#### **Smart Loading Prevention**
```dart
// CRITICAL FIX: Prevent reloading if image data already exists
if (_imageData != null && _loadingState == ImageLoadingState.loaded && !_loadError) {
  print('[CustomNetworkImage] Already have valid image data, skipping preload');
  return;
}
```

#### **IndexedDB Integration**
```dart
// Check IndexedDB cache before any network requests
final cachedData = await webCache.getCachedImage(widget.url, widget.webStorageCacheConfig);
if (cachedData != null) {
  // Display from cache instantly - no network request
  final imageData = cachedData.toImageDataInfo();
  setState(() => _imageData = imageData);
}
```

#### **Build Method Optimization**
```dart
// PRIORITY 1: Always display from memory if available (prevents network requests)
if (_imageData != null) {
  return Image.memory(_imageData!.imageBytes); // No network widget created
}
// Only create network widgets if no cached data exists
```

### 📊 Performance Benefits

#### **ListView Scrolling**
* **✅ Zero network requests** after initial cache population
* **✅ Instant image display** from IndexedDB cache during scrolling
* **✅ Smooth scrolling performance** without loading indicators
* **✅ Server stress elimination** - no repeated requests for same images
* **✅ Bandwidth conservation** - images loaded once, cached persistently

#### **Cross-Session Persistence**
* **✅ Browser refresh** - images load instantly from IndexedDB
* **✅ Tab reopening** - cached images available immediately
* **✅ Session restoration** - no re-downloading of previously viewed images
* **✅ Offline capability** - cached images viewable without network

### 🧪 Comprehensive Testing

#### **ListView Stress Testing**
```dart
// Test with 50+ images in ListView
ListView.builder(
  itemCount: 50,
  itemBuilder: (context, index) {
    return CustomNetworkImage(
      url: 'https://picsum.photos/400/300?random=$index',
      webStorageCacheConfig: WebStorageCacheConfig(
        enabled: true,
        maxCacheSize: 100 * 1024 * 1024, // 100MB
        cacheExpirationHours: 168, // 7 days
      ),
    );
  },
)
```

#### **Performance Validation**
1. **First scroll**: Network requests occur (normal behavior)
2. **Refresh page (F5)**: Zero network requests in DevTools
3. **Rapid scrolling**: Instant image display from cache
4. **Cache statistics**: Real-time monitoring of cached image count and size

### 🔧 Configuration Options

#### **WebStorageCacheConfig Parameters**
```dart
WebStorageCacheConfig(
  enabled: true,                    // Enable/disable IndexedDB caching
  maxCacheSize: 100 * 1024 * 1024, // Maximum cache size in bytes (100MB)
  cacheExpirationHours: 168,       // Cache expiration time (7 days)
  cacheVersion: 1,                 // Cache version for invalidation
)
```

#### **Cache Management**
```dart
// Get cache statistics
final stats = await WebStorageCache.instance.getCacheStats();
print('Cached images: ${stats['count']}');
print('Cache size: ${stats['totalSizeMB']} MB');

// Clear cache manually
await WebStorageCache.instance.clearCache();

// Clean up expired entries (automatic, but can be triggered manually)
final cleanedCount = await WebStorageCache.instance.cleanupExpiredEntries();
print('Cleaned up $cleanedCount expired entries');

// Clean up with custom expiration time
final customCleaned = await WebStorageCache.instance.cleanupExpiredEntries(
  customExpirationHours: 24, // Clean entries older than 24 hours
);
```

### 🎨 Enhanced Example App

#### **New ListView Demo Tab**
* **Visual Design**: Color-coded performance indicators
* **Real-time Stats**: Live cache statistics display
* **Testing Instructions**: Step-by-step performance testing guide
* **Problem/Solution**: Clear explanation of original issue and fix
* **Network Monitoring**: DevTools integration instructions

#### **Comprehensive Documentation**
* **Performance Testing**: Detailed testing procedures
* **Cache Configuration**: Complete configuration examples
* **Troubleshooting**: Debug logging and performance monitoring
* **Best Practices**: Optimal cache settings for different use cases

### 🔄 Backward Compatibility
* **100% backward compatible** - existing code continues to work unchanged
* **Optional enhancement** - IndexedDB caching enabled by default but configurable
* **No breaking changes** - all existing parameters and functionality preserved
* **Progressive adoption** - can be enabled/disabled per image or globally

### 🌐 Platform Support

| Platform | IndexedDB Cache | ListView Performance | Cross-Session |
|----------|-----------------|---------------------|---------------|
| **Web** | ✅ Full support | ✅ Optimized | ✅ Persistent |
| **Mobile** | ❌ Not applicable | ✅ Memory optimization | ❌ Not applicable |
| **Desktop** | ❌ Not applicable | ✅ Memory optimization | ❌ Not applicable |

### 📱 Real-World Impact

#### **Server Load Reduction**
* **Before**: 100 images × 10 scroll cycles = 1,000 server requests
* **After**: 100 images × 1 initial load = 100 server requests (90% reduction)

#### **User Experience**
* **Before**: Loading indicators during ListView scrolling
* **After**: Instant image display with smooth scrolling
* **Bandwidth**: Significant reduction in data usage for repeated viewing

---

## 0.3.6 - Context Menu Positioning Fix

### 🐛 Bug Fixes
* **Fixed Context Menu Positioning**: Resolved a critical bug where the right-click context menu appeared in the wrong location if the Flutter web app was not positioned at the top-left of the browser viewport.
* **Improved Coordinate Conversion**: Implemented a robust coordinate system conversion to correctly map browser viewport coordinates (from `clientX`/`clientY`) to the Flutter `Overlay`'s local coordinate system.
* **Enhanced Hit-Testing**: Made the widget bounds check more reliable by properly converting global click points to the widget's local coordinate system, ensuring the context menu only appears when clicking directly on the image.

### 🛠️ Technical Changes
* The `_showContextMenuAt` method in `CustomNetworkImage` now uses `overlayRenderBox.globalToLocal()` to accurately calculate the menu's position within the Flutter app's coordinate space.
* The `isPointInBounds` method in `DisableWebContextMenu` now uses `renderBox.globalToLocal()` for more accurate hit-testing.
* Removed previous complex and incorrect coordinate calculations in favor of a simpler, more correct approach.

### 🧪 Validation
* ✅ Context menu now appears precisely at the cursor's position when right-clicking, regardless of the app's position on the web page.
* ✅ Hit-testing is accurate, preventing the menu from appearing for clicks outside the image bounds.
* ✅ Tested in various layouts, including centered apps, scrolled pages, and nested views.

## 0.3.5 - Platform Compatibility Fix Release

### 🔧 Platform Compatibility Improvements
* **Fixed Platform Support**: Resolved critical platform compatibility issues that caused 0/6 platform support score
* **Conditional Imports**: Implemented conditional imports pattern to properly handle platform-specific libraries
* **Enhanced Image Loading**: Integrated ExtendedImage for better caching, error handling, and retry functionality  
* **Web/IO Separation**: Created dedicated helper files for web and IO operations with proper stub implementations
* **Cross-Platform**: Now supports all Flutter platforms (web, Android, iOS, desktop) without compilation errors

### 🛠️ Technical Changes
* Added conditional imports using `dart.library.io` and `dart.library.html` checks
* Created platform-specific helper files with stub implementations for unsupported platforms
* Replaced NetworkImage with ExtendedNetworkImageProvider for improved reliability
* Removed direct platform-specific imports that caused compatibility issues
* Enhanced error handling and retry mechanisms across all platforms

## 0.3.4 - Raw Bytes Clipboard Support Release

### 🚀 New Major Features

#### **Raw Image Bytes Clipboard Support**
* **NEW**: `copyImageBytesToClipboard(Uint8List fileData, {required int width, required int height})` method for copying raw image bytes to clipboard
* **NEW**: Alternative to `copyImageToClipboard()` when working with raw `Uint8List` data instead of `ImageDataInfo` wrapper
* **NEW**: Required `width` and `height` parameters to ensure proper canvas rendering on web platforms
* **NEW**: Full platform support with dedicated helper methods for mobile and desktop

#### **Enhanced Clipboard Architecture**
* **NEW**: `_copyImageBytesOnMobile()` - Platform-specific implementation for Android/iOS
* **NEW**: `_copyImageBytesOnDesktop()` - Platform-specific implementation for desktop platforms  
* **NEW**: `saveImageBytesToTempFile()` - Utility method for saving raw bytes to temporary files
* **NEW**: Automatic `ImageDataInfo` wrapper creation for web compatibility

### 🎯 Use Cases & Benefits

#### **When to Use Each Method**
```dart
// ✅ Use copyImageToClipboard when you have ImageDataInfo from CustomNetworkImage
CustomNetworkImage(
  url: 'https://example.com/image.jpg',
  onImageLoaded: (imageData) async {
    await ImageClipboardHelper.copyImageToClipboard(imageData);
  },
)

// ✅ Use copyImageBytesToClipboard when working with raw bytes from other sources
final Uint8List cameraImageBytes = await camera.takePicture();
final success = await ImageClipboardHelper.copyImageBytesToClipboard(
  cameraImageBytes,
  width: 1920,
  height: 1080,
);
```

#### **Perfect for Integration With**
* **Camera plugins** - Copy photos directly from camera capture
* **File picker plugins** - Copy selected images without loading into CustomNetworkImage  
* **Image processing libraries** - Copy processed/filtered images
* **Custom image generation** - Copy programmatically created images
* **Screenshot functionality** - Copy captured screen regions

### 🛠️ Technical Implementation

#### **Function Signature**
```dart
static Future<bool> copyImageBytesToClipboard(
  Uint8List fileData, {
  required int width,
  required int height,
}) async
```

#### **Platform-Specific Behavior**
* **Web**: Creates canvas with specified dimensions for proper image rendering
* **Mobile**: Uses platform channels with raw bytes, falls back to temp file + path copying
* **Desktop**: Saves to temp file and copies file path to clipboard

#### **Canvas Rendering Fix**
* **Problem Solved**: Canvas creation with 0x0 dimensions was failing on web
* **Solution**: Required `width` and `height` parameters ensure valid canvas dimensions
* **Web Compatibility**: Proper `ImageDataInfo` wrapper creation for existing web clipboard methods

### 🔧 Integration Examples

#### **Camera Integration**
```dart
import 'package:camera/camera.dart';
import 'package:flutter_cors_image/flutter_cors_image.dart';
import 'package:image/image.dart' as img;

class CameraExample extends StatelessWidget {
  final CameraController controller;
  
  Future<void> captureAndCopy() async {
    try {
      final XFile photo = await controller.takePicture();
      final Uint8List imageBytes = await photo.readAsBytes();
      
      // Decode image to get actual dimensions
      final img.Image? decodedImage = img.decodeImage(imageBytes);
      if (decodedImage == null) {
        print('Failed to decode image');
        return;
      }
      
      final width = decodedImage.width;
      final height = decodedImage.height;
      
      print('Copying camera image: ${imageBytes.length} bytes, ${width}x${height}');
      
      final success = await ImageClipboardHelper.copyImageBytesToClipboard(
        imageBytes,
        width: width,
        height: height,
      );
      
      if (success) {
        print('✅ Camera image copied to clipboard! Size: ${(imageBytes.length / 1024 / 1024).toStringAsFixed(1)} MB');
        // User can now paste with Ctrl+V in other applications
      } else {
        print('❌ Failed to copy camera image');
      }
    } catch (e) {
      print('Error copying camera image: $e');
    }
  }
  
  // Enhanced example with error handling and user feedback
  Future<void> captureAndCopyWithFeedback(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Capturing and copying image...'),
            ],
          ),
        ),
      );
      
      final XFile photo = await controller.takePicture();
      final Uint8List imageBytes = await photo.readAsBytes();
      final img.Image? decodedImage = img.decodeImage(imageBytes);
      
      if (decodedImage == null) throw Exception('Failed to decode image');
      
      final success = await ImageClipboardHelper.copyImageBytesToClipboard(
        imageBytes,
        width: decodedImage.width,
        height: decodedImage.height,
      );
      
      Navigator.of(context).pop(); // Dismiss loading dialog
      
      // Show result
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success 
            ? '📸 Photo copied! Size: ${(imageBytes.length / 1024 / 1024).toStringAsFixed(1)} MB - Press Ctrl+V to paste'
            : '❌ Failed to copy photo'),
          backgroundColor: success ? Colors.green : Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Dismiss loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }
}
```

#### **File Picker Integration**
```dart
import 'package:file_picker/file_picker.dart';
import 'package:flutter_cors_image/flutter_cors_image.dart';
import 'package:image/image.dart' as img;

class FilePickerExample extends StatelessWidget {
  Future<void> pickAndCopyImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );
      
      if (result != null && result.files.single.bytes != null) {
        final imageBytes = result.files.single.bytes!;
        final fileName = result.files.single.name;
        
        print('Processing selected image: $fileName (${imageBytes.length} bytes)');
        
        // Decode image to get actual dimensions
        final img.Image? decodedImage = img.decodeImage(imageBytes);
        if (decodedImage == null) {
          print('Failed to decode selected image');
          return;
        }
        
        final width = decodedImage.width;
        final height = decodedImage.height;
        final sizeInMB = (imageBytes.length / 1024 / 1024);
        
        print('Image info: ${width}x${height}, ${sizeInMB.toStringAsFixed(1)} MB');
        
        final success = await ImageClipboardHelper.copyImageBytesToClipboard(
          imageBytes,
          width: width,
          height: height,
        );
        
        if (success) {
          print('✅ Selected image copied to clipboard! Size: ${sizeInMB.toStringAsFixed(1)} MB');
          print('📋 You can now paste it anywhere with Ctrl+V');
        } else {
          print('❌ Failed to copy selected image');
        }
      }
    } catch (e) {
      print('Error copying selected image: $e');
    }
  }
  
  // Enhanced example for heavy images with progress feedback
  Future<void> pickAndCopyHeavyImageWithFeedback(BuildContext context) async {
    try {
      // Pick image
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );
      
      if (result == null || result.files.single.bytes == null) return;
      
      final imageBytes = result.files.single.bytes!;
      final fileName = result.files.single.name;
      final sizeInMB = (imageBytes.length / 1024 / 1024);
      
      // Show processing dialog for heavy images
      if (sizeInMB > 2.0) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text('Processing heavy image...'),
                Text('$fileName (${sizeInMB.toStringAsFixed(1)} MB)'),
              ],
            ),
          ),
        );
      }
      
      // Decode and copy
      final img.Image? decodedImage = img.decodeImage(imageBytes);
      if (decodedImage == null) throw Exception('Failed to decode image');
      
      final success = await ImageClipboardHelper.copyImageBytesToClipboard(
        imageBytes,
        width: decodedImage.width,
        height: decodedImage.height,
      );
      
      if (sizeInMB > 2.0) {
        Navigator.of(context).pop(); // Dismiss loading dialog
      }
      
      // Show result
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success 
            ? '📁 ${fileName} copied! (${sizeInMB.toStringAsFixed(1)} MB) - Press Ctrl+V to paste'
            : '❌ Failed to copy ${fileName}'),
          backgroundColor: success ? Colors.green : Colors.red,
          duration: Duration(seconds: sizeInMB > 5 ? 5 : 3), // Longer for heavy images
        ),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Dismiss any open dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }
}
```

#### **Image Processing Integration**
```dart
import 'package:image/image.dart' as img;
import 'package:flutter_cors_image/flutter_cors_image.dart';

class ImageProcessingExample extends StatelessWidget {
  Future<void> processAndCopyImage(Uint8List originalBytes) async {
    try {
      // Decode original image
      final img.Image? originalImage = img.decodeImage(originalBytes);
      if (originalImage == null) return;
      
      // Apply filters/processing
      final processedImage = img.adjustColor(originalImage, brightness: 1.2);
      final filteredImage = img.gaussianBlur(processedImage, radius: 2);
      
      // Encode back to bytes
      final processedBytes = Uint8List.fromList(img.encodePng(filteredImage));
      
      // Copy processed image to clipboard
      final success = await ImageClipboardHelper.copyImageBytesToClipboard(
        processedBytes,
        width: filteredImage.width,
        height: filteredImage.height,
      );
      
      if (success) {
        print('Processed image copied to clipboard!');
      }
    } catch (e) {
      print('Failed to copy processed image: $e');
    }
  }
}
```

### 📱 Platform Support

| Platform | Raw Bytes Support | Canvas Rendering | Temp File Fallback |
|----------|-------------------|------------------|---------------------|
| **Web** | ✅ Full support | ✅ Required dimensions | ❌ Not applicable |
| **Android** | ✅ Platform channels | ❌ Not applicable | ✅ Fallback method |
| **iOS** | ✅ Platform channels | ❌ Not applicable | ✅ Fallback method |
| **Desktop** | ✅ File path copy | ❌ Not applicable | ✅ Primary method |

### 🔄 Backward Compatibility
* **100% backward compatible** - existing `copyImageToClipboard()` continues to work unchanged
* **Optional enhancement** - new method provides alternative for different use cases
* **No conflicts** - both methods can be used in the same application
* **Same dependencies** - no additional packages required

#### **Heavy Image Performance Testing**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_cors_image/flutter_cors_image.dart';
import 'dart:typed_data';

class HeavyImageCopyExample extends StatefulWidget {
  @override
  _HeavyImageCopyExampleState createState() => _HeavyImageCopyExampleState();
}

class _HeavyImageCopyExampleState extends State<HeavyImageCopyExample> {
  ImageDataInfo? _heavyImageData;
  bool _isProcessing = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Heavy Image Copy Testing')),
      body: Column(
        children: [
          // Heavy image display
          CustomNetworkImage(
            url: 'https://picsum.photos/4000/3000?random=heavy', // 4K image (~3-5 MB)
            width: 400,
            height: 300,
            fit: BoxFit.cover,
            onImageLoaded: (imageData) {
              setState(() => _heavyImageData = imageData);
              final sizeInMB = (imageData.imageBytes.length / 1024 / 1024);
              print('Heavy image loaded: ${sizeInMB.toStringAsFixed(1)} MB');
            },
            customLoadingBuilder: (context, child, progress) {
              return Container(
                width: 400,
                height: 300,
                color: Colors.grey[200],
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(value: progress?.progress),
                      Text('Loading heavy image...'),
                      Text('4K Resolution (~3-5 MB)'),
                    ],
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 20),
          
          // Copy buttons
          if (_heavyImageData != null) ...[
            Text('Image loaded: ${(_heavyImageData!.imageBytes.length / 1024 / 1024).toStringAsFixed(1)} MB'),
            Text('Resolution: ${_heavyImageData!.width}x${_heavyImageData!.height}'),
            
            const SizedBox(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _isProcessing ? null : () => _copyImageDataMethod(),
                  icon: Icon(Icons.copy),
                  label: Text('Copy via ImageDataInfo'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
                ElevatedButton.icon(
                  onPressed: _isProcessing ? null : () => _copyRawBytesMethod(),
                  icon: Icon(Icons.content_copy),
                  label: Text('Copy via Raw Bytes'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Performance comparison
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : () => _performanceComparison(),
              icon: Icon(Icons.speed),
              label: Text('Performance Comparison'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            ),
            
            if (_isProcessing) ...[
              const SizedBox(height: 16),
              CircularProgressIndicator(),
              Text('Processing heavy image...'),
            ],
          ],
        ],
      ),
    );
  }
  
  Future<void> _copyImageDataMethod() async {
    if (_heavyImageData == null) return;
    
    setState(() => _isProcessing = true);
    final stopwatch = Stopwatch()..start();
    
    try {
      final success = await ImageClipboardHelper.copyImageToClipboard(_heavyImageData!);
      stopwatch.stop();
      
      final sizeInMB = (_heavyImageData!.imageBytes.length / 1024 / 1024);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success 
            ? '✅ ImageDataInfo method: ${sizeInMB.toStringAsFixed(1)} MB copied in ${stopwatch.elapsedMilliseconds}ms'
            : '❌ ImageDataInfo method failed'),
          backgroundColor: success ? Colors.green : Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }
  
  Future<void> _copyRawBytesMethod() async {
    if (_heavyImageData == null) return;
    
    setState(() => _isProcessing = true);
    final stopwatch = Stopwatch()..start();
    
    try {
      final success = await ImageClipboardHelper.copyImageBytesToClipboard(
        _heavyImageData!.imageBytes,
        width: _heavyImageData!.width,
        height: _heavyImageData!.height,
      );
      stopwatch.stop();
      
      final sizeInMB = (_heavyImageData!.imageBytes.length / 1024 / 1024);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success 
            ? '✅ Raw Bytes method: ${sizeInMB.toStringAsFixed(1)} MB copied in ${stopwatch.elapsedMilliseconds}ms'
            : '❌ Raw Bytes method failed'),
          backgroundColor: success ? Colors.green : Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }
  
  Future<void> _performanceComparison() async {
    if (_heavyImageData == null) return;
    
    setState(() => _isProcessing = true);
    
    try {
      final results = <String, int>{};
      
      // Test ImageDataInfo method
      final stopwatch1 = Stopwatch()..start();
      final success1 = await ImageClipboardHelper.copyImageToClipboard(_heavyImageData!);
      stopwatch1.stop();
      results['ImageDataInfo'] = stopwatch1.elapsedMilliseconds;
      
      await Future.delayed(Duration(milliseconds: 500)); // Brief pause
      
      // Test Raw Bytes method
      final stopwatch2 = Stopwatch()..start();
      final success2 = await ImageClipboardHelper.copyImageBytesToClipboard(
        _heavyImageData!.imageBytes,
        width: _heavyImageData!.width,
        height: _heavyImageData!.height,
      );
      stopwatch2.stop();
      results['Raw Bytes'] = stopwatch2.elapsedMilliseconds;
      
      final sizeInMB = (_heavyImageData!.imageBytes.length / 1024 / 1024);
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Performance Comparison'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Image Size: ${sizeInMB.toStringAsFixed(1)} MB'),
              Text('Resolution: ${_heavyImageData!.width}x${_heavyImageData!.height}'),
              Divider(),
              Text('ImageDataInfo: ${results['ImageDataInfo']}ms'),
              Text('Raw Bytes: ${results['Raw Bytes']}ms'),
              Divider(),
              Text(
                'Both methods provide identical clipboard functionality. '
                'Use ImageDataInfo with CustomNetworkImage, Raw Bytes with external sources.',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Comparison failed: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }
}
```

### 🧪 Testing & Validation
* **Web canvas rendering** - verified proper canvas creation with valid dimensions
* **Platform channel integration** - tested on Android/iOS with platform-specific methods
* **Temp file management** - validated file creation and cleanup on desktop platforms
* **Error handling** - comprehensive error catching and graceful fallbacks
* **Memory management** - proper disposal of temporary resources
* **Heavy image performance** - tested with 4K-8K images up to 10MB in size
* **Performance comparison** - both methods provide identical performance characteristics

---

## 0.3.3 - Right-Click Context Menu Release

### 🚀 New Major Features

#### **Right-Click Context Menu System (Web Only)**
* **NEW**: Native-like right-click context menu for images with browser-style actions
* **NEW**: `enableContextMenu` parameter to enable/disable context menu functionality
* **NEW**: `customContextMenuItems` for adding custom menu items with icons and callbacks
* **NEW**: Built-in context menu actions:
  * **Copy image** - Copies image to system clipboard for Ctrl+V pasting
  * **Save image as...** - Shows browser save dialog with File System Access API
  * **Open image in new tab** - Opens image URL in new browser tab
  * **Copy image address** - Copies image URL to clipboard

#### **Advanced Context Menu Customization**
* **NEW**: `ContextMenuItem` class for defining custom menu items with icons and actions
* **NEW**: `ContextMenuAction` enum for built-in and custom actions
* **NEW**: Context menu styling options:
  * `contextMenuBackgroundColor` - Custom background color
  * `contextMenuTextColor` - Custom text color
  * `contextMenuElevation` - Shadow elevation
  * `contextMenuBorderRadius` - Corner radius
  * `contextMenuPadding` - Internal padding
* **NEW**: `onContextMenuAction` callback for handling menu item selections

#### **Smart Context Menu Behavior**
* **NEW**: Automatic browser context menu prevention only when hovering over images
* **NEW**: Smart positioning to keep menu on screen (auto-adjusts near edges)
* **NEW**: Overlay-based rendering for proper z-index and click-outside dismissal
* **NEW**: Works across all image loading states (loading, loaded, error, HTML fallback)

#### **Enhanced Download & Save Experience**
* **NEW**: File System Access API integration for proper save dialogs with location picker
* **NEW**: Traditional blob download fallback for browser compatibility
* **NEW**: Success/failure toast notifications with color-coded feedback
* **NEW**: Proper file permissions and visibility in file system
* **NEW**: Enhanced error handling with detailed logging for debugging

### 🎨 Usage Examples

#### **Basic Context Menu**
```dart
CustomNetworkImage(
  url: 'https://example.com/image.jpg',
  width: 300,
  height: 200,
  
  // ✅ NEW: Enable right-click context menu
  enableContextMenu: true,
  
  // ✅ NEW: Handle context menu actions
  onContextMenuAction: (action) {
    print('Context menu action: $action');
  },
)
```

#### **Custom Context Menu Items**
```dart
CustomNetworkImage(
  url: 'https://example.com/image.jpg',
  enableContextMenu: true,
  
  // ✅ NEW: Custom menu items with icons
  customContextMenuItems: [
    ContextMenuItem(
      title: 'Download Image',
      icon: Icons.download,
      action: ContextMenuAction.saveImage,
    ),
    ContextMenuItem(
      title: 'Copy to Clipboard',
      icon: Icons.copy,
      action: ContextMenuAction.copyImage,
    ),
    ContextMenuItem(
      title: 'Custom Action',
      icon: Icons.star,
      action: ContextMenuAction.custom,
      onTap: () {
        // Custom action handler
        print('Custom action executed!');
      },
    ),
  ],
  
  // ✅ NEW: Custom styling
  contextMenuBackgroundColor: Colors.grey[800],
  contextMenuTextColor: Colors.white,
  contextMenuElevation: 8.0,
  contextMenuBorderRadius: BorderRadius.circular(12),
)
```

#### **Context Menu with Toast Notifications**
```dart
CustomNetworkImage(
  url: 'https://example.com/image.jpg',
  enableContextMenu: true,
  onContextMenuAction: (action) {
    // Toast notifications automatically shown for:
    // ✅ Image saved successfully!
    // ❌ Failed to save image
    // Image copied to clipboard
    // Image URL copied to clipboard
    // Opening image in new tab
  },
)
```

### 🛠️ Technical Implementation

#### **New Classes & Enums**
```dart
// Context menu item definition
class ContextMenuItem {
  final String title;
  final IconData? icon;
  final ContextMenuAction action;
  final VoidCallback? onTap;
}

// Available context menu actions
enum ContextMenuAction {
  copyImage,           // Copy image to clipboard
  saveImage,           // Save image with file picker
  openImageInNewTab,   // Open in new browser tab
  copyImageUrl,        // Copy URL to clipboard
  custom,              // Custom action with onTap callback
}
```

#### **Context Menu Parameters**
```dart
CustomNetworkImage(
  // Context menu control
  enableContextMenu: true,                    // Enable/disable context menu
  customContextMenuItems: [...],              // Custom menu items
  onContextMenuAction: (action) => {...},     // Action callback
  
  // Styling options
  contextMenuBackgroundColor: Colors.white,   // Background color
  contextMenuTextColor: Colors.black,         // Text color
  contextMenuElevation: 8.0,                  // Shadow elevation
  contextMenuBorderRadius: BorderRadius.circular(8), // Corner radius
  contextMenuPadding: EdgeInsets.all(8),      // Internal padding
)
```

### 🌐 Platform Support & Behavior

#### **Web Platform (Primary Target)**
* **✅ Full context menu functionality** with native-like behavior
* **✅ File System Access API** for proper save dialogs with location picker
* **✅ Clipboard API integration** for image and URL copying
* **✅ Browser context menu prevention** only when hovering over images
* **✅ Toast notifications** for user feedback

#### **Mobile/Desktop Platforms**
* **⚠️ Limited support** - Context menus are primarily a web/desktop concept
* **✅ Hover icons remain available** as alternative for touch interfaces
* **✅ Manual download/copy buttons** continue to work normally

### 🎯 Smart Context Menu Features

#### **Intelligent Positioning**
* **Auto-adjustment**: Menu automatically repositions to stay on screen
* **Edge detection**: Prevents menu from going off screen edges
* **Responsive sizing**: Adapts to different screen sizes and orientations

#### **State-Aware Behavior**
* **Loading state**: Context menu available during image loading
* **Loaded state**: Full functionality with image data access
* **Error state**: Context menu still works with URL-based actions
* **HTML fallback**: Context menu overlays HTML img elements

#### **Browser Integration**
* **Selective prevention**: Only prevents browser context menu when over images
* **Normal browsing**: Browser context menu works normally on text, links, etc.
* **Download integration**: Uses browser's download system for familiar UX

### 🔧 Enhanced Download System

#### **File System Access API (Modern Browsers)**
* **Save dialog**: Shows native file picker for choosing save location
* **File permissions**: Proper file permissions for visibility in file managers
* **Progress feedback**: Toast notifications for save success/failure
* **User control**: Full control over save location and filename

#### **Fallback Download Methods**
* **Blob download**: Traditional browser download to Downloads folder
* **Direct download**: URL-based download as last resort
* **Error handling**: Graceful degradation with detailed error logging

### 📱 Example Integration

#### **Complete Context Menu Demo**
```dart
class ContextMenuDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomNetworkImage(
      url: 'https://picsum.photos/300/200',
      width: 300,
      height: 200,
      
      // Enable context menu with default items
      enableContextMenu: true,
      
      // Custom styling
      contextMenuBackgroundColor: Colors.grey[800],
      contextMenuTextColor: Colors.white,
      contextMenuElevation: 12.0,
      contextMenuBorderRadius: BorderRadius.circular(8),
      
      // Handle actions
      onContextMenuAction: (action) {
        switch (action) {
          case ContextMenuAction.copyImage:
            // Image copied to clipboard automatically
            break;
          case ContextMenuAction.saveImage:
            // Save dialog shown automatically
            break;
          case ContextMenuAction.openImageInNewTab:
            // Image opened in new tab automatically
            break;
          case ContextMenuAction.copyImageUrl:
            // URL copied to clipboard automatically
            break;
        }
      },
    );
  }
}
```

### 🔄 Backward Compatibility
* **100% backward compatible** - existing code continues to work unchanged
* **Optional feature** - context menu is opt-in via `enableContextMenu` parameter
* **No conflicts** - works alongside existing hover icons and callbacks
* **Progressive enhancement** - add context menu to existing implementations gradually

### 🧪 Comprehensive Testing
* **Cross-browser testing** on Chrome, Firefox, Safari, Edge
* **File System Access API** testing with save dialog functionality
* **Clipboard integration** testing with copy/paste operations
* **Context menu positioning** testing near screen edges
* **Toast notification** testing for user feedback
* **Error handling** testing for various failure scenarios

---

## 0.3.2 - Controller Feature Release

### 🚀 New Major Features

#### **External Controller System**
* **NEW**: `CustomNetworkImageController` for external image management and control
* **NEW**: `controller` parameter in `CustomNetworkImage` for linking external controller
* **NEW**: External methods for image operations:
  * `controller.reload()` - Reload image from URL
  * `controller.downloadImage()` - Download image to device
  * `controller.copyImageToClipboard()` - Copy image to system clipboard
  * `controller.getCurrentImageData()` - Get current image data
  * `controller.waitForLoad()` - Wait for image loading with timeout

#### **Real-time State Management**
* **NEW**: Live state monitoring with `ChangeNotifier` integration:
  * `controller.isLoading` - Check if image is currently loading
  * `controller.isLoaded` - Check if image loaded successfully
  * `controller.isFailed` - Check if image failed to load
  * `controller.hasImageData` - Check if image data is available
  * `controller.loadingProgress` - Get current loading progress
  * `controller.errorMessage` - Get current error message

#### **Multiple Controller Support**
* **NEW**: Use separate controllers for different images in same widget tree
* **NEW**: Independent state management for each image instance
* **NEW**: External control of multiple images simultaneously

### 🏗️ Architecture Improvements

#### **Code Refactoring & Separation**
* **NEW**: `lib/src/types.dart` - Shared types and enums for better organization
* **NEW**: `lib/src/custom_network_image_controller.dart` - Dedicated controller implementation
* **IMPROVED**: Removed duplicate type definitions across files
* **IMPROVED**: Better import structure and dependency management
* **IMPROVED**: Cleaner codebase with separated concerns

#### **Enhanced Library Exports**
* **NEW**: Export controller and types for external usage
* **NEW**: Public API access to `CustomNetworkImageController`
* **NEW**: Access to `ImageLoadingState`, `CustomImageProgress`, `ImageDataInfo`
* **NEW**: Public access to `ImageClipboardHelper` for manual operations

### 🎮 Usage Examples

#### **Basic Controller Usage**
```dart
final controller = CustomNetworkImageController();

// Listen to state changes
controller.addListener(() {
  print('Loading state: ${controller.loadingState}');
  if (controller.isLoaded) {
    print('Image ready: ${controller.imageData?.width}x${controller.imageData?.height}');
  }
});

// Use with widget
CustomNetworkImage(
  url: 'https://example.com/image.jpg',
  controller: controller,
  downloadIcon: Icon(Icons.download),
  copyIcon: Icon(Icons.copy),
)

// External control
await controller.downloadImage();
await controller.copyImageToClipboard();
controller.reload();
```

#### **Multiple Controllers**
```dart
class MultiImageWidget extends StatefulWidget {
  @override
  _MultiImageWidgetState createState() => _MultiImageWidgetState();
}

class _MultiImageWidgetState extends State<MultiImageWidget> {
  late CustomNetworkImageController controller1;
  late CustomNetworkImageController controller2;
  
  @override
  void initState() {
    super.initState();
    controller1 = CustomNetworkImageController();
    controller2 = CustomNetworkImageController();
  }
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              CustomNetworkImage(
                url: 'https://example.com/image1.jpg',
                controller: controller1,
              ),
              ElevatedButton(
                onPressed: () => controller1.reload(),
                child: Text('Reload Image 1'),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              CustomNetworkImage(
                url: 'https://example.com/image2.jpg',
                controller: controller2,
              ),
              ElevatedButton(
                onPressed: () => controller2.downloadImage(),
                child: Text('Download Image 2'),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  @override
  void dispose() {
    controller1.dispose();
    controller2.dispose();
    super.dispose();
  }
}
```

### 🔧 Technical Implementation

#### **Controller State Management**
```dart
class CustomNetworkImageController extends ChangeNotifier {
  // State properties
  ImageLoadingState get loadingState;
  CustomImageProgress? get loadingProgress;
  ImageDataInfo? get imageData;
  String? get errorMessage;
  
  // Convenience getters
  bool get isLoading;
  bool get isLoaded;
  bool get isFailed;
  bool get hasImageData;
  
  // Control methods
  void reload();
  Future<bool> downloadImage();
  Future<bool> copyImageToClipboard();
  Future<ImageDataInfo> waitForLoad({Duration timeout});
}
```

#### **Integration with Existing Features**
* **Full Compatibility**: Controller works alongside all existing hover icons and callbacks
* **State Sync**: Widget state automatically syncs with controller state
* **Error Handling**: Controller captures and exposes all error states
* **Progress Tracking**: Real-time loading progress available through controller

### 📱 Enhanced Example App
* **NEW**: Comprehensive controller demonstration in `example/simple_usage_example.dart`
* **NEW**: Live status panel showing controller state in real-time
* **NEW**: External action buttons for controller methods
* **NEW**: Multiple controller examples with independent control
* **NEW**: Status tracking and error handling demonstrations

### 🔄 Backward Compatibility
* **100% Backward Compatible**: All existing code continues to work unchanged
* **Optional Enhancement**: Controller is optional - existing callback/hover icon patterns still work
* **Progressive Adoption**: Add controller gradually to existing implementations
* **No Breaking Changes**: All existing parameters and functionality preserved

### 🛠️ Developer Experience
* **Type Safety**: Full TypeScript-like type safety with controller state
* **IntelliSense**: Rich IDE support for controller methods and properties
* **Documentation**: Comprehensive inline documentation for all new features
* **Examples**: Multiple usage patterns and best practices demonstrated

---

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