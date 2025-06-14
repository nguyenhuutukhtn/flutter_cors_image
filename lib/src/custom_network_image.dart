import 'dart:async';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'web_image_loader.dart' if (dart.library.io) 'stub_image_loader.dart';
import 'image_clipboard_helper.dart';
import 'types.dart';
import 'custom_network_image_controller.dart';
import 'disable_web_context_menu.dart';
import 'image_context_menu.dart';
// Web-specific imports for CORS workaround
import 'dart:html' as html show document;
import 'dart:js' as js show context, allowInterop, JsObject;

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

  /// NEW: Callback when image loads successfully with image data for copy functionality
  /// This provides the raw image bytes and metadata that can be used for copying
  final void Function(ImageDataInfo imageData)? onImageLoaded;

  /// NEW: Hover icons for quick actions (primarily for web)
  /// Custom download icon widget that appears on hover
  final Widget? downloadIcon;
  
  /// Custom copy icon widget that appears on hover  
  final Widget? copyIcon;
  
  /// Position of the hover icons (default: topRight)
  final HoverIconPosition hoverIconPosition;
  
  /// Layout direction for hover icons (default: auto)
  final HoverIconLayout hoverIconLayout;
  
  /// Enable hover icons (default: true on web, false on mobile)
  final bool enableHoverIcons;
  
  /// Spacing between hover icons when both are shown
  final double hoverIconSpacing;
  
  /// Padding around hover icons from the edge
  final EdgeInsetsGeometry hoverIconPadding;
  
  /// Callback when download icon is tapped
  final VoidCallback? onDownloadTap;
  
  /// Callback when copy icon is tapped  
  final VoidCallback? onCopyTap;
  
  /// NEW: Context menu functionality
  /// Enable right-click context menu (web only)
  final bool enableContextMenu;
  
  /// Custom context menu items (if null, uses default items)
  final List<ContextMenuItem>? customContextMenuItems;
  
  /// Context menu background color
  final Color? contextMenuBackgroundColor;
  
  /// Context menu text color
  final Color? contextMenuTextColor;
  
  /// Context menu elevation
  final double? contextMenuElevation;
  
  /// Context menu border radius
  final BorderRadius? contextMenuBorderRadius;
  
  /// Context menu padding
  final EdgeInsetsGeometry? contextMenuPadding;
  
  /// Callback when context menu action is performed
  final Function(ContextMenuAction)? onContextMenuAction;
  
  /// NEW v0.2.0: Widget-based error handling (RECOMMENDED)
  /// Custom error widget to show when image fails to load
  final Widget? errorWidget;
  
  /// Custom reload widget to show for retrying failed images
  final Widget? reloadWidget;
  
  /// Custom open URL widget to show for opening image URL in new tab
  final Widget? openUrlWidget;

  /// Background color for the error widget. Defaults to grey if not specified.
  final Color? errorBackgroundColor;
  
  /// NEW: Controller for external management
  /// Provides methods to reload, download, copy image and get state externally
  final CustomNetworkImageController? controller;
  
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
  /// Use [onImageLoaded] to receive image data when loading is successful for copy functionality.
  /// 
  /// NEW: Use [controller] for external control of the image widget:
  /// - controller.reload() - reload the image
  /// - controller.downloadImage() - download the image
  /// - controller.copyImageToClipboard() - copy image to clipboard
  /// - controller.getCurrentImageData() - get current image data
  /// - Listen to controller for state changes
  /// 
  /// NEW: Hover icons for quick actions (web/desktop):
  /// - [downloadIcon]: Custom icon for download action
  /// - [copyIcon]: Custom icon for copy action  
  /// - [hoverIconPosition]: Position of icons (topLeft, topRight, etc.)
  /// - [enableHoverIcons]: Enable/disable hover functionality
  /// - [hoverIconSpacing]: Space between icons when both are shown
  /// - [hoverIconPadding]: Padding around icons from image edge
  /// 
  /// NEW: Context menu functionality (web only):
  /// - [enableContextMenu]: Enable right-click context menu
  /// - [customContextMenuItems]: Custom menu items (uses default if null)
  /// - [contextMenuBackgroundColor]: Background color of context menu
  /// - [contextMenuTextColor]: Text color of context menu
  /// - [contextMenuElevation]: Elevation of context menu
  /// - [contextMenuBorderRadius]: Border radius of context menu
  /// - [contextMenuPadding]: Padding inside context menu
  /// - [onContextMenuAction]: Callback when context menu action is performed
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
    this.onImageLoaded, // NEW: Image data callback
    // NEW widget-based parameters (v0.2.0+)
    this.errorWidget,
    this.reloadWidget,
    this.openUrlWidget,
    // NEW: Controller parameter
    this.controller,
    // DEPRECATED string parameters (for backward compatibility)
    @Deprecated('Use errorWidget parameter instead. This will be removed in v1.0.0')
    this.errorText,
    @Deprecated('Use reloadWidget parameter instead. This will be removed in v1.0.0')
    this.reloadText,
    @Deprecated('Use openUrlWidget parameter instead. This will be removed in v1.0.0')
    this.openUrlText,
    this.errorBackgroundColor,
    this.downloadIcon,
    this.copyIcon,
    this.hoverIconPosition = HoverIconPosition.topRight,
    this.enableHoverIcons = true,
    this.hoverIconSpacing = 8.0,
    this.hoverIconPadding = EdgeInsets.zero,
    this.hoverIconLayout = HoverIconLayout.auto,
    this.onDownloadTap,
    this.onCopyTap,
    // Context menu parameters
    this.enableContextMenu = false,
    this.customContextMenuItems,
    this.contextMenuBackgroundColor,
    this.contextMenuTextColor,
    this.contextMenuElevation,
    this.contextMenuBorderRadius,
    this.contextMenuPadding,
    this.onContextMenuAction,
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
  
  // NEW: Store image data for copy functionality
  ImageDataInfo? _imageData;
  
  // NEW: Hover state for showing action icons
  bool _isHovering = false;
  
  // NEW: Context menu state
  OverlayEntry? _contextMenuOverlay;

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
    
    // NEW: Setup controller if provided
    if (widget.controller != null) {
      widget.controller!.setCallbacks(
        onReload: _handleControllerReload,
        onDownload: _handleControllerDownload,
        onCopy: _handleControllerCopy,
      );
      // Initialize controller state
      widget.controller!.updateLoadingState(_loadingState);
    }
    
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
        if (mounted) {
          setState(() {
            _htmlError = true;
            _waitingForHtml = false;
          });
          
          // Update controller state
          if (widget.controller != null) {
            widget.controller!.updateLoadingState(ImageLoadingState.failed);
            widget.controller!.updateError('HTML fallback also failed');
          }
        }
      });
      
      // NEW: Register HTML success callback
      setHtmlImageSuccessCallback(_viewType, () {
        if (mounted) {
          setState(() {
            _waitingForHtml = false; // Hide loading overlay
          });
          
          // IMPORTANT: Try to extract image data for copy functionality
          // when HTML fallback succeeds
          _tryExtractImageDataFromHtmlFallback();
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
    
    // Try loading the image asynchronously after initState completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _preloadImage();
      }
    });
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
          
          // IMPORTANT: Try to extract image data for copy functionality
          // when HTML fallback succeeds
          _tryExtractImageDataFromHtmlFallback();
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
    // PERFORMANCE FIX: Only clean up context menu if it was enabled
    if (widget.enableContextMenu && kIsWeb) {
      _removeContextMenu();
    }
    
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
    print('🔍 PROD DEBUG: _preloadImage called for ${widget.url}');
    
    // Clean up any existing stream
    _cleanupImageStream();
    
    // Reset loading state
    setState(() {
      _loadingState = ImageLoadingState.loading;
      _loadingProgress = const CustomImageProgress(cumulativeBytesLoaded: 0);
      _loadError = false;
      _htmlError = false;
      _waitingForHtml = false;
      _imageData = null; // Reset image data
    });
    
    print('🔍 PROD DEBUG: Reset loading state for ${widget.url}');
    
    // Update controller state
    if (widget.controller != null) {
      widget.controller!.updateLoadingState(_loadingState);
      widget.controller!.updateLoadingProgress(_loadingProgress);
      widget.controller!.updateImageData(null);
      widget.controller!.updateError(null);
      print('🔍 PROD DEBUG: Updated controller state for ${widget.url}');
    }
    
    // Create image provider and stream
    final imageProvider = NetworkImage(widget.url, headers: widget.headers);
    _imageStream = imageProvider.resolve(ImageConfiguration.empty);
    
    print('🔍 PROD DEBUG: Created image provider and stream for ${widget.url}');
    
    
    // Create our custom listener that tracks progress more reliably
    _imageStreamListener = ImageStreamListener(
      (ImageInfo info, bool synchronousCall) async {
        // PRODUCTION DEBUG: Log when image loads successfully
        print('🔍 PROD DEBUG: Image loaded successfully for ${widget.url}');
        print('🔍 PROD DEBUG: Image dimensions: ${info.image.width}x${info.image.height}');
        
        // Image loaded successfully
        if (mounted) {
          setState(() {
            _loadingState = ImageLoadingState.loaded;
            _loadingProgress = null;
            _loadError = false;
          });
          
          // Update controller state
          if (widget.controller != null) {
            widget.controller!.updateLoadingState(_loadingState);
            widget.controller!.updateLoadingProgress(null);
          }
          
          // Stop animation controller if not needed
          if (_transformSyncController.isAnimating) {
            _transformSyncController.stop();
          }
          
          // NEW: Extract image data for copy functionality
          if (widget.onImageLoaded != null || widget.controller != null) {
            print('🔍 PROD DEBUG: Attempting to extract image data for ${widget.url}');
            try {
              // Get the image bytes
              final Uint8List? imageBytes = await _getImageBytes(imageProvider);
              print('🔍 PROD DEBUG: _getImageBytes returned: ${imageBytes != null ? '${imageBytes.length} bytes' : 'null'} for ${widget.url}');
              
              if (imageBytes != null) {
                final imageData = ImageDataInfo(
                  imageBytes: imageBytes,
                  width: info.image.width,
                  height: info.image.height,
                  url: widget.url,
                );
                
                print('✅ PROD DEBUG: Created ImageDataInfo for ${widget.url}: ${imageData.imageBytes.length} bytes, ${imageData.width}x${imageData.height}');
                
                // Store image data and call callback
                _imageData = imageData;
                
                // Update controller
                if (widget.controller != null) {
                  widget.controller!.updateImageData(imageData);
                  print('✅ PROD DEBUG: Updated controller with image data for ${widget.url}');
                }
                
                // Call callback if provided
                if (widget.onImageLoaded != null) {
                  widget.onImageLoaded!(imageData);
                  print('✅ PROD DEBUG: Called onImageLoaded callback for ${widget.url}');
                }
              } else {
                print('❌ PROD DEBUG: Failed to extract image bytes for ${widget.url}');
                // Update controller with error
                if (widget.controller != null) {
                  widget.controller!.updateError('Failed to extract image bytes');
                }
              }
            } catch (e) {
              print('❌ PROD DEBUG: Error extracting image data for ${widget.url}: $e');
              print('❌ PROD DEBUG: Error stack trace: ${StackTrace.current}');
              // Error extracting image data
              if (widget.controller != null) {
                widget.controller!.updateError('Failed to extract image data: $e');
              }
            }
          } else {
            print('🔍 PROD DEBUG: Skipping image data extraction (no callback or controller) for ${widget.url}');
          }
        }
      },
      onError: (dynamic error, StackTrace? stackTrace) {
        // PRODUCTION DEBUG: Log image loading errors
        print('❌ PROD DEBUG: Image loading error for ${widget.url}: $error');
        print('❌ PROD DEBUG: Stack trace: $stackTrace');
        
        // Image failed to load
        if (mounted) {
          setState(() {
            _loadingState = ImageLoadingState.failed;
            _loadingProgress = null;
            _loadError = true;
            _waitingForHtml = true; // We'll try HTML next
            _imageData = null; // Clear image data on error
          });
          
          print('🔍 PROD DEBUG: Updated state to failed for ${widget.url}, will try HTML fallback');
          
          // Update controller state
          if (widget.controller != null) {
            widget.controller!.updateLoadingState(_loadingState);
            widget.controller!.updateLoadingProgress(null);
            widget.controller!.updateImageData(null);
            widget.controller!.updateError('Failed to load image: $error');
            print('🔍 PROD DEBUG: Updated controller with error for ${widget.url}');
          }
          
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
          
          final loadingProgress = CustomImageProgress(
            cumulativeBytesLoaded: event.cumulativeBytesLoaded,
            expectedTotalBytes: event.expectedTotalBytes,
            progress: progress,
          );
          
          setState(() {
            _loadingProgress = loadingProgress;
          });
          
          // Update controller state
          if (widget.controller != null) {
            widget.controller!.updateLoadingProgress(loadingProgress);
          }
        }
      },
    );
    
    // Add the listener to the stream
    _imageStream!.addListener(_imageStreamListener!);
  }

  // NEW: Helper method to extract image bytes from ImageProvider
  Future<Uint8List?> _getImageBytes(ImageProvider imageProvider) async {
    // PRODUCTION DEBUG: Add detailed logging
    print('🔍 PROD DEBUG: _getImageBytes called for URL: ${widget.url}');
    
    try {
      final ImageStream stream = imageProvider.resolve(ImageConfiguration.empty);
      final Completer<Uint8List?> completer = Completer<Uint8List?>();
      
      print('🔍 PROD DEBUG: Created image stream for ${widget.url}');
      
      late ImageStreamListener listener;
      listener = ImageStreamListener(
        (ImageInfo info, bool synchronousCall) async {
          print('🔍 PROD DEBUG: Image stream listener called for ${widget.url}');
          print('🔍 PROD DEBUG: Image info - width: ${info.image.width}, height: ${info.image.height}');
          
          try {
            print('🔍 PROD DEBUG: Attempting to convert image to bytes for ${widget.url}');
            final ByteData? byteData = await info.image.toByteData(format: ui.ImageByteFormat.png);
            print('🔍 PROD DEBUG: toByteData result: ${byteData != null ? '${byteData.lengthInBytes} bytes' : 'null'}');
            
            if (byteData != null) {
              final Uint8List bytes = byteData.buffer.asUint8List();
              print('🔍 PROD DEBUG: Successfully extracted ${bytes.length} bytes for ${widget.url}');
              stream.removeListener(listener);
              completer.complete(bytes);
            } else {
              print('❌ PROD DEBUG: ByteData is null for ${widget.url} - trying CORS workaround');
              stream.removeListener(listener);
              
              // Try CORS workaround when toByteData fails
              final corsBytes = await _fetchImageBytesWithCors(widget.url);
              if (corsBytes != null) {
                print('✅ PROD DEBUG: CORS workaround successful for ${widget.url}: ${corsBytes.length} bytes');
                completer.complete(corsBytes);
              } else {
                print('❌ PROD DEBUG: CORS workaround also failed for ${widget.url}');
                completer.complete(null);
              }
            }
          } catch (e) {
            print('❌ PROD DEBUG: Error in toByteData for ${widget.url}: $e');
            print('❌ PROD DEBUG: Error stack trace: ${StackTrace.current}');
            stream.removeListener(listener);
            
            // Try CORS workaround when toByteData throws an exception
            try {
              final corsBytes = await _fetchImageBytesWithCors(widget.url);
              if (corsBytes != null) {
                print('✅ PROD DEBUG: CORS workaround successful after exception for ${widget.url}: ${corsBytes.length} bytes');
                completer.complete(corsBytes);
              } else {
                print('❌ PROD DEBUG: CORS workaround also failed after exception for ${widget.url}');
                completer.complete(null);
              }
            } catch (corsError) {
              print('❌ PROD DEBUG: CORS workaround threw exception for ${widget.url}: $corsError');
              completer.complete(null);
            }
          }
        },
        onError: (dynamic error, StackTrace? stackTrace) {
          print('❌ PROD DEBUG: Image stream error for ${widget.url}: $error');
          print('❌ PROD DEBUG: Error stack trace: $stackTrace');
          stream.removeListener(listener);
          completer.complete(null);
        },
      );
      
      stream.addListener(listener);
      print('🔍 PROD DEBUG: Added listener to image stream for ${widget.url}');
      
      final result = await completer.future;
      print('🔍 PROD DEBUG: _getImageBytes result for ${widget.url}: ${result != null ? '${result.length} bytes' : 'null'}');
      return result;
    } catch (e) {
      print('❌ PROD DEBUG: _getImageBytes exception for ${widget.url}: $e');
      print('❌ PROD DEBUG: Exception stack trace: ${StackTrace.current}');
      
      // Last resort: try CORS workaround
      try {
        print('🔍 PROD DEBUG: Attempting CORS workaround as last resort for ${widget.url}');
        final corsBytes = await _fetchImageBytesWithCors(widget.url);
        if (corsBytes != null) {
          print('✅ PROD DEBUG: Last resort CORS workaround successful for ${widget.url}: ${corsBytes.length} bytes');
          return corsBytes;
        }
      } catch (corsError) {
        print('❌ PROD DEBUG: Last resort CORS workaround failed for ${widget.url}: $corsError');
      }
      
      return null;
    }
  }

  // NEW: Fetch image bytes directly using browser's fetch API to bypass CORS restrictions
  Future<Uint8List?> _fetchImageBytesWithCors(String imageUrl) async {
    if (!kIsWeb) {
      print('🔍 PROD DEBUG: _fetchImageBytesWithCors called on non-web platform');
      return null;
    }
    
    print('🔍 PROD DEBUG: _fetchImageBytesWithCors called for $imageUrl');
    
    try {
      // Use JavaScript fetch API which has better CORS handling
      final completer = Completer<Uint8List?>();
      
      final script = html.document.createElement('script');
      script.text = '''
        window.fetchImageBytes${widget.url.hashCode} = async function() {
          try {
            console.log('🔍 JS DEBUG: Fetching image bytes for $imageUrl');
            
            // Try different CORS modes
            let response;
            try {
              // First try with CORS mode (allows reading response)
              response = await fetch('$imageUrl', { 
                mode: 'cors',
                cache: 'no-cache'
              });
            } catch (corsError) {
              console.log('🔍 JS DEBUG: CORS mode failed, trying no-cors:', corsError.message);
              try {
                // Fallback to no-cors (won't allow reading response, but might work for some cases)
                response = await fetch('$imageUrl', { 
                  mode: 'no-cors',
                  cache: 'no-cache'
                });
              } catch (noCorsError) {
                console.log('🔍 JS DEBUG: No-cors also failed, trying default:', noCorsError.message);
                // Last try with default settings
                response = await fetch('$imageUrl');
              }
            }
            
            console.log('🔍 JS DEBUG: Fetch response status:', response.status, response.type);
            
            if (response.type === 'opaque') {
              console.log('❌ JS DEBUG: Response is opaque (no-cors), cannot read bytes');
              return null;
            }
            
            if (!response.ok) {
              console.log('❌ JS DEBUG: Response not ok:', response.status, response.statusText);
              return null;
            }
            
            const arrayBuffer = await response.arrayBuffer();
            const uint8Array = new Uint8Array(arrayBuffer);
            
            console.log('✅ JS DEBUG: Successfully fetched', uint8Array.length, 'bytes');
            
            // Convert to regular Array to avoid interop issues
            const regularArray = Array.from(uint8Array);
            console.log('🔍 JS DEBUG: Converted to regular array:', regularArray.length, 'elements');
            return regularArray;
            
          } catch (error) {
            console.error('❌ JS DEBUG: Fetch error:', error);
            return null;
          }
        };
      ''';
      
      html.document.head!.append(script);
      
      // Call the function
      final promise = js.context.callMethod('fetchImageBytes${widget.url.hashCode}');
      
      // Handle the promise
      final thenCallback = js.allowInterop((result) {
        script.remove(); // Clean up
        if (result != null) {
          try {
            print('🔍 PROD DEBUG: Processing JS result, type: ${result.runtimeType}');
            
            // Convert JavaScript regular array to Dart Uint8List
            final jsArray = result as js.JsObject;
            final length = jsArray['length'] as int;
            print('🔍 PROD DEBUG: JS array length: $length');
            
            // Create Dart Uint8List and copy data
            final dartList = Uint8List(length);
            for (int i = 0; i < length; i++) {
              // Convert each element to int (JS numbers to Dart ints)
              final value = jsArray[i];
              if (value is num) {
                dartList[i] = value.toInt();
              } else {
                dartList[i] = int.parse(value.toString());
              }
            }
            
            print('✅ PROD DEBUG: Successfully converted JS array to Dart Uint8List: ${dartList.length} bytes');
            completer.complete(dartList);
            
          } catch (conversionError) {
            print('❌ PROD DEBUG: Error converting JS array to Dart: $conversionError');
            print('❌ PROD DEBUG: Conversion stack trace: ${StackTrace.current}');
            completer.complete(null);
          }
        } else {
          print('❌ PROD DEBUG: JS fetch returned null');
          completer.complete(null);
        }
      });
      
      final catchCallback = js.allowInterop((error) {
        print('❌ PROD DEBUG: JS promise rejected: $error');
        script.remove(); // Clean up
        completer.complete(null);
      });
      
      if (promise != null) {
        promise.callMethod('then', [thenCallback]).callMethod('catch', [catchCallback]);
      } else {
        print('❌ PROD DEBUG: JS function returned null promise');
        script.remove();
        completer.complete(null);
      }
      
      final result = await completer.future;
      print('🔍 PROD DEBUG: _fetchImageBytesWithCors final result for $imageUrl: ${result != null ? '${result.length} bytes' : 'null'}');
      return result;
      
    } catch (e) {
      print('❌ PROD DEBUG: _fetchImageBytesWithCors exception for $imageUrl: $e');
      print('❌ PROD DEBUG: Exception stack trace: ${StackTrace.current}');
      return null;
    }
  }

  // NEW: Try to extract image data from HTML fallback for copy functionality
  Future<void> _tryExtractImageDataFromHtmlFallback() async {
    print('🔍 PROD DEBUG: _tryExtractImageDataFromHtmlFallback called for ${widget.url}');
    print('🔍 PROD DEBUG: mounted: $mounted, _imageData: ${_imageData != null}');
    
    if (!mounted || _imageData != null) {
      print('🔍 PROD DEBUG: Skipping HTML data extraction - mounted: $mounted, hasData: ${_imageData != null}');
      return; // Already have data
    }
    
    try {
      print('🔍 PROD DEBUG: Attempting to extract image data from HTML fallback for ${widget.url}');
      // Attempt to load the image again using ImageProvider to get bytes
      // This is a workaround since HTML img doesn't provide bytes directly
      final imageProvider = NetworkImage(widget.url, headers: widget.headers);
      final imageBytes = await _getImageBytes(imageProvider);
      
      print('🔍 PROD DEBUG: HTML fallback _getImageBytes returned: ${imageBytes != null ? '${imageBytes.length} bytes' : 'null'} for ${widget.url}');
      
      if (imageBytes != null && mounted) {
        print('🔍 PROD DEBUG: Got image bytes from HTML fallback, attempting to decode for ${widget.url}');
        // We need to get dimensions, try to decode the image
        try {
          final codec = await ui.instantiateImageCodec(imageBytes);
          final frame = await codec.getNextFrame();
          final ui.Image image = frame.image;
          
          print('🔍 PROD DEBUG: Successfully decoded image dimensions: ${image.width}x${image.height} for ${widget.url}');
          
          final imageData = ImageDataInfo(
            imageBytes: imageBytes,
            width: image.width,
            height: image.height,
            url: widget.url,
          );
          
          // Update state
          setState(() {
            _imageData = imageData;
            _loadingState = ImageLoadingState.loaded; // Update to loaded since HTML succeeded
          });
          
          print('✅ PROD DEBUG: HTML fallback - Updated state with image data for ${widget.url}');
          
          // Update controller
          if (widget.controller != null) {
            widget.controller!.updateImageData(imageData);
            widget.controller!.updateLoadingState(ImageLoadingState.loaded);
            widget.controller!.updateError(null);
            print('✅ PROD DEBUG: HTML fallback - Updated controller with image data for ${widget.url}');
          }
          
          // Call callback if provided
          if (widget.onImageLoaded != null) {
            widget.onImageLoaded!(imageData);
            print('✅ PROD DEBUG: HTML fallback - Called onImageLoaded callback for ${widget.url}');
          }
          
          image.dispose();
        } catch (e) {
          print('⚠️ PROD DEBUG: Failed to decode image dimensions for ${widget.url}: $e');
          // Failed to decode image for dimensions, create with unknown dimensions
          final imageData = ImageDataInfo(
            imageBytes: imageBytes,
            width: 0, // Unknown
            height: 0, // Unknown
            url: widget.url,
          );
          
          if (mounted) {
            setState(() {
              _imageData = imageData;
              _loadingState = ImageLoadingState.loaded;
            });
            
            print('✅ PROD DEBUG: HTML fallback - Updated state with unknown dimensions for ${widget.url}');
            
            // Update controller
            if (widget.controller != null) {
              widget.controller!.updateImageData(imageData);
              widget.controller!.updateLoadingState(ImageLoadingState.loaded);
              widget.controller!.updateError(null);
              print('✅ PROD DEBUG: HTML fallback - Updated controller with unknown dimensions for ${widget.url}');
            }
            
            // Call callback if provided
            if (widget.onImageLoaded != null) {
              widget.onImageLoaded!(imageData);
              print('✅ PROD DEBUG: HTML fallback - Called onImageLoaded callback with unknown dimensions for ${widget.url}');
            }
          }
        }
      } else {
        print('❌ PROD DEBUG: HTML fallback failed to get image bytes for ${widget.url}');
      }
    } catch (e) {
      print('❌ PROD DEBUG: HTML fallback exception for ${widget.url}: $e');
      print('❌ PROD DEBUG: HTML fallback stack trace: ${StackTrace.current}');
      // Failed to extract image data, but HTML is still showing the image
      // This is not a critical error, just means copy won't work
      
      // Update controller with partial success state
      if (widget.controller != null) {
        widget.controller!.updateLoadingState(ImageLoadingState.loaded);
        widget.controller!.updateError('Image loaded via HTML but copy functionality unavailable');
      }
    }
  }

  // NEW: Public method to get current image data (if available)
  ImageDataInfo? getCurrentImageData() {
    return _imageData;
  }

  @override
  Widget build(BuildContext context) {
    // Removed debug print to improve performance
    
    Widget imageWidget;
    
    // Check if we should show Flutter error widget (both Flutter and HTML failed)
    if (kIsWeb && _loadError && _htmlError) {
      imageWidget = _buildFlutterErrorWidget();
    }
    // If we're on web and Flutter failed but HTML hasn't been tried yet or is in progress
    else if (kIsWeb && _loadError) {
      imageWidget = _buildHtmlImageView();
    } 
    // If we're still loading and have a custom loading builder, show loading state
    else if (_loadingState == ImageLoadingState.loading && widget.customLoadingBuilder != null) {
      imageWidget = _buildCustomLoadingWidget();
    }
    // If we haven't detected an error yet, try normal Flutter image
    else if (!_loadError) {
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
    
    // NEW: Wrap with hover functionality if enabled and we have icons
    if (widget.enableHoverIcons && _shouldShowHoverIcons()) {
      imageWidget = _buildHoverImageWidget(imageWidget);
    }
    
    // Apply context menu support and gesture handling to ALL widgets
    return _buildWithContextMenuSupport(imageWidget);
  }

  /// Build widget with context menu support
  Widget _buildWithContextMenuSupport(Widget imageWidget) {
    Widget wrappedWidget = imageWidget;
    
    // Add tap gesture handling if needed (but not for HTML fallback which has its own handling)
    if (widget.onTap != null && !(kIsWeb && _loadError)) {
      wrappedWidget = GestureDetector(
        onTap: widget.onTap,
        child: wrappedWidget,
      );
    }
    
    // PERFORMANCE FIX: Only add context menu support if enabled (web only)
    if (widget.enableContextMenu && kIsWeb) {
      wrappedWidget = _buildContextMenuWrapper(wrappedWidget);
    }
    
    return wrappedWidget;
  }
  
  /// Build context menu wrapper with right-click detection
  Widget _buildContextMenuWrapper(Widget child) {
    return DisableWebContextMenu(
      identifier: 'image_${widget.url.hashCode}_${hashCode}',
      onContextMenu: _showContextMenuAt,
      child: child,
    );
  }
  
  /// Show context menu at the specified global position
  void _showContextMenuAt(Offset globalPosition) {
    // PERFORMANCE FIX: Early return if context menu is disabled
    if (!widget.enableContextMenu || !kIsWeb || !mounted) return;
    
    // Remove any existing context menu
    _removeContextMenu();
    
    // Get context menu items (use custom or default)
    final items = widget.customContextMenuItems ?? ImageContextMenu.defaultItems;
    
    // Create the overlay entry
    _contextMenuOverlay = OverlayEntry(
      builder: (context) {
        return ImageContextMenu(
          position: globalPosition,
          items: items,
          imageUrl: widget.url,
          imageData: _imageData,
          backgroundColor: widget.contextMenuBackgroundColor,
          textColor: widget.contextMenuTextColor,
          elevation: widget.contextMenuElevation,
          borderRadius: widget.contextMenuBorderRadius,
          padding: widget.contextMenuPadding,
          onDismiss: _removeContextMenu,
          onAction: (action) {
            // Call the callback if provided
            if (widget.onContextMenuAction != null) {
              widget.onContextMenuAction!(action);
            }
          },
        );
      },
    );
    
    // Insert the overlay
    try {
      Overlay.of(context).insert(_contextMenuOverlay!);
    } catch (e) {
      // Silently fail
    }
  }
  
  /// Remove the context menu
  void _removeContextMenu() {
    // PERFORMANCE FIX: Only remove if overlay exists
    if (_contextMenuOverlay != null) {
      _contextMenuOverlay!.remove();
      _contextMenuOverlay = null;
    }
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
                    child: const Center(
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
              final syntheticProgress = const CustomImageProgress(
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
            return const Center(
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
              child: const Center(
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
          const Icon(Icons.error, color: Colors.red),
          if (widget.errorText?.isNotEmpty == true) ...[
            const SizedBox(width: 8),
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
          const Icon(Icons.refresh),
          if (widget.reloadText?.isNotEmpty == true) ...[
            const SizedBox(width: 8),
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
          const Icon(Icons.open_in_new),
          if (widget.openUrlText?.isNotEmpty == true) ...[
            const SizedBox(width: 8),
            Text(openUrlMessage),
          ],
        ],
      );
    }

    // Determine which widgets to use (new widget parameters take precedence)
    final errorWidget = widget.errorWidget ?? 
        (widget.errorText != null ? _createDefaultErrorWidget() : 
         const Row(
           mainAxisSize: MainAxisSize.min,
           children: [
             Icon(Icons.error, color: Colors.red),
             SizedBox(width: 8),
             Text('Image failed to load'),
           ],
         ));

    final reloadWidget = widget.reloadWidget ?? 
        (widget.reloadText != null ? _createDefaultReloadWidget() : 
         const Row(
           mainAxisSize: MainAxisSize.min,
           children: [
             Icon(Icons.refresh),
             SizedBox(width: 8),
             Text('Reload'),
           ],
         ));

    final openUrlWidget = widget.openUrlWidget ?? 
        (widget.openUrlText != null ? _createDefaultOpenUrlWidget() : 
         const Row(
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
                            // Error opening URL
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

  // NEW: Check if we should show hover icons
  bool _shouldShowHoverIcons() {
    return (widget.downloadIcon != null || widget.copyIcon != null) && 
           (_imageData != null || _loadingState == ImageLoadingState.loaded);
  }
  
  // NEW: Build image widget with hover functionality
  Widget _buildHoverImageWidget(Widget imageWidget) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: Stack(
        children: [
          imageWidget,
          if (_isHovering) _buildHoverIcons(),
        ],
      ),
    );
  }
  
  // NEW: Build hover icons overlay
  Widget _buildHoverIcons() {
    final List<Widget> icons = [];
    
    // Add download icon if provided
    if (widget.downloadIcon != null) {
      icons.add(
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (widget.onDownloadTap != null) {
                widget.onDownloadTap!();
              } else {
                _handleDownloadTap();
              }
            },
            borderRadius: BorderRadius.circular(4),
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: widget.downloadIcon!,
            ),
          ),
        ),
      );
    }
    
    // Add copy icon if provided
    if (widget.copyIcon != null) {
      icons.add(
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (widget.onCopyTap != null) {
                widget.onCopyTap!();
              } else {
                _handleCopyTap();
              }
            },
            borderRadius: BorderRadius.circular(4),
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: widget.copyIcon!,
            ),
          ),
        ),
      );
    }
    
    if (icons.isEmpty) return SizedBox.shrink();
    
    // Position the icons based on the selected position
    return _getIconPositionedWidget(
      Padding(
        padding: widget.hoverIconPadding,
        child: _getIconLayout(icons),
      ),
    );
  }
  
  // NEW: Get positioning properties for the icons
  Positioned _getIconPositionedWidget(Widget child) {
    switch (widget.hoverIconPosition) {
      case HoverIconPosition.topLeft:
        return Positioned(top: 0, left: 0, child: child);
      case HoverIconPosition.topRight:
        return Positioned(top: 0, right: 0, child: child);
      case HoverIconPosition.bottomLeft:
        return Positioned(bottom: 0, left: 0, child: child);
      case HoverIconPosition.bottomRight:
        return Positioned(bottom: 0, right: 0, child: child);
      case HoverIconPosition.topCenter:
        return Positioned(top: 0, left: 0, right: 0, child: child);
      case HoverIconPosition.bottomCenter:
        return Positioned(bottom: 0, left: 0, right: 0, child: child);
    }
  }
  
  // NEW: Get layout for icons (row or column based on position and layout setting)
  Widget _getIconLayout(List<Widget> icons) {
    bool useHorizontalLayout;
    
    // Determine layout direction based on setting
    switch (widget.hoverIconLayout) {
      case HoverIconLayout.row:
        useHorizontalLayout = true;
        break;
      case HoverIconLayout.column:
        useHorizontalLayout = false;
        break;
      case HoverIconLayout.auto:
        // Auto: horizontal for center positions, vertical for corner positions
        useHorizontalLayout = widget.hoverIconPosition == HoverIconPosition.topCenter ||
                             widget.hoverIconPosition == HoverIconPosition.bottomCenter;
        break;
    }
    
    if (useHorizontalLayout) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: widget.hoverIconPosition == HoverIconPosition.topCenter ||
                          widget.hoverIconPosition == HoverIconPosition.bottomCenter
            ? MainAxisAlignment.center 
            : MainAxisAlignment.start,
        children: icons.expand((icon) => [
          icon, 
          if (icon != icons.last) SizedBox(width: widget.hoverIconSpacing)
        ]).toList(),
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: icons.expand((icon) => [
          icon, 
          if (icon != icons.last) SizedBox(height: widget.hoverIconSpacing)
        ]).toList(),
      );
    }
  }
  
  // NEW: Handle download icon tap
  Future<void> _handleDownloadTap() async {
    if (_imageData == null) return;
    
    try {
      // Use download method for download action
      await ImageClipboardHelper.downloadImage(_imageData!);
    } catch (e) {
      // Error downloading image
    }
  }
  
  // NEW: Handle copy icon tap  
  Future<void> _handleCopyTap() async {
    if (_imageData == null) return;
    
    try {
      // Use clipboard copy method for copy action
      await ImageClipboardHelper.copyImageToClipboard(_imageData!);
    } catch (e) {
      // Error copying image
    }
  }

  // NEW: Controller callback handlers
  void _handleControllerReload() {
    _preloadImage();
  }

  void _handleControllerDownload() {
    if (widget.onDownloadTap != null) {
      widget.onDownloadTap!();
    } else {
      _handleDownloadTap();
    }
  }

  void _handleControllerCopy() {
    if (widget.onCopyTap != null) {
      widget.onCopyTap!();
    } else {
      _handleCopyTap();
    }
  }
} 