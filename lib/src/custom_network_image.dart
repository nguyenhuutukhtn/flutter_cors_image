import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'web_image_loader.dart' if (dart.library.io) 'stub_image_loader.dart' as image_loader;
import 'image_clipboard_helper.dart';
import 'types.dart';
import 'custom_network_image_controller.dart';
import 'disable_web_context_menu.dart';
import 'image_context_menu.dart';
import 'web_storage_cache.dart';
// Import context menu helper for openUrlInNewTab function
import 'web_context_menu_helper.dart' if (dart.library.io) 'stub_context_menu_helper.dart';

/// A network image widget that handles problematic images by falling back to HTML img tag
/// when the standard Flutter image loader fails.
///
/// This widget first tries to load the image using Flutter's Image.network,
/// and if that fails (on web platforms), it automatically falls back to using an HTML img tag.



class CustomNetworkImage extends StatefulWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  
  // NEW: Local file support
  /// Local image bytes (Uint8List) - works on all platforms
  final Uint8List? localFileBytes;
  /// Web File object (for Flutter web only) - use dynamic type for cross-platform compatibility
  final dynamic webFile;
  /// Web Blob object (for Flutter web only) - use dynamic type for cross-platform compatibility
  final dynamic webBlob;
  
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

  /// NEW: Context to show the context menu at
  final BuildContext? contextToShowContextMenu;
  
  /// NEW: Web storage cache configuration
  /// Enables persistent caching of images in browser storage (localStorage)
  /// Only works on web platforms. Defaults to enabled with 7-day expiration.
  final WebStorageCacheConfig webStorageCacheConfig;
  
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
  /// Either [url] for network images or one of [localFileBytes], [webFile], [webBlob] for local files must be provided.
  /// For local files, the widget will try Flutter's Image.memory first, then fall back to HTML with data URLs or Blob URLs if needed.
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
  /// 
  /// NEW: Web storage caching (web only):
  /// - [webStorageCacheConfig]: Configure persistent image caching in browser storage
  /// - Caches images in localStorage to prevent repeated server requests
  /// - Configurable cache size limit and expiration time
  /// - Automatically manages cache cleanup when storage quota is reached
  const CustomNetworkImage({
    Key? key,
    this.url,
    // NEW: Local file parameters
    this.localFileBytes,
    this.webFile,
    this.webBlob,
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
    this.contextToShowContextMenu,
    this.webStorageCacheConfig = const WebStorageCacheConfig(),
  }) : assert(
         (url != null) ^ (localFileBytes != null || webFile != null || webBlob != null),
         'Either url or one of localFileBytes/webFile/webBlob must be provided, but not both'
       ),
       super(key: key);
  
  /// Helper getter to check if this is a local file
  bool get isLocalFile => localFileBytes != null || webFile != null || webBlob != null;
  
  /// Helper getter to get display name for local files
  String get displayName {
    if (url != null) return url!;
    if (webFile != null && kIsWeb) {
      try {
        return (webFile as dynamic).name ?? 'web_file';
      } catch (e) {
        return 'web_file';
      }
    }
    return 'local_image';
  }

  @override
  State<CustomNetworkImage> createState() => _CustomNetworkImageState();
}

class _CustomNetworkImageState extends State<CustomNetworkImage> with SingleTickerProviderStateMixin {
  
  bool _loadError = false;
  bool _htmlError = false; // NEW: Track when HTML also fails
  bool _waitingForHtml = false; // Track when we're trying HTML
  final GlobalKey _key = GlobalKey();
  late String _viewType;
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
  
  // NEW: Loading guard to prevent multiple simultaneous loads
  bool _isCurrentlyLoading = false;
  

  
  // NEW: Helper method to cache image in web storage
  void _cacheImageInWebStorage(ImageDataInfo imageData, String contentType) {
    if (!kIsWeb || !widget.webStorageCacheConfig.enabled) return;
    
    // Run async caching in the background without blocking UI
    Future.microtask(() async {
      try {
        final webCache = WebStorageCache.instance;
        await webCache.cacheImage(imageData, contentType, widget.webStorageCacheConfig);
      } catch (e) {
        // Silently fail - web storage caching is not critical
      }
    });
  }

  @override
  void initState() {
    super.initState();
    
    // Create a unique view type name for this widget instance
    // Include uniqueId if provided for better isolation in ListViews
    final displayId = widget.uniqueId ?? widget.displayName.hashCode;
    _viewType = 'html-image-$displayId-${DateTime.now().millisecondsSinceEpoch}';
    
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
    
    // REMOVED: Don't register HTML view factory early - only when needed
    // This prevents empty HTML elements from being created prematurely
    
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
    
    // If URL/local file or uniqueId changed, we need to update our references
    bool needsViewUpdate = oldWidget.url != widget.url || 
                          oldWidget.uniqueId != widget.uniqueId ||
                          oldWidget.localFileBytes != widget.localFileBytes ||
                          oldWidget.webFile != widget.webFile ||
                          oldWidget.webBlob != widget.webBlob;
    
    // Only update HTML view if we're actually using HTML fallback
    if (needsViewUpdate && kIsWeb && _loadError) {
      // Clean up old references
      _cleanupHtmlResources();
      
      // Create new view type
      final displayId = widget.uniqueId ?? widget.displayName.hashCode;
      final newViewType = 'html-image-$displayId-${DateTime.now().millisecondsSinceEpoch}';
      
      // Update view type (now allowed since it's not final)
      _viewType = newViewType;
      
      // Re-register HTML fallback with new view type and URL
      _setHtmlFallbackState();
    }
    
    // Handle transformation controller changes
    if (oldWidget.transformationController != widget.transformationController) {
      if (oldWidget.transformationController != null) {
        oldWidget.transformationController!.removeListener(_handleTransformationChange);
      }
      
      if (widget.transformationController != null && kIsWeb && _loadError) {
        widget.transformationController!.addListener(_handleTransformationChange);
        
        // Ensure animation controller is running if needed
        if (!_transformSyncController.isAnimating) {
          _transformSyncController.repeat();
          _transformSyncController.addListener(_checkForTransformationUpdates);
        }
      } else if (_transformSyncController.isAnimating) {
        _transformSyncController.stop();
      }
    }
    
    // Handle onTap changes for HTML fallback
    if (oldWidget.onTap != widget.onTap && kIsWeb && _loadError) {
      if (widget.onTap != null) {
        image_loader.setHtmlImageTapCallback(_viewType, () {
          if (widget.onTap != null) {
            widget.onTap!();
          }
        });
      } else {
        image_loader.removeHtmlImageTapCallback(_viewType);
      }
    }
    
    // Check if styling properties changed for HTML fallback update
    bool needsStylingUpdate = oldWidget.fit != widget.fit;
    
    // Update HTML fallback styling if we're using HTML fallback and styling changed
    if (needsStylingUpdate && kIsWeb && _loadError && !_htmlError) {
      image_loader.updateHtmlImageStyling(
        _viewType,
        boxFit: widget.fit,
        borderRadius: 0.0, // Border radius handled by ClipRRect wrapper
      );
    }
    
    // If URL or local file changed, reload the image
    if (oldWidget.url != widget.url ||
        oldWidget.localFileBytes != widget.localFileBytes ||
        oldWidget.webFile != widget.webFile ||
        oldWidget.webBlob != widget.webBlob) {
      // Reset loading guard for content change
      _isCurrentlyLoading = false;
      _preloadImage();
    }
  }
  
  @override
  void dispose() {
    // PERFORMANCE FIX: Only clean up context menu if it was enabled
    if (widget.enableContextMenu && kIsWeb) {
      _removeContextMenu();
    }
    
    // Clean up HTML resources only if we're using HTML fallback
    _cleanupHtmlResources();
    
    // NEW: Clean up JavaScript fetch function to prevent memory leaks
    if (kIsWeb && widget.url != null) {
      image_loader.cleanupCorsFunction(widget.url!);
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
  
  // NEW: Clean up HTML resources (utility method)
  void _cleanupHtmlResources() {
    if (!kIsWeb || !_loadError) return;
    
    image_loader.removeHtmlImageTapCallback(_viewType);
    image_loader.removeHtmlImageErrorCallback(_viewType);
    image_loader.removeHtmlImageSuccessCallback(_viewType);
    image_loader.cleanupHtmlElement(_viewType);
    
    // Remove transformation listener if it was added
    if (widget.transformationController != null) {
      widget.transformationController!.removeListener(_handleTransformationChange);
    }
    
    // Stop animation controller if running
    if (_transformSyncController.isAnimating) {
      _transformSyncController.stop();
    }
  }
  
  // Continuously check for transformation changes for smoother updates
  void _checkForTransformationUpdates() {
    if (kIsWeb && _loadError && widget.transformationController != null) {
      // Only update if we're using HTML fallback and have a transformation controller
      final matrix = widget.transformationController!.value;
      if (_lastTransformation != matrix) {
        image_loader.updateHtmlImageTransform(_viewType, matrix);
        _lastTransformation = matrix;
      }
    }
  }
  
  // Handle discrete transformation changes
  void _handleTransformationChange() {
    if (!kIsWeb || !_loadError || widget.transformationController == null) return;
    
    // This is called when the controller value changes programmatically
    final matrix = widget.transformationController!.value;
    image_loader.updateHtmlImageTransform(_viewType, matrix);
    _lastTransformation = matrix;
  }

  void _preloadImage() async {
    
    // Prevent multiple simultaneous loading attempts
    if (_isCurrentlyLoading) {
      return;
    }
    
    // CRITICAL FIX: If we already have valid image data, don't reload
    if (_imageData != null && _loadingState == ImageLoadingState.loaded && !_loadError) {
      return;
    }
    
    // NEW: Handle local files first (they don't need web storage cache)
    if (widget.isLocalFile) {
      _preloadLocalFile();
      return;
    }
    
    // Ensure we have a URL for network images
    if (widget.url == null) {
      setState(() {
        _loadingState = ImageLoadingState.failed;
        _loadError = true;
      });
      return;
    }
    
    // NEW: Check web storage cache (IndexedDB) for persistent caching
    if (kIsWeb && widget.webStorageCacheConfig.enabled) {
      try {
        final webCache = WebStorageCache.instance;
        final cachedData = await webCache.getCachedImage(widget.url!, widget.webStorageCacheConfig);
        
        if (cachedData != null && mounted) {
          final imageData = cachedData.toImageDataInfo();
          
          setState(() {
            _imageData = imageData;
            _loadingState = ImageLoadingState.loaded;
            _loadError = false;
            _htmlError = false;
            _waitingForHtml = false;
          });
          
          // Update controller state
          if (widget.controller != null) {
            widget.controller!.updateLoadingState(ImageLoadingState.loaded);
            widget.controller!.updateImageData(imageData);
            widget.controller!.updateError(null);
          }
          
          // Call callback if provided
          if (widget.onImageLoaded != null) {
            widget.onImageLoaded!(imageData);
          }
          
          _isCurrentlyLoading = false;
          return;
        } else {
        }
      } catch (e) {
        // Web storage cache failed, continue with normal loading
      }
    }
    
    // IMPORTANT FIX: Don't reload if image is already successfully loaded
    // This prevents unnecessary reloading in ListView scrolling scenarios
    if (_loadingState == ImageLoadingState.loaded && _imageData != null && !_loadError) {
      return;
    }
    
    // Also don't reload if we're using HTML fallback and it's working (not in error state)
    if (kIsWeb && _loadError && !_htmlError && !_waitingForHtml) {
      return;
    }
    
    _isCurrentlyLoading = true;
    
    // Clean up any existing stream
    _cleanupImageStream();
    
    // Only reset loading state if we're not already loaded or in a working state
    bool shouldResetState = _loadingState != ImageLoadingState.loaded || _imageData == null;
    
    if (shouldResetState) {
      // Reset loading state
      setState(() {
        _loadingState = ImageLoadingState.loading;
        _loadingProgress = const CustomImageProgress(cumulativeBytesLoaded: 0);
        _loadError = false;
        _htmlError = false;
        _waitingForHtml = false;
        _imageData = null; // Reset image data
      });
      
      // Update controller state
      if (widget.controller != null) {
        widget.controller!.updateLoadingState(_loadingState);
        widget.controller!.updateLoadingProgress(_loadingProgress);
        widget.controller!.updateImageData(null);
        widget.controller!.updateError(null);
      }
    }
    
    // On web platform, try to fetch image bytes first to prevent duplicate requests
    if (kIsWeb) {
      _preloadImageWeb();
    } else {
      _preloadImageNative();
    }
  }
  
  // NEW: Local file loading that handles Uint8List, Web File, or Web Blob
  void _preloadLocalFile() async {
    _isCurrentlyLoading = true;
    
    setState(() {
      _loadingState = ImageLoadingState.loading;
      _loadingProgress = const CustomImageProgress(cumulativeBytesLoaded: 0);
      _loadError = false;
      _htmlError = false;
      _waitingForHtml = false;
      _imageData = null;
    });
    
    // Update controller state
    if (widget.controller != null) {
      widget.controller!.updateLoadingState(_loadingState);
      widget.controller!.updateLoadingProgress(_loadingProgress);
      widget.controller!.updateImageData(null);
      widget.controller!.updateError(null);
    }
    
    try {
      Uint8List? imageBytes;
      
      // Get bytes from different local file sources
      if (widget.localFileBytes != null) {
        imageBytes = widget.localFileBytes!;
      } else if (widget.webFile != null && kIsWeb) {
        // Handle web File object
        imageBytes = await _readWebFile(widget.webFile);
      } else if (widget.webBlob != null && kIsWeb) {
        // Handle web Blob object
        imageBytes = await _readWebBlob(widget.webBlob);
      }
      
      if (imageBytes != null && mounted) {
        // Try to decode the image with Flutter first
        try {
          final codec = await ui.instantiateImageCodec(imageBytes);
          final frame = await codec.getNextFrame();
          final ui.Image image = frame.image;
          
          // Create image data
          final imageData = ImageDataInfo(
            imageBytes: imageBytes,
            width: image.width,
            height: image.height,
            url: widget.displayName,
          );
          
          // Update state - image loaded successfully
          if (mounted) {
            setState(() {
              _loadingState = ImageLoadingState.loaded;
              _loadingProgress = null;
              _loadError = false;
              _imageData = imageData;
            });
            
            // Update controller state
            if (widget.controller != null) {
              widget.controller!.updateLoadingState(_loadingState);
              widget.controller!.updateLoadingProgress(null);
              widget.controller!.updateImageData(imageData);
              widget.controller!.updateError(null);
            }
            
            // Call callback if provided
            if (widget.onImageLoaded != null) {
              widget.onImageLoaded!(imageData);
            }
          }
          
          image.dispose();
          _isCurrentlyLoading = false;
          
        } catch (decodeError) {
          // Failed to decode with Flutter - try HTML fallback on web
          if (kIsWeb && mounted) {
            _setLocalFileHtmlFallback(imageBytes);
          } else {
            // On non-web platforms, show error
            _setLocalFileError('Failed to decode image: $decodeError');
          }
          _isCurrentlyLoading = false;
        }
      } else {
        // Failed to read file
        _setLocalFileError('Failed to read local file');
        _isCurrentlyLoading = false;
      }
      
    } catch (e) {
      // Error reading local file
      _setLocalFileError('Error loading local file: $e');
      _isCurrentlyLoading = false;
    }
  }
  
  // Helper method to read Web File (web only)
  Future<Uint8List?> _readWebFile(dynamic file) async {
    if (!kIsWeb) return null;
    
    try {
      // Use FileReader to read the file as array buffer
      final completer = Completer<Uint8List?>();
      
      // Create a FileReader using JavaScript interop
      final reader = image_loader.createFileReader();
      
      // Set up callbacks
      image_loader.setFileReaderCallbacks(
        reader,
        onLoad: (result) {
          completer.complete(result);
        },
        onError: (error) {
          completer.complete(null);
        },
      );
      
      // Start reading the file
      image_loader.readFileAsArrayBuffer(reader, file);
      
      return await completer.future;
    } catch (e) {
      return null;
    }
  }
  
  // Helper method to read Web Blob (web only)
  Future<Uint8List?> _readWebBlob(dynamic blob) async {
    if (!kIsWeb) return null;
    
    try {
      // Convert Blob to ArrayBuffer and then to Uint8List
      return await image_loader.readBlobAsUint8List(blob);
    } catch (e) {
      return null;
    }
  }
  
  // Helper method to set HTML fallback for local files
  void _setLocalFileHtmlFallback(Uint8List imageBytes) {
    setState(() {
      _loadingState = ImageLoadingState.failed;
      _loadingProgress = null;
      _loadError = true;
      _waitingForHtml = true;
      _imageData = null;
    });
    
    // Update controller state
    if (widget.controller != null) {
      widget.controller!.updateLoadingState(_loadingState);
      widget.controller!.updateLoadingProgress(null);
      widget.controller!.updateImageData(null);
      widget.controller!.updateError('Failed to decode with Flutter, using HTML fallback');
    }
    
    // Register HTML view factory with data URL
    if (kIsWeb) {
      // Create data URL from bytes
      final dataUrl = image_loader.createDataUrlFromBytes(imageBytes);
      
      // Register callbacks
      _registerLocalFileHtmlCallbacks();
      
      // Register the HTML view factory with the data URL and styling parameters
      image_loader.registerHtmlImageFactory(
        _viewType, 
        dataUrl,
        boxFit: widget.fit,
        borderRadius: 0.0, // Local files don't use ClipRRect border radius in HTML
        width: widget.width,
        height: widget.height,
      );
    }
  }
  
  // Helper method to set local file error
  void _setLocalFileError(String error) {
    if (mounted) {
      setState(() {
        _loadingState = ImageLoadingState.failed;
        _loadingProgress = null;
        _loadError = true;
        _htmlError = true; // Both Flutter and HTML failed
        _waitingForHtml = false;
        _imageData = null;
      });
      
      // Update controller state
      if (widget.controller != null) {
        widget.controller!.updateLoadingState(_loadingState);
        widget.controller!.updateLoadingProgress(null);
        widget.controller!.updateImageData(null);
        widget.controller!.updateError(error);
      }
    }
  }
  
  // Helper method to register HTML callbacks for local files
  void _registerLocalFileHtmlCallbacks() {
    // Register the tap callback if we have one
    if (widget.onTap != null) {
      image_loader.setHtmlImageTapCallback(_viewType, () {
        if (widget.onTap != null) {
          widget.onTap!();
        }
      });
    }
    
    // Register HTML error callback
    image_loader.setHtmlImageErrorCallback(_viewType, () {
      if (mounted) {
        setState(() {
          _htmlError = true;
          _waitingForHtml = false;
        });
        
        // Update controller state
        if (widget.controller != null) {
          widget.controller!.updateLoadingState(ImageLoadingState.failed);
          widget.controller!.updateError('Local file HTML fallback also failed');
        }
      }
    });
    
    // Register HTML success callback
    image_loader.setHtmlImageSuccessCallback(_viewType, () {
      if (mounted) {
        setState(() {
          _waitingForHtml = false; // Hide loading overlay
        });
        
        // For local files, we can't extract image data from HTML fallback easily
        // since we already have the original bytes, but they failed to decode
        if (widget.controller != null) {
          widget.controller!.updateLoadingState(ImageLoadingState.loaded);
          widget.controller!.updateError('Image loaded via HTML but original bytes failed to decode');
        }
      }
    });
    
    // Add transformation listener if controller is provided
    if (widget.transformationController != null) {
      widget.transformationController!.addListener(_handleTransformationChange);
      
      // Start the animation for continuous transformation updates
      if (!_transformSyncController.isAnimating) {
        _transformSyncController.repeat();
        _transformSyncController.addListener(_checkForTransformationUpdates);
      }
    }
  }
  
  // NEW: Web-specific image loading that fetches bytes first
  // OPTIMIZATION: This prevents duplicate network requests on web platforms
  // by fetching image bytes using fetch first, then displaying from memory.
  // This approach solves CORS issues and ensures consistent image data between
  // display and copy functionality, while providing better progress tracking.
  void _preloadImageWeb() async {
    try {
      // Attempt to fetch image bytes with progress tracking
      final imageBytes = await image_loader.fetchImageBytesWithCors(
        widget.url!,
        onProgress: (progress) {
          if (mounted) {
            // Estimate total bytes for progress (we'll get real size later)
            const estimatedTotal = 1024 * 1024; // 1MB estimate
            final loaded = (progress * estimatedTotal).round();
            
            final loadingProgress = CustomImageProgress(
              cumulativeBytesLoaded: loaded,
              expectedTotalBytes: estimatedTotal,
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
      
      if (imageBytes != null && mounted) {
        // Successfully fetched image bytes, now decode to get dimensions
        try {
          final codec = await ui.instantiateImageCodec(imageBytes);
          final frame = await codec.getNextFrame();
          final ui.Image image = frame.image;
          
          // Create image data
          final imageData = ImageDataInfo(
            imageBytes: imageBytes,
            width: image.width,
            height: image.height,
            url: widget.url ?? 'unknown',
          );
          
          
          // Update state - image loaded successfully
          if (mounted) {
            setState(() {
              _loadingState = ImageLoadingState.loaded;
              _loadingProgress = null;
              _loadError = false;
              _imageData = imageData;
            });
            
            // NEW: Also cache in web storage for persistence
            if (kIsWeb && widget.webStorageCacheConfig.enabled) {
              _cacheImageInWebStorage(imageData, 'image/unknown');
            }
            
            // Update controller state
            if (widget.controller != null) {
              widget.controller!.updateLoadingState(_loadingState);
              widget.controller!.updateLoadingProgress(null);
              widget.controller!.updateImageData(imageData);
              widget.controller!.updateError(null);
            }
            
            // Call callback if provided
            if (widget.onImageLoaded != null) {
              widget.onImageLoaded!(imageData);
            }
          }
          
          image.dispose();
          
          // Reset loading guard - success
          _isCurrentlyLoading = false;
          
        } catch (decodeError) {
          // Failed to decode - go directly to HTML fallback on web
          if (mounted) {
            _setHtmlFallbackState();
          }
          _isCurrentlyLoading = false;
        }
        
      } else {
        // Failed to fetch bytes - go directly to HTML fallback on web to avoid duplicate network request
        if (mounted) {
          _setHtmlFallbackState();
        }
        _isCurrentlyLoading = false;
      }
      
    } catch (e) {
      // Error in web fetch - go directly to HTML fallback on web to avoid duplicate network request
      if (mounted) {
        _setHtmlFallbackState();
      }
      _isCurrentlyLoading = false;
    }
  }
  
  // NEW: Helper method to set HTML fallback state directly
  void _setHtmlFallbackState() {
    setState(() {
      _loadingState = ImageLoadingState.failed;
      _loadingProgress = null;
      _loadError = true;
      _waitingForHtml = true; // This will trigger HTML display
      _imageData = null;
    });
    
    // Update controller state
    if (widget.controller != null) {
      widget.controller!.updateLoadingState(_loadingState);
      widget.controller!.updateLoadingProgress(null);
      widget.controller!.updateImageData(null);
      widget.controller!.updateError('Failed to load image via CORS, using HTML fallback');
    }
    
    // NEW: Register HTML view factory only when we need it (lazy registration)
    if (kIsWeb) {
      // Register the tap callback if we have one
      if (widget.onTap != null) {
        image_loader.setHtmlImageTapCallback(_viewType, () {
          if (widget.onTap != null) {
            widget.onTap!();
          }
        });
      }
      
      // Register HTML error callback
      image_loader.setHtmlImageErrorCallback(_viewType, () {
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
      
      // Register HTML success callback
      image_loader.setHtmlImageSuccessCallback(_viewType, () {
        if (mounted) {
          setState(() {
            _waitingForHtml = false; // Hide loading overlay
          });
          
          // IMPORTANT: Try to extract image data for copy functionality
          // when HTML fallback succeeds
          _tryExtractImageDataFromHtmlFallback();
        }
      });
      
      // Register the HTML view factory with the current URL and styling parameters
      if (widget.url != null) {
        image_loader.registerHtmlImageFactory(
          _viewType, 
          widget.url!,
          boxFit: widget.fit,
          borderRadius: 0.0, // Border radius is handled by ClipRRect wrapper in Flutter
          width: widget.width,
          height: widget.height,
        );
      }
      
      // Add transformation listener if controller is provided
      if (widget.transformationController != null) {
        widget.transformationController!.addListener(_handleTransformationChange);
        
        // Start the animation for continuous transformation updates
        if (!_transformSyncController.isAnimating) {
          _transformSyncController.repeat();
          _transformSyncController.addListener(_checkForTransformationUpdates);
        }
      }
    }
  }

  // Native/fallback image loading using ExtendedImage for better caching and error handling
  void _preloadImageNative() {
    // Use ExtendedImage's NetworkImageProvider for better caching and error handling
    final imageProvider = ExtendedNetworkImageProvider(
      widget.url!, 
      headers: widget.headers,
      cache: true,
      retries: 2,
    );
    _imageStream = imageProvider.resolve(ImageConfiguration.empty);
    
    // Create our custom listener that tracks progress more reliably
    _imageStreamListener = ImageStreamListener(
      (ImageInfo info, bool synchronousCall) async {
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
            try {
              // Get the image bytes
              final Uint8List? imageBytes = await _getImageBytes(imageProvider);
              
              if (imageBytes != null) {
                final imageData = ImageDataInfo(
                  imageBytes: imageBytes,
                  width: info.image.width,
                  height: info.image.height,
                  url: widget.url ?? 'unknown',
                );
                
                // Store image data and call callback
                _imageData = imageData;
                
                // NEW: Also cache in web storage for persistence
                if (kIsWeb && widget.webStorageCacheConfig.enabled) {
                  _cacheImageInWebStorage(imageData, 'image/unknown');
                }
                
                // Update controller
                if (widget.controller != null) {
                  widget.controller!.updateImageData(imageData);
                }
                
                // Call callback if provided
                if (widget.onImageLoaded != null) {
                  widget.onImageLoaded!(imageData);
                }
              } else {
                // Update controller with error
                if (widget.controller != null) {
                  widget.controller!.updateError('Failed to extract image bytes');
                }
              }
            } catch (e) {
              // Error extracting image data
              if (widget.controller != null) {
                widget.controller!.updateError('Failed to extract image data: $e');
              }
            }
          }
        }
        
        // Reset loading guard - success
        _isCurrentlyLoading = false;
      },
      onError: (dynamic error, StackTrace? stackTrace) {
        // Image failed to load
        if (mounted) {
          setState(() {
            _loadingState = ImageLoadingState.failed;
            _loadingProgress = null;
            _loadError = true;
            _waitingForHtml = true; // We'll try HTML next
            _imageData = null; // Clear image data on error
          });
          
          // Update controller state
          if (widget.controller != null) {
            widget.controller!.updateLoadingState(_loadingState);
            widget.controller!.updateLoadingProgress(null);
            widget.controller!.updateImageData(null);
            widget.controller!.updateError('Failed to load image: $error');
          }
          
          // Start animation controller for frequent updates
          if (widget.transformationController != null && !_transformSyncController.isAnimating) {
            _transformSyncController.repeat();
          }
        }
        
        // Reset loading guard - error
        _isCurrentlyLoading = false;
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
    try {
      final ImageStream stream = imageProvider.resolve(ImageConfiguration.empty);
      final Completer<Uint8List?> completer = Completer<Uint8List?>();
      
      late ImageStreamListener listener;
      listener = ImageStreamListener(
        (ImageInfo info, bool synchronousCall) async {
          try {
            final ByteData? byteData = await info.image.toByteData(format: ui.ImageByteFormat.png);
            
            if (byteData != null) {
              final Uint8List bytes = byteData.buffer.asUint8List();
              stream.removeListener(listener);
              completer.complete(bytes);
            } else {
              stream.removeListener(listener);
              
              // Try CORS workaround when toByteData fails
              if (widget.url != null) {
                final corsBytes = await image_loader.fetchImageBytesWithCors(widget.url!);
                completer.complete(corsBytes);
              } else {
                completer.complete(null);
              }
            }
          } catch (e) {
            stream.removeListener(listener);
            
            // Try CORS workaround when toByteData throws an exception
            try {
              if (widget.url != null) {
                final corsBytes = await image_loader.fetchImageBytesWithCors(widget.url!);
                completer.complete(corsBytes);
              } else {
                completer.complete(null);
              }
            } catch (corsError) {
              completer.complete(null);
            }
          }
        },
        onError: (dynamic error, StackTrace? stackTrace) {
          stream.removeListener(listener);
          completer.complete(null);
        },
      );
      
      stream.addListener(listener);
      
      final result = await completer.future;
      return result;
    } catch (e) {
      // Last resort: try CORS workaround
      try {
        if (widget.url != null) {
          final corsBytes = await image_loader.fetchImageBytesWithCors(widget.url!);
          return corsBytes;
        }
        return null;
      } catch (corsError) {
        return null;
      }
    }
  }



  // NEW: Try to extract image data from HTML fallback for copy functionality
  Future<void> _tryExtractImageDataFromHtmlFallback() async {
    if (!mounted || _imageData != null) {
      return; // Already have data
    }
    
    try {
      // Attempt to load the image again using ImageProvider to get bytes
      // This is a workaround since HTML img doesn't provide bytes directly
      if (widget.url == null) return;
      final imageProvider = NetworkImage(widget.url!, headers: widget.headers);
      final imageBytes = await _getImageBytes(imageProvider);
      
      if (imageBytes != null && mounted) {
        // We need to get dimensions, try to decode the image
        try {
          final codec = await ui.instantiateImageCodec(imageBytes);
          final frame = await codec.getNextFrame();
          final ui.Image image = frame.image;
          
          final imageData = ImageDataInfo(
            imageBytes: imageBytes,
            width: image.width,
            height: image.height,
            url: widget.url ?? 'unknown',
          );
          
          // Update state
          setState(() {
            _imageData = imageData;
            _loadingState = ImageLoadingState.loaded; // Update to loaded since HTML succeeded
          });
          
          // NEW: Also cache in web storage for persistence
          if (kIsWeb && widget.webStorageCacheConfig.enabled) {
            _cacheImageInWebStorage(imageData, 'image/unknown');
          }
          
          // Update controller
          if (widget.controller != null) {
            widget.controller!.updateImageData(imageData);
            widget.controller!.updateLoadingState(ImageLoadingState.loaded);
            widget.controller!.updateError(null);
          }
          
          // Call callback if provided
          if (widget.onImageLoaded != null) {
            widget.onImageLoaded!(imageData);
          }
          
          image.dispose();
        } catch (e) {
          // Failed to decode image for dimensions, create with unknown dimensions
          final imageData = ImageDataInfo(
            imageBytes: imageBytes,
            width: 0, // Unknown
            height: 0, // Unknown
            url: widget.url ?? 'unknown',
          );
          
          if (mounted) {
            setState(() {
              _imageData = imageData;
              _loadingState = ImageLoadingState.loaded;
            });
            
            // NEW: Also cache in web storage for persistence
            if (kIsWeb && widget.webStorageCacheConfig.enabled) {
              _cacheImageInWebStorage(imageData, 'image/unknown');
            }
            
            // Update controller
            if (widget.controller != null) {
              widget.controller!.updateImageData(imageData);
              widget.controller!.updateLoadingState(ImageLoadingState.loaded);
              widget.controller!.updateError(null);
            }
            
            // Call callback if provided
            if (widget.onImageLoaded != null) {
              widget.onImageLoaded!(imageData);
            }
          }
        }
      }
    } catch (e) {
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
    
    Widget imageWidget;
    
    // PRIORITY 1: If we have cached image data, ALWAYS display from bytes (prevents network requests)
    if (_imageData != null) {
      imageWidget = Image.memory(
        _imageData!.imageBytes,
        key: _key,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        // Pass through all other parameters
        scale: widget.scale,
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
      );
    }
    // PRIORITY 2: Check if we should show Flutter error widget (both Flutter and HTML failed)
    else if (kIsWeb && _loadError && _htmlError) {
      imageWidget = _buildFlutterErrorWidget();
    }
    // PRIORITY 3: If we're on web and Flutter failed but HTML hasn't been tried yet or is in progress
    else if (kIsWeb && _loadError) {
      imageWidget = _buildHtmlImageView();
    } 
    // PRIORITY 4: If we're still loading and have a custom loading builder, show loading state
    else if (_loadingState == ImageLoadingState.loading && widget.customLoadingBuilder != null) {
      imageWidget = _buildCustomLoadingWidget();
    }
    // PRIORITY 5: If we're still loading (including initial state), show loading placeholder
    else if (_loadingState == ImageLoadingState.loading || _loadingState == ImageLoadingState.initial) {
      // Show loading placeholder to prevent network requests during cache check
      imageWidget = Container(
        width: widget.width,
        height: widget.height,
        color: Colors.grey[100],
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    // PRIORITY 6: If we haven't detected an error yet and don't have cached data, try network loading
    else if (!_loadError) {
      // Standard Flutter image loading (only when we don't have cached data)
      imageWidget = widget.url != null ? Image.network(
        widget.url!,
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
            print('[CustomNetworkImage] errorBuilder: $error');
            // We're already in error state, use HTML fallback
            return _buildHtmlImageView();
          } else {
            // On native platforms, use ExtendedImage fallback
            return _buildExtendedImageFallback();
          }
        },
      ) : _buildFlutterErrorWidget();
    } else {
      // PRIORITY 7: Non-web fallback
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
    
    // PERFORMANCE FIX: Only add context menu support if enabled (web only) and not on HTML fallback
    if (widget.enableContextMenu && kIsWeb && !_loadError) {
      wrappedWidget = _buildContextMenuWrapper(wrappedWidget);
    }
    
    return wrappedWidget;
  }
  
  /// Build context menu wrapper with right-click detection
  Widget _buildContextMenuWrapper(Widget child) {
    return DisableWebContextMenu(
      identifier: 'image_${widget.displayName.hashCode}_$hashCode',
      onContextMenu: _showContextMenuAt,
      child: child,
    );
  }
  
  /// Show context menu at the specified position (client coordinates from mouse event)
  void _showContextMenuAt(Offset clientPosition) {
    // PERFORMANCE FIX: Early return if context menu is disabled
    if (!widget.enableContextMenu || !kIsWeb || !mounted) return;
    
    // Remove any existing context menu
    _removeContextMenu();
    
    // Get context menu items (use custom or default)
    final items = widget.customContextMenuItems ?? ImageContextMenu.defaultItems;
    
    // The most reliable way to position the overlay is to convert the global
    // screen coordinates (clientPosition) into the Overlay's local coordinates.
    final overlay = Overlay.of(context);
    final RenderBox? overlayRenderBox = overlay.context.findRenderObject() as RenderBox?;
    
    if (overlayRenderBox == null) return;

    final overlayPosition = overlayRenderBox.globalToLocal(clientPosition);

    // Create the overlay entry
    _contextMenuOverlay = OverlayEntry(
      builder: (overlayContext) {
        return ImageContextMenu(
          position: overlayPosition,
          items: items,
          imageUrl: widget.url ?? widget.displayName,
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
      // Use the widget's context if contextToShowContextMenu is specified, otherwise use current context
      final overlayContext = widget.contextToShowContextMenu ?? context;
      Overlay.of(overlayContext).insert(_contextMenuOverlay!);
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
    // Use HtmlElementView for web platforms
    return kIsWeb
        ? SizedBox(
            width: widget.width,
            height: widget.height,
            child: Stack(
              children: [
                HtmlElementView(
                  viewType: _viewType,
                  // Apply transformations after the HTML element is created
                  onPlatformViewCreated: (int id) {
                    // Schedule transformation update for next frame to ensure HTML element is ready
                    if (widget.transformationController != null) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          image_loader.updateHtmlImageTransform(_viewType, widget.transformationController!.value);
                        }
                      });
                    }
                  },
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
    if (widget.url == null) {
      return _buildFlutterErrorWidget();
    }
    
    Widget image = ExtendedImage.network(
      widget.url!,
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
              const syntheticProgress = CustomImageProgress(
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
                        // Clean up HTML resources if we were using HTML fallback
                        _cleanupHtmlResources();
                        
                        // Reset error states and try reloading
                        setState(() {
                          _loadError = false;
                          _htmlError = false;
                          _waitingForHtml = false;
                          _loadingState = ImageLoadingState.initial;
                          _imageData = null;
                        });
                        // Reset loading guard to allow reload
                        _isCurrentlyLoading = false;
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
                            if (widget.url != null) {
                              openUrlInNewTab(widget.url!);
                            }
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
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
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
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: widget.copyIcon!,
            ),
          ),
        ),
      );
    }
    
    if (icons.isEmpty) return const SizedBox.shrink();
    
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
    // Clean up HTML resources if we were using HTML fallback
    _cleanupHtmlResources();
    
    // Reset loading guard for controller-initiated reload
    _isCurrentlyLoading = false;
    
    // Force reload by resetting the loaded state
    setState(() {
      _loadingState = ImageLoadingState.initial;
      _imageData = null;
      _loadError = false;
      _htmlError = false;
      _waitingForHtml = false;
    });
    
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