enum StorageObject {
  user,
  client,
  card,
  program,
  coupon,
  reward,
  leaflet,
  productItem,
}

extension StorageObjectPath on StorageObject {
  static final _folderNameMap = {
    StorageObject.user: "user",
    StorageObject.client: "client",
    StorageObject.card: "card",
    StorageObject.program: "program",
    StorageObject.coupon: "coupon",
    StorageObject.reward: "reward",
    StorageObject.leaflet: "leaflet",
    StorageObject.productItem: "productItem",
  };

  String get folderName => _folderNameMap[this]!;
}


// eof
