import "package:riverpod/riverpod.dart";

import "../../core_repositories.dart";

final deviceRepository = Provider<DeviceRepository>(
  (ref) => HiveDeviceRepository(),
);

final remoteUserRepository = Provider<UserRepository>(
  (ref) => ApiUserRepository(
    deviceRepository: ref.read(deviceRepository),
  ),
);

final localClientRepository = Provider<ClientRepository>(
  (ref) => HiveClientRepository(),
);

final remoteClientRepository = Provider<ClientRepository>(
  (ref) => ApiClientRepository(
    deviceRepository: ref.read(deviceRepository),
  ),
);




// eof
