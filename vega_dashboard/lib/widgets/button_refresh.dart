// refresh button with rotation animation

import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

class VegaRefreshButton extends ConsumerStatefulWidget {
  final bool isRotating;
  final VoidCallback? onPressed;
  final bool disabled;

  const VegaRefreshButton({
    required this.isRotating,
    this.onPressed,
    this.disabled = false,
    super.key,
  });

  @override
  createState() => _VegaRefreshButtonState();
}

class _VegaRefreshButtonState extends ConsumerState<VegaRefreshButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 750),
  );

  @override
  void initState() {
    super.initState();
    if (widget.isRotating) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant VegaRefreshButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRotating != oldWidget.isRotating) {
      if (widget.isRotating) {
        _controller.repeat();
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * 3.141592653589793,
          child: IconButton(
            icon: VegaIcon(name: AtomIcons.refresh, color: widget.disabled ? ref.scheme.content20 : null),
            onPressed: (widget.isRotating || widget.disabled) ? null : widget.onPressed,
          ),
        );
      },
    );
  }
}

// eof

