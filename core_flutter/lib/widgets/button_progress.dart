import "package:flutter/material.dart";

// https://pub.dev/packages/progress_state_button
// progress_state_button: ^1.0.4

enum ButtonState { idle, loading, success, fail }

class ProgressButtonIconButton {
  final String? text;
  final Icon? icon;
  final Color color;

  const ProgressButtonIconButton({
    this.text,
    this.icon,
    required this.color,
  });
}

Widget _buildChildWithIcon(ProgressButtonIconButton iconedButton, double iconPadding, TextStyle textStyle) {
  return _buildChildWithIC(iconedButton.text, iconedButton.icon, iconPadding, textStyle);
}

Widget _buildChildWithIC(String? text, Icon? icon, double gap, TextStyle textStyle) {
  var children = <Widget>[];
  children.add(icon ?? Container());
  if (text != null) {
    children.add(Padding(padding: EdgeInsets.all(gap)));
    children.add(_buildText(text, textStyle));
  }

  return Wrap(
    direction: Axis.horizontal,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: children,
  );
}

Widget _buildText(String text, TextStyle style) {
  return Text(text, style: style);
}

class ProgressButton extends StatefulWidget {
  final Map<ButtonState, Widget> stateWidgets;
  final Map<ButtonState, Color> stateColors;
  final Color? disabledColor;
  final void Function()? onPressed;
  final Function? onAnimationEnd;
  final ButtonState? state;
  final double minWidth;
  final double maxWidth;
  final double radius;
  final double height;
  final ProgressIndicator? progressIndicator;
  final double progressIndicatorSize;
  final MainAxisAlignment progressIndicatorAlignment;
  final EdgeInsets padding;
  final List<ButtonState> minWidthStates;
  final Duration animationDuration;

  ProgressButton(
      {Key? key,
      required this.stateWidgets,
      required this.stateColors,
      this.disabledColor,
      this.state = ButtonState.idle,
      this.onPressed,
      this.onAnimationEnd,
      this.minWidth = 200.0,
      this.maxWidth = 400.0,
      this.radius = 16.0,
      this.height = 53.0,
      this.progressIndicatorSize = 35.0,
      this.progressIndicator,
      this.progressIndicatorAlignment = MainAxisAlignment.spaceBetween,
      this.padding = EdgeInsets.zero,
      this.minWidthStates = const <ButtonState>[ButtonState.loading],
      this.animationDuration = const Duration(milliseconds: 500)})
      : assert(
          stateWidgets.keys.toSet().containsAll(ButtonState.values.toSet()),
          "Must be non-null widgetds provided in map of stateWidgets. Missing keys => ${ButtonState.values.toSet().difference(stateWidgets.keys.toSet())}",
        ),
        assert(
          stateColors.keys.toSet().containsAll(ButtonState.values.toSet()),
          "Must be non-null widgetds provided in map of stateWidgets. Missing keys => ${ButtonState.values.toSet().difference(stateColors.keys.toSet())}",
        ),
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ProgressButtonState();
  }

  factory ProgressButton.icon({
    required Map<ButtonState, ProgressButtonIconButton> iconButtons,
    void Function()? onPressed,
    ButtonState? state = ButtonState.idle,
    Function? animationEnd,
    maxWidth = 170.0,
    minWidth = 58.0,
    height = 53.0,
    radius = 100.0,
    progressIndicatorSize = 35.0,
    double iconPadding = 4.0,
    TextStyle? textStyle,
    CircularProgressIndicator? progressIndicator,
    MainAxisAlignment? progressIndicatorAlignment,
    EdgeInsets padding = EdgeInsets.zero,
    List<ButtonState> minWidthStates = const <ButtonState>[ButtonState.loading],
  }) {
    assert(
      iconButtons.keys.toSet().containsAll(ButtonState.values.toSet()),
      "Must be non-null widgets provided in map of stateWidgets. Missing keys => ${ButtonState.values.toSet().difference(iconButtons.keys.toSet())}",
    );

    textStyle ??= const TextStyle(color: Colors.white, fontWeight: FontWeight.w500);

    Map<ButtonState, Widget> stateWidgets = {
      ButtonState.idle: _buildChildWithIcon(iconButtons[ButtonState.idle]!, iconPadding, textStyle),
      ButtonState.loading: const Column(),
      ButtonState.fail: _buildChildWithIcon(iconButtons[ButtonState.fail]!, iconPadding, textStyle),
      ButtonState.success: _buildChildWithIcon(iconButtons[ButtonState.success]!, iconPadding, textStyle)
    };

    Map<ButtonState, Color> stateColors = {
      ButtonState.idle: iconButtons[ButtonState.idle]!.color,
      ButtonState.loading: iconButtons[ButtonState.loading]!.color,
      ButtonState.fail: iconButtons[ButtonState.fail]!.color,
      ButtonState.success: iconButtons[ButtonState.success]!.color,
    };

    return ProgressButton(
      stateWidgets: stateWidgets,
      stateColors: stateColors,
      state: state,
      onPressed: onPressed,
      onAnimationEnd: animationEnd,
      maxWidth: maxWidth,
      minWidth: minWidth,
      radius: radius,
      height: height,
      progressIndicatorSize: progressIndicatorSize,
      progressIndicatorAlignment: MainAxisAlignment.center,
      progressIndicator: progressIndicator,
      minWidthStates: minWidthStates,
    );
  }
}

class _ProgressButtonState extends State<ProgressButton> with TickerProviderStateMixin {
  AnimationController? colorAnimationController;
  Animation<Color?>? colorAnimation;
  double? width;
  Widget? progressIndicator;

  void startAnimations(ButtonState? oldState, ButtonState? newState) {
    Color? begin = widget.stateColors[oldState!];
    Color? end = widget.stateColors[newState!];
    if (widget.minWidthStates.contains(newState)) {
      width = widget.minWidth;
    } else {
      width = widget.maxWidth;
    }
    colorAnimation = ColorTween(begin: begin, end: end).animate(
      CurvedAnimation(
        parent: colorAnimationController!,
        curve: const Interval(
          0,
          1,
          curve: Curves.easeIn,
        ),
      ),
    );
    colorAnimationController!.forward();
  }

  Color? get backgroundColor => colorAnimation == null
      ? widget.stateColors[widget.state!]
      : colorAnimation!.value ?? widget.stateColors[widget.state!];

  @override
  void initState() {
    super.initState();

    width = widget.maxWidth;

    colorAnimationController = AnimationController(duration: widget.animationDuration, vsync: this);
    colorAnimationController!.addStatusListener((status) {
      if (widget.onAnimationEnd != null) {
        widget.onAnimationEnd!(status, widget.state);
      }
    });

    progressIndicator = widget.progressIndicator ??
        CircularProgressIndicator(
          backgroundColor: widget.stateColors[widget.state!],
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
        );
  }

  @override
  void dispose() {
    colorAnimationController!.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ProgressButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.state != widget.state) {
      colorAnimationController?.reset();
      startAnimations(oldWidget.state, widget.state);
    }
  }

  Widget getButtonChild(bool visibility) {
    Widget? buttonChild = widget.stateWidgets[widget.state!];
    if (widget.state == ButtonState.loading) {
      return Row(
        mainAxisAlignment: widget.progressIndicatorAlignment,
        children: <Widget>[
          SizedBox(
            width: widget.progressIndicatorSize,
            height: widget.progressIndicatorSize,
            child: progressIndicator,
          ),
          buttonChild ?? Container(),
          Container()
        ],
      );
    }
    return AnimatedOpacity(
      opacity: visibility ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      child: buttonChild,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: colorAnimationController!,
      builder: (context, child) {
        return AnimatedContainer(
            width: width,
            height: widget.height,
            duration: widget.animationDuration,
            child: MaterialButton(
              padding: widget.padding,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(widget.radius),
                side: const BorderSide(color: Colors.transparent, width: 0),
              ),
              color: widget.onPressed == null ? widget.disabledColor : backgroundColor,
              onPressed: () => widget.onPressed?.call(),
              child: getButtonChild(
                colorAnimation == null ? true : colorAnimation!.isCompleted,
              ),
            ));
      },
    );
  }
}

// eof
