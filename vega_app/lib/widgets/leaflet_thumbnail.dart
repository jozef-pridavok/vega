import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../caches.dart";

class LeafletOverviewThumbnail extends ConsumerWidget {
  final LeafletOverview overview;

  const LeafletOverviewThumbnail(this.overview, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final thumbnail = overview.thumbnail;
    final thumbnailBh = overview.thumbnailBh;
    return thumbnail == null
        ? Container(color: ref.scheme.content10)
        : CachedImage(
            config: Caches.leafletImage,
            alignment: Alignment.topLeft,
            url: thumbnail,
            blurHash: thumbnailBh,
            errorBuilder: (_, __, ___) => SvgAsset.logo(),
          );
  }
}

class LeafletDetailThumbnail extends ConsumerWidget {
  final LeafletDetail detail;

  const LeafletDetailThumbnail(this.detail, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final thumbnail = detail.thumbnail;
    final thumbnailBh = detail.thumbnailBh;
    return thumbnail == null
        ? Container(color: ref.scheme.content10)
        : CachedImage(
            config: Caches.leafletImage,
            alignment: Alignment.topCenter,
            fit: BoxFit.cover,
            url: thumbnail,
            blurHash: thumbnailBh,
            errorBuilder: (_, __, ___) => SvgAsset.logo(),
          );
  }
}
// eof
