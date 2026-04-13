import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

/// Cross-platform image picker helper.
///
/// Uses [FilePicker] for desktop platforms (better Linux support)
/// and [ImagePicker] for mobile platforms (native gallery UI).
class ImagePickerHelper {
  ImagePickerHelper._();

  /// Picks an image from gallery/file system.
  ///
  /// Returns the file path if successful, null if cancelled or failed.
  ///
  /// **Platform-specific behavior:**
  /// - **Mobile (iOS/Android):** Uses native gallery picker
  /// - **Desktop (Linux/macOS/Windows):** Uses system file picker
  static Future<String?> pickImage() async {
    // Use file_picker for desktop platforms (better Linux support)
    if (!kIsWeb && (Platform.isLinux || Platform.isMacOS || Platform.isWindows)) {
      return _pickImageDesktop();
    }

    // Use image_picker for mobile platforms (native gallery UI)
    return _pickImageMobile();
  }

  /// Desktop implementation using file_picker.
  ///
  /// Provides better support for Linux desktop environments.
  static Future<String?> _pickImageDesktop() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        dialogTitle: 'Select Issue Photo',
      );

      if (result != null && result.files.single.path != null) {
        return result.files.single.path;
      }

      return null;
    } on Exception {
      return null;
    }
  }

  /// Mobile implementation using image_picker.
  ///
  /// Provides native gallery UI on iOS and Android.
  static Future<String?> _pickImageMobile() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      return pickedFile?.path;
    } on Exception {
      return null;
    }
  }
}
