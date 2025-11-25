import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../core_flutter.dart";

//
// For App Bar - don't use!
//
/*
class MoleculeCardOutline extends ConsumerWidget {
  final Color backgroundColor;
  final String imageUrl;
  final CachedImageConfig imageCache;

  const MoleculeCardOutline({
    required this.backgroundColor,
    required this.imageUrl,
    required this.imageCache,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AspectRatio(
      aspectRatio: 4 / 3.0,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          //border: Border.all(color: ref.scheme.content10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(0), // 8
          child: FractionallySizedBox(
            widthFactor: 0.8,
            heightFactor: 0.8,
            child: CachedImage(
              url: imageUrl,
              config: imageCache,
              errorBuilder: (context, object, stacktrace) => SvgAsset.logo(),
            ),
          ),
        ),
      ),
    );
  }
}
*/

///
/// For grid
///
/// Molecules/Cards/Card-promo-4
/// For 2 column
class MoleculusCardGrid4 extends ConsumerWidget {
  final Color backgroundColor;
  final Widget? image;
  final String? imageUrl;
  final CachedImageConfig? imageCache;
  final String? imageBlurHash;
  final Widget? imagePlaceholder;
  final String? detailText;
  final String? detailIcon;
  final int detailMaxLines;

  const MoleculusCardGrid4({
    required this.backgroundColor,
    this.image,
    this.imageUrl,
    this.imageCache,
    this.imageBlurHash,
    this.imagePlaceholder,
    this.detailText,
    this.detailIcon,
    this.detailMaxLines = 2,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //
    final separator = backgroundColor.isDark() ? Colors.white : const Color(0xFFD1D2D6);
    final color = backgroundColor.isDark() ? Colors.white : Colors.black;
    final hasIcon = detailIcon != null;
    return AspectRatio(
      aspectRatio: 4 / 3.0,
      child: Container(
        decoration: moleculeShadowDecoration(backgroundColor),
        child: Padding(
          padding: const EdgeInsets.all(8), //8
          child: Column(
            children: [
              Expanded(
                child: image ??
                    (imageUrl != null
                        ? CachedImage(
                            url: imageUrl!,
                            config: imageCache!,
                            blurHash: imageBlurHash,
                            placeholder: imagePlaceholder,
                            errorBuilder: (context, object, stacktrace) => SvgAsset.logo(),
                          )
                        : SvgAsset.logo()),
              ),
              if (detailText != null) ...[
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Container(color: separator, height: 0.5),
                    ),
                    Row(
                      children: [
                        if (hasIcon) ...[
                          VegaIcon(name: detailIcon!, size: 20, color: color),
                          const SizedBox(width: 8),
                          Expanded(
                            child: detailText.label.color(color).maxLine(detailMaxLines).overflowEllipsis.alignLeft,
                          ),
                        ],
                        if (!hasIcon)
                          Expanded(
                            child: detailText.label.color(color).maxLine(detailMaxLines).overflowEllipsis.alignCenter,
                          ),
                      ],
                    ),
                  ],
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}

/// Molecules/Cards/Card-promo-3
/// For 3 columns
class MoleculusCardGrid3 extends ConsumerWidget {
  final Color backgroundColor;
  final Widget? image;
  final String? imageUrl;
  final CachedImageConfig? imageCache;
  final String? imageBlurHash;
  final Widget? imagePlaceholder;
  final String? text;

  const MoleculusCardGrid3({
    required this.backgroundColor,
    this.image,
    this.imageUrl,
    this.imageCache,
    this.imageBlurHash,
    this.imagePlaceholder,
    this.text,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //
    final separator = backgroundColor.isDark() ? Colors.white : const Color(0xFFD1D2D6);
    final color = backgroundColor.isDark() ? Colors.white : Colors.black;
    return AspectRatio(
      aspectRatio: 4 / 3.0,
      child: Container(
        decoration: moleculeShadowDecoration(backgroundColor),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Expanded(
                child: image ??
                    (imageUrl != null
                        ? CachedImage(
                            url: imageUrl!,
                            config: imageCache!,
                            blurHash: imageBlurHash,
                            placeholder: imagePlaceholder,
                            errorBuilder: (context, object, stacktrace) => SvgAsset.logo(),
                          )
                        : SvgAsset.logo()),
              ),
              if (text != null) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Container(color: separator, height: 0.5),
                    ),
                    text.label.color(color).maxLine(1).overflowEllipsis.alignCenter,
                  ],
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}

/// Molecules/Cards/Card-promo-2
/// For 4 columns
typedef MoleculusCardGrid2 = MoleculusCardGrid3;

/// Molecules/Cards/Card-promo-1
/// For 5 columns
class MoleculusCardGrid1 extends ConsumerWidget {
  final Color backgroundColor;
  final bool shadow;
  final Widget? image;
  final String? imageUrl;
  final CachedImageConfig? imageCache;
  final String? imageBlurHash;
  final Widget? imagePlaceholder;

  const MoleculusCardGrid1({
    required this.backgroundColor,
    this.shadow = true,
    this.image,
    this.imageUrl,
    this.imageCache,
    this.imageBlurHash,
    this.imagePlaceholder,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AspectRatio(
      aspectRatio: 4 / 3.0,
      child: Container(
        decoration: shadow
            ? moleculeShadowDecoration(backgroundColor)
            : moleculeOutlineDecoration(ref.scheme.content10, backgroundColor),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: image ??
              (imageUrl != null
                  ? CachedImage(
                      url: imageUrl!,
                      config: imageCache!,
                      blurHash: imageBlurHash,
                      placeholder: imagePlaceholder,
                      errorBuilder: (context, object, stacktrace) => SvgAsset.logo(),
                    )
                  : SvgAsset.logo()),
        ),
      ),
    );
  }
}

/// Molecules/Card-loyalty Big, 3:2
/// Old: MoleculusCardBig
class MoleculeCardLoyaltyBig extends ConsumerWidget {
  final String? title;
  final String? label;
  final CrossAxisAlignment labelAlignment;
  final bool showSeparator;
  final String? actionText;
  final void Function()? onAction;
  final Widget? image;
  final double imageAspectRatio;
  final Widget? child;

  const MoleculeCardLoyaltyBig({
    Key? key,
    this.label,
    this.title,
    this.labelAlignment = CrossAxisAlignment.start,
    this.showSeparator = false,
    this.actionText,
    this.onAction,
    this.image,
    this.imageAspectRatio = 2,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: moleculeShadowDecoration(ref.scheme.paperCard),
      child: Padding(
        padding: const EdgeInsets.only(
          left: moleculeScreenPadding,
          top: moleculeScreenPadding,
          right: moleculeScreenPadding,
        ),
        child: Column(
          crossAxisAlignment: labelAlignment,
          children: [
            //
            if (title != null)
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: title!.toUpperCase().h4.color(ref.scheme.content50)),
                      if (actionText != null) ...[
                        const SizedBox(width: 16),
                        GestureDetector(
                          child: actionText.label.color(onAction != null ? ref.scheme.primary : ref.scheme.content50),
                          onTap: () => onAction?.call(),
                        ),
                      ]
                    ],
                  ),
                  if (showSeparator) ...[
                    const SizedBox(height: 16),
                    const MoleculeItemSeparator(),
                    const SizedBox(height: 16),
                  ],
                  if (!showSeparator) const SizedBox(height: 16),
                ],
              ),
            if (child == null)
              AspectRatio(
                aspectRatio: imageAspectRatio,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  child: image ?? Container(color: ref.scheme.content10),
                ),
              ),
            if (child != null) child!,
            if (label != null) ...[
              const SizedBox(height: 16),
              label.text.maxLine(2).color(ref.scheme.content),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}

/// Molecules/Card-loyalty Medium, 3:1
/// Old: MoleculusCardMedium
class MoleculeCardLoyaltyMedium extends ConsumerWidget {
  final String label;
  final CrossAxisAlignment labelAlignment;
  final Widget? image;
  final Widget? logo;

  const MoleculeCardLoyaltyMedium({
    Key? key,
    required this.label,
    this.labelAlignment = CrossAxisAlignment.start,
    this.image,
    this.logo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: moleculeShadowDecoration(ref.scheme.paperCard),
      child: Padding(
        padding: const EdgeInsets.all(moleculeScreenPadding),
        child: Column(
          crossAxisAlignment: labelAlignment,
          children: [
            AspectRatio(
              aspectRatio: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(4)),
                child: image ?? Container(color: ref.scheme.content10),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: label.text.color(ref.scheme.content).maxLine(2)),
                if (logo != null) ...[
                  const SizedBox(width: 16),
                  SizedBox(height: 45, child: logo!),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Molecules/Card-flyer Medium, 3:1
class MoleculeCardFlyer extends ConsumerWidget {
  final String title;
  final String label;
  final String? info;
  final Widget? thumbnail;

  const MoleculeCardFlyer({
    Key? key,
    required this.title,
    required this.label,
    this.info,
    this.thumbnail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: moleculeShadowDecoration(ref.scheme.paperCard),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
              child: thumbnail ?? Container(color: ref.scheme.content10),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: title.h4.color(ref.scheme.content50).maxLine(2),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: label.label.color(ref.scheme.content).maxLine(1),
          ),
          if (info != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: info.label.color(ref.scheme.content50).maxLine(1),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/*
class MoleculusCardLeaflet extends ConsumerWidget {
  final String title;
  final String description;
  final String imageUrl;
  final BaseCacheManager imageCache;

  const MoleculusCardLeaflet({
    Key? key,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.imageCache,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: moleculusDecoration(ref.scheme.paperCard),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            child: AspectRatio(
              aspectRatio: 96 / 144.0,
              child: CachedNetworkImage(
                height: 144,
                imageUrl: imageUrl,
                cacheManager: imageCache,
                fit: BoxFit.cover,
                progressIndicatorBuilder: (context, url, progress) => const CenteredWaitIndicator(),
                errorWidget: (context, url, error) => Center(
                  child: KartyIcon(name: "x_circle", color: ref.scheme.negative),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: title.toUpperCase().h4.maxLine(1).color(ref.scheme.content50),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: description.label.maxLine(1).color(ref.scheme.content),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
*/

// eof
