import "command.dart";
import "cryptex_decode.dart";
import "cyptex_encode.dart";

class CryptexCommand extends VegaCommand {
  CryptexCommand() {
    addSubcommand(CryptexEncode());
    addSubcommand(CryptexDecode());
  }

  @override
  String get name => "cryptex";

  @override
  String get description => "Cryptex command";
}

// eof
