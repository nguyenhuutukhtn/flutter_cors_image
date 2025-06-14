import 'dart:async';
import 'package:flutter/foundation.dart';
import 'image_clipboard_helper.dart';
import 'types.dart';

/// Controller for managing CustomNetworkImage widget externally
/// 
/// This controller provides methods to:
/// - Reload the image
/// - Download the image
/// - Copy image to clipboard
/// - Get current image data and state
/// - Listen to state changes
class CustomNetworkImageController extends ChangeNotifier {
  // Internal state
  ImageLoadingState _loadingState = ImageLoadingState.initial;
  CustomImageProgress? _loadingProgress;
  ImageDataInfo? _imageData;
  String? _errorMessage;
  bool _isDisposed = false;

  // Callbacks to trigger widget actions
  VoidCallback? _onReload;
  VoidCallback? _onDownload;
  VoidCallback? _onCopy;

  /// Current loading state of the image
  ImageLoadingState get loadingState => _loadingState;

  /// Current loading progress (null when not loading)
  CustomImageProgress? get loadingProgress => _loadingProgress;

  /// Current image data (null when not loaded or failed)
  ImageDataInfo? get imageData => _imageData;

  /// Current error message (null when no error)
  String? get errorMessage => _errorMessage;

  /// Whether the image is currently loading
  bool get isLoading => _loadingState == ImageLoadingState.loading;

  /// Whether the image has loaded successfully
  bool get isLoaded => _loadingState == ImageLoadingState.loaded;

  /// Whether the image failed to load
  bool get isFailed => _loadingState == ImageLoadingState.failed;

  /// Whether image data is available for copy/download operations
  bool get hasImageData => _imageData != null;

  // Methods accessible by the widget (changed from private to public)
  void updateLoadingState(ImageLoadingState state) {
    if (_isDisposed) return;
    _loadingState = state;
    notifyListeners();
  }

  void updateLoadingProgress(CustomImageProgress? progress) {
    if (_isDisposed) return;
    _loadingProgress = progress;
    notifyListeners();
  }

  void updateImageData(ImageDataInfo? data) {
    print('🔍 PROD DEBUG: updateImageData called');
    print('🔍 PROD DEBUG: _isDisposed: $_isDisposed');
    print('🔍 PROD DEBUG: data is null: ${data == null}');
    if (data != null) {
      print('🔍 PROD DEBUG: data: ${data.imageBytes.length} bytes, ${data.width}x${data.height}, url: ${data.url}');
    }
    
    if (_isDisposed) return;
    _imageData = data;
    
    print('🔍 PROD DEBUG: _imageData updated, notifying listeners');
    notifyListeners();
  }

  void updateError(String? error) {
    if (_isDisposed) return;
    _errorMessage = error;
    notifyListeners();
  }

  void setCallbacks({
    VoidCallback? onReload,
    VoidCallback? onDownload,
    VoidCallback? onCopy,
  }) {
    _onReload = onReload;
    _onDownload = onDownload;
    _onCopy = onCopy;
  }

  /// Reload the image
  /// 
  /// This will trigger the widget to reload the image from the URL
  void reload() {
    if (_isDisposed || _onReload == null) return;
    _onReload!();
  }

  /// Download the current image
  /// 
  /// Returns true if download was successful, false otherwise
  /// Throws an exception if no image data is available
  Future<bool> downloadImage() async {
    print('🔍 PROD DEBUG: downloadImage called');
    print('🔍 PROD DEBUG: _isDisposed: $_isDisposed');
    print('🔍 PROD DEBUG: _imageData is null: ${_imageData == null}');
    print('🔍 PROD DEBUG: hasImageData: $hasImageData');
    print('🔍 PROD DEBUG: loadingState: $_loadingState');
    
    if (_isDisposed) return false;
    
    if (_imageData == null) {
      print('❌ PROD DEBUG: No image data available for download');
      throw StateError('No image data available for download. Make sure the image is loaded first.');
    }

    print('🔍 PROD DEBUG: Image data available: ${_imageData!.imageBytes.length} bytes, ${_imageData!.width}x${_imageData!.height}');

    if (_onDownload != null) {
      print('🔍 PROD DEBUG: Using custom download callback');
      _onDownload!();
      return true; // Assume success if custom callback is provided
    }

    // Default download behavior
    try {
      print('🔍 PROD DEBUG: Using default download behavior');
      final result = await ImageClipboardHelper.downloadImage(_imageData!);
      print('🔍 PROD DEBUG: Download result: $result');
      return result;
    } catch (e) {
      print('❌ PROD DEBUG: Download error: $e');
      print('❌ PROD DEBUG: Download stack trace: ${StackTrace.current}');
      return false;
    }
  }

  /// Copy the current image to clipboard
  /// 
  /// Returns true if copy was successful, false otherwise
  /// Throws an exception if no image data is available
  Future<bool> copyImageToClipboard() async {
    print('🔍 PROD DEBUG: copyImageToClipboard called');
    print('🔍 PROD DEBUG: _isDisposed: $_isDisposed');
    print('🔍 PROD DEBUG: _imageData is null: ${_imageData == null}');
    print('🔍 PROD DEBUG: hasImageData: $hasImageData');
    print('🔍 PROD DEBUG: loadingState: $_loadingState');
    
    if (_isDisposed) return false;
    
    if (_imageData == null) {
      print('❌ PROD DEBUG: No image data available for copying');
      throw StateError('No image data available for copying. Make sure the image is loaded first.');
    }

    print('🔍 PROD DEBUG: Image data available: ${_imageData!.imageBytes.length} bytes, ${_imageData!.width}x${_imageData!.height}');

    if (_onCopy != null) {
      print('🔍 PROD DEBUG: Using custom copy callback');
      _onCopy!();
      return true; // Assume success if custom callback is provided
    }

    // Default copy behavior
    try {
      print('🔍 PROD DEBUG: Using default copy behavior');
      final result = await ImageClipboardHelper.copyImageToClipboard(_imageData!);
      print('🔍 PROD DEBUG: Copy result: $result');
      return result;
    } catch (e) {
      print('❌ PROD DEBUG: Copy error: $e');
      print('❌ PROD DEBUG: Copy stack trace: ${StackTrace.current}');
      return false;
    }
  }

  /// Copy the current image to clipboard (safe version)
  /// 
  /// This method handles the case when image is not loaded yet.
  /// Returns a CopyResult indicating success, failure, or waiting state.
  Future<CopyResult> copyImageToClipboardSafe() async {
    if (_isDisposed) return CopyResult.failed('Controller has been disposed');
    
    // If image is currently loading, return waiting state
    if (_loadingState == ImageLoadingState.loading) {
      return CopyResult.waiting('Image is still loading. Please wait or use copyImageToClipboardWhenReady()');
    }
    
    // If image failed to load, return failed state
    if (_loadingState == ImageLoadingState.failed) {
      return CopyResult.failed('Image failed to load: ${_errorMessage ?? "Unknown error"}');
    }
    
    // If no image data available, return failed state
    if (_imageData == null) {
      return CopyResult.failed('No image data available. Image may not be loaded yet.');
    }

    // Try to copy
    try {
      final success = await copyImageToClipboard();
      return success ? CopyResult.success() : CopyResult.failed('Copy operation failed');
    } catch (e) {
      return CopyResult.failed('Copy error: $e');
    }
  }

  /// Copy the current image to clipboard when ready
  /// 
  /// This method waits for the image to load before copying.
  /// [timeout] specifies how long to wait before timing out.
  /// Returns true if copy was successful, false otherwise.
  Future<bool> copyImageToClipboardWhenReady({Duration timeout = const Duration(seconds: 30)}) async {
    if (_isDisposed) return false;
    
    try {
      // Wait for the image to load first
      await waitForLoad(timeout: timeout);
      
      // Now copy the image
      return await copyImageToClipboard();
    } catch (e) {
      if (kDebugMode) {
        print('Copy when ready error: $e');
      }
      return false;
    }
  }

  /// Try to copy image to clipboard without throwing exceptions
  /// 
  /// Returns true if successful, false if failed or not ready.
  /// This is the safest method to use for UI buttons.
  Future<bool> tryCopyToClipboard() async {
    try {
      return await copyImageToClipboard();
    } catch (e) {
      if (kDebugMode) {
        print('Try copy error: $e');
      }
      return false;
    }
  }

  /// Check if copy functionality is available
  /// 
  /// Returns true if image data is available for copying.
  /// Useful for enabling/disabling copy buttons.
  bool get canCopy => hasImageData && !_isDisposed;

  /// Get detailed copy status information
  /// 
  /// Returns information about why copy might not be available.
  CopyAvailabilityStatus getCopyAvailabilityStatus() {
    if (_isDisposed) {
      return CopyAvailabilityStatus.unavailable('Controller has been disposed');
    }
    
    if (_loadingState == ImageLoadingState.initial) {
      return CopyAvailabilityStatus.unavailable('Image loading not started');
    }
    
    if (_loadingState == ImageLoadingState.loading) {
      return CopyAvailabilityStatus.waiting('Image is still loading');
    }
    
    if (_loadingState == ImageLoadingState.failed) {
      return CopyAvailabilityStatus.unavailable('Image failed to load: ${_errorMessage ?? "Unknown error"}');
    }
    
    if (_loadingState == ImageLoadingState.loaded && _imageData == null) {
      return CopyAvailabilityStatus.unavailable('Image loaded via HTML fallback - copy functionality may be limited');
    }
    
    if (_imageData != null) {
      return CopyAvailabilityStatus.available('Ready to copy');
    }
    
    return CopyAvailabilityStatus.unavailable('Unknown state');
  }

  /// Get the current image data
  /// 
  /// Returns null if image is not loaded or failed to load
  ImageDataInfo? getCurrentImageData() {
    return _imageData;
  }

  /// Wait for the image to load
  /// 
  /// Returns the image data when loaded, or throws an exception if loading fails
  /// [timeout] specifies how long to wait before timing out
  Future<ImageDataInfo> waitForLoad({Duration timeout = const Duration(seconds: 30)}) async {
    if (_isDisposed) {
      throw StateError('Controller has been disposed');
    }

    if (_loadingState == ImageLoadingState.loaded && _imageData != null) {
      return _imageData!;
    }

    if (_loadingState == ImageLoadingState.failed) {
      throw StateError('Image failed to load: ${_errorMessage ?? "Unknown error"}');
    }

    final completer = Completer<ImageDataInfo>();
    late VoidCallback listener;

    listener = () {
      if (_loadingState == ImageLoadingState.loaded && _imageData != null) {
        removeListener(listener);
        if (!completer.isCompleted) {
          completer.complete(_imageData!);
        }
      } else if (_loadingState == ImageLoadingState.failed) {
        removeListener(listener);
        if (!completer.isCompleted) {
          completer.completeError(StateError('Image failed to load: ${_errorMessage ?? "Unknown error"}'));
        }
      }
    };

    addListener(listener);

    // Set up timeout
    Timer(timeout, () {
      removeListener(listener);
      if (!completer.isCompleted) {
        completer.completeError(TimeoutException('Image loading timed out', timeout));
      }
    });

    return completer.future;
  }

  @override
  void dispose() {
    _isDisposed = true;
    _onReload = null;
    _onDownload = null;
    _onCopy = null;
    super.dispose();
  }
}