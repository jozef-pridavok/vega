import "package:blurhash_dart/blurhash_dart.dart" as implementation;
import "package:image/image.dart" as img;

class BlurHash {
  static img.Image decode(String hash, {double? width, double? height}) {
    final blurHash = implementation.BlurHash.decode(hash);
    return blurHash.toImage(width?.toInt() ?? 300, height?.toInt() ?? 100);
  }

  static String encode(img.Image image, {int numCompX = 4, int numCompY = 3}) {
    final blurHash = implementation.BlurHash.encode(image, numCompX: numCompX, numCompY: numCompY);
    return blurHash.hash;
  }
}

// eof
