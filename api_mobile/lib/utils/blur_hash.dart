import "package:core_dart/core_algorithm.dart";
import "package:image/image.dart";

Future<String?> getImageBhFromFile(String filePath) async {
  final cmd = Command();
  cmd.decodeImageFile(filePath);
  await cmd.execute();
  final image = cmd.outputImage;
  return image != null ? BlurHash.encode(image) : null;
}

// eof
