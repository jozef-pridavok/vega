import "package:hive/hive.dart";

import "../../../core_dart.dart";
import "../device/device.dart";
import "client.dart";

class HiveClientRepository extends ClientRepository with LoggerMixin {
  static const String _boxKey = "cccdf2f8-0913-4f2b-9bcc-b99ef369f94c";

  final DeviceRepository? deviceRepository;

  HiveClientRepository({this.deviceRepository});

  static late Box<Client> _box;

  static Future<void> init() async {
    _box = await Hive.openBox(_boxKey);
  }

  static Future<void> reset() async {
    await Hive.deleteBoxFromDisk(_boxKey);
  }

  static void clear() => _box.clear();

  @override
  Future<void> create(Client client) async => _box.put(client.clientId, client);

  @override
  Future<Client?> read(String clientId, {bool ignoreCache = false}) async => _box.get(clientId);

  //@override
  //Future<List<Client>?> readAll({Country? country}) async => _box.values.toList();
}

// eof
