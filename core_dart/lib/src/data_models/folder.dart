import "package:core_dart/src/extensions/map.dart";

import "../enums/folder_layout.dart";
import "../enums/folder_type.dart";

enum FolderKeys {
  folderId,
  name,
  layout,
  type,
  userCardIds,
}

class Folder {
  static const idAll = "all";
  static const idFavorites = "favorites";

  final String folderId;
  final String name;
  final FolderLayout layout;
  final FolderType type;
  final List<String> userCardIds;

  Folder({
    required this.folderId,
    required this.name,
    required this.layout,
    required this.type,
    required this.userCardIds,
  });

  bool get isNew => folderId.isEmpty;

  Folder copyWith({
    String? folderId,
    String? name,
    FolderLayout? layout,
    FolderType? type,
    List<String>? userCardIds,
  }) =>
      Folder(
        folderId: folderId ?? this.folderId,
        name: name ?? this.name,
        layout: layout ?? this.layout,
        type: type ?? this.type,
        userCardIds: userCardIds ?? this.userCardIds,
      );

  static const camel = {
    FolderKeys.folderId: "folderId",
    FolderKeys.name: "name",
    FolderKeys.layout: "layout",
    FolderKeys.type: "type",
    FolderKeys.userCardIds: "userCards",
  };

  static const snake = {
    FolderKeys.folderId: "folder_id",
    FolderKeys.name: "name",
    FolderKeys.layout: "layout",
    FolderKeys.type: "type",
    FolderKeys.userCardIds: "user_cards",
  };

  factory Folder.createNew() => Folder(
        folderId: "",
        name: "",
        layout: FolderLayout.threeColumns,
        type: FolderType.common,
        userCardIds: [],
      );

  factory Folder.fromMap(Map<String, dynamic> map, Map<FolderKeys, String> mapper) => Folder(
        folderId: map[mapper[FolderKeys.folderId]] as String,
        name: map[mapper[FolderKeys.name]] as String,
        layout: FolderLayoutCode.fromCode(map[mapper[FolderKeys.layout]] as int),
        type: FolderTypeCode.fromCode(map[mapper[FolderKeys.type]] as int),
        userCardIds: (map[mapper[FolderKeys.userCardIds]] as List<dynamic>).cast<String>(),
      );

  Map<String, dynamic> toMap(Map<FolderKeys, String> mapper) => {
        mapper[FolderKeys.folderId]!: folderId,
        mapper[FolderKeys.name]!: name,
        mapper[FolderKeys.layout]!: layout.code,
        mapper[FolderKeys.type]!: type.code,
        mapper[FolderKeys.userCardIds]!: /*folderId == idAll ? [] :*/ userCardIds,
      };
}

enum FoldersKeys { selectedFolder, list }

class Folders {
  final String? selectedFolder;
  final List<Folder> list;

  const Folders({
    required this.selectedFolder,
    required this.list,
  });

  static const camel = {
    FoldersKeys.selectedFolder: "selectedFolder",
    FoldersKeys.list: "list",
  };

  static const snake = {
    FoldersKeys.selectedFolder: "selected_folder",
    FoldersKeys.list: "list",
  };

  //static Map<String, dynamic> _convertMapKeysToString(Map<dynamic, dynamic> map) {
  //  return map.map((key, value) => MapEntry<String, dynamic>(key.toString(), value));
  //}

  factory Folders.fromMap(Map<String, dynamic> map, Map<FoldersKeys, String> mapper) {
    // Note: folders are always saved in camel case (json) in the database
    final listMapper = Folder.camel;
    //mapper == Folders.camel ? Folder.camel : Folder.snake;
    final list = (map[mapper[FoldersKeys.list]] as List<dynamic>)
        //.map((e) => _convertMapKeysToString(e as Map<dynamic, dynamic>))
        .map((e) => (e as Map<dynamic, dynamic>).asStringMap)
        .map((e) => Folder.fromMap(e, listMapper));
    return Folders(
      selectedFolder: map[mapper[FoldersKeys.selectedFolder]] as String?,
      list: list.toList(),
    );
  }

  Map<String, dynamic> toMap(Map<FoldersKeys, String> mapper) {
    final listMapper = mapper == Folders.camel ? Folder.camel : Folder.snake;
    return <String, dynamic>{
      mapper[FoldersKeys.selectedFolder]!: selectedFolder,
      mapper[FoldersKeys.list]!: list.map((e) => e.toMap(listMapper)).toList(),
    };
  }

  static const Folders empty = Folders(selectedFolder: null, list: []);

  Folders copyWith({
    String? selectedFolder,
    List<Folder>? list,
  }) =>
      Folders(
        selectedFolder: selectedFolder ?? this.selectedFolder,
        list: list ?? this.list,
      );
}

// eof
