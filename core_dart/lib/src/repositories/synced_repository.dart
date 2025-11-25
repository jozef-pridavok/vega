import "package:core_dart/core_dart.dart";

abstract class SyncedRemoteRepository<T> {
  Future<List<T>?> readAll({bool ignoreCache = false});
  Future<void> create(T entity);
  Future<void> update(T entity);
  Future<void> delete(T entity);
}

abstract class SyncedLocalRepository<T> {
  Future<List<T>?> readAll({bool includeDeleted = false});
  Future<void> synced(T entity);
  Future<void> create(T entity);
  Future<void> deleteAll();
}

/*
function sync()
{
  new_local_data = select all from local_data where is_from_server = false and is_active = true;
  insert new_local_data to remote_data;

  updated_local_data = select all from local_data where is_from_server = true and is_modified = true and is_active = true;
  update remote_data with updated_local_data;

  deleted_local_data = select all from local_data where is_from_server = true and is_active = false;
  delete deleted_local_data from remote_data;

  delete all local_data;
  remote_data = select all from remote_data;
  insert all remote_data to local_data by overriding attributes: is_from_server = true, is_modified = false, is_active = true;
}
*/

Future<void> sync(
  SyncedLocalRepository<SyncedDataModel> local,
  SyncedRemoteRepository<SyncedDataModel> remote, {
  bool debug = false,
}) async {
  try {
    final allLocal = await local.readAll(includeDeleted: true);
    final newLocal = allLocal?.where((x) => !x.syncIsRemote && x.syncIsActive) ?? [];
    await Future.wait(newLocal.map((x) => remote.create(x)));
    //
    final updatedLocal = allLocal?.where((x) => x.syncIsRemote && x.syncIsModified && x.syncIsActive) ?? [];
    await Future.wait(updatedLocal.map((x) => remote.update(x)));
    //
    final deletedLocal = allLocal?.where((x) => x.syncIsRemote && !x.syncIsActive) ?? [];
    await Future.wait(deletedLocal.map((x) => remote.delete(x)));
    //
    await local.deleteAll();
    final remoteAll = await remote.readAll(ignoreCache: true) ?? [];
    await Future.wait(remoteAll.map((x) => local.synced(x)));
    if (debug) {
      print("-- synced --");
      for (final x in remoteAll) print(x);
    }
  } on Exception catch (ex) {
    throw errorSynchronizationEx(ex: ex);
  } catch (e) {
    throw errorSynchronization;
  }
}

// eof
