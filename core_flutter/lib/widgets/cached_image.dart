import "dart:async";

import "package:core_flutter/core_flutter.dart";
import "package:dio/dio.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:hive_flutter/hive_flutter.dart";

class CachedImage extends StatefulWidget {
  final CachedImageConfig config;
  final String url;

  final ImageErrorWidgetBuilder? errorBuilder;

  final AlignmentGeometry alignment;

  final Duration fadeInDuration;

  final double? width;

  final double? height;

  final BoxFit fit;

  final bool disableErrorLogs;

  final String? blurHash;

  final Widget? placeholder;

  ///[CachedImage] creates a widget to display network images. This widget downloads the network image
  ///when this widget is build for the first time. Later whenever this widget is called the image will be displayed from
  ///the downloaded database instead of the network. This can avoid unnecessary downloads and load images much faster.
  const CachedImage({
    required this.config,
    required this.url,
    this.errorBuilder,
    this.disableErrorLogs = kDebugMode,
    this.alignment = Alignment.center,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.fadeInDuration = stateRefreshDuration,
    int? cacheWidth,
    int? cacheHeight,
    this.blurHash,
    this.placeholder,
    Key? key,
  }) : super(key: key);

  @override
  State<CachedImage> createState() => _CachedImageState();
}

class _CachedImageState extends State<CachedImage> with TickerProviderStateMixin {
  CachedImageConfig get config => widget.config;
  bool get isLazy => config.isLazy;

  late Animation<double> _animation;
  late AnimationController _animationController;

  _ImageResponse? _imageResponse;

  Widget? _blurWidget;

  Widget get placeholder => widget.placeholder ?? const SizedBox();

  @override
  void initState() {
    super.initState();

    if (isLazy) {
      _animationController = AnimationController(vsync: this, duration: widget.fadeInDuration);
      _animation =
          Tween<double>(begin: widget.fadeInDuration == Duration.zero ? 1 : 0, end: 1).animate(_animationController);

      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _loadAsync(widget.url);
      });
    } else {
      final data = config._getImage(widget.url);
      if (data != null) {
        _animationController = AnimationController(vsync: this);
        _animation = Tween<double>(begin: 1, end: 1).animate(_animationController);

        _imageResponse = _ImageResponse(imageData: data, error: null);
      } else {
        _animationController = AnimationController(vsync: this, duration: widget.fadeInDuration);
        _animation =
            Tween<double>(begin: widget.fadeInDuration == Duration.zero ? 1 : 0, end: 1).animate(_animationController);

        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          _loadAsync(widget.url);
        });
      }
    }

    //Future.microtask(() {
    //  _loadAsync(widget.url);
    //});
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_imageResponse?.error != null) {
      _logErrors(_imageResponse?.error);
      return widget.errorBuilder != null
          ? widget.errorBuilder!(context, Object, StackTrace.fromString(_imageResponse!.error!))
          : placeholder;
    }
    if (_imageResponse == null) {
      _blurWidget ??= widget.blurHash != null ? BlurHash(widget.blurHash!) : placeholder;
      return _blurWidget!;
    }

    return Stack(
      alignment: Alignment.center,
      fit: StackFit.passthrough,
      children: [
        if (_blurWidget != null) _blurWidget!,
        FadeTransition(
          opacity: _animation,
          child: Image.memory(
            _imageResponse!.imageData,
            width: widget.width,
            height: widget.height,
            alignment: widget.alignment,
            key: widget.key,
            fit: widget.fit,
            errorBuilder: (a, c, v) {
              config.deleteCachedImageAsync(imageUrl: widget.url);
              return widget.errorBuilder != null ? widget.errorBuilder!(a, c, v) : placeholder;
            },
          ),
        ),
      ],
    );
  }

  Future<void> _loadAsync(url) async {
    Uint8List? image = isLazy ? await config._getImageAsync(url) : config._getImage(url);
    if (image != null) return _finish(image);

    StreamController chunkEvents = StreamController();

    try {
      final Uri resolved = Uri.base.resolve(url);
      final dio = Dio();

      //await Future.delayed(const Duration(seconds: 1));

      final response = await dio.get(url, options: Options(responseType: ResponseType.bytes),
          onReceiveProgress: (int received, int total) {
        if (received < 0 || total < 0) return;
        chunkEvents.add(ImageChunkEvent(
          cumulativeBytesLoaded: received,
          expectedTotalBytes: total,
        ));
      });

      final Uint8List bytes = response.data;

      if (response.statusCode != 200) {
        String error = NetworkImageLoadException(statusCode: response.statusCode ?? 0, uri: resolved).toString();
        return _finish(Uint8List.fromList([]), error);
      }

      _finish(bytes, bytes.isEmpty ? "Image is empty." : null);

      isLazy ? await config._saveImageAsync(url, bytes) : config._saveImage(url, bytes);
    } catch (e) {
      _finish(Uint8List.fromList([]), e.toString());
    } finally {
      if (!chunkEvents.isClosed) await chunkEvents.close();
    }
  }

  void _finish(Uint8List data, [String? error]) {
    if (!mounted) return;
    if (data.isNotEmpty && error == null) {
      if (isLazy || widget.blurHash == null)
        _animationController.forward(from: 1);
      else
        _animationController.forward();
    }
    setState(() => _imageResponse = _ImageResponse(imageData: data, error: error));
  }

  void _logErrors(dynamic object) {
    if (widget.disableErrorLogs) return;
    debugPrint("CachedImage: ${widget.url} - $object");
  }
}

class _ImageResponse {
  Uint8List imageData;
  String? error;
  _ImageResponse({required this.imageData, required this.error});
}

class CachedImageConfig {
  final String key;
  final bool isLazy;
  String get imagesKeyBox => "bcc23df7-15b7-467c-9010-c9a35d40baf1_$key";
  String get imagesBox => "90877357-f9dc-4576-b273-a5b8c37de82f_$key";

  late LazyBox _lazyImageKeyBox;
  late LazyBox _lazyImageDataBox;

  late Box _imageKeyBox;
  late Box _imageDataBox;

  bool _isInitialized = false;

  CachedImageConfig(this.isLazy, this.key);

  Future<void> init({String? subDir, Duration? clearCacheAfter}) async {
    if (_isInitialized) return;
    _isInitialized = true;

    clearCacheAfter ??= const Duration(days: 7);

    await Hive.initFlutter(subDir);

    if (isLazy) {
      _lazyImageKeyBox = await Hive.openLazyBox(imagesKeyBox);
      _lazyImageDataBox = await Hive.openLazyBox(imagesBox);
      await _clearOldCacheAsync(clearCacheAfter);
    } else {
      _imageKeyBox = await Hive.openBox(imagesKeyBox);
      _imageDataBox = await Hive.openBox(imagesBox);
      _clearOldCache(clearCacheAfter);
    }
  }

  Future<Uint8List?> _getImageAsync(String url) async {
    if (_lazyImageKeyBox.keys.contains(url) && _lazyImageDataBox.keys.contains(url)) {
      Uint8List? data = await _lazyImageDataBox.get(url);
      if (data == null || data.isEmpty) return null;
      return data;
    }

    return null;
  }

  Uint8List? _getImage(String url) {
    if (_imageKeyBox.keys.contains(url) && _imageDataBox.keys.contains(url)) {
      Uint8List? data = _imageDataBox.get(url);
      if (data == null || data.isEmpty) return null;
      return data;
    }

    return null;
  }

  Future<void> _saveImageAsync(String url, Uint8List image) async {
    await _lazyImageKeyBox.put(url, DateTime.now());
    await _lazyImageDataBox.put(url, image);
  }

  void _saveImage(String url, Uint8List image) {
    _imageKeyBox.put(url, DateTime.now());
    _imageDataBox.put(url, image);
  }

  Future<void> _clearOldCacheAsync(Duration cleatCacheAfter) async {
    assert(isLazy);
    DateTime today = DateTime.now();

    for (final key in _lazyImageKeyBox.keys) {
      DateTime? dateCreated = await _lazyImageKeyBox.get(key);

      if (dateCreated == null) continue;

      if (today.difference(dateCreated) > cleatCacheAfter) {
        await _lazyImageKeyBox.delete(key);
        await _lazyImageDataBox.delete(key);
      }
    }
  }

  void _clearOldCache(Duration cleatCacheAfter) {
    assert(!isLazy);
    DateTime today = DateTime.now();

    for (final key in _imageKeyBox.keys) {
      DateTime? dateCreated = _imageKeyBox.get(key);

      if (dateCreated == null) continue;

      if (today.difference(dateCreated) > cleatCacheAfter) {
        _lazyImageKeyBox.delete(key);
        _lazyImageDataBox.delete(key);
      }
    }
  }

  Future<void> deleteCachedImageAsync({required String imageUrl, bool showLog = true}) async {
    assert(isLazy);
    if (_lazyImageKeyBox.keys.contains(imageUrl) && _lazyImageDataBox.keys.contains(imageUrl)) {
      await _lazyImageKeyBox.delete(imageUrl);
      await _lazyImageDataBox.delete(imageUrl);
      if (showLog) {
        debugPrint("FastCacheImage: Removed image $imageUrl from cache.");
      }
    }
  }

  void deleteCachedImage({required String imageUrl, bool showLog = true}) {
    assert(!isLazy);
    if (_imageKeyBox.keys.contains(imageUrl) && _imageDataBox.keys.contains(imageUrl)) {
      _imageKeyBox.delete(imageUrl);
      _imageDataBox.delete(imageUrl);
      if (showLog) {
        debugPrint("FastCacheImage: Removed image $imageUrl from cache.");
      }
    }
  }

  Future<void> clearAllCachedImages({bool showLog = true}) async {
    if (isLazy) {
      await _lazyImageKeyBox.deleteFromDisk();
      await _lazyImageDataBox.deleteFromDisk();
      if (showLog) debugPrint("FastCacheImage: All cache cleared.");
      _lazyImageKeyBox = await Hive.openLazyBox(imagesKeyBox);
      _lazyImageDataBox = await Hive.openLazyBox(imagesBox);
    } else {
      await _imageKeyBox.deleteFromDisk();
      await _imageDataBox.deleteFromDisk();
      if (showLog) debugPrint("FastCacheImage: All cache cleared.");
      _imageKeyBox = await Hive.openBox(imagesKeyBox);
      _imageDataBox = await Hive.openBox(imagesBox);
    }
  }

  bool isLazyCached({required String imageUrl}) {
    assert(isLazy);
    if (_lazyImageKeyBox.containsKey(imageUrl) && _lazyImageDataBox.keys.contains(imageUrl)) return true;
    return false;
  }

  bool isCached({required String imageUrl}) {
    assert(!isLazy);
    if (_imageKeyBox.containsKey(imageUrl) && _imageDataBox.keys.contains(imageUrl)) return true;
    return false;
  }
}


// eof
