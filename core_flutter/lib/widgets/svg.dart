import "package:flutter/widgets.dart";
import "package:flutter_svg/flutter_svg.dart";

class SvgAsset extends StatelessWidget {
  final String assetName;
  final double? width;
  final double? height;
  final BoxFit fit;
  final AlignmentGeometry alignment;

  const SvgAsset(
    this.assetName, {
    Key? key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
  }) : super(key: key);

  factory SvgAsset.logo() => const SvgAsset("assets/images/logo.svg");

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetName,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
    );
  }
}

// eof
