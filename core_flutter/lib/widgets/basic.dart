import "dart:async";

import "package:core_flutter/core_flutter.dart";
import "package:easy_refresh/easy_refresh.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_svg/flutter_svg.dart";

/*
const $screenMenuItemRowHeight = 50.0; //.h;

class HorizontalSpacer extends StatelessWidget {
  const HorizontalSpacer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const SizedBox(width: 16);
}

class VerticalSpacer extends StatelessWidget {
  const VerticalSpacer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const SizedBox(height: 16);
}

class DoubleVerticalSpacer extends StatelessWidget {
  const DoubleVerticalSpacer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const SizedBox(height: 32);
}

class QuadVerticalSpacer extends StatelessWidget {
  const QuadVerticalSpacer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const SizedBox(height: 64);
}

class HalfVerticalSpacer extends StatelessWidget {
  const HalfVerticalSpacer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const SizedBox(height: 8);
}

class HalfHorizontalSpacer extends StatelessWidget {
  const HalfHorizontalSpacer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const SizedBox(width: 8);
}
*/

class VegaIcon extends ConsumerWidget {
  final String name;
  final double size;
  final Color? color;
  final bool applyColorFilter;

  const VegaIcon({
    required this.name,
    this.color,
    this.size = 24,
    this.applyColorFilter = true,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = this.color ?? ref.scheme.primary;
    return SvgPicture.asset(
      "assets/icons/ic_$name.svg",
      width: size,
      height: size,
      colorFilter: applyColorFilter ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }
}

class VegaImage extends ConsumerWidget {
  final String name;
  final double width;
  final double height;
  final Color? color;

  const VegaImage({
    required this.name,
    this.color,
    this.width = 128,
    this.height = 128,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SvgPicture.asset(
      "assets/images/im_$name.svg",
      width: width,
      height: height,
      colorFilter: color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
    );
  }
}

class VegaSvg extends StatelessWidget {
  final String assetName;
  final BoxFit fit;
  const VegaSvg(this.assetName, {Key? key, this.fit = BoxFit.contain}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final asset = "assets/images/$assetName.svg";
    return SvgPicture.asset(asset, fit: fit);
  }
}

class WaitIndicator extends StatelessWidget {
  final Color? color;
  final double? value;
  final double? size;

  const WaitIndicator({
    Key? key,
    this.color,
    this.value,
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = this.color ?? Theme.of(context).primaryColor;
    return SizedBox(
      width: size ?? 30,
      height: size ?? 30,
      child: CircularProgressIndicator(
        strokeWidth: 0.5,
        backgroundColor: Colors.transparent,
        value: value,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}

class CenteredWaitIndicator extends StatelessWidget {
  final Color? color;
  final double? value;

  const CenteredWaitIndicator({
    Key? key,
    this.color,
    this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: WaitIndicator(
        color: color,
        value: value,
      ),
    );
  }
}

class AlignedWaitIndicator extends StatelessWidget {
  final Alignment alignment;
  final Color? color;
  final double? value;

  const AlignedWaitIndicator({
    Key? key,
    this.alignment = Alignment.topCenter,
    this.color,
    this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: WaitIndicator(
        color: color,
        value: value,
      ),
    );
  }
}

/*
class OldPullToRefresh extends ConsumerWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final IndicatorController? controller;
  const OldPullToRefresh({
    Key? key,
    required this.child,
    required this.onRefresh,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomRefreshIndicator(
      onRefresh: () => onRefresh(),
      controller: controller,
      builder: (context, child, controller) {
        return AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            return Stack(
              alignment: Alignment.center,
              fit: StackFit.expand,
              children: <Widget>[
                child,
                if (!controller.isIdle)
                  Positioned(
                    top: 0 * controller.value, // 35
                    child: WaitIndicator(value: controller.value),
                  ),
              ],
            );
          },
        );
      },
      child: child,
    );
  }
}
*/

/*
class CPullToRefresh extends ConsumerStatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const CPullToRefresh({
    Key? key,
    required this.child,
    required this.onRefresh,
  }) : super(key: key);

  @override
  createState() => _CPullToRefreshState();
}

class _CPullToRefreshState extends ConsumerState<CPullToRefresh> with SingleTickerProviderStateMixin {
  static const _indicatorSize = 70.0;

  /// Whether to render check mark instead of spinner
  bool _renderCompleteState = false;

  ScrollDirection prevScrollDirection = ScrollDirection.idle;

  @override
  Widget build(BuildContext context) {
    return cri.CustomRefreshIndicator(
      //offsetToArmed: 30, //_indicatorSize,
      triggerMode: cri.IndicatorTriggerMode.anywhere,
      //containerExtentPercentageToArmed: 30,
      onRefresh: () => widget.onRefresh(),
      //completeStateDuration: const Duration(seconds: 2),
      indicatorCancelDuration: const Duration(milliseconds: 20),
      onStateChanged: (change) {
        /// set [_renderCompleteState] to true when controller.state become completed
        if (change.didChange(to: cri.IndicatorState.complete)) {
          setState(() => _renderCompleteState = true);

          /// set [_renderCompleteState] to false when controller.state become idle
        } else if (change.didChange(to: cri.IndicatorState.idle)) {
          setState(() => _renderCompleteState = false);
        }
      },
      builder: (context, child, controller) {
        return Stack(
          //fit: StackFit.expand,
          children: <Widget>[
            if (!controller.isIdle)
              AnimatedBuilder(
                animation: controller,
                builder: (context, _) {
                  if (controller.scrollingDirection == ScrollDirection.reverse &&
                      prevScrollDirection == ScrollDirection.forward) {
                    controller.stopDrag();
                  }
                  prevScrollDirection = controller.scrollingDirection;
                  final containerHeight = controller.value * _indicatorSize;
                  return Container(
                    alignment: Alignment.center,
                    height: containerHeight,
                    child: OverflowBox(
                      maxHeight: 40,
                      minHeight: 40,
                      maxWidth: 40,
                      minWidth: 40,
                      alignment: Alignment.topCenter,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _renderCompleteState ? ref.scheme.positive : ref.scheme.paper,
                          shape: BoxShape.circle,
                        ),
                        child: _renderCompleteState
                            ? Icon(Icons.check, color: ref.scheme.light)
                            : WaitIndicator(
                                value: controller.isDragging || controller.isArmed
                                    ? controller.value.clamp(0.0, 1.0)
                                    : null,
                              ),
                      ),
                    ),
                  );
                },
              ),
            AnimatedBuilder(
              builder: (context, _) =>
                  Transform.translate(offset: Offset(0.0, controller.value * _indicatorSize), child: child),
              animation: controller,
            ),
          ],
        );
      },
      child: widget.child,
    );
  }
}
*/

class PullToRefresh extends ConsumerStatefulWidget {
  final Widget child;
  final FutureOr<void> Function() onRefresh;

  const PullToRefresh({
    Key? key,
    required this.child,
    required this.onRefresh,
  }) : super(key: key);

  @override
  createState() => _PullToRefreshState();
}

class _PullToRefreshState extends ConsumerState<PullToRefresh> with SingleTickerProviderStateMixin {
  late EasyRefreshController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: false,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EasyRefresh(
      controller: _controller,
      header: CupertinoHeader(
        backgroundColor: ref.scheme.content10,
        foregroundColor: ref.scheme.primary,
        safeArea: false,
      ),
      onRefresh: () async {
        await widget.onRefresh();
        if (!mounted) return;
        _controller.finishRefresh();
        _controller.resetFooter();
      },
      child: widget.child,
    );
  }
}

// eof