import "dart:io";

import "package:core_flutter/core_dart.dart";

import "program.dart";

extension _ProgramRepositoryFilterCode on ProgramRepositoryFilter {
  static final _codeMap = {
    ProgramRepositoryFilter.active: 1,
    ProgramRepositoryFilter.prepared: 2,
    ProgramRepositoryFilter.finished: 3,
    ProgramRepositoryFilter.archived: 4,
  };
  int get code => _codeMap[this]!;
}

class ApiProgramRepository with LoggerMixin implements ProgramRepository {
  @override
  Future<List<Program>> readAll({ProgramRepositoryFilter filter = ProgramRepositoryFilter.active}) async {
    final res = await ApiClient().get("/v1/dashboard/program/", params: {"filter": filter.code});
    final json = await res.handleStatusCodeWithJson();
    return (json?["programs"] as JsonArray?)?.map((e) => Program.fromMap(e, Convention.camel)).toList() ?? [];
  }

  @override
  Future<bool> create(Program program, {List<int>? image}) async {
    final path = "/v1/dashboard/program/${program.programId}";
    final api = ApiClient();

    final res = image != null
        ? await api.postMultipart(path, [image, program.toMap(Convention.camel)])
        : await api.post(path, data: program.toMap(Convention.camel));

    final json = await res.handleStatusCodeWithJson(HttpStatus.created);
    return (json?["affected"] as int?) == 1;
  }

  @override
  Future<bool> update(Program program, {List<int>? image}) async {
    final path = "/v1/dashboard/program/${program.programId}";
    final api = ApiClient();

    final res = image != null
        ? await api.putMultipart(path, [image, program.toMap(Convention.camel)])
        : await api.put(path, data: program.toMap(Convention.camel));

    final json = await res.handleStatusCodeWithJson(HttpStatus.accepted);
    return (json?["affected"] as int?) == 1;
  }

  @override
  Future<bool> reorder(List<Program> programs) async {
    final ApiResponse res = await ApiClient().put(
      "/v1/dashboard/program/reorder",
      data: {"reorder": programs.map((e) => e.programId).toList()},
    );
    final json = await res.handleStatusCodeWithJson(HttpStatus.accepted);
    return (json?["affected"] as int?) == programs.length;
  }

  Future<bool> _patch(Program program, Map<String, dynamic> data) async {
    final res = await ApiClient().patch("/v1/dashboard/program/${program.programId}", data: data);
    final json = await res.handleStatusCodeWithJson(HttpStatus.accepted);
    return (json?["affected"] as int?) == 1;
  }

  @override
  Future<bool> start(Program program) => _patch(program, {"start": true});

  @override
  Future<bool> finish(Program program) => _patch(program, {"finish": true});

  @override
  Future<bool> block(Program program) => _patch(program, {"blocked": true});

  @override
  Future<bool> unblock(Program program) => _patch(program, {"blocked": false});

  @override
  Future<bool> archive(Program program) => _patch(program, {"archived": true});
}

// eof
