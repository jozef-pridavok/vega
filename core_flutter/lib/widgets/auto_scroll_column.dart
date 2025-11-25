import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../themes/theme.dart";

class AutoScrollColumn extends ConsumerStatefulWidget {
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment;
  final List<Widget> children;

  const AutoScrollColumn({
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.children = const <Widget>[],
    Key? key,
  }) : super(key: key);

  @override
  createState() => _AutoScrollColumnState();
}

class _AutoScrollColumnState extends ConsumerState<AutoScrollColumn> {
  final GlobalKey _columnKey = GlobalKey();
  double? _columnHeight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, viewportConstraints) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final renderBoxRed = _columnKey.currentContext!.findRenderObject() as RenderBox?;
        _columnHeight = renderBoxRed?.size.height;
        setState(() {});
      });
      return SingleChildScrollView(
        physics: (_columnHeight ?? 0) > viewportConstraints.maxHeight
            ? vegaScrollPhysic
            : const NeverScrollableScrollPhysics(),
        child: Column(
          key: _columnKey,
          mainAxisAlignment: widget.mainAxisAlignment,
          mainAxisSize: widget.mainAxisSize,
          crossAxisAlignment: widget.crossAxisAlignment,
          children: widget.children,
        ),
      );
    });
  }
}

// eof
