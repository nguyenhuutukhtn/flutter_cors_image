import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'web_image_loader.dart' if (dart.library.io) 'stub_image_loader.dart';

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
  final Widget Function(BuildContext, Widget, ImageChunkEvent?)? loadingBuilder;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;
  
  /// Callback when the image is tapped
  final VoidCallback? onTap;

  /// Creates a CustomNetworkImage.
  ///
  /// The [url] parameter must not be null.
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
    this.loadingBuilder,
    this.errorBuilder,
    this.onTap,
  }) : super(key: key);

  @override
  State<CustomNetworkImage> createState() => _CustomNetworkImageState();
}

class _CustomNetworkImageState extends State<CustomNetworkImage> {
  bool _loadError = false;
  final GlobalKey _key = GlobalKey();
  late final String _viewType;

  @override
  void initState() {
    super.initState();
    // Create a unique view type name for this widget instance
    _viewType = 'html-image-${widget.url.hashCode}-${DateTime.now().millisecondsSinceEpoch}';
    
    // Register the view factory early if on web and likely to need it
    if (kIsWeb) {
      // Register the tap callback if we have one
      if (widget.onTap != null) {
        setHtmlImageTapCallback(() {
          if (widget.onTap != null) {
            widget.onTap!();
          }
        });
      }
      
      registerHtmlImageFactory(_viewType, widget.url);
    }
    
    // Try loading the image first
    _preloadImage();
  }

  void _preloadImage() {
    // Preload the image to detect errors before build
    final imageProvider = NetworkImage(widget.url);
    final imageStream = imageProvider.resolve(ImageConfiguration.empty);
    
    imageStream.addListener(ImageStreamListener(
      (ImageInfo info, bool synchronousCall) {
        // Image loaded successfully
        if (mounted && _loadError) {
          setState(() {
            _loadError = false;
          });
        }
      },
      onError: (dynamic error, StackTrace? stackTrace) {
        // Image failed to load
        print('Error pre-loading image: $error');
        if (mounted && !_loadError) {
          setState(() {
            _loadError = true;
          });
        }
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    // If we have a tap callback, wrap the image with a GestureDetector
    Widget imageWidget;
    
    // If we're on web and already know the image will fail, go straight to HTML
    if (kIsWeb && _loadError) {
      imageWidget = _buildHtmlImageView();
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
        loadingBuilder: widget.loadingBuilder ?? (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / 
                    loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
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

  Widget _buildHtmlImageView() {
    // Use HtmlElementView for web platforms
    return kIsWeb
        ? Container(
            width: widget.width,
            height: widget.height,
            child: HtmlElementView(
              viewType: _viewType,
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
            if (widget.loadingBuilder != null) {
              return widget.loadingBuilder!(
                context, 
                Container(), 
                const ImageChunkEvent(cumulativeBytesLoaded: 0, expectedTotalBytes: null)
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
} 