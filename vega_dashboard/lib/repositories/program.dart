import "package:core_flutter/core_dart.dart";

enum ProgramRepositoryFilter {
  active,
  prepared,
  finished,
  archived,
}

abstract class ProgramRepository {
  Future<List<Program>> readAll({ProgramRepositoryFilter filter});
  Future<bool> create(Program program, {List<int>? image});
  Future<bool> update(Program program, {List<int>? image});

  Future<bool> start(Program program);
  Future<bool> finish(Program program);
  Future<bool> block(Program program);
  Future<bool> unblock(Program program);
  Future<bool> archive(Program program);

  Future<bool> reorder(List<Program> programs);
}

// eof
