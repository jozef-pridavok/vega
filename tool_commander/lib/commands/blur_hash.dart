import "blur_hash_decode.dart";
import "blur_hash_encode.dart";
import "command.dart";

class BlurHashCommand extends VegaCommand {
  BlurHashCommand() {
    addSubcommand(BlurHashEncode());
    addSubcommand(BlurHashDecode());
  }

  @override
  String get name => "blur_hash";

  @override
  String get description => "BlurHash command";
}

// eof
