import "package:core_flutter/core_dart.dart" hide Color;
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../states/developer_translations.dart";
import "../../states/providers.dart";
import "../../strings.dart";
import "../../utils/debouncer.dart";
import "../../widgets/button_refresh.dart";
import "../../widgets/data_grid.dart";
import "../../widgets/molecule_picker.dart";
import "../../widgets/state_error.dart";
import "../screen_app.dart";

//typedef _AskToDiscardChanges = void Function(BuildContext context, WidgetRef ref,
//   {TranslationModule? module, TranslationScope? scope, String? language});

class TranslationsScreen extends VegaScreen {
  const TranslationsScreen({super.showDrawer, super.key});

  @override
  createState() => _TranslationsState();
}

class _TranslationsState extends VegaScreenState<TranslationsScreen> with SingleTickerProviderStateMixin {
  final _debouncer = Debouncer(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(translationsLogic.notifier).load());
  }

  @override
  String? getTitle() => "Translations";

  @override
  List<Widget>? buildAppBarActions() {
    final state = ref.watch(translationsLogic);
    final isRefreshing = state is TranslationLoading;
    final editing = cast<TranslationEditing>(state);
    final hasChanges = editing?.changes.isNotEmpty ?? false;
    return [
      Padding(
        padding: const EdgeInsets.all(moleculeScreenPadding / 2),
        child: MoleculeSecondaryButton(
          titleText: "Submit changes",
          color: hasChanges ? null : ref.scheme.content20,
          onTap: hasChanges ? () => ref.read(translationsLogic.notifier).submitChanges() : () {},
        ),
      ),
      VegaRefreshButton(
        onPressed: () => ref.read(translationsLogic.notifier).load(),
        isRotating: isRefreshing,
      ),
      VegaMenuButton(
        items: [
          PopupMenuItem(
            child: MoleculeItemBasic(
              title: "Discard changes",
              onAction: () => _askToDiscardChanges(context, ref),
            ),
          ),
        ],
      ),
      const SizedBox(width: moleculeScreenPadding),
    ];
  }

  void _askToDiscardChanges(
    BuildContext context,
    WidgetRef ref, {
    TranslationModule? module,
    TranslationScope? scope,
    String? language,
  }) =>
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: "You have unsaved changes".h3,
          content: "Do you want to discard the changes and reload the data from the database?".text,
          actions: [
            MoleculePrimaryButton(
              titleText: LangKeys.buttonCancel.tr(),
              onTap: () {
                context.pop();
                ref.read(translationsLogic.notifier).refresh();
              },
            ),
            MoleculePrimaryButton(
              titleText: "Discard changes and reload",
              onTap: () {
                context.pop();
                ref.read(translationsLogic.notifier).load(module: module, scope: scope, language: language);
              },
              color: ref.scheme.negative,
            ),
          ],
        ),
      );

  @override
  Widget buildBody(BuildContext context) {
    _listenToTranslationState(context);
    return Padding(
      padding: const EdgeInsets.all(moleculeScreenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Filters(debouncer: _debouncer),
          const MoleculeItemSpace(),
          Expanded(child: const _Translations()),
        ],
      ),
    );
  }

  void _listenToTranslationState(BuildContext context) {
    ref.listen<TranslationState>(translationsLogic, (previous, state) {
      if (state is TranslationLoadingFailed) {
        toastError("Failed to load translations: ${state.error}");
      } else if (state is TranslationSavingFailed) {
        toastError("Failed to save translations: ${state.error}");
      } else if (state is TranslationSaved) {
        toastInfo("Translations saved");
        ref.read(translationsLogic.notifier).load();
      }
    });
  }
}

class _Filters extends ConsumerWidget {
  final Debouncer debouncer;

  const _Filters({required this.debouncer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: const _ModuleFilter()),
        const MoleculeItemHorizontalSpace(),
        Flexible(child: const _ScopeFilter()),
        const MoleculeItemHorizontalSpace(),
        Flexible(child: const _LanguageFilter()),
        const MoleculeItemHorizontalSpace(),
        Flexible(child: _TextFilter(debouncer: debouncer)),
      ],
    );
  }
}

class _ModuleFilter extends ConsumerWidget {
  const _ModuleFilter();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(translationsLogic);
    return MoleculeSingleSelect(
      title: "Module",
      hint: "Select module",
      items: TranslationModule.values.toSelectItems(),
      selectedItem: state.filter.module.toSelectItem(),
      onChanged: (val) => ref.read(translationsLogic.notifier).load(module: val.toTranslationModule()),
    );
  }
}

class _ScopeFilter extends ConsumerWidget {
  const _ScopeFilter();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(translationsLogic);
    return MoleculeSingleSelect(
      title: "Scope",
      hint: "Select scope",
      items: TranslationScope.values.toSelectItems(),
      selectedItem: state.filter.scope.toSelectItem(),
      onChanged: (val) => ref.read(translationsLogic.notifier).load(scope: val.toTranslationScope()),
    );
  }
}

class _LanguageFilter extends ConsumerWidget {
  const _LanguageFilter();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(translationsLogic);
    return MoleculeSingleSelect(
      title: "Language",
      hint: "Select language",
      items: context.supportedLocales.toSelectItems(),
      selectedItem: Locale(state.filter.language).toSelectItem(),
      onChanged: (item) => ref.read(translationsLogic.notifier).load(language: item.value),
    );
  }
}

class _TextFilter extends ConsumerWidget {
  final Debouncer debouncer;

  const _TextFilter({required this.debouncer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(translationsLogic);
    return MoleculeInput(
      title: "Filter",
      hint: "Enter filter",
      initialValue: state.filter.term,
      enabled: state is! TranslationLoading,
      onChanged: (val) => debouncer.run(() => ref.read(translationsLogic.notifier).search(val)),
    );
  }
}

class _Translations extends ConsumerWidget {
  const _Translations();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(translationsLogic);
    if (state is TranslationLoading || state is TranslationSaving) {
      return const CenteredWaitIndicator();
    } else if (state is TranslationLoadingFailed) {
      return StateErrorWidget(
        translationsLogic,
        onReload: () => ref.read(translationsLogic.notifier).load(),
      );
    } else if (state is TranslationSavingFailed) {
      return StateErrorWidget(
        translationsLogic,
        onReload: () => ref.read(translationsLogic.notifier).submitChanges(),
      );
    } else if (state is TranslationEditing) {
      return _TranslationGrid(editing: state);
    } else {
      return const CenteredWaitIndicator();
    }
  }
}

class _TranslationGrid extends ConsumerWidget {
  final TranslationEditing editing;

  const _TranslationGrid({required this.editing});

  static const _columnKey = "key";
  static const _columnValue = "value";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DataGrid<Translation>(
      rows: editing.rows,
      columns: [
        DataGridColumn(name: _columnKey, label: "Key", width: 350),
        DataGridColumn(name: _columnValue, label: "Translation", width: double.nan),
      ],
      onBuildCell: (column, translation) => _buildCell(context, ref, column, editing, translation),
      onRowTapUp: (column, translation, details) => _popupOperations(context, ref, editing, translation, details),
    );
  }

  Widget _buildCell(
    BuildContext context,
    WidgetRef ref,
    String column,
    TranslationEditing editing,
    Translation translation,
  ) {
    Color color = ref.scheme.content;
    if (translation.isChanged) color = ref.scheme.primary;
    final cell = switch (column) {
      _columnKey => translation.displayKey.micro.color(color),
      _columnValue => editing.getValue(translation.displayKey).text.maxLine(2).overflowEllipsis.color(color),
      _ => "?".text.color(ref.scheme.content),
    };
    return translation.markedForDeletion ? cell.lineThrough : cell;
  }

  void _popupOperations(
      BuildContext context, WidgetRef ref, TranslationEditing editing, Translation translation, TapUpDetails details) {
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: "Edit translation".h3,
        content: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 400, maxWidth: 600),
          child: _EditTranslation(editing: editing, translation: translation),
        ),
        actions: [
          if (editing.filter.scope == TranslationScope.pending)
            MoleculePrimaryButton(
              titleText: translation.markedForDeletion ? "Revert deletion" : LangKeys.buttonDelete.tr(),
              color: ref.scheme.negative,
              onTap: () {
                ref.read(translationsLogic.notifier).delete(translation);
                context.pop(true);
              },
            ),
          MoleculeSecondaryButton(
            titleText: LangKeys.buttonCancel.tr(),
            onTap: () => context.pop(false),
          ),
          MoleculePrimaryButton(
            titleText: LangKeys.buttonConfirm.tr(),
            onTap: () {
              if (ref.read(translationsLogic.notifier).update(translation)) {
                context.pop(true);
                return;
              }
              toastError(ref, "New translation has different number of placeholders!");
            },
          ),
        ],
      ),
    );
  }
}

class _EditTranslation extends ConsumerWidget {
  final TranslationEditing editing;
  final Translation translation;
  late final TextEditingController _controller;

  _EditTranslation({required this.editing, required this.translation}) {
    _controller = TextEditingController(text: _getValue());
  }

  String _getValue() => editing.getValue(translation.displayKey);
  String _getInitialValue() => editing.getInitialValue(translation.displayKey);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        MoleculeInput(
          title: translation.displayKey,
          controller: _controller,
          maxLines: 10,
          autofocus: true,
          onChanged: (value) => ref.read(translationsLogic.notifier).keepValue(value),
        ),
        const SizedBox(height: moleculeItemSpace / 2),
        MoleculeLinkButton(
            titleText: "Revert",
            onTap: () {
              _controller.text = _getInitialValue();
              ref.read(translationsLogic.notifier).keepValue(_controller.text);
            }),
      ],
    );
  }
}

// eof
