# Changelog

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