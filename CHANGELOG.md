# Changelog

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