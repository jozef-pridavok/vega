import "package:api_mobile/implementations/api_shelf2.dart";
import "package:api_mobile/implementations/configuration_yaml.dart";
import "package:core_dart/core_api_server2.dart";
import "package:riverpod/riverpod.dart";

// macos: lsof -t -i tcp:8080 | xargs kill

void main(List<String> arguments) async {
  final container = ProviderContainer();
  final configFile = arguments.isNotEmpty ? arguments.first : "config.yaml";
  final yamlConfig = await YamlConfig.fromFile(configFile);
  final config = MobileApiConfig(yamlConfig);
  final api = MobileApi(config);
  await api.serve();
  container.dispose();
}

// eof
