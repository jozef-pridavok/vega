import "package:core_dart/core_dart.dart";

mixin StateMixin {
  final _logger = Logger();

  void verbose(MessageFunction message) => _logger.verbose(message);

  void debug(MessageFunction message) => _logger.debug(message);

  void info(String message) => _logger.info(message);

  void warning(String message) => _logger.warning(message);

  void error(String message) => _logger.error(message);

  void invalidState(state) => debug(() => errorUnexpectedStateEx(state.runtimeType.toString()).toString());

  T? expect<T>(state) {
    final expected = cast<T>(state);
    if (expected != null) return expected;
    debug(() => errorUnexpectedStateType(T, state.runtimeType).toString());
    return null;
  }

  (T1?, T2?) expectOr<T1, T2>(state) {
    final s1 = cast<T1>(state);
    final s2 = cast<T2>(state);
    if (s1 != null) return (s1, null);
    if (s2 != null) return (null, s2);
    debug(() => errorUnexpectedStateEx("${state.runtimeType} but expect $T1 or $T2.").toString());
    return (null, null);
  }

  //void setState(List<bool> conditions, Function() callback) {
  //  if (conditions.every((c) => c)) callback();
  //}

  bool next(state, List<Type> types, dynamic Function() callback) {
    final stateType = state.runtimeType;
    if (types.any((t) => stateType == t)) {
      return cast<bool>(callback()) ?? true;
    }
    final unexpected = types.firstWhere((t) => stateType != t, orElse: () => Null);
    debug(() => errorUnexpectedStateType(unexpected.runtimeType, state.runtimeType).toString());
    return false;
  }
}

abstract class FailedState {
  final CoreError error;
  FailedState(this.error);
}

// eof
