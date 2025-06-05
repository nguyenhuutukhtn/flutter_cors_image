import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'web_image_loader.dart' if (dart.library.io) 'stub_image_loader.dart';

/// Custom loading state for tracking image loading progress
enum ImageLoadingState {
  initial,
  loading,
  loaded,
  failed,
}

/// Custom loading progress information
class CustomImageProgress {
  final int cumulativeBytesLoaded;
  final int? expectedTotalBytes;
  final double? progress;

  const CustomImageProgress({
    required this.cumulativeBytesLoaded,
    this.expectedTotalBytes,
    this.progress,
  });
}

/// A network image widget that handles problematic images by falling back to HTML img tag
/// when the standard Flutter image loader fails.
///
/// This widget first tries to load the image using Flutter's Image.network,
/// and if that fails (on web platforms), it automatically falls back to using an HTML img tag.
class CustomNetworkImage extends StatefulWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  
  // Image.network parameters
  final double scale;
  final Map<String, String>? headers;
  final int? cacheWidth;
  final int? cacheHeight;
  final Color? color;
  final BlendMode? colorBlendMode;
  final String? semanticLabel;
  final bool excludeFromSemantics;
  final AlignmentGeometry alignment;
  final ImageRepeat repeat;
  final Rect? centerSlice;
  final bool matchTextDirection;
  final bool gaplessPlayback;
  final FilterQuality filterQuality;
  final bool isAntiAlias;
  
  /// CUSTOM ALTERNATIVE: Replacement for buggy Flutter loadingBuilder
  /// Custom loading builder that receives our reliable loading progress
  final Widget Function(BuildContext, Widget, CustomImageProgress?)? customLoadingBuilder;
  
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;
  
  /// Callback when the image is tapped
  final VoidCallback? onTap;
  
  /// TransformationController for supporting zooming with InteractiveViewer
  final TransformationController? transformationController;
  
  /// Optional unique ID if needed to handle multiple similar images
  final String? uniqueId;

  /// NEW v0.2.0: Widget-based error handling (RECOMMENDED)
  /// Custom error widget to show when image fails to load
  final Widget? errorWidget;
  
  /// Custom reload widget to show for retrying failed images
  final Widget? reloadWidget;
  
  /// Custom open URL widget to show for opening image URL in new tab
  final Widget? openUrlWidget;

  /// Background color for the error widget. Defaults to grey if not specified.
  final Color? errorBackgroundColor;
  
  /// DEPRECATED: Use errorWidget instead
  /// Custom error message text. If null, only icon will be shown.
  @Deprecated('Use errorWidget parameter instead. This will be removed in v1.0.0')
  final String? errorText;
  
  /// DEPRECATED: Use reloadWidget instead
  /// Custom reload button text. If null, only icon will be shown.
  @Deprecated('Use reloadWidget parameter instead. This will be removed in v1.0.0')
  final String? reloadText;
  
  /// DEPRECATED: Use openUrlWidget instead
  /// Custom open URL button text. If null, only icon will be shown.
  @Deprecated('Use openUrlWidget parameter instead. This will be removed in v1.0.0')
  final String? openUrlText;

  /// Creates a CustomNetworkImage.
  ///
  /// The [url] parameter must not be null.
  /// 
  /// For v0.2.0+, use [errorWidget], [reloadWidget], and [openUrlWidget] for error handling.
  /// The [errorBackgroundColor] can be used to customize the background color of the error state.
  /// The old text-based parameters are deprecated but still supported.
  /// 
  /// Use [customLoadingBuilder] instead of loadingBuilder for reliable loading progress tracking.
  const CustomNetworkImage({
    Key? key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    // Default values to match Image.network
    this.scale = 1.0,
    this.headers,
    this.cacheWidth,
    this.cacheHeight,
    this.color,
    this.colorBlendMode,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.centerSlice,
    this.matchTextDirection = false,
    this.gaplessPlayback = false,
    this.filterQuality = FilterQuality.low,
    this.isAntiAlias = false,
    this.customLoadingBuilder, // REPLACEMENT for buggy loadingBuilder
    this.errorBuilder,
    this.onTap,
    this.transformationController,
    this.uniqueId,
    // NEW widget-based parameters (v0.2.0+)
    this.errorWidget,
    this.reloadWidget,
    this.openUrlWidget,
    // DEPRECATED string parameters (for backward compatibility)
    @Deprecated('Use errorWidget parameter instead. This will be removed in v1.0.0')
    this.errorText,
    @Deprecated('Use reloadWidget parameter instead. This will be removed in v1.0.0')
    this.reloadText,
    @Deprecated('Use openUrlWidget parameter instead. This will be removed in v1.0.0')
    this.openUrlText,
    this.errorBackgroundColor,
  }) : super(key: key);

  @override
  State<CustomNetworkImage> createState() => _CustomNetworkImageState();
}

class _CustomNetworkImageState extends State<CustomNetworkImage> with SingleTickerProviderStateMixin {
  bool _loadError = false;
  bool _htmlError = false; // NEW: Track when HTML also fails
  bool _waitingForHtml = false; // Track when we're trying HTML
  final GlobalKey _key = GlobalKey();
  late final String _viewType;
  Matrix4? _lastTransformation;
  // Animation controller for smoother transformation updates
  late AnimationController _transformSyncController;
  
  // CUSTOM LOADING STATE MANAGEMENT (Alternative to buggy Flutter loadingBuilder)
  ImageLoadingState _loadingState = ImageLoadingState.initial;
  CustomImageProgress? _loadingProgress;
  ImageStream? _imageStream;
  ImageStreamListener? _imageStreamListener;
  
  @override
  void initState() {
    super.initState();
    // Create a unique view type name for this widget instance
    // Include uniqueId if provided for better isolation in ListViews
    _viewType = 'html-image-${widget.uniqueId ?? widget.url.hashCode}-${DateTime.now().millisecondsSinceEpoch}';
    
    // Initialize animation controller for frequent transformation updates
    _transformSyncController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16), // ~60fps
    );
    
    // Register the view factory early if on web and likely to need it
    if (kIsWeb) {
      // Register the tap callback if we have one
      if (widget.onTap != null) {
        setHtmlImageTapCallback(_viewType, () {
          if (widget.onTap != null) {
            widget.onTap!();
          }
        });
      }
      
      // NEW: Register HTML error callback
      setHtmlImageErrorCallback(_viewType, () {
        print('HTML error callback triggered for $_viewType');
        if (mounted) {
          setState(() {
            _htmlError = true;
            _waitingForHtml = false;
          });
        }
      });
      
      // NEW: Register HTML success callback
      setHtmlImageSuccessCallback(_viewType, () {
        print('HTML success callback triggered for $_viewType');
        if (mounted) {
          setState(() {
            _waitingForHtml = false; // Hide loading overlay
          });
        }
      });
      
      registerHtmlImageFactory(
        _viewType, 
        widget.url,
      );
      
      // Add transformation listener if controller is provided
      if (widget.transformationController != null) {
        widget.transformationController!.addListener(_handleTransformationChange);
        
        // Start the animation for continuous transformation updates
        _transformSyncController.repeat();
        _transformSyncController.addListener(_checkForTransformationUpdates);
      }
    }
    
    // Try loading the image first
    _preloadImage();
  }
  
  @override
  void didUpdateWidget(CustomNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // If URL or uniqueId changed, we need to update our references
    bool needsViewUpdate = oldWidget.url != widget.url || 
                          oldWidget.uniqueId != widget.uniqueId;
    
    if (needsViewUpdate && kIsWeb && _loadError) {
      // Clean up old references
      removeHtmlImageTapCallback(_viewType);
      removeHtmlImageErrorCallback(_viewType);
      removeHtmlImageSuccessCallback(_viewType);
      cleanupHtmlElement(_viewType);
      
      // Create new view type
      final newViewType = 'html-image-${widget.uniqueId ?? widget.url.hashCode}-${DateTime.now().millisecondsSinceEpoch}';
      
      // Register new callback and factory
      if (widget.onTap != null) {
        setHtmlImageTapCallback(newViewType, () {
          if (widget.onTap != null) {
            widget.onTap!();
          }
        });
      }
      
      // Register new error callback
      setHtmlImageErrorCallback(newViewType, () {
        if (mounted) {
          setState(() {
            _htmlError = true;
            _waitingForHtml = false;
          });
        }
      });

      // Register new success callback
      setHtmlImageSuccessCallback(newViewType, () {
        if (mounted) {
          setState(() {
            _waitingForHtml = false; // Hide loading overlay
          });
        }
      });

      registerHtmlImageFactory(newViewType, widget.url);
      
      // Update view type
      _viewType = newViewType;
      
      // Force reload
      _preloadImage();
    }
    
    // Handle transformation controller changes
    if (oldWidget.transformationController != widget.transformationController) {
      if (oldWidget.transformationController != null) {
        oldWidget.transformationController!.removeListener(_handleTransformationChange);
      }
      
      if (widget.transformationController != null) {
        widget.transformationController!.addListener(_handleTransformationChange);
        
        // Ensure animation controller is running if needed
        if (!_transformSyncController.isAnimating && kIsWeb && _loadError) {
          _transformSyncController.repeat();
        }
      } else if (_transformSyncController.isAnimating) {
        _transformSyncController.stop();
      }
    }
    
    // If onTap changed, update the callback
    if (oldWidget.onTap != widget.onTap && kIsWeb && _loadError) {
      if (widget.onTap != null) {
        setHtmlImageTapCallback(_viewType, () {
          if (widget.onTap != null) {
            widget.onTap!();
          }
        });
      } else {
        removeHtmlImageTapCallback(_viewType);
      }
    }
    
    // If URL changed, reload the image
    if (oldWidget.url != widget.url) {
      _preloadImage();
    }
  }
  
  @override
  void dispose() {
    // Clean up HTML resources
    if (kIsWeb) {
      removeHtmlImageTapCallback(_viewType);
      removeHtmlImageErrorCallback(_viewType);
      removeHtmlImageSuccessCallback(_viewType);
      cleanupHtmlElement(_viewType);
    }
    
    // Remove transformation listener
    if (widget.transformationController != null) {
      widget.transformationController!.removeListener(_handleTransformationChange);
    }
    
    // Clean up image stream listener
    _cleanupImageStream();
    
    // Dispose animation controller
    _transformSyncController.dispose();
    
    super.dispose();
  }
  
  // Clean up image stream resources
  void _cleanupImageStream() {
    if (_imageStream != null && _imageStreamListener != null) {
      _imageStream!.removeListener(_imageStreamListener!);
      _imageStream = null;
      _imageStreamListener = null;
    }
  }
  
  // Continuously check for transformation changes for smoother updates
  void _checkForTransformationUpdates() {
    if (kIsWeb && _loadError && widget.transformationController != null) {
      // Only update if we're using HTML fallback and have a transformation controller
      final matrix = widget.transformationController!.value;
      if (_lastTransformation != matrix) {
        updateHtmlImageTransform(_viewType, matrix);
        _lastTransformation = matrix;
      }
    }
  }
  
  // Handle discrete transformation changes
  void _handleTransformationChange() {
    if (!kIsWeb || !_loadError || widget.transformationController == null) return;
    
    // This is called when the controller value changes programmatically
    final matrix = widget.transformationController!.value;
    updateHtmlImageTransform(_viewType, matrix);
    _lastTransformation = matrix;
  }

  void _preloadImage() {
    // Clean up any existing stream
    _cleanupImageStream();
    
    // Reset loading state
    setState(() {
      _loadingState = ImageLoadingState.loading;
      _loadingProgress = const CustomImageProgress(cumulativeBytesLoaded: 0);
      _loadError = false;
      _htmlError = false;
      _waitingForHtml = false;
    });
    
    // Create image provider and stream
    final imageProvider = NetworkImage(widget.url, headers: widget.headers);
    _imageStream = imageProvider.resolve(ImageConfiguration.empty);
    
    // Create our custom listener that tracks progress more reliably
    _imageStreamListener = ImageStreamListener(
      (ImageInfo info, bool synchronousCall) {
        // Image loaded successfully
        print('Image loaded successfully');
        if (mounted) {
          setState(() {
            _loadingState = ImageLoadingState.loaded;
            _loadingProgress = null;
            _loadError = false;
          });
          
          // Stop animation controller if not needed
          if (_transformSyncController.isAnimating) {
            _transformSyncController.stop();
          }
        }
      },
      onError: (dynamic error, StackTrace? stackTrace) {
        // Image failed to load
        print('Error pre-loading image: $error');
        if (mounted) {
          setState(() {
            _loadingState = ImageLoadingState.failed;
            _loadingProgress = null;
            _loadError = true;
            _waitingForHtml = true; // We'll try HTML next
          });
          
          // Start animation controller for frequent updates
          if (widget.transformationController != null && !_transformSyncController.isAnimating) {
            _transformSyncController.repeat();
          }
        }
      },
      onChunk: (ImageChunkEvent event) {
        // Update loading progress - this is our reliable alternative to buggy loadingBuilder
        if (mounted) {
          final progress = event.expectedTotalBytes != null 
              ? event.cumulativeBytesLoaded / event.expectedTotalBytes! 
              : null;
          
          setState(() {
            _loadingProgress = CustomImageProgress(
              cumulativeBytesLoaded: event.cumulativeBytesLoaded,
              expectedTotalBytes: event.expectedTotalBytes,
              progress: progress,
            );
          });
        }
      },
    );
    
    // Add the listener to the stream
    _imageStream!.addListener(_imageStreamListener!);
  }

  @override
  Widget build(BuildContext context) {
    print('Building CustomNetworkImage: _loadError=$_loadError, _htmlError=$_htmlError, _waitingForHtml=$_waitingForHtml, _loadingState=$_loadingState');
    
    // NEW v0.2.0: If HTML also failed, show Flutter error UI
    if (kIsWeb && _loadError && _htmlError) {
      print('Showing Flutter error widget');
      return _buildFlutterErrorWidget();
    }
    
    Widget imageWidget;
    
    // If we're on web and already know the image will fail, go straight to HTML
    if (kIsWeb && _loadError) {
      print('Using HTML fallback');
      imageWidget = _buildHtmlImageView();
    } 
    // If we're still loading and have a custom loading builder, show loading state
    else if (_loadingState == ImageLoadingState.loading && widget.customLoadingBuilder != null) {
      print('Showing custom loading state');
      imageWidget = _buildCustomLoadingWidget();
    }
    // If we haven't detected an error yet, try normal Flutter image
    else if (!_loadError) {
      print('Using Flutter Image.network');
      imageWidget = Image.network(
        widget.url,
        key: _key,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        // Pass through all other parameters
        scale: widget.scale,
        headers: widget.headers,
        cacheWidth: widget.cacheWidth,
        cacheHeight: widget.cacheHeight,
        color: widget.color,
        colorBlendMode: widget.colorBlendMode,
        semanticLabel: widget.semanticLabel,
        excludeFromSemantics: widget.excludeFromSemantics,
        alignment: widget.alignment,
        repeat: widget.repeat,
        centerSlice: widget.centerSlice,
        matchTextDirection: widget.matchTextDirection,
        gaplessPlayback: widget.gaplessPlayback,
        filterQuality: widget.filterQuality,
        isAntiAlias: widget.isAntiAlias,
        errorBuilder: (context, error, stackTrace) {
          print('Error loading image with Flutter: $error');
          
          // Use custom errorBuilder if provided
          if (widget.errorBuilder != null) {
            return widget.errorBuilder!(context, error, stackTrace);
          }
          
          // Don't call setState here - we'll handle via initState preloading
          if (kIsWeb) {
            // We're already in error state, use HTML fallback
            return _buildHtmlImageView();
          } else {
            // On native platforms, use ExtendedImage fallback
            return _buildExtendedImageFallback();
          }
        },
      );
    } else {
      // Non-web fallback
      imageWidget = _buildExtendedImageFallback();
    }
    
    // Wrap with GestureDetector only if we have an onTap and not using HTML fallback
    // (HTML fallback has its own tap handling)
    if (widget.onTap != null && !(kIsWeb && _loadError)) {
      return GestureDetector(
        onTap: widget.onTap,
        child: imageWidget,
      );
    }
    
    return imageWidget;
  }

  // CUSTOM LOADING WIDGET - Alternative to buggy Flutter loadingBuilder
  Widget _buildCustomLoadingWidget() {
    // Create a placeholder for the image dimensions
    final placeholder = Container(
      width: widget.width,
      height: widget.height,
      color: Colors.transparent,
    );
    
    // Use the custom loading builder
    return widget.customLoadingBuilder!(
      context, 
      placeholder, 
      _loadingProgress
    );
  }

  Widget _buildHtmlImageView() {
    // If we have a transformation controller, make sure it's reflected in HTML
    if (widget.transformationController != null) {
      updateHtmlImageTransform(_viewType, widget.transformationController!.value);
    }
    
    // Use HtmlElementView for web platforms
    return kIsWeb
        ? SizedBox(
            width: widget.width,
            height: widget.height,
            child: Stack(
              children: [
                HtmlElementView(
                  viewType: _viewType,
                ),
                // Show loading indicator while waiting for HTML to load/fail
                if (_waitingForHtml)
                  Container(
                    color: Colors.grey[300],
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 8),
                          Text('Loading fallback...'),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          )
        : Container(
            width: widget.width,
            height: widget.height,
            color: Colors.grey[300],
            child: const Center(
              child: Text('HTML fallback not available on native'),
            ),
          );
  }

  Widget _buildExtendedImageFallback() {
    Widget image = ExtendedImage.network(
      widget.url,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      cache: true,
      // Pass through other parameters that ExtendedImage supports
      scale: widget.scale,
      headers: widget.headers,
      cacheWidth: widget.cacheWidth,
      cacheHeight: widget.cacheHeight,
      color: widget.color,
      colorBlendMode: widget.colorBlendMode,
      semanticLabel: widget.semanticLabel,
      alignment: widget.alignment,
      repeat: widget.repeat,
      centerSlice: widget.centerSlice,
      matchTextDirection: widget.matchTextDirection,
      gaplessPlayback: widget.gaplessPlayback,
      filterQuality: widget.filterQuality,
      enableLoadState: true,
      loadStateChanged: (ExtendedImageState state) {
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            // Use our custom loading builder if available
            if (widget.customLoadingBuilder != null) {
              // Create synthetic progress for ExtendedImage
              final syntheticProgress = CustomImageProgress(
                cumulativeBytesLoaded: 0,
                expectedTotalBytes: null,
                progress: null,
              );
              return widget.customLoadingBuilder!(
                context, 
                Container(), 
                syntheticProgress
              );
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          case LoadState.completed:
            return null; // Use default rendering
          case LoadState.failed:
            if (widget.errorBuilder != null) {
              return widget.errorBuilder!(context, state.lastException ?? 'Failed to load', null);
            }
            return Container(
              width: widget.width,
              height: widget.height,
              color: Colors.grey[300],
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error, color: Colors.red),
                    SizedBox(height: 8),
                    Text('Failed to load image'),
                  ],
                ),
              ),
            );
          default:
            return Container();
        }
      },
    );
    
    return image;
  }

  Widget _buildFlutterErrorWidget() {
    // Helper function to create default widgets from deprecated string parameters
    Widget _createDefaultErrorWidget() {
      final errorMessage = widget.errorText?.isNotEmpty == true ? widget.errorText! : 'Image failed to load';
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error, color: Colors.red),
          if (widget.errorText?.isNotEmpty == true) ...[
            SizedBox(width: 8),
            Text(errorMessage),
          ],
        ],
      );
    }

    Widget _createDefaultReloadWidget() {
      final reloadMessage = widget.reloadText?.isNotEmpty == true ? widget.reloadText! : 'Reload';
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.refresh),
          if (widget.reloadText?.isNotEmpty == true) ...[
            SizedBox(width: 8),
            Text(reloadMessage),
          ],
        ],
      );
    }

    Widget _createDefaultOpenUrlWidget() {
      final openUrlMessage = widget.openUrlText?.isNotEmpty == true ? widget.openUrlText! : 'Open in New Tab';
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.open_in_new),
          if (widget.openUrlText?.isNotEmpty == true) ...[
            SizedBox(width: 8),
            Text(openUrlMessage),
          ],
        ],
      );
    }

    // Determine which widgets to use (new widget parameters take precedence)
    final errorWidget = widget.errorWidget ?? 
        (widget.errorText != null ? _createDefaultErrorWidget() : 
         Row(
           mainAxisSize: MainAxisSize.min,
           children: [
             Icon(Icons.error, color: Colors.red),
             SizedBox(width: 8),
             Text('Image failed to load'),
           ],
         ));

    final reloadWidget = widget.reloadWidget ?? 
        (widget.reloadText != null ? _createDefaultReloadWidget() : 
         Row(
           mainAxisSize: MainAxisSize.min,
           children: [
             Icon(Icons.refresh),
             SizedBox(width: 8),
             Text('Reload'),
           ],
         ));

    final openUrlWidget = widget.openUrlWidget ?? 
        (widget.openUrlText != null ? _createDefaultOpenUrlWidget() : 
         Row(
           mainAxisSize: MainAxisSize.min,
           children: [
             Icon(Icons.open_in_new),
             SizedBox(width: 8),
             Text('Open in New Tab'),
           ],
         ));

    return Container(
      width: widget.width,
      height: widget.height,
      color: widget.errorBackgroundColor ?? Colors.grey[300],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error message widget
              Flexible(
                child: errorWidget,
              ),
              const SizedBox(height: 12),
              // Action buttons in column to prevent overflow
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Reload button
                  SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: () {
                        // Reset error states and try reloading
                        setState(() {
                          _loadError = false;
                          _htmlError = false;
                          _waitingForHtml = false;
                        });
                        _preloadImage();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(child: reloadWidget),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Open URL button
                  SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: () {
                        // Open URL in new tab/window
                        if (kIsWeb) {
                          // For web, we can use dart:html
                          try {
                            // Import dart:html dynamically to avoid issues on non-web platforms
                            // This will be handled by the conditional import
                            openUrlInNewTab(widget.url);
                          } catch (e) {
                            print('Error opening URL: $e');
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(child: openUrlWidget),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 