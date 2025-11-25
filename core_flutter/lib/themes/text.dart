import "package:core_flutter/themes/theme.dart";
import "package:flutter/material.dart";

class ThemedText extends StatelessWidget {
  final String? text;
  final TextStyle? Function(TextTheme)? style;
  final Map<String, dynamic>? extra;

  const ThemedText({
    Key? key,
    required this.text,
    this.style,
    this.extra,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    //final colorScheme = theme.colorScheme;
    if (extra == null) return Text(text ?? "", style: style!(textTheme));
    return Text(
      text ?? "",
      style: style!(textTheme),
      overflow: extra!["overflow"],
      maxLines: extra!["maxLine"],
      softWrap: extra!["softWrap"],
      textAlign: extra!["textAlign"],
      textScaleFactor: extra!["textScaleFactor"],
    );
  }

  ThemedText _style<T>(T v) => (v is Map) ? _styled(extra: v) : _styled(style: v as TextStyle);

  ThemedText _styled({TextStyle? style, Map? extra}) => ThemedText(
        text: text,
        style: (tt) => this.style!(tt)?.merge(style),
        extra: {...this.extra ?? {}, ...extra as Map<String, dynamic>? ?? {}},
      );

  ThemedText get lineThrough => _style(const TextStyle(decoration: TextDecoration.lineThrough));

  ThemedText get underline => _style(const TextStyle(decoration: TextDecoration.underline));
  ThemedText get overline => _style(const TextStyle(decoration: TextDecoration.overline));

  ThemedText color(Color? v) => _style(TextStyle(color: v));
  ThemedText backgroundColor(Color v) => _style(TextStyle(backgroundColor: v));
  ThemedText size(double v) => _style(TextStyle(fontSize: v));
  ThemedText height(double v) => _style(TextStyle(height: v));

  ThemedText get italic => _style(const TextStyle(fontStyle: FontStyle.italic));
  ThemedText get thin => _style(const TextStyle(fontWeight: FontWeight.w100));
  ThemedText get extraLight => _style(const TextStyle(fontWeight: FontWeight.w200));
  ThemedText get light => _style(const TextStyle(fontWeight: FontWeight.w300));
  ThemedText get regular => _style(const TextStyle(fontWeight: FontWeight.normal));
  ThemedText get medium => _style(const TextStyle(fontWeight: FontWeight.w500));
  ThemedText get semiBold => _style(const TextStyle(fontWeight: FontWeight.w600));
  ThemedText get bold => _style(const TextStyle(fontWeight: FontWeight.w700));
  ThemedText get extraBold => _style(const TextStyle(fontWeight: FontWeight.w800));
  ThemedText get black => _style(const TextStyle(fontWeight: FontWeight.w900));

  ThemedText get solidLine => _style(const TextStyle(decorationStyle: TextDecorationStyle.solid));
  ThemedText get dottedLine => _style(const TextStyle(decorationStyle: TextDecorationStyle.dotted));
  ThemedText get doubledLine => _style(const TextStyle(decorationStyle: TextDecorationStyle.double));
  ThemedText get wavyLine => _style(const TextStyle(decorationStyle: TextDecorationStyle.wavy));
  ThemedText get dashedLine => _style(const TextStyle(decorationStyle: TextDecorationStyle.dashed));

  ThemedText lineColor(Color v) => _style(TextStyle(decorationColor: v));
  ThemedText lineThickness(double v) => _style(TextStyle(decorationThickness: v));

  ThemedText get alphabeticBaseline => _style(const TextStyle(textBaseline: TextBaseline.alphabetic));
  ThemedText get ideographicBaseline => _style(const TextStyle(textBaseline: TextBaseline.ideographic));

  ThemedText fontFamily(String v) => _style(TextStyle(fontFamily: v));
  ThemedText letterSpacing(double v) => _style(TextStyle(letterSpacing: v));
  ThemedText wordSpacing(double v) => _style(TextStyle(wordSpacing: v));
  ThemedText locale(Locale v) => _style(TextStyle(locale: v));
  ThemedText foreground(Paint v) => _style(TextStyle(foreground: v));
  ThemedText shadows(List<Shadow> v) => _style(TextStyle(shadows: v));
  ThemedText fontFeatures(List<FontFeature> v) => _style(TextStyle(fontFeatures: v));

  ThemedText softWrap(bool v) => _style({"softWrap": v});

  ThemedText get overflowVisible => _style({"overflow": TextOverflow.visible});
  ThemedText get overflowClip => _style({"overflow": TextOverflow.clip});
  ThemedText get overflowEllipsis => _style({"overflow": TextOverflow.ellipsis});
  ThemedText get overflowFade => _style({"overflow": TextOverflow.fade});

  ThemedText maxLine(int v) => _style({"maxLine": v});
  ThemedText scaleFactor(double v) => _style({"textScaleFactor": v});
  ThemedText get alignLeft => _style({"textAlign": TextAlign.left});
  ThemedText get alignRight => _style({"textAlign": TextAlign.right});
  ThemedText get alignCenter => _style({"textAlign": TextAlign.center});
  ThemedText get alignJustify => _style({"textAlign": TextAlign.justify});
  ThemedText get alignStart => _style({"textAlign": TextAlign.start});
  ThemedText get alignEnd => _style({"textAlign": TextAlign.end});
}

extension ThemedTextStyle on ThemedText {}

extension TextLess on String? {
  ThemedText style(TextStyle style) => ThemedText(text: this, style: (t) => style);

  ThemedText get h1 => ThemedText(text: this, style: (t) => AtomStyles.h1Text);
  ThemedText get h2 => ThemedText(text: this, style: (t) => AtomStyles.h2Text);
  ThemedText get h3 => ThemedText(text: this, style: (t) => AtomStyles.h3Text);
  ThemedText get h4 => ThemedText(text: this, style: (t) => AtomStyles.h4Text);

  ThemedText get bigText => ThemedText(text: this, style: (t) => AtomStyles.bigText);
  ThemedText get text => ThemedText(text: this, style: (t) => AtomStyles.text);
  ThemedText get textBold => ThemedText(text: this, style: (t) => AtomStyles.textBold);

  ThemedText get label => ThemedText(text: this, style: (t) => AtomStyles.labelText);
  ThemedText get labelBold => ThemedText(text: this, style: (t) => AtomStyles.labelBoldText);
  ThemedText get micro => ThemedText(text: this, style: (t) => AtomStyles.microText);
}

// eof
