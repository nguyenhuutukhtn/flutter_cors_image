import 'dart:html' as html;
import 'dart:async';
import 'dart:js' as js;
import 'package:flutter/foundation.dart';

/// Global flag to track if context menu prevention is active
bool _isContextMenuPreventionActive = false;

/// Global stream subscription for context menu events
StreamSubscription<html.MouseEvent>? _contextMenuSubscription;

/// Set of widget IDs that should have context menu prevented
final Set<String> _preventedWidgetIds = <String>{};

/// Enable context menu prevention for specific widget areas only
/// This will only prevent browser's default context menu on Flutter canvas elements
void enableContextMenuPrevention() {
  if (_isContextMenuPreventionActive) return;
  
  _isContextMenuPreventionActive = true;
  
  // Listen for context menu events and prevent them only on Flutter canvas
  _contextMenuSubscription = html.document.onContextMenu.listen((event) {
    final target = event.target;
    
    // Only prevent context menu if the target is a Flutter canvas element
    if (target is html.CanvasElement || 
        target is html.Element && target.tagName == 'CANVAS') {
      event.preventDefault();
      event.stopPropagation();
    }
    // Allow normal context menu for all other elements (text, links, etc.)
  });
}

/// Add a specific widget ID to the prevention list
void addWidgetToContextMenuPrevention(String widgetId) {
  _preventedWidgetIds.add(widgetId);
}

/// Remove a specific widget ID from the prevention list
void removeWidgetFromContextMenuPrevention(String widgetId) {
  _preventedWidgetIds.remove(widgetId);
}

/// Disable context menu prevention
/// This will restore browser's default context menu behavior
void disableContextMenuPrevention() {
  if (!_isContextMenuPreventionActive) return;
  
  _isContextMenuPreventionActive = false;
  
  // Cancel the subscription
  _contextMenuSubscription?.cancel();
  _contextMenuSubscription = null;
  
  // Clear all prevented widget IDs
  _preventedWidgetIds.clear();
}

/// Check if context menu prevention is currently active
bool isContextMenuPreventionActive() {
  return _isContextMenuPreventionActive;
}

/// Toggle context menu prevention
void toggleContextMenuPrevention() {
  if (_isContextMenuPreventionActive) {
    disableContextMenuPrevention();
  } else {
    enableContextMenuPrevention();
  }
}

/// Enable context menu prevention for a specific widget
/// This is a more targeted approach than global prevention
void enableContextMenuPreventionForWidget(String widgetId) {
  addWidgetToContextMenuPrevention(widgetId);
  
  // Ensure global prevention is active
  if (!_isContextMenuPreventionActive) {
    enableContextMenuPrevention();
  }
}

/// Disable context menu prevention for a specific widget
void disableContextMenuPreventionForWidget(String widgetId) {
  removeWidgetFromContextMenuPrevention(widgetId);
  
  // If no widgets need prevention, disable global prevention
  if (_preventedWidgetIds.isEmpty && _isContextMenuPreventionActive) {
    disableContextMenuPrevention();
  }
}

/// Download image from URL using web APIs
Future<bool> downloadImageFromUrl(String imageUrl) async {
  if (!kIsWeb) return false;
  
  try {
    
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
              
              const writable = await fileHandle.createWritable();
              console.log('Writable stream created');
              
              console.log('About to write blob, size: ' + finalBlob.size + ', type: ' + finalBlob.type);
              await writable.write(finalBlob);
              console.log('Blob written to file successfully');
              
              await writable.close();
              console.log('File stream closed successfully');
              
              console.log('Image saved using File System Access API');
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

/// Open URL in new tab
void openUrlInNewTab(String url) {
  if (!kIsWeb) return;
  
  try {
    html.window.open(url, '_blank');
  } catch (e) {
    if (kDebugMode) {
      print('Failed to open URL in new tab: $e');
    }
  }
} 