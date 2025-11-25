import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

class MoleculusItemCard extends ConsumerWidget {
  final String? icon;
  final Color? iconColor;
  final bool applyIconColorFilter;
  final Widget card;
  final String title;
  final String? label;
  final String? actionIcon;
  final bool applyActionIconColorFilter;
  final Color? actionIconColor;

  const MoleculusItemCard({
    Key? key,
    this.icon,
    this.iconColor,
    this.applyIconColorFilter = true,
    required this.card,
    required this.title,
    this.label,
    this.actionIcon,
    this.actionIconColor,
    this.applyActionIconColorFilter = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: moleculeItemHeight + 3,
      child: Row(
        children: [
          if (icon != null) ...[
            VegaIcon(name: icon!, applyColorFilter: applyIconColorFilter, color: iconColor),
            const SizedBox(width: 16),
          ],
          SizedBox(height: 48, child: card),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                title.text.maxLine(3).color(ref.scheme.content),
                if (label != null) ...[
                  if (label != null) ...[
                    const SizedBox(height: 8),
                    label!.label.color(ref.scheme.content50),
                  ]
                ],
              ],
            ),
          ),
          if (actionIcon != null) ...[
            const SizedBox(width: 16),
            VegaIcon(name: actionIcon!, applyColorFilter: applyActionIconColorFilter, color: actionIconColor)
          ],
        ],
      ),
    );
  }
}

class MoleculusItemCardLogo extends ConsumerWidget {
  final Color backgroundColor;
  final String? imageUrl;
  final String? imageBh;
  final CachedImageConfig? imageCache;

  const MoleculusItemCardLogo({
    required this.backgroundColor,
    this.imageUrl,
    this.imageBh,
    this.imageCache,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AspectRatio(
      aspectRatio: 4 / 3.0,
      child: Container(
        decoration: moleculeShadowDecoration(backgroundColor),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Expanded(
                child: (imageUrl != null
                    ? CachedImage(
                        //fadeInDuration: const Duration(milliseconds: 10),
                        url: imageUrl!,
                        blurHash: imageBh,
                        config: imageCache!,
                        errorBuilder: (context, object, stacktrace) => SvgAsset.logo(),
                      )
                    : SvgAsset.logo()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// eof
