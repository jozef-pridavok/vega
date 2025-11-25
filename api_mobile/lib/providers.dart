import "package:api_mobile/implementations/configuration_yaml.dart";
import "package:core_dart/core_api_server.dart";
import "package:riverpod/riverpod.dart";

final configurationProvider = FutureProvider.family<Configuration, String>((_, configFile) async {
  return YamlConfiguration.fromFile(configFile);
});

final logProvider = FutureProvider.family<LogBag, String>((ref, configFile) async {
  final config = await ref.watch(configurationProvider(configFile).future);
  LogBag().add(ConsoleLog(config: config));
  return LogBag();
});

// eof
