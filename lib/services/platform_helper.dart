import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import 'dart:async'; // Added import for Completer

// Conditionally import dart:html for web platform only
// This is a conditional import to avoid the error when running on mobile
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' if (dart.library.io) './stub_html.dart' as html;

/// Helper class to handle platform-specific operations
class PlatformHelper {
  /// Pick an image from web and return the file
  static Future<dynamic> pickWebImage() async {
    if (!kIsWeb) {
      throw UnsupportedError('This method is only supported on web platforms');
    }

    final completer = Completer<dynamic>();

    // Create input element
    final uploadInput = html.FileUploadInputElement()..accept = 'image/*';
    uploadInput.click();

    // Listen for file selection
    uploadInput.onChange.listen((event) {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        final file = files.first;
        completer.complete(file);
      } else {
        completer.complete(null);
      }
    });

    return completer.future;
  }

  /// Get base64 string from web file
  static Future<String> getBase64FromWebFile(dynamic file) async {
    if (!kIsWeb) {
      throw UnsupportedError('This method is only supported on web platforms');
    }

    final completer = Completer<String>();

    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    reader.onLoadEnd.listen((event) {
      final result = reader.result;
      if (result is List<int>) {
        final base64 = base64Encode(result);
        completer.complete(base64);
      } else {
        completer.completeError('Failed to read file');
      }
    });

    return completer.future;
  }
}
