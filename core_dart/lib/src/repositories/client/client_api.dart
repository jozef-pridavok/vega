import "../../../core_dart.dart";
import "../device/device.dart";
import "client.dart";

class ApiClientRepository extends ClientRepository with LoggerMixin {
  final DeviceRepository deviceRepository;

  ApiClientRepository({required this.deviceRepository});

  @override
  Future<void> create(Client client) => throw UnimplementedError();

  @override
  Future<Client?> read(String clientId, {bool ignoreCache = false}) async {
    final cacheKey = "09179040-e2ed-4f43-b471-b1b962cf8e4b";
    final cached = deviceRepository.getCacheKey(cacheKey);

    final res = await ApiClient().get("/v1/client/detail/$clientId", params: {
      if (!ignoreCache && cached != null) "cache": cached,
    });

    final json = await res.handleStatusCodeWithJson();
    if (json == null) return null;

    final client = json["client"] as JsonObject;
    final timestamp = cast<int>(json["cache"]);
    if (timestamp != null) deviceRepository.putCacheKey(cacheKey, timestamp);

    return Client.fromMap(client, Client.camel);
  }
}

// eof
