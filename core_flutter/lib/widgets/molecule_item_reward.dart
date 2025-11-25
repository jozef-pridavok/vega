import "package:core_flutter/core_extensions.dart";
import "package:core_flutter/core_theme.dart";
import "package:core_flutter/core_widgets.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

/// Figma: Molecules/Item Program
class MoleculeItemReward extends ConsumerWidget {
  final String? icon;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final Widget? image;
  final String? imageUrl;
  final String? imageBh;
  final CachedImageConfig? imageCache;
  final String title;
  final String? label;
  final bool applyColorFilter;

  const MoleculeItemReward({
    super.key,
    this.icon,
    this.iconColor,
    this.iconBackgroundColor,
    this.image,
    this.imageUrl,
    this.imageBh,
    this.imageCache,
    required this.title,
    this.label,
    this.applyColorFilter = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 112,
      child: Row(
        children: [
          if (icon != null) ...[
            iconBackgroundColor != null
                ? CircleAvatar(
                    backgroundColor: iconBackgroundColor,
                    child: VegaIcon(name: icon!, color: iconColor ?? ref.scheme.light),
                  )
                : VegaIcon(name: icon!, applyColorFilter: applyColorFilter, color: iconColor),
            const SizedBox(width: 16),
          ],
          if (imageUrl != null) ...[
            SizedBox(
              width: 96,
              height: 96,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                child: image ??
                    CachedImage(
                      url: imageUrl!,
                      config: imageCache!,
                      blurHash: imageBh,
                      errorBuilder: (context, error, stackTrace) => SvgAsset.logo(),
                    ),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                title.text.color(ref.scheme.content),
                if (label != null) ...[
                  if (label != null) ...[
                    const SizedBox(height: 8),
                    label!.label.maxLine(2).overflowEllipsis.color(ref.scheme.content50),
                  ]
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// eof
