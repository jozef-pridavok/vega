import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../states/program_reward_patch.dart";
import "../../states/program_rewards.dart";
import "../../states/providers.dart";
import "../../strings.dart";
import "../../widgets/data_grid.dart";
import "../../widgets/state_error.dart";
import "../dialog.dart";
import "../program_rewards/popup_menu_items.dart";
import "../screen_app.dart";
import "screen_edit.dart";

class ProgramRewardsScreen extends VegaScreen {
  final Program program;
  const ProgramRewardsScreen(this.program, {super.key}) : super();

  @override
  createState() => _ProgramRewardsState();
}

class _ProgramRewardsState extends VegaScreenState<ProgramRewardsScreen> with SingleTickerProviderStateMixin {
  Program get _program => widget.program;

  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(initialIndex: 0, length: 1, vsync: this);
    Future.microtask(() => ref.read(rewardsLogic(_program).notifier).load());
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  void onGainedVisibility() {
    Future.microtask(() => ref.read(rewardsLogic(_program).notifier).load());
  }

  @override
  String? getTitle() => LangKeys.screenProgramsRewardsTitle.tr();

  @override
  List<Widget>? buildAppBarActions() {
    return [
      IconButton(
        icon: const VegaIcon(name: AtomIcons.add),
        onPressed: () {
          ref.read(rewardEditorLogic.notifier).create(_program);
          context.push(EditProgramReward());
        },
      ),
      const SizedBox(width: moleculeScreenPadding),
    ];
  }

  @override
  Widget buildBody(BuildContext context) {
    _listenToLogics(context);
    final state = ref.watch(rewardsLogic(_program));
    if (state is RewardsSucceed)
      return _GridWidget(_program);
    else if (state is RewardsFailed)
      return StateErrorWidget(
        rewardsLogic(_program),
        onReload: () => ref.read(rewardsLogic(_program).notifier).refresh(),
      );
    return const CenteredWaitIndicator();
  }

  void _listenToLogics(BuildContext context) {
    ref.listen<RewardPatchState>(rewardPatchLogic, (previous, next) {
      bool closeDialog = next is RewardPatchFailed;
      if ([RewardPatchPhase.blocked, RewardPatchPhase.unblocked].contains(next.phase)) {
        closeDialog = ref.read(rewardsLogic(_program).notifier).updated(next.reward);
      }
      if ([RewardPatchPhase.archived].contains(next.phase)) {
        closeDialog = ref.read(rewardsLogic(_program).notifier).removed(next.reward);
      }
      if (closeDialog) closeWaitDialog(context, ref);
      if (next is RewardPatchFailed) toastCoreError(next.error);
    });
    ref.listen(refreshLogic, (previous, next) {
      final key = ref.read(activeProgramsLogic.notifier).hasRefreshKey(next);
      if (key == null) return;
      ref.read(refreshLogic.notifier).clear(key);
      ref.read(activeProgramsLogic.notifier).load();
    });
  }
}

class _GridWidget extends ConsumerWidget {
  final Program program;

  const _GridWidget(this.program);

  static const _columnName = "name";
  static const _columnDescription = "description";
  static const _columnPoints = "points";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = ref.watch(layoutLogic).isMobile;
    final rewards = (ref.watch(rewardsLogic(program)) as RewardsSucceed).rewards;
    return Padding(
      padding: const EdgeInsets.all(moleculeScreenPadding),
      child: PullToRefresh(
        onRefresh: () => ref.read(rewardsLogic(program).notifier).refresh(),
        child: DataGrid<Reward>(
          rows: rewards,
          columns: [
            DataGridColumn(name: _columnName, label: LangKeys.columnName.tr()),
            if (!isMobile) DataGridColumn(name: _columnDescription, label: LangKeys.columnDescription.tr()),
            DataGridColumn(name: _columnPoints, label: LangKeys.columnPoints.tr()),
          ],
          onBuildCell: (column, program) => _buildCell(context, ref, column, program),
          onRowTapUp: (column, data, details) => _popupOperations(context, ref, data, details),
          onReorder: (oldIndex, newIndex) {
            if (oldIndex < newIndex) newIndex -= 1;
            ref.read(rewardsLogic(program).notifier).reorder(oldIndex, newIndex);
          },
        ),
      ),
    );
  }

  Widget _buildCell(BuildContext context, WidgetRef ref, String column, Reward reward) {
    final isBlocked = reward.blocked;
    final points = formatAmount(context.locale.languageCode, program.plural, reward.points, digits: program.digits);
    final columnMap = <String, ThemedText>{
      _columnName: reward.name.text.color(ref.scheme.content),
      _columnDescription: reward.description.text.maxLine(2).overflowEllipsis.color(ref.scheme.content),
      _columnPoints: points.text.color(ref.scheme.content),
    };
    final cell = columnMap[column] ?? "?".text.color(ref.scheme.content);
    return isBlocked ? cell.lineThrough : cell;
  }

  void _popupOperations(BuildContext context, WidgetRef ref, Reward reward, TapUpDetails details) => showVegaPopupMenu(
        context: context,
        ref: ref,
        details: details,
        title: reward.name,
        items: [
          RewardMenuItems.edit(context, ref, program, reward),
          RewardMenuItems.block(context, ref, reward),
          RewardMenuItems.archive(context, ref, reward),
        ],
      );
}

// eof
