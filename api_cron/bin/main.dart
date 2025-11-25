import "package:api_cron/implementations/api_shelf.dart";
import "package:api_cron/implementations/configuration_yaml.dart";
import "package:core_dart/core_api_server2.dart";
import "package:riverpod/riverpod.dart";

// macos: lsof -t -i tcp:80 | xargs kill

void main(List<String> arguments) async {
  final container = ProviderContainer();
  final configFile = arguments.isNotEmpty ? arguments.first : "config.yaml";
  final yamlConfig = await YamlConfig.fromFile(configFile);
  final config = CronApiConfig(yamlConfig);
  final api = CronApi(config);
  await api.serve();
  container.dispose();
}

// eof
