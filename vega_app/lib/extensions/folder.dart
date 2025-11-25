import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_extensions.dart";
import "package:core_flutter/core_theme.dart";
import "package:vega_app/strings.dart";

extension FolderLocalizations on Folder {
  String get localizedName {
    switch (type) {
      case FolderType.all:
        return LangKeys.folderAllCards.tr();
      case FolderType.favorites:
        return LangKeys.folderFavoriteCards.tr();
      default:
        return name;
    }
  }

  String get localizedType {
    switch (type) {
      case FolderType.all:
        return LangKeys.folderAllCards.tr();
      case FolderType.favorites:
        return LangKeys.folderFavoriteCards.tr();
      default:
        return LangKeys.folderTypeCommon.tr();
    }
  }

  String get localizedLayout => LangKeys.columns.plural(layout.code);

  String get icon {
    switch (type) {
      case FolderType.all:
        return AtomIcons.folder;
      case FolderType.favorites:
        return AtomIcons.favorite;
      default:
        return AtomIcons.folder;
    }
  }
}

// eof
