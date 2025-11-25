import "package:barcode/barcode.dart";
import "package:core_dart/core_enums.dart";
import "package:flutter/widgets.dart";
import "package:flutter_svg/flutter_svg.dart";

extension _CodeTypeBarcode on CodeType {
  static final _codeMap = {
    CodeType.upca: Barcode.upcA(),
    CodeType.upce: Barcode.upcE(),
    CodeType.ean8: Barcode.ean8(),
    CodeType.ean13: Barcode.ean13(),
    CodeType.code39: Barcode.code39(),
    CodeType.code93: Barcode.code93(),
    CodeType.code128: Barcode.code128(),
    CodeType.itf14: Barcode.itf14(),
    CodeType.interleaved2of5: Barcode.itf(),
    CodeType.pdf417: Barcode.pdf417(),
    CodeType.aztec: Barcode.aztec(),
    CodeType.qr: Barcode.qrCode(),
    CodeType.datamatrix: Barcode.dataMatrix(),
  };

  static final _heightMap = <CodeType, double>{
    CodeType.upca: 80,
    CodeType.upce: 80,
    CodeType.ean8: 80,
    CodeType.ean13: 80,
    CodeType.code39: 80,
    CodeType.code93: 80,
    CodeType.code128: 80,
    CodeType.itf14: 80,
    CodeType.interleaved2of5: 80,
    CodeType.pdf417: 80,
    CodeType.aztec: 200,
    CodeType.qr: 200,
    CodeType.datamatrix: 200,
  };

  Barcode get barcode => _codeMap[this]!;
  double get height => _heightMap[this]!;
  double get width => 200;
}

class CodeWidget extends StatelessWidget {
  final CodeType type;
  final String code;
  final double? width;
  final double? height;

  const CodeWidget({
    Key? key,
    required this.type,
    required this.code,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final generator = type.barcode;
    final defaultWidth = type.width;
    final defaultHeight = type.height;
    final svg = generator.toSvg(code, drawText: false, width: width ?? defaultWidth, height: height ?? defaultHeight);
    return SvgPicture.string(svg);
  }
}

// eof
