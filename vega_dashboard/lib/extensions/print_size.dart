import "package:core_flutter/core_dart.dart";
import "package:pdf/pdf.dart";
import "package:pdf/widgets.dart" as pw;

extension PrintSizeToPdfPageFormat on PrintSize {
  static const double inch = 72.0;
  static Map<PrintSize, PdfPageFormat> sizeMap = {
    PrintSize.a3: PdfPageFormat.a3,
    PrintSize.a4: PdfPageFormat.a4,
    PrintSize.a5: PdfPageFormat.a5,
    PrintSize.letter: PdfPageFormat.letter,
    PrintSize.legal: PdfPageFormat.legal,
    PrintSize.tabloid: PdfPageFormat(11 * inch, 17.0 * inch, marginAll: inch),
  };

  PdfPageFormat toPdfPageFormat() => sizeMap[this]!;
}

extension PrintOrientationToPageOrientation on PrintOrientation {
  pw.PageOrientation toPageOrientation() {
    switch (this) {
      case PrintOrientation.portrait:
        return pw.PageOrientation.portrait;
      case PrintOrientation.landscape:
        return pw.PageOrientation.landscape;
    }
  }
}
