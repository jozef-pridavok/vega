// ignore: prefer_double_quotes
import 'package:flutter/material.dart';
import "package:flutter/services.dart";

//double hairLine = 0;

const moleculeScreenPadding = 16.0;
const moleculeButtonHeight = 48.0;
const moleculeButtonRadius = 8.0;
const moleculusItemHeaderHeight = 24.0;
const moleculeItemHeight = 78.0;
const moleculeCompactItemHeight = 52.0;
const moleculeItemSpace = 24.0;
const moleculeItemDoubleSpace = 48.0;
const moleculeItemDoublePadding = 48.0;

// Pre bottomshhet horné rohy
const moleculeBottomSheetBorder = RoundedRectangleBorder(
  borderRadius: BorderRadius.only(
      topLeft: Radius.circular(8), topRight: Radius.circular(8)),
);

// Shadow for cards
BoxDecoration moleculeShadowDecoration([Color? color]) => BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          offset: const Offset(0, 2),
          blurRadius: 12,
          blurStyle: BlurStyle.normal, // outer
        )
      ],
    );

BoxDecoration moleculeOutlineDecoration(Color borderColor,
        [Color? color, double width = 0]) =>
    BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: borderColor, width: width),
    );

Widget moleculeDragDecorator(
    Widget child, int index, Animation<double> animation) {
  return Material(
    //color: Colors.red,
    shadowColor: Colors.black.withOpacity(0.5),
    child: Container(
      decoration: moleculeShadowDecoration(),
      child: child,
    ),
  );
}

Widget _moleculeDragDecoratorWithColor(
    Widget child, int index, Animation<double> animation, Color color) {
  return Material(
    color: color,
    shadowColor: Colors.black.withOpacity(0.5),
    child: Container(
      decoration: moleculeShadowDecoration(),
      child: child,
    ),
  );
}

ReorderItemProxyDecorator createMoleculeDragDecorator(Color color) {
  return (
    Widget child,
    int index,
    Animation<double> animation,
  ) =>
      _moleculeDragDecoratorWithColor(child, index, animation, color);
}

/*
Widget proxyDecorator(Widget child, int index, Animation<double> animation) {
  return Material(
    //color: Colors.red,
    shadowColor: Colors.black.withOpacity(0.5),
    child: child,
  );
  return AnimatedBuilder(
    animation: animation,
    builder: (BuildContext context, Widget? child) {
      final double animValue = Curves.easeInOut.transform(animation.value);
      final double elevation = lerpDouble(0, 1, animValue)!;
      return Material(
        elevation: elevation,
        color: Colors.transparent,
        shadowColor: Colors.black.withOpacity(0.5),
        child: child,
      );
    },
    child: child,
  );
}
*/

const stateRefreshDuration = Duration(milliseconds: 2500);
const fastRefreshDuration = Duration(milliseconds: 250);

const vegaScrollPhysic = BouncingScrollPhysics(
  parent: AlwaysScrollableScrollPhysics(),
);

const _primaryFont = "Poppins";

class AtomColors {
  static const lightPrimaryBlue = Color(0xFF0084F4);
  static const darkPrimaryBlue = Color(0xFF006AC3);

  static const lightSecondaryBlue = Color(0xFFAFDAFF);
  static const darkSecondaryBlue = Color(0xFF8CAECC);

  static const lightContent = Color(0xFF333333);
  static const darkContent = Color(0xFFE8E8EB);

  static const lightContent50 = Color(0xFF8C8E99);
  static const darkContent50 = Color(0xFFD1D2D6);

  static const lightContent20 = Color(0xFFD1D2D6);
  static const darkContent20 = Color(0xFF8C8E99);

  static const lightContent10 = Color(0xFFE8E8EB);
  static const darkContent10 = Color(0xFF65666D);

  static const lightPaper = Color(0xFFFFFFFF);
  static const darkPaper = Color(0xFF121724);

  static const lightPaperBold = Color(0xFFF7F8FD);
  static const darkPaperBold = Color(0xFF1C2335);

  static const lightPaperCard = Color(0xFFFFFFFF);
  static const darkPaperCard = Color(0xFF1C2335);

  static const lightPositive = Color(0xFF00C48C);
  static const darkPositive = Color(0xFF009D70);

  static const lightNegative = Color(0xFFFF647C);
  static const darkNegative = Color(0xFFCC5063);

  static const lightAccent = Color(0xFFFFD260);
  static const darkAccent = Color(0xFFCCA84D);

  static const lightLight = Color(0xFFFFFFFF);
  static const darkLight = Color(0xFFE8E8EB);
}

class AtomStyles {
  static const bigText = TextStyle(
    fontFamily: _primaryFont,
    fontWeight: FontWeight.w700,
    fontSize: 64,
    height: 80 / 64.0,
  );

  static const h1Text = TextStyle(
    fontFamily: _primaryFont,
    fontWeight: FontWeight.w700,
    fontSize: 48,
    height: 64 / 48.0,
  );

  static const h2Text = TextStyle(
    fontFamily: _primaryFont,
    fontWeight: FontWeight.w700,
    fontSize: 36,
    height: 40 / 36.0,
  );

  static const h3Text = TextStyle(
    fontFamily: _primaryFont,
    fontWeight: FontWeight.w600,
    fontSize: 28,
    height: 32 / 28.0,
  );

  static const h4Text = TextStyle(
    fontFamily: _primaryFont,
    fontWeight: FontWeight.w600,
    fontSize: 14,
    height: 18 / 14.0,
  );

  static const text = TextStyle(
    fontFamily: _primaryFont,
    fontWeight: FontWeight.w300,
    fontSize: 16,
    height: 24 / 16.0, //? 14
  );

  static const textBold = TextStyle(
    fontFamily: _primaryFont,
    fontWeight: FontWeight.w600,
    fontSize: 16,
    height: 24 / 16.0, //? 14
  );

  static const labelText = TextStyle(
    fontFamily: _primaryFont,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 18 / 14.0,
  );

  static const labelBoldText = TextStyle(
    fontFamily: _primaryFont,
    fontWeight: FontWeight.w600,
    fontSize: 14,
    height: 18 / 14.0,
  );

  static const microText = TextStyle(
    fontFamily: _primaryFont,
    fontWeight: FontWeight.w400,
    fontSize: 12,
    height: 16 / 12.0,
  );
}

class MoleculeTheme {
  final ThemeMode mode;
  final Color primary;
  final Color secondary;
  final Color content;
  final Color content50;
  final Color content20;
  final Color content10;
  final Color paper;
  final Color paperBold;
  final Color paperCard;
  final Color positive;
  final Color negative;
  final Color accent;
  final Color light;

  const MoleculeTheme({
    required this.mode,
    required this.primary,
    required this.secondary,
    required this.content,
    required this.content50,
    required this.content20,
    required this.content10,
    required this.paper,
    required this.paperBold,
    required this.paperCard,
    required this.positive,
    required this.negative,
    required this.accent,
    required this.light,
  });
}

const lightBlueTheme = MoleculeTheme(
  mode: ThemeMode.light,
  primary: AtomColors.lightPrimaryBlue,
  secondary: AtomColors.lightSecondaryBlue,
  content: AtomColors.lightContent,
  content50: AtomColors.lightContent50,
  content20: AtomColors.lightContent20,
  content10: AtomColors.lightContent10,
  paper: AtomColors.lightPaper,
  paperBold: AtomColors.lightPaperBold,
  paperCard: AtomColors.lightPaperCard,
  positive: AtomColors.lightPositive,
  negative: AtomColors.lightNegative,
  accent: AtomColors.lightAccent,
  light: AtomColors.lightLight,
);

const darkBlueTheme = MoleculeTheme(
  mode: ThemeMode.dark,
  primary: AtomColors.darkPrimaryBlue,
  secondary: AtomColors.darkSecondaryBlue,
  content: AtomColors.darkContent,
  content50: AtomColors.darkContent50,
  content20: AtomColors.darkContent20,
  content10: AtomColors.darkContent10,
  paper: AtomColors.darkPaper,
  paperBold: AtomColors.darkPaperBold,
  paperCard: AtomColors.darkPaperCard,
  positive: AtomColors.darkPositive,
  negative: AtomColors.darkNegative,
  accent: AtomColors.darkAccent,
  light: AtomColors.darkLight,
);

InputDecoration defaultInputDecoration(
  MoleculeTheme scheme, {
  String? hint,
  String? label,
  bool? isDense = true,
  bool focusable = true,
  bool enabled = true,
  String? prefixText,
  Widget? prefixIcon,
  BoxConstraints? prefixIconConstraints,
  String? suffixText,
  Widget? suffixIcon,
  BoxConstraints? suffixIconConstraints,
  EdgeInsetsGeometry? contentPadding,
  TextStyle? hintStyle,
}) {
  return InputDecoration(
    contentPadding: contentPadding ?? const EdgeInsets.fromLTRB(12, 12, 20, 12),
    isDense: isDense,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        width: 1,
        color: focusable ? scheme.content20 : scheme.primary,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        width: 1,
        color: focusable ? scheme.content20 : scheme.primary,
      ),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(width: 1, color: scheme.negative),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(width: 1, color: scheme.negative),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(width: 1, color: scheme.primary),
    ),
    floatingLabelBehavior: FloatingLabelBehavior.never,
    errorStyle: AtomStyles.text.copyWith(color: scheme.negative),
    errorMaxLines: 1,
    hintText: hint,
    enabled: enabled,
    hintStyle: hintStyle ?? AtomStyles.text.copyWith(color: scheme.content20),
    prefixText: prefixText,
    prefixStyle: AtomStyles.text.copyWith(color: scheme.content20),
    prefixIcon: prefixIcon,
    prefixIconConstraints: prefixIconConstraints,
    suffixText: suffixText,
    suffixIcon: suffixIcon,
    suffixIconConstraints: suffixIconConstraints,
  );
}

ThemeData _buildTheme(ThemeData base, MoleculeTheme theme) {
  return base.copyWith(
    //useMaterial3: true,
    primaryColor: theme.primary,
    // disable Ripple effect
    splashFactory: NoSplash.splashFactory,
    //splashFactory: const NoSplashFactory(),
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    hoverColor: Colors.transparent,
    // rest
    disabledColor: theme.secondary,
    scaffoldBackgroundColor: theme.paper,
    // tab bar icon color
    bottomAppBarTheme: BottomAppBarTheme(color: theme.primary),
    appBarTheme: AppBarTheme(
      backgroundColor: theme.paper,
      elevation: 0,
      toolbarTextStyle: AtomStyles.text.copyWith(color: theme.primary),
    ),
    primaryIconTheme: IconThemeData(color: theme.primary),
    bottomSheetTheme:
        base.bottomSheetTheme.copyWith(backgroundColor: theme.paper),
    buttonTheme: base.buttonTheme.copyWith(disabledColor: Colors.amber),
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
      TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
      TargetPlatform.fuchsia: CupertinoPageTransitionsBuilder(),
    }),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        overlayColor: MaterialStateProperty.all<Color>(Colors.transparent),
        splashFactory: NoSplash.splashFactory,
      ),
    ),
  );
}

final ThemeData kLightBlueTheme =
    _buildTheme(ThemeData.light(), lightBlueTheme);
final ThemeData kDarkBlueTheme = _buildTheme(ThemeData.dark(), darkBlueTheme);

class AtomIcons {
  static const String add = "add";
  static const String about = "about";
  static const String maximize = "maximize";
  static const String camera = maximize;
  static const String card = "card";
  static const String cancel = "cancel";
  static const String coupon = "percent";
  static const String dashboard = "monitor";
  static const String heart = "heart";
  static const String program = heart;
  static const String arrowLeft = "arrow_left";
  static const String arrowRight = "arrow_right";
  static const String chevronRight = "chevron_right";
  static const String chevronDown = "chevron_down";
  static const String chevronUp = "chevron_up";
  static const String itemDetail = chevronRight;
  static const String mail = "mail";
  static const String fileText = "file_text";
  static const String globe = "globe";
  static const String gift = "gift";
  static const String flag = "flag";
  static const String logout = "logout";
  static const String folder = "folders";
  static const String favorite = heart;
  static const String plusCircle = "plus_circle";
  static const String minusCircle = "minus_circle";
  static const String plusSquare = "plus_square";
  static const String minusSquare = "minus_square";
  static const String eye = "eye";
  static const String eyeOff = "eye_off";
  static const String refresh = "refresh";
  static const String check = "check";
  static const String checkboxOff = "checkbox";
  static const String checkboxOn = "checkbox_done";
  static const String phone = "phone";
  static const String email = "email";
  static const String location = "map_pin";
  static const String map = "map";
  static const String mapMarkerDefault = "map_marker_default";
  static const String mapMarkerSelected = "map_marker_selected";
  static const String mapActualBig = "map_actual_big";
  static const String mapActualSmall = "map_actual_small";
  static const String list = "list";
  static const String start = "play";
  static const String stop = "pause";
  static const String edit = "edit";
  static const String delete = "delete";
  static const String user = "user";
  static const String users = "users";
  static const String send = "send";
  static const String shield = "shield";
  static const String shieldOff = "shield_off";
  static const String lock = "lock";
  static const String unlock = "unlock";
  static const String slash = "slash";
  static const String block = slash;
  static const String blocked = slash;
  static const String clock = "clock";
  static const String care = "care";
  static const String reservation = clock;
  static const String slot = care;
  static const String shoppingCard = "shopping_cart";
  static const String shoppingCardAdd = "shopping_cart_add";
  static const String moreHorizontal = "more_horizontal";
  static const String moreVertical = "more_vertical";
  static const String xCircle = "x_circle";
  static const String wifiOff = "wifi_off";
  static const String cloudOff = "cloud_of";
  static const String cloudLightning = "cloud_lightning";
  static const String offline = wifiOff;
  static const String invoice = "invoice";
  static const String leaflet = invoice;
  static const String qr = "qr";
  static const String trendingUp = "trending_up";
  static const String sidebar = "sidebar";
  static const String menu = "menu";
  static const String package = "package";
  static const String home = "home";
  static const String calendar = "calendar";
  static const String offer = "package";
}

const hapticDelay = Duration(milliseconds: 500);
DateTime _lastHaptic = DateTime.now();

bool _canHaptic() {
  final now = DateTime.now();
  if (now.difference(_lastHaptic) < hapticDelay) return false;
  _lastHaptic = now;
  return true;
}

Future<void> hapticHeavy() =>
    _canHaptic() ? HapticFeedback.heavyImpact() : Future.value();
Future<void> hapticMedium() =>
    _canHaptic() ? HapticFeedback.mediumImpact() : Future.value();
Future<void> hapticLight() =>
    _canHaptic() ? HapticFeedback.lightImpact() : Future.value();

// eof
