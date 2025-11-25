import "dart:math";
import "dart:typed_data";

import "package:image/image.dart" as image;
import "package:image_picker/image_picker.dart" as impl;

enum ImagePickerMimeType { jpeg, png }

class ImagePicker {
  final _picker = impl.ImagePicker();

  static final _instance = ImagePicker._();
  factory ImagePicker() => _instance;
  ImagePicker._();

  Future<Uint8List?> pickImage({
    width = 300,
    height = 100,
    factor = 2,
    quality = 85,
    ImagePickerMimeType mimeType = ImagePickerMimeType.jpeg,
  }) async {
    final pickedFile = await _picker.pickImage(source: impl.ImageSource.gallery);
    if (pickedFile == null) return null;
    final bytes = await pickedFile.readAsBytes();
    final data = image.decodeImage(bytes);
    if (data == null) return null;
    final targetWidth = width * factor;
    final targetHeight = height * factor;
    final resized = image.copyResize(data, width: targetWidth);
    final x = max(0, (resized.width - targetWidth) ~/ 2);
    final y = max(0, (resized.height - targetHeight) ~/ 2);
    final cropped = image.copyCrop(resized, x: x, y: y, width: targetWidth, height: targetHeight);
    return mimeType == ImagePickerMimeType.jpeg ? image.encodeJpg(cropped, quality: 85) : image.encodePng(cropped);
  }
}

// eof
