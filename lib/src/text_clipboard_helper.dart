import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// Helper class for copying text to clipboard
class TextClipboardHelper {
  /// Copy text to clipboard
  static Future<bool> copyTextToClipboard(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to copy text to clipboard: $e');
      }
      return false;
    }
  }
} 