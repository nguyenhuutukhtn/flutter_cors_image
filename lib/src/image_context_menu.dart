import 'dart:async';
import 'dart:js' as js;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as html;
import 'types.dart';
import 'image_clipboard_helper.dart';
import 'text_clipboard_helper.dart';
import 'web_image_loader.dart' if (dart.library.io) 'stub_image_loader.dart';

/// Custom context menu widget for image actions
class ImageContextMenu extends StatelessWidget {
  final Offset position;
  final List<ContextMenuItem> items;
  final Color? backgroundColor;
  final Color? textColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final ImageDataInfo? imageData;
  final String imageUrl;
  final VoidCallback onDismiss;
  final Function(ContextMenuAction)? onAction;

  const ImageContextMenu({
    Key? key,
    required this.position,
    required this.items,
    required this.imageUrl,
    required this.onDismiss,
    this.backgroundColor,
    this.textColor,
    this.elevation,
    this.borderRadius,
    this.padding,
    this.imageData,
    this.onAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print('ImageContextMenu.build() called');
      print('Position: $position, Items count: ${items.length}');
      print('ImageData: ${imageData != null ? 'available' : 'null'}');
    }
    
    // Get screen dimensions to ensure menu fits
    final screenSize = MediaQuery.of(context).size;
    final menuWidth = 250.0;
    final estimatedMenuHeight = items.length * 48.0 + 16.0; // Rough estimate
    
    if (kDebugMode) {
      print('Screen size: $screenSize, Menu size: ${menuWidth}x$estimatedMenuHeight');
    }
    
    // Adjust position to keep menu on screen
    double left = position.dx;
    double top = position.dy;
    
    // Ensure menu doesn't go off right edge
    if (left + menuWidth > screenSize.width) {
      left = screenSize.width - menuWidth - 16;
    }
    
    // Ensure menu doesn't go off bottom edge
    if (top + estimatedMenuHeight > screenSize.height) {
      top = screenSize.height - estimatedMenuHeight - 16;
    }
    
    // Ensure menu doesn't go off left edge
    if (left < 0) left = 16;
    
    // Ensure menu doesn't go off top edge
    if (top < 0) top = 16;
    
    if (kDebugMode) {
      print('Final menu position: left=$left, top=$top');
      print('Creating Material with Stack containing ${items.length} menu items');
    }
    
    return Material(
      color: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Invisible overlay to capture taps outside the menu
          Positioned.fill(
            child: GestureDetector(
              onTap: onDismiss,
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          // The actual context menu
          Positioned(
            left: left,
            top: top,
            child: Material(
              elevation: elevation ?? 8.0,
              borderRadius: borderRadius ?? BorderRadius.circular(8.0),
              color: backgroundColor ?? Colors.white,
              child: Container(
                width: menuWidth,
                padding: padding ?? const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: items.map((item) => _buildMenuItem(context, item)).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, ContextMenuItem item) {
    return InkWell(
      onTap: () => _handleMenuItemTap(context, item),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.icon != null) ...[
              Icon(
                item.icon,
                size: 20,
                color: textColor ?? Colors.black87,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                item.title,
                style: TextStyle(
                  color: textColor ?? Colors.black87,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuItemTap(BuildContext context, ContextMenuItem item) async {
    // Store the context before dismissing the menu
    final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
    
    // Dismiss the menu first
    onDismiss();
    
    // Call the action callback
    if (onAction != null) {
      onAction!(item.action);
    }
    
    // Handle built-in actions
    switch (item.action) {
      case ContextMenuAction.copyImage:
        await _copyImage();
        _showMessageWithMessenger(scaffoldMessenger, 'Image copied to clipboard');
        break;
      case ContextMenuAction.saveImage:
        final success = await _saveImage();
        if (success) {
          _showMessageWithMessenger(scaffoldMessenger, '✅ Image saved successfully!');
        } else {
          _showMessageWithMessenger(scaffoldMessenger, '❌ Failed to save image');
        }
        break;
      case ContextMenuAction.openImageInNewTab:
        await _openImageInNewTab();
        _showMessageWithMessenger(scaffoldMessenger, 'Opening image in new tab');
        break;
      case ContextMenuAction.copyImageUrl:
        await _copyImageUrl();
        _showMessageWithMessenger(scaffoldMessenger, 'Image URL copied to clipboard');
        break;
      case ContextMenuAction.custom:
        // Custom actions are handled by the onTap callback
        if (item.onTap != null) {
          item.onTap!();
        }
        break;
    }
  }
  
  /// Show a feedback message to the user
  void _showMessage(BuildContext context, String message) {
    // Check if the context is still valid and mounted
    try {
      if (ScaffoldMessenger.maybeOf(context) != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            backgroundColor: message.contains('✅') ? Colors.green : 
                           message.contains('❌') ? Colors.red : null,
          ),
        );
      }
    } catch (e) {
      // Context is no longer valid, ignore the message
      if (kDebugMode) {
        print('Could not show message "$message" - context no longer valid');
      }
    }
  }
  
  /// Show a feedback message using a pre-obtained ScaffoldMessenger
  void _showMessageWithMessenger(ScaffoldMessengerState? scaffoldMessenger, String message) {
    try {
      if (scaffoldMessenger != null) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            backgroundColor: message.contains('✅') ? Colors.green : 
                           message.contains('❌') ? Colors.red : null,
          ),
        );
      } else {
        if (kDebugMode) {
          print('Could not show message "$message" - no ScaffoldMessenger available');
        }
      }
    } catch (e) {
      // ScaffoldMessenger is no longer valid, ignore the message
      if (kDebugMode) {
        print('Could not show message "$message" - ScaffoldMessenger error: $e');
      }
    }
  }

  Future<void> _copyImage() async {
    if (imageData != null) {
      try {
        await ImageClipboardHelper.copyImageToClipboard(imageData!);
      } catch (e) {
        if (kDebugMode) {
          print('Failed to copy image: $e');
        }
      }
    }
  }

  Future<bool> _saveImage() async {
    if (kDebugMode) {
      print('Save image clicked. Image data available: ${imageData != null}');
      if (imageData != null) {
        print('Image data size: ${imageData!.imageBytes.length} bytes, ${imageData!.width}x${imageData!.height}');
      }
    }
    
    try {
      if (imageData != null) {
        // Use image data if available
        if (kDebugMode) {
          print('Attempting to download image using ImageClipboardHelper...');
        }
        final success = await ImageClipboardHelper.downloadImage(imageData!);
        if (kDebugMode) {
          print('Download result: $success');
        }
        if (!success) {
          if (kDebugMode) {
            print('ImageClipboardHelper failed, trying URL fallback...');
          }
          final urlSuccess = await _downloadImageFromUrl();
          return urlSuccess;
        }
        return success;
      } else {
        // Fallback: download directly from URL
        if (kDebugMode) {
          print('No image data available, using URL fallback...');
        }
        final urlSuccess = await _downloadImageFromUrl();
        return urlSuccess;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to save image: $e');
        print('Attempting URL fallback after error...');
      }
      try {
        final fallbackSuccess = await _downloadImageFromUrl();
        return fallbackSuccess;
      } catch (fallbackError) {
        if (kDebugMode) {
          print('URL fallback also failed: $fallbackError');
        }
        return false;
      }
    }
  }
  
  /// Fallback method to download image directly from URL when image data is not available
  Future<bool> _downloadImageFromUrl() async {
    if (!kIsWeb) return false;
    
    try {
      if (kDebugMode) {
        print('Starting proper image download for: $imageUrl');
      }
      
      // Use JavaScript to fetch the image as blob and trigger save-as dialog
      // We create a function that returns a Promise we can await
      final completer = Completer<bool>();
      final functionName = 'downloadImage${DateTime.now().millisecondsSinceEpoch}';
      
      final script = '''
        window.$functionName = async function() {
          try {
            console.log('=== Starting image download process ===');
            console.log('Fetching image from URL: $imageUrl');
            
            // Try fetch with different CORS modes
            let response;
            try {
              // First try with no-cors mode
              response = await fetch('$imageUrl', { mode: 'cors' });
            } catch (corsError) {
              console.log('CORS fetch failed, trying no-cors mode: ' + corsError.message);
              try {
                response = await fetch('$imageUrl', { mode: 'no-cors' });
              } catch (noCorsError) {
                console.log('No-cors fetch also failed, trying default: ' + noCorsError.message);
                response = await fetch('$imageUrl');
              }
            }
            console.log('Fetch response status:', response.status, response.statusText);
            console.log('Response headers content-type:', response.headers.get('content-type'));
            
            if (!response.ok) {
              throw new Error('Failed to fetch image: ' + response.status + ' ' + response.statusText);
            }
            
            const blob = await response.blob();
            
            // Force string conversion for logging
            const blobSize = blob.size + '';
            const blobType = blob.type + '';
            
            console.log('Image fetched as blob');
            console.log('Blob size: ' + blobSize + ' bytes');
            console.log('Blob type: ' + blobType);
            console.log('Blob valid: ' + (blob instanceof Blob));
            
            // Ensure we have a valid blob
            if (!blob || blob.size === 0) {
              console.error('Invalid or empty blob received, size: ' + blobSize);
              throw new Error('Invalid or empty blob received, size: ' + blobSize);
            }
            
            // If blob type is empty, try to set it based on URL or default to PNG
            let finalBlob = blob;
            if (!blob.type || blob.type === '') {
              console.log('Blob has no type, creating new blob with image/png type');
              finalBlob = new Blob([blob], { type: 'image/png' });
              console.log('New blob created, size: ' + finalBlob.size + ', type: ' + finalBlob.type);
            }
            
            // Try modern File System Access API first (shows save dialog)
            if ('showSaveFilePicker' in window) {
              try {
                console.log('Attempting File System Access API save dialog');
                const fileHandle = await window.showSaveFilePicker({
                  suggestedName: 'image_${DateTime.now().millisecondsSinceEpoch}.png',
                  types: [{
                    description: 'PNG Images',
                    accept: { 'image/png': ['.png'] }
                  }]
                });
                
                console.log('Save dialog completed, writing file');
                console.log('File handle obtained, name: ' + (fileHandle.name || 'unknown'));
                console.log('File handle kind: ' + (fileHandle.kind || 'unknown'));
                
                // Try to get more info about the file location
                if (fileHandle.getFile) {
                  try {
                    const tempFile = await fileHandle.getFile();
                    console.log('File path info - name: ' + tempFile.name + ', size: ' + tempFile.size);
                    if (tempFile.webkitRelativePath) {
                      console.log('Webkit relative path: ' + tempFile.webkitRelativePath);
                    }
                  } catch (pathError) {
                    console.log('Could not get file path info: ' + pathError.message);
                  }
                }
                
                const writable = await fileHandle.createWritable();
                console.log('Writable stream created');
                
                console.log('About to write blob, size: ' + finalBlob.size + ', type: ' + finalBlob.type);
                await writable.write(finalBlob);
                console.log('Blob written to file successfully');
                
                await writable.close();
                console.log('File stream closed successfully');
                
                // Verify the file was written by checking if we can read it back
                try {
                  const file = await fileHandle.getFile();
                  console.log('File verification - size: ' + file.size + ', type: ' + file.type + ', lastModified: ' + new Date(file.lastModified));
                  
                  if (file.size === 0) {
                    console.error('WARNING: File was created but has 0 bytes!');
                    return { success: false, method: 'fileSystemAccess', error: 'File created but empty' };
                  }
                  
                } catch (verifyError) {
                  console.warn('Could not verify file: ' + verifyError.message);
                }
                
                console.log('Image saved using File System Access API to: ' + (fileHandle.name || 'selected location'));
                return { success: true, method: 'fileSystemAccess' };
              } catch (fsError) {
                // Check if user cancelled the dialog
                if (fsError.name === 'AbortError' || fsError.message.includes('aborted') || fsError.message.includes('cancelled')) {
                  console.log('User cancelled the save dialog');
                  return { success: false, method: 'cancelled' };
                } else {
                  console.error('File System Access API failed:', fsError.name, fsError.message);
                  console.log('Falling back to blob download method');
                  // API failed for technical reasons, fall through to blob method
                }
              }
            } else {
              console.log('File System Access API not available, using blob download');
            }
            
            // Fallback: Create blob URL and download
            try {
              console.log('Attempting blob download fallback');
              const blobUrl = URL.createObjectURL(finalBlob);
              console.log('Created blob URL:', blobUrl);
              
              // Create download link
              const link = document.createElement('a');
              link.href = blobUrl;
              link.download = 'image_${DateTime.now().millisecondsSinceEpoch}.png';
              
              // Make it more likely to show save dialog by simulating user interaction
              link.style.display = 'none';
              document.body.appendChild(link);
              
              console.log('Attempting blob download with click event');
              
              // Dispatch a synthetic click event that's more likely to trigger save dialog
              const clickEvent = new MouseEvent('click', {
                view: window,
                bubbles: true,
                cancelable: true
              });
              link.dispatchEvent(clickEvent);
              
              document.body.removeChild(link);
              
              // Clean up
              setTimeout(() => URL.revokeObjectURL(blobUrl), 1000);
              
              console.log('Image download triggered with enhanced click event');
              return { success: true, method: 'blobDownload' };
            } catch (blobError) {
              console.error('Blob download failed:', blobError);
              // Fall through to final fallback
            }
          } catch (error) {
            console.error('Failed to download image:', error);
            
            // Final fallback: try direct download first, then new tab
            try {
              console.log('Attempting final fallback download');
              const link = document.createElement('a');
              link.href = '$imageUrl';
              link.download = 'image_${DateTime.now().millisecondsSinceEpoch}.png';
              // Don't set target='_blank' initially to try download first
              link.style.display = 'none';
              document.body.appendChild(link);
              link.click();
              document.body.removeChild(link);
              
              console.log('Final fallback download attempted');
              return { success: true, method: 'directDownload' };
            } catch (finalError) {
              console.error('Direct download also failed, opening in new tab:', finalError);
              
              // Last resort: open in new tab
              const link = document.createElement('a');
              link.href = '$imageUrl';
              link.target = '_blank';
              document.body.appendChild(link);
              link.click();
              document.body.removeChild(link);
              
              return { success: false, method: 'openInNewTab' };
            }
          }
        };
      ''';
      
      // Execute the script to define the function
      final scriptElement = html.document.createElement('script');
      scriptElement.text = script;
      html.document.head!.append(scriptElement);
      
      // Call the function and handle the result
      try {
        final jsFunction = js.context[functionName];
        if (jsFunction != null) {
          final promise = jsFunction.apply([]);
          
          final thenCallback = js.allowInterop((result) {
            if (kDebugMode) {
              print('Download result: $result');
              if (result != null && result['method'] != null) {
                print('Download method used: ${result['method']}');
                if (result['method'] == 'cancelled') {
                  print('User cancelled the save dialog - no fallback download');
                }
              }
            }
            
            // Clean up
            scriptElement.remove();
            js.context.deleteProperty(functionName);
            
            completer.complete(result != null && result['success'] == true);
          });
          
          final catchCallback = js.allowInterop((error) {
            if (kDebugMode) {
              print('Download promise rejected: $error');
            }
            
            // Clean up
            scriptElement.remove();
            js.context.deleteProperty(functionName);
            
            completer.complete(false);
          });
          
          promise.callMethod('then', [thenCallback]).callMethod('catch', [catchCallback]);
        } else {
          if (kDebugMode) {
            print('Failed to get JavaScript function');
          }
          scriptElement.remove();
          completer.complete(false);
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error calling JavaScript function: $e');
        }
        scriptElement.remove();
        js.context.deleteProperty(functionName);
        completer.complete(false);
      }
      
      // Wait for the result
      final success = await completer.future;
      
      if (kDebugMode) {
        print('Download completed with success: $success');
      }
      
      return success;
      
    } catch (e) {
      if (kDebugMode) {
        print('Failed to execute download script: $e');
      }
      return false;
    }
  }

  Future<void> _openImageInNewTab() async {
    if (kIsWeb) {
      try {
        openUrlInNewTab(imageUrl);
      } catch (e) {
        if (kDebugMode) {
          print('Failed to open image in new tab: $e');
        }
      }
    }
  }

  Future<void> _copyImageUrl() async {
    try {
      await TextClipboardHelper.copyTextToClipboard(imageUrl);
      if (kDebugMode) {
        print('Copied image URL to clipboard: $imageUrl');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to copy image URL: $e');
      }
    }
  }

  /// Default context menu items similar to browser image context menu
  static List<ContextMenuItem> get defaultItems => [
    const ContextMenuItem(
      title: 'Copy image',
      icon: Icons.copy,
      action: ContextMenuAction.copyImage,
    ),
    const ContextMenuItem(
      title: 'Save image as...',
      icon: Icons.download,
      action: ContextMenuAction.saveImage,
    ),
    const ContextMenuItem(
      title: 'Open image in new tab',
      icon: Icons.open_in_new,
      action: ContextMenuAction.openImageInNewTab,
    ),
    const ContextMenuItem(
      title: 'Copy image address',
      icon: Icons.link,
      action: ContextMenuAction.copyImageUrl,
    ),
  ];
} 