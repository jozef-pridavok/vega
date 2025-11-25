import "dart:async";

import "package:core_dart/core_algorithm.dart";
import "package:dio/dio.dart";
import "package:image/image.dart" as img;

import "command.dart";

class BlurHashEncode extends VegaCommand {
  BlurHashEncode() {
    argParser.addOption("url", help: "Url to image to calculate blur hash", mandatory: false);
    //argParser.addOption("file", help: "File to image to calculate blur hash", mandatory: false);
  }

  @override
  String get name => "encode";

  @override
  String get description => "BlurHash encoder";

  @override
  List<String> get aliases => ["e"];

  @override
  FutureOr<String>? run() async {
    await super.prepare();
    final url = argResults?["url"];
    final dio = Dio();
    final response = await dio.get(url!, options: Options(responseType: ResponseType.bytes));
    final bytes = response.data;
    final cmd = img.Command();
    cmd.decodeImage(bytes);
    await cmd.execute();
    final image = cmd.outputImage;
    if (image == null) return "Error decoding image";
    final blurHash = BlurHash.encode(image);
    return blurHash;
  }
}

// eof
