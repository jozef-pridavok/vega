import "package:core_dart/core_algorithm.dart" as core;
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
// flutter_blurhash: ^0.7.0
// import "package:flutter_blurhash/flutter_blurhash.dart" as implementation;
import "package:image/image.dart" as img;

class BlurHash extends StatefulWidget {
  static const _defaultSize = 32.0;

  final String imageBh;
  final double? width;
  final double? height;

  const BlurHash(this.imageBh, {super.key, this.width, this.height});

  @override
  createState() => _BlurHashState();
}

final _cachedBytes = <String, Uint8List>{};

Uint8List _convertBlurHashToImage(String blurHash, double width, double height) {
  final image = core.BlurHash.decode(blurHash, width: width, height: height);
  final bytes = img.encodePng(image);
  _cachedBytes[blurHash] = bytes;
  return bytes;
}

class _BlurHashState extends State<BlurHash> {
  Uint8List? _bytes;

  //Future<Uint8List> _getImage(String blurHash) async {
  //  return compute(_convertBlurHashToImage, blurHash);
  //}

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      try {
        _bytes ??= _cachedBytes[widget.imageBh] ??
            _convertBlurHashToImage(
              widget.imageBh,
              widget.width ?? BlurHash._defaultSize,
              widget.height ?? BlurHash._defaultSize,
            );
        setState(() {});
      } catch (ex) {
        if (kDebugMode) print("${widget.imageBh} - $ex");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    //return Container(color: Colors.amber);
    final cached = _cachedBytes[widget.imageBh];
    if (cached != null) {
      return Image.memory(
        cached,
        fit: BoxFit.cover,
        key: widget.key,
        width: widget.width,
        height: widget.height,
      );
    }
    return (_bytes?.length ?? 0) > 0
        ? Image.memory(
            _bytes!,
            fit: BoxFit.cover,
            key: widget.key,
            width: widget.width,
            height: widget.height,
          )
        : const SizedBox();
  }
}

// eof
