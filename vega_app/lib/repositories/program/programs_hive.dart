import "package:core_flutter/core_dart.dart";
import "package:hive/hive.dart";

import "programs.dart";

class HiveProgramsRepository extends ProgramsRepository {
  static const String _boxKey = "96668c2d-375c-4aa8-bf89-4c1ae8e830c6";

  static late Box<Program> _box;

  static Future<void> init() async {
    _box = await Hive.openBox(_boxKey);
  }

  static Future<void> reset() async {
    await Hive.deleteBoxFromDisk(_boxKey);
  }

  static void clear() => _box.clear();

  @override
  Future<Program?> read(String programId, {bool ignoreCache = false}) async => _box.get(programId);

  @override
  Future<void> create(Program program) async => _box.put(program.programId, program);

  @override
  Future<(String?, List<String>?)> applyTag(String tagId, {String? cardId, String? userCardId}) =>
      throw UnimplementedError();
}

// eof
