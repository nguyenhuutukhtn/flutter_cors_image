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
    if (_isDisposed) return;
    _imageData = data;
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
    if (_isDisposed) return false;
    
    if (_imageData == null) {
      throw StateError('No image data available for download. Make sure the image is loaded first.');
    }

    if (_onDownload != null) {
      _onDownload!();
      return true; // Assume success if custom callback is provided
    }

    // Default download behavior
    try {
      return await ImageClipboardHelper.downloadImage(_imageData!);
    } catch (e) {
      if (kDebugMode) {
        print('Download error: $e');
      }
      return false;
    }
  }

  /// Copy the current image to clipboard
  /// 
  /// Returns true if copy was successful, false otherwise
  /// Throws an exception if no image data is available
  Future<bool> copyImageToClipboard() async {
    if (_isDisposed) return false;
    
    if (_imageData == null) {
      throw StateError('No image data available for copying. Make sure the image is loaded first.');
    }

    if (_onCopy != null) {
      _onCopy!();
      return true; // Assume success if custom callback is provided
    }

    // Default copy behavior
    try {
      return await ImageClipboardHelper.copyImageToClipboard(_imageData!);
    } catch (e) {
      if (kDebugMode) {
        print('Copy error: $e');
      }
      return false;
    }
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