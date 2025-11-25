import "dart:convert";

import "stream_reader.dart";

const String suffix = "\r\n";

///
/// Base class for all RESP types.
///
abstract class RedisType<P> {
  final String prefix;
  final P payload;

  const RedisType._(this.prefix, this.payload);

  ///
  /// Serializes this type to RESP.
  ///
  List<int> serialize() {
    return utf8.encode("$prefix$payload$suffix");
  }

  @override
  String toString() {
    return utf8.decode(serialize());
  }

  ///
  /// The name of the concrete type.
  ///
  String get typeName;

  ///
  /// Calls one of the given handlers based on the
  /// concrete type. Returns [true] if a handler for
  /// the concrete type was provided, otherwise [false]
  /// is returned. If the handler throws an error while
  /// executing, the error is raised to the caller of
  /// this method.
  ///
  T handleAs<T>({
    T Function(RedisSimpleString)? simple,
    T Function(RedisBulkString)? bulk,
    T Function(RedisInteger)? integer,
    T Function(RedisArray)? array,
    T Function(RedisError)? error,
  }) {
    if (isSimpleString && simple != null) {
      return simple(toSimpleString());
    } else if (isBulkString && bulk != null) {
      return bulk(toBulkString());
    } else if (isInteger && integer != null) {
      return integer(toInteger());
    } else if (isArray && array != null) {
      return array(toArray());
    } else if (isError && error != null) {
      return error(toError());
    }
    throw ArgumentError("No handler provided for type $typeName!");
  }

  ///
  /// Converts this type to a simple string. Throws a
  /// [StateError] if this is not a simple string.
  ///
  RedisSimpleString toSimpleString() => throw StateError("${toString()} is not a simple string!");

  ///
  /// Converts this type to a bulk string. Throws a
  /// [StateError] if this is not a bulk string.
  ///
  RedisBulkString toBulkString() => throw StateError("${toString()} is not a bulk string!");

  ///
  /// Converts this type to an integer. Throws a
  /// [StateError] if this is not an integer.
  ///
  RedisInteger toInteger() => throw StateError("${toString()} is not an integer!");

  ///
  /// Converts this type to an array. Throws a
  /// [StateError] if this is not an array.
  ///
  RedisArray toArray() => throw StateError("${toString()} is not an array!");

  ///
  /// Converts this type to an error. Throws a
  /// [StateError] if this is not an error.
  ///
  RedisError toError() => throw StateError("${toString()} is not an error!");

  ///
  /// Return [true] if this type is a simple string.
  ///
  bool get isSimpleString => false;

  ///
  /// Return [true] if this type is a bulk string.
  ///
  bool get isBulkString => false;

  ///
  /// Return [true] if this type is an integer.
  ///
  bool get isInteger => false;

  ///
  /// Return [true] if this type is an array.
  ///
  bool get isArray => false;

  ///
  /// Return [true] if this type is an error.
  ///
  bool get isError => false;

  dynamic toDart() => throw UnimplementedError();
}

///
/// Implementation of a RESP simple string.
///
class RedisSimpleString extends RedisType<String> {
  const RedisSimpleString(String payload) : super._("+", payload);

  @override
  RedisSimpleString toSimpleString() => this;

  @override
  bool get isSimpleString => true;

  @override
  String get typeName => "simple string";

  @override
  dynamic toDart() => payload;
}

///
/// Implementation of a RESP bulk string.
///
class RedisBulkString extends RedisType<String?> {
  static final nullString = utf8.encode("\$-1$suffix");

  const RedisBulkString(String? payload) : super._("\$", payload);

  @override
  List<int> serialize() {
    final pl = payload;
    if (pl != null) {
      final length = utf8.encode(pl).length;
      return utf8.encode("$prefix$length$suffix$pl$suffix");
    }
    return nullString;
  }

  @override
  RedisBulkString toBulkString() => this;

  @override
  bool get isBulkString => true;

  @override
  String get typeName => "bulk string";

  @override
  dynamic toDart() => payload;
}

///
/// Implementation of a RESP integer.
///
class RedisInteger extends RedisType<int> {
  const RedisInteger(int payload) : super._(":", payload);

  @override
  RedisInteger toInteger() => this;

  @override
  bool get isInteger => true;

  @override
  String get typeName => "integer";

  @override
  dynamic toDart() => payload;
}

///
/// Implementation of a RESP array.
///
class RedisArray extends RedisType<List<RedisType>?> {
  // TODO: check
  static final nullArray = utf8.encode("*-1$suffix");

  const RedisArray(List<RedisType>? payload) : super._("*", payload);

  @override
  List<int> serialize() {
    final pl = payload;
    if (pl != null) {
      return [
        ...utf8.encode("$prefix${pl.length}$suffix"),
        ...pl.expand((element) => element.serialize()),
        ...utf8.encode(suffix),
      ];
    }
    return nullArray;
  }

  @override
  RedisArray toArray() => this;

  @override
  bool get isArray => true;

  @override
  String get typeName => "array";

  @override
  dynamic toDart() => payload?.map((e) => e.toDart()).toList();
}

///
/// Implementation of a RESP error.
///
class RedisError extends RedisType<String> {
  const RedisError(String payload) : super._("-", payload);

  @override
  RedisError toError() => this;

  @override
  bool get isError => true;

  @override
  String get typeName => "error";

  @override
  dynamic toDart() => payload;
}

Future<RedisType> deserializeRespType(RedisStreamReader streamReader) async {
  final typePrefix = await streamReader.takeOne();
  switch (typePrefix) {
    case 0x2b: // simple string
      final payload = utf8.decode(await streamReader.takeWhile((data) => data != 0x0d));
      await streamReader.takeCount(2);
      return RedisSimpleString(payload);
    case 0x2d: // error
      final payload = utf8.decode(await streamReader.takeWhile((data) => data != 0x0d));
      await streamReader.takeCount(2);
      return RedisError(payload);
    case 0x3a: // integer
      final payload = int.parse(utf8.decode(await streamReader.takeWhile((data) => data != 0x0d)));
      await streamReader.takeCount(2);
      return RedisInteger(payload);
    case 0x24: // bulk string
      final length = int.parse(utf8.decode(await streamReader.takeWhile((data) => data != 0x0d)));
      await streamReader.takeCount(2);
      if (length == -1) {
        return RedisBulkString(null);
      }
      final payload = utf8.decode(await streamReader.takeCount(length));
      await streamReader.takeCount(2);
      return RedisBulkString(payload);
    case 0x2a: // array
      final count = int.parse(utf8.decode(await streamReader.takeWhile((data) => data != 0x0d)));
      await streamReader.takeCount(2);
      if (count == -1) {
        return RedisArray(null);
      }
      final elements = <RedisType>[];
      for (var i = 0; i < count; i++) {
        elements.add(await deserializeRespType(streamReader));
      }
      return RedisArray(elements);
    default:
      throw StateError("unexpected character: $typePrefix");
  }
}
