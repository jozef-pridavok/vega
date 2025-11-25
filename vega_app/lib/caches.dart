import "package:core_flutter/widgets/cached_image.dart";
import "package:flutter/foundation.dart";

class Caches {
  static Future<void> init() => Future.wait([
        _clientLogo.init(clearCacheAfter: const Duration(days: 365)),
        _cardLogo.init(clearCacheAfter: const Duration(days: 365)),
        _rewardImage.init(clearCacheAfter: const Duration(days: 62)),
        _couponImage.init(clearCacheAfter: const Duration(days: 62)),
        _leafletImage.init(clearCacheAfter: const Duration(days: 31)),
        _productPhoto.init(clearCacheAfter: const Duration(days: 31)),
      ]);

  static Future<void> clear() => Future.wait([
        _clientLogo.clearAllCachedImages(showLog: kDebugMode),
        _cardLogo.clearAllCachedImages(showLog: kDebugMode),
        _rewardImage.clearAllCachedImages(showLog: kDebugMode),
        _couponImage.clearAllCachedImages(showLog: kDebugMode),
        _leafletImage.clearAllCachedImages(showLog: kDebugMode),
        _productPhoto.clearAllCachedImages(showLog: kDebugMode),
      ]);

  static final CachedImageConfig _clientLogo = CachedImageConfig(false, "406961e5-5c00-48e1-a9a2-3430807d9611");
  static CachedImageConfig get clientLogo => _clientLogo;

  static final CachedImageConfig _cardLogo = CachedImageConfig(false, "bbd3b395-2d31-4291-9e0a-d06b9e46d2b5");
  static CachedImageConfig get cardLogo => _cardLogo;

  static final CachedImageConfig _rewardImage = CachedImageConfig(true, "1798ce59-a3d1-42ec-9be4-e2f8efc9bee3");
  static CachedImageConfig get rewardImage => _rewardImage;

  static final CachedImageConfig _couponImage = CachedImageConfig(true, "f5df2dde-c960-4434-9a0f-8367f917c1af");
  static CachedImageConfig get couponImage => _couponImage;

  static final CachedImageConfig _leafletImage = CachedImageConfig(true, "d53d3d90-5238-4ae7-89cb-759354ccfa5e");
  static CachedImageConfig get leafletImage => _leafletImage;

  static final CachedImageConfig _productPhoto = CachedImageConfig(true, "1b4f8d04-f9cb-4534-9445-70faf54c40b4");
  static CachedImageConfig get productPhoto => _productPhoto;
}

// eof
