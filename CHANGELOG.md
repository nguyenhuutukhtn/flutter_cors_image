# Changelog

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

* Initial release with two image loading solutions:
  * CustomNetworkImage: Uses HTML img tag as fallback
  * ProxyNetworkImage: Uses iframe to completely bypass CORS restrictions
* Support for all standard Image.network parameters
* Full web platform support for problematic images
* Example app showing how to use both approaches 