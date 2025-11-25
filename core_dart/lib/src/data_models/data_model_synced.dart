// https://yohanes.gultom.me/2019/12/19/offline-data-sync-design-patterns/

mixin SyncedDataModel {
  bool syncIsRemote = false; // remotely synced
  bool syncIsModified = false; // local modified
  bool syncIsActive = true; // local active / not deleted

  /// Entity has been created locally
  void syncCreated() {
    syncIsRemote = false;
  }

  /// Entity has been read from local source
  void syncReadFromRemote() {
    syncIsRemote = true;
  }

  /// Entity has been updated locally
  void syncUpdated() {
    syncIsModified = true;
  }

  /// Entity has been deleted locally
  void syncDeleted() {
    syncIsActive = false;
  }

  /// Entity has been synced with remote source
  void synced() {
    syncIsRemote = true;
    syncIsModified = false;
    syncIsActive = true;
  }
}


// eof
