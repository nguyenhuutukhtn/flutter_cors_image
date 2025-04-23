import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

/// A network image component that handles problematic images by displaying them 
/// directly in an iframe when on web platforms, or falling back to a standard Image widget.
class ProxyNetworkImage extends StatefulWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  
  // Add all Image.network parameters
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
  final Widget Function(BuildContext)? placeholderBuilder;
  final Widget Function(BuildContext, dynamic)? errorBuilder;
  
  const ProxyNetworkImage({
    Key? key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
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
    this.placeholderBuilder,
    this.errorBuilder,
  }) : super(key: key);

  @override
  State<ProxyNetworkImage> createState() => _ProxyNetworkImageState();
}

class _ProxyNetworkImageState extends State<ProxyNetworkImage> {
  late final String _viewType;
  bool _isLoaded = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    // Create a unique view type name for this instance
    _viewType = 'iframe-view-${widget.url.hashCode}-${DateTime.now().millisecondsSinceEpoch}';

    // Register the view factory if on web
    if (kIsWeb) {
      _registerViewFactory();
    }
  }

  void _registerViewFactory() {
    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) => _createIframeElement(widget.url),
    );
  }

  html.IFrameElement _createIframeElement(String url) {
    // Create an iframe to display the image directly
    final iframe = html.IFrameElement()
      ..style.border = 'none'
      ..style.height = '100%'
      ..style.width = '100%'
      ..style.overflow = 'hidden'
      ..style.backgroundColor = 'transparent'
      ..setAttribute('scrolling', 'no')
      ..srcdoc = '''
        <!DOCTYPE html>
        <html>
        <head>
          <style>
            body, html {
              margin: 0;
              padding: 0;
              height: 100%;
              width: 100%;
              overflow: hidden;
              background: transparent;
              display: flex;
              justify-content: center;
              align-items: center;
            }
            img {
              max-width: 100%;
              max-height: 100%;
              object-fit: ${_boxFitToObjectFit(widget.fit)};
            }
            .error-container {
              display: flex;
              flex-direction: column;
              align-items: center;
              justify-content: center;
              height: 100%;
              width: 100%;
              background-color: #f0f0f0;
              color: #444;
              text-align: center;
              padding: 10px;
            }
            .error-icon {
              font-size: 32px;
              margin-bottom: 8px;
              color: #d32f2f;
            }
          </style>
        </head>
        <body>
          <img src="$url" onerror="showError()" onload="imageLoaded()"/>
          <script>
            function imageLoaded() {
              window.parent.postMessage('loaded', '*');
            }
            function showError() {
              window.parent.postMessage('error', '*');
              document.body.innerHTML = '<div class="error-container"><div class="error-icon">⚠️</div><div>Failed to load image</div></div>';
            }
          </script>
        </body>
        </html>
      ''';

    // Listen for messages from the iframe
    html.window.onMessage.listen((event) {
      if (event.data == 'loaded' && mounted) {
        setState(() {
          _isLoaded = true;
          _hasError = false;
        });
      } else if (event.data == 'error' && mounted) {
        setState(() {
          _hasError = true;
        });
      }
    });

    return iframe;
  }

  String _boxFitToObjectFit(BoxFit fit) {
    switch (fit) {
      case BoxFit.cover:
        return 'cover';
      case BoxFit.contain:
        return 'contain';
      case BoxFit.fill:
        return 'fill';
      case BoxFit.fitWidth:
        return 'contain';
      case BoxFit.fitHeight:
        return 'contain';
      case BoxFit.none:
        return 'none';
      case BoxFit.scaleDown:
        return 'scale-down';
      default:
        return 'cover';
    }
  }

  @override
  Widget build(BuildContext context) {
    // If we're not on web, use the standard Flutter Image widget
    if (!kIsWeb) {
      return Image.network(
        widget.url,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
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
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          
          if (widget.placeholderBuilder != null) {
            return widget.placeholderBuilder!(context);
          }
          
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          if (widget.errorBuilder != null) {
            return widget.errorBuilder!(context, error);
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
        },
      );
    }

    // For web, use the iframe approach
    return Container(
      width: widget.width,
      height: widget.height, 
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (!_isLoaded && !_hasError && widget.placeholderBuilder != null)
            widget.placeholderBuilder!(context)
          else if (!_isLoaded && !_hasError)
            Center(child: CircularProgressIndicator()),
          
          Opacity(
            opacity: _isLoaded ? 1.0 : 0.0,
            child: HtmlElementView(
              viewType: _viewType,
            ),
          ),
        ],
      ),
    );
  }
} 