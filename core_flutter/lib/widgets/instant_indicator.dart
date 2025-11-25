import "dart:async";

import "package:flutter/material.dart";
import "package:flutter/services.dart";

enum Position {
  top,
  bottom,
}

// https://pub.dev/packages/iosish_indicator

class Instant {
  /// The context where the indicator will be shown.
  final BuildContext _context;

  /// The double value of StatusBar Height.
  final double _statusBarHeight;

  /// OverlayEntry that will overlay the indicator.
  OverlayState? _overlay;

  Instant(this._context) : _statusBarHeight = MediaQuery.of(_context).padding.top;

  /// Create Indicator.
  ///
  /// [title] is the text that will be shown and is required to create indicator.
  ///
  /// [position] is Position where the indicator will be shown.
  /// Default value is [Position.top].
  ///
  /// If [haptic] is true, then haptic feedback will be generated when the indicator is shown.
  ///
  /// Wait [duration] after indicator is shown and will be automatically closed.
  ///
  /// Can add [child] Widget on the left side of indicator.
  void createIndicator({
    required String title,
    Position position = Position.top,
    Color? backgroundColor,
    Duration? duration,
    bool haptic = true,
    Widget? child,
  }) {
    final finalDuration = duration ?? const Duration(milliseconds: 4000);
    _overlay = Overlay.of(_context);
    final entry = OverlayEntry(
      builder: (context) => _Indicator(
        title: title,
        backgroundColor: backgroundColor,
        duration: finalDuration,
        position: position,
        haptic: haptic,
        statusBarHeight: _statusBarHeight,
        child: child,
      ),
    );

    // Show Overlay over the context.
    _overlay?.insert(entry);

    // After the indicator is exited from the context, remove the Overlay.
    _removeEntry(entry, finalDuration);
  }

  /// Remove Overlay.
  ///
  /// [Duration] with 600 ms is for pop-up animation and hiding animation delay.
  /// and [Duration] value [duration] is the waiting duration of indicator.
  void _removeEntry(OverlayEntry entry, Duration duration) async {
    await Future.delayed(duration + const Duration(milliseconds: 600));
    entry.remove();
  }
}

class _Indicator extends StatefulWidget {
  /// The double value of StatusBar Height.
  final double statusBarHeight;

  /// The string value of main title [Text].
  final String title;

  /// Indicator will wait until [duration] time is over.
  final Duration duration;

  /// The [Position] value of indicator.
  ///
  /// Default value is [Position.top].
  final Position position;

  /// The bool value of HapticFeedback.
  ///
  /// If haptic is true, then hapticFeedback will be created when indicator is created.
  final bool haptic;

  /// More [Widget] to show over the indicator.
  final Widget? child;

  final Color? backgroundColor;

  const _Indicator({
    Key? key,
    required this.statusBarHeight,
    required this.title,
    this.backgroundColor,
    required this.duration,
    required this.position,
    required this.haptic,
    this.child,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _IndicatorState();
}

class _IndicatorState extends State<_Indicator> {
  /// Position where the indicator is started.
  static const double _beginPosition = -64;

  /// Position where the indicator is shown.
  static const double _finishPosition = 100;

  /// Current position of the indicator.
  double? _currentPos;

  /// The function that makes indicator move to [_finishPosition].
  void startMove() async {
    _currentPos = _beginPosition;

    // What until position is applied
    await Future.delayed(const Duration(milliseconds: 100));

    // Move to finish position without statusbar height.
    if (mounted)
      setState(() {
        _currentPos = _finishPosition - widget.statusBarHeight;
      });
    endMove();
  }

  /// The function that makes indicator hide.
  void endMove() async {
    await Future.delayed(widget.duration);
    // Move indicator from _finishPosition to _beginPosition.
    if (mounted) setState(() => _currentPos = _beginPosition);
  }

  @override
  void initState() {
    super.initState();

    // If haptic is true, then create HapticFeedBack.
    if (widget.haptic) {
      HapticFeedback.heavyImpact();
    }

    // Start move indicator when state is initialized.
    startMove();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        AnimatedPositioned(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          top: widget.position == Position.top ? _currentPos : null,
          bottom: widget.position == Position.bottom ? _currentPos : null,
          child: Material(
            color: Colors.transparent,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              padding: const EdgeInsets.only(
                top: 16,
                bottom: 16,
                left: 16,
                right: 32,
              ),
              decoration: BoxDecoration(
                color: widget.backgroundColor ?? Theme.of(context).cardColor,
                borderRadius: const BorderRadius.all(Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 16,
                  )
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  widget.child ?? const SizedBox(),
                  const SizedBox(width: 16),
                  Container(
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    child: Column(
                      children: [
                        Text(
                          widget.title,
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: widget.backgroundColor != null ? Colors.white : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// eof
