import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import 'dart:async';
import 'package:extended_image/extended_image.dart';
import 'package:image/image.dart' as img;

// Conditional imports for web platform
// ignore: avoid_web_libraries_in_flutter

// For conditional import:
import 'web_image_loader.dart' if (dart.library.io) 'stub_image_loader.dart';
import 'proxy_network_image_export.dart';

// These imports will be used on web only
// ignore: unused_import
import 'dart:js_interop';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/original': (context) => const ImageScreen(),
        '/custom-demo': (context) => const ImageDemoScreen(),
        '/iframe-demo': (context) => const IFrameImageDemoScreen(),
      },
    );
  }
}

Future<Uint8List?> convertToCompatibleJpeg(Uint8List inputBytes) async {
  try {
    // Print information about the input bytes
    print('Input bytes length: ${inputBytes.length}');
    
    // For images that might be corrupted or have unusual encoding
    // Let's try a different approach with catchError
    final originalImage = img.decodeImage(inputBytes.sublist(0, inputBytes.length));
    
    if (originalImage == null) {
      print('Failed to decode original image');
      return null;
    }
    
    // Encode as PNG instead of JPEG for better compatibility
    final processedBytes = img.encodePng(originalImage);
    
    return Uint8List.fromList(processedBytes);
  } catch (e) {
    print('Error in convertToCompatibleJpeg: $e');
    return null;
  }
}

class ImageScreen extends StatefulWidget {
  const ImageScreen({super.key});

  @override
  State<ImageScreen> createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  Uint8List? processedImageBytes;
  bool isLoading = true;
  String errorMessage = '';
  String imageMethod = '';

  @override
  void initState() {
    super.initState();
    _loadAndProcessImage();
  }

  Future<void> _loadAndProcessImage() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
      processedImageBytes = null;
      imageMethod = '';
    });

    try {
      // Load the original image bytes from assets
      final ByteData data = await rootBundle.load('assets/images/test.jpeg');
      final Uint8List originalBytes = data.buffer.asUint8List();
      
      if (kIsWeb) {
        // Use base64 approach for web
        try {
          final base64String = base64Encode(originalBytes);
          print('Base64 image size: ${base64String.length}');
          setState(() {
            processedImageBytes = originalBytes;
            isLoading = false;
            imageMethod = 'Direct bytes for Web with base64 fallback';
          });
        } catch (e) {
          print('Error with Web approach: $e');
          _tryFallbackMethod(originalBytes);
        }
      } else {
        // Try image package for non-web platforms
        final Uint8List? processedBytes = await convertToCompatibleJpeg(originalBytes);
        if (processedBytes != null) {
          setState(() {
            processedImageBytes = processedBytes;
            isLoading = false;
            imageMethod = 'Image package processing';
          });
        } else {
          _tryFallbackMethod(originalBytes);
        }
      }
    } catch (e) {
      print('Error in _loadAndProcessImage: $e');
      setState(() {
        errorMessage = 'Error processing image: $e';
        isLoading = false;
      });
    }
  }
  
  void _tryFallbackMethod(Uint8List originalBytes) {
    // Try direct display as fallback
    setState(() {
      processedImageBytes = originalBytes;
      isLoading = false;
      imageMethod = 'Direct display (fallback)';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Display Solution'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imageMethod.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Method: $imageMethod',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            if (isLoading)
              const CircularProgressIndicator()
            else if (errorMessage.isNotEmpty)
              Column(
                children: [
                  Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: 300,
                    height: 300,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Text('Failed to process image'),
                    ),
                  ),
                ],
              )
            else if (processedImageBytes != null)
              (kIsWeb 
                ? _buildWebImageView()
                : _buildNativeImageView())
            else
              Container(
                width: 300,
                height: 300,
                color: Colors.grey[300],
                child: const Center(
                  child: Text('No image data'),
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadAndProcessImage,
              child: const Text('Reload & Process Image'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWebImageView() {
    if (processedImageBytes == null) return Container();
    
    // For web, try using Image.memory directly first
    return Image.memory(
      processedImageBytes!,
      width: 300,
      height: 300,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        print('Error displaying image on web: $error');
        // Fallback to data URL approach for web
        final base64String = base64Encode(processedImageBytes!);
        final dataUrl = 'data:image/jpeg;base64,$base64String';
        
        return Image.network(
          dataUrl,
          width: 300,
          height: 300,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('Error with data URL: $error');
            return Container(
              width: 300,
              height: 300,
              color: Colors.grey[300],
              child: const Center(
                child: Text('Failed to display with all web methods'),
              ),
            );
          },
        );
      },
    );
  }
  
  Widget _buildNativeImageView() {
    if (processedImageBytes == null) return Container();
    
    // For native platforms, use Image.memory with extended fallbacks
    return ExtendedImage.memory(
      processedImageBytes!,
      width: 300,
      height: 300,
      fit: BoxFit.cover,
      enableLoadState: true,
      loadStateChanged: (ExtendedImageState state) {
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            return const Center(child: CircularProgressIndicator());
          case LoadState.completed:
            return null; // Use default rendering
          case LoadState.failed:
            print('ExtendedImage failed to load');
            // If ExtendedImage fails, try regular Image as fallback
            return Image.memory(
              processedImageBytes!,
              width: 300,
              height: 300,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print('Basic image display also failed: $error');
                return Container(
                  width: 300,
                  height: 300,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Text('All display methods failed'),
                  ),
                );
              },
            );
          default:
            return Container(
              width: 300,
              height: 300,
              color: Colors.grey[300],
              child: const Center(
                child: Text('Unknown state'),
              ),
            );
        }
      },
    );
  }
}

class CustomNetworkImage extends StatefulWidget {
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
  final Widget Function(BuildContext, Widget, ImageChunkEvent?)? loadingBuilder;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  const CustomNetworkImage({
    Key? key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    // Add default values to match Image.network
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
    // If we're on web and already know the image will fail, go straight to HTML
    if (kIsWeb && _loadError) {
      return _buildHtmlImageView();
    }

    // If we haven't detected an error yet, try normal Flutter image
    if (!_loadError) {
      return Image.network(
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
      return _buildExtendedImageFallback();
    }
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
    return ExtendedImage.network(
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
  }
}

class ImageDemoScreen extends StatelessWidget {
  const ImageDemoScreen({super.key});

  // Error image that needs HTML fallback
  // static const String errorImageUrl = 'https://cdn-cs-prod.s3.ap-southeast-1.amazonaws.com/20250422/image/57ae968a8a876c76aa04a406f6869cdb';
  static const String errorImageUrl = 'https://cdn-cs-prod.s3.ap-southeast-1.amazonaws.com/20250422/image/57ae968a8a876c76aa04a406f68db';

  
  // Normal image that should load normally
  static const String normalImageUrl = 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8f/Example_image.svg/600px-Example_image.svg.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Image Loader Demo'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Problem Image (with HTML Fallback)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const CustomNetworkImage(
                    url: errorImageUrl,
                    width: 300,
                    height: 300,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Normal Image',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const CustomNetworkImage(
                    url: normalImageUrl,
                    width: 300,
                    height: 300,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'How it works:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 300,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('1. First tries to load with Flutter Image.network'),
                      SizedBox(height: 4),
                      Text('2. On error in web, falls back to HTML img tag'),
                      SizedBox(height: 4),
                      Text('3. On native platforms, uses ExtendedImage as fallback')
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Sample usage of the new widget:
// CustomNetworkImage(
//   url: 'https://cdn-cs-prod.s3.ap-southeast-1.amazonaws.com/20250422/image/57ae968a8a876c76aa04a406f6869cdb',
//   width: 300,
//   height: 300,
// )

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Loading Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Flutter Image Loading Solutions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/original'),
              child: const Text('Original Image Screen'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/custom-demo'),
              child: const Text('Custom Network Image Demo'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/iframe-demo'),
              child: const Text('IFrame Approach Demo (Recommended)'),
            ),
            const SizedBox(height: 30),
            Container(
              width: 300,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Features:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('• Custom network image loader'),
                  Text('• Automatic HTML fallback for web'),
                  Text('• Handles problematic images'),
                  Text('• ExtendedImage fallback for native')
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class IFrameImageDemoScreen extends StatelessWidget {
  const IFrameImageDemoScreen({super.key});

  // Error image that needs HTML fallback
  static const String errorImageUrl = 'https://cdn-cs-prod.s3.ap-southeast-1.amazonaws.com/20250422/image/57ae968a8a876c76aa04a406f6869cdb';
  
  // Normal image that should load normally
  static const String normalImageUrl = 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8f/Example_image.svg/600px-Example_image.svg.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IFrame Image Solution Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Problem Image with IFrame Solution',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const ProxyNetworkImage(
                    url: errorImageUrl,
                    width: 300,
                    height: 300,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Normal Image',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const ProxyNetworkImage(
                    url: normalImageUrl,
                    width: 300,
                    height: 300,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: 300,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('IFrame Solution:', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('• Uses iframe to display image directly'),
                      Text('• Completely bypasses CORS restrictions'),
                      Text('• Handles problematic images well'),
                      Text('• No image format conversion needed'),
                      Text('• Works with all image formats'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About IFrame Solution'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'This solution uses an iframe to embed the image directly, completely bypassing CORS restrictions that normally affect Flutter web apps.',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 12),
              Text(
                'The IFrame Solution:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(height: 8),
              Text('• Creates an iframe with HTML content'),
              Text('• Loads the image inside the iframe context'),
              Text('• Handles errors with javascript'),
              Text('• Communicates via postMessage API'),
              SizedBox(height: 12),
              Text(
                'This approach works for images that have CORS restrictions or unusual formats that Flutter cannot decode.',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
