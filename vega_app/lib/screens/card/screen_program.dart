import "package:collection/collection.dart";
import "package:core_flutter/core_app.dart";
import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../caches.dart";
import "../../states/program/program.dart";
import "../../states/providers.dart";
import "../../states/user/user_card.dart";
import "../../strings.dart";
import "../../widgets/status_error.dart";
import "../screen_app.dart";

class ProgramScreen extends AppScreen {
  final UserCard userCard;
  final ProgramOnUserCard program;
  const ProgramScreen(this.userCard, this.program, {super.key});

  @override
  createState() => _ProgramState();
}

class _ProgramState extends AppScreenState<ProgramScreen> {
  String get _userCardId => widget.userCard.userCardId;
  String get programId => widget.program.programId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(programLogic(programId).notifier).load());
  }

  @override
  bool onPushNotification(PushNotification message) {
    if (message["programId"] != programId) return false;
    final action = message.actionType;
    if (action == null || !action.isProgram) return super.onPushNotification(message);
    ref.read(userCardLogic(_userCardId).notifier).refreshOnBackground();
    return true;
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) => VegaAppBar(title: widget.program.name);

  @override
  Widget buildBody(BuildContext context) {
    final userCard = cast<UserCardLoaded>(ref.watch(userCardLogic(_userCardId)))?.userCard ?? widget.userCard;
    final program = userCard.programs?.firstWhereOrNull((e) => e.programId == programId) ?? widget.program;
    final state = ref.watch(programLogic(programId));
    if (state is ProgramSucceed)
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
        child: _ProgramWidget(userCard, program),
      );
    else if (state is ProgramFailed)
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
        child: StatusErrorWidget(
          programLogic(programId),
          onReload: () => ref.read(programLogic(programId).notifier).reload(),
        ),
      );
    else
      return const AlignedWaitIndicator();
  }
}

class _ProgramSummary {
  final UserCard userCard;
  final ProgramSucceed programSucceed;
  final ProgramOnUserCard programOnUserCard;
  late List<Reward>? reachedRewards;
  late DateTime? earliestRewardValidTo;

  String get programId => programOnUserCard.programId;
  Program get program => programSucceed.program;
  List<Reward>? get rewards => programSucceed.program.rewards;
  int get userPoints => programOnUserCard.userPoints;
  int get digits => programOnUserCard.digits;
  int get totalPoints => programSucceed.totalPoints;
  Plural get plural => programOnUserCard.plural;
  List<int> get stamps => programSucceed.stamps;

  String? get lastLocationName => programOnUserCard.lastLocationName;
  DateTime? get lastTransactionDate => programOnUserCard.lastTransactionDate;

  static Reward? _getRewardWithEarliestValidTo(List<Reward>? rewards) {
    rewards?.sort((a, b) {
      final aValidTo = a.validTo ?? IntDate.fromDate(DateTime(9999, 12, 31));
      final bValidTo = b.validTo ?? IntDate.fromDate(DateTime(9999, 12, 31));
      return aValidTo.value.compareTo(bValidTo.value);
    });
    return rewards?.firstOrNull;
  }

  _ProgramSummary(this.userCard, this.programSucceed, this.programOnUserCard) {
    reachedRewards = programSucceed.program.rewards?.where((e) => e.points <= programOnUserCard.userPoints).toList();
    earliestRewardValidTo = _getRewardWithEarliestValidTo(reachedRewards)?.validTo?.toDate().toLocal();
  }
}

class _ProgramWidget extends ConsumerWidget {
  final UserCard userCard;
  final ProgramOnUserCard programOnUserCard;
  String get programId => programOnUserCard.programId;

  const _ProgramWidget(this.userCard, this.programOnUserCard);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programSucceed = ref.watch(programLogic(programId)) as ProgramSucceed;
    final program = _ProgramSummary(userCard, programSucceed, programOnUserCard);
    final programType = program.program.type;
    final totalPoints = programSucceed.totalPoints;
    return PullToRefresh(
      onRefresh: () => ref.watch(programLogic(programId).notifier).refresh(),
      child: ListView(
        children: [
          if (programType == ProgramType.reach) ...[
            totalPoints <= 24 ? _StampsWidget(program) : _ProgressWidget(program),
            _RewardsWidget(userCard, programOnUserCard),
          ],
          if (programType == ProgramType.credit || programType == ProgramType.collect) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: moleculeScreenPadding),
              child: formatAmount(
                context.locale.languageCode,
                program.plural,
                program.userPoints,
                digits: program.digits,
              ).h3.alignCenter,
            ),
          ],
          if (programType == ProgramType.credit) ...[
            _CreditInfoWidget(program),
          ],
        ],
      ),
    );
  }
}

class _StampsWidget extends ConsumerWidget {
  final _ProgramSummary program;
  String get programId => program.programId;

  const _StampsWidget(this.program);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final validTo = formatDate(context.languageCode, program.earliestRewardValidTo);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: moleculeScreenPadding, horizontal: 4),
      child: MoleculeCardLoyaltyBig(
        title: formatAmount(context.locale.languageCode, program.plural, program.userPoints, digits: program.digits),
        label: validTo != null ? LangKeys.rewardsValidTo.tr(args: [validTo]) : LangKeys.rewardsValidToUntilProgram.tr(),
        actionText: LangKeys.reachedRewards.plural(program.reachedRewards!.length),
        child: GridView.count(
          crossAxisCount: 6,
          crossAxisSpacing: 22,
          mainAxisSpacing: moleculeScreenPadding,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            ...program.stamps.map((e) => _StampWidget(e, program.programOnUserCard, program.rewards!)),
          ],
        ),
      ),
    );
  }
}

class _ProgressWidget extends ConsumerWidget {
  final _ProgramSummary program;
  String get programId => program.programId;

  const _ProgressWidget(this.program);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalPoints = program.totalPoints;
    final userPoints = program.userPoints;
    final validTo = formatDate(context.languageCode, program.earliestRewardValidTo);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: moleculeScreenPadding, horizontal: 4),
      child: MoleculeCardLoyaltyBig(
        title: formatAmount(context.locale.languageCode, program.plural, userPoints, digits: program.digits),
        label: validTo != null ? LangKeys.rewardsValidTo.tr(args: [validTo]) : LangKeys.rewardsValidToUntilProgram.tr(),
        actionText: LangKeys.reachedRewards.plural(program.reachedRewards!.length),
        child: SizedBox(
          height: 24,
          child: Center(
            child: LinearProgressIndicator(
              backgroundColor: ref.scheme.paperBold,
              value: (userPoints / totalPoints),
            ),
          ),
        ),
      ),
    );
  }
}

class _CreditInfoWidget extends ConsumerWidget {
  final _ProgramSummary program;
  String get programId => program.programId;

  const _CreditInfoWidget(this.program);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastTransactionDate = formatDate(context.languageCode, program.lastTransactionDate);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: moleculeScreenPadding, horizontal: 4),
      child: MoleculeCardLoyaltyBig(
        title: LangKeys.lastCreditUsage.tr(), //program.program.name,
        showSeparator: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (program.lastLocationName != null) ...[
              Row(
                children: [
                  Expanded(
                      child: LangKeys.creditLocation.tr().text.color(ref.scheme.content).maxLine(2).overflowEllipsis),
                  const MoleculeItemHorizontalSpace(),
                  program.lastLocationName.text.color(ref.scheme.content50).maxLine(1).overflowEllipsis,
                ],
              ),
              const SizedBox(height: 16),
            ],
            if (lastTransactionDate != null) ...[
              Row(
                children: [
                  Expanded(child: LangKeys.creditDate.tr().text.color(ref.scheme.content).maxLine(3).overflowEllipsis),
                  const MoleculeItemHorizontalSpace(),
                  lastTransactionDate.text.color(ref.scheme.content50).maxLine(1).overflowEllipsis,
                ],
              ),
              const SizedBox(height: 16),
            ],
            program.program.description.label.color(ref.scheme.content),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _StampWidget extends ConsumerWidget {
  final ProgramOnUserCard program;
  String get programId => program.programId;
  final List<Reward> rewards;
  final int stamp;

  const _StampWidget(this.stamp, this.program, this.rewards);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchReward = rewards.where((e) => e.points == stamp).isNotEmpty;
    final reached = stamp <= program.userPoints;
    return CircleAvatar(
      backgroundColor: reached ? (matchReward ? ref.scheme.positive : ref.scheme.accent) : ref.scheme.paperBold,
      child: VegaIcon(
        name: matchReward ? "gift" : "heart",
        color: reached ? ref.scheme.light : ref.scheme.content20,
      ),
    );
  }
}

class _RewardsWidget extends ConsumerWidget {
  final UserCard userCard;
  final ProgramOnUserCard programOnUserCard;
  String get programId => programOnUserCard.programId;

  const _RewardsWidget(this.userCard, this.programOnUserCard);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programSucceed = ref.watch(programLogic(programId)) as ProgramSucceed;
    final program = programSucceed.program;
    return Column(
      children: [
        ...program.rewards!.map(
          (e) => _RewardWidget(userCard, e, programOnUserCard),
        ),
      ],
    );
  }
}

class _RewardWidget extends ConsumerWidget {
  final UserCard userCard;
  final Reward reward;
  final ProgramOnUserCard program;
  String get programId => program.programId;

  const _RewardWidget(this.userCard, this.reward, this.program);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reached = reward.points <= program.userPoints;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _showRewardDetail(context, ref, reached),
      child: MoleculeItemReward(
        icon: AtomIcons.gift,
        iconColor: reached ? ref.scheme.light : ref.scheme.content20,
        iconBackgroundColor: reached ? ref.scheme.positive : ref.scheme.paper,
        imageCache: Caches.rewardImage,
        imageUrl: reward.image,
        imageBh: reward.imageBh,
        title: reward.name,
        label: formatAmount(context.locale.languageCode, program.plural, reward.points, digits: program.digits),
      ),
    );
  }

  void _showRewardDetail(BuildContext context, WidgetRef ref, bool reached) {
    final rewardImage = reward.image;
    modalBottomSheet(
      context,
      FractionallySizedBox(
        heightFactor: 0.876,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const MoleculeItemSpace(),
            MoleculeItemTitle(header: (reached ? LangKeys.reachableRewardTitle : LangKeys.unreachableRewardTitle).tr()),
            const MoleculeItemSpace(),
            Expanded(
              child: ListView(
                physics: vegaScrollPhysic,
                children: [
                  if (rewardImage != null) ...[
                    AspectRatio(
                      aspectRatio: 1,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                        child: CachedImage(
                          url: rewardImage,
                          config: Caches.rewardImage,
                          blurHash: reward.imageBh,
                          errorBuilder: (context, error, stackTrace) => SvgAsset.logo(),
                        ),
                      ),
                    ),
                    const MoleculeItemSpace(),
                  ],
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: MoleculeCardLoyaltyBig(
                      title: reward.name,
                      showSeparator: true,
                      label: reward.description ?? "",
                      child: formatAmount(
                        context.locale.languageCode,
                        program.plural,
                        reward.points,
                        digits: program.digits,
                      ).text.color(reached ? ref.scheme.positive : ref.scheme.content).maxLine(3).overflowEllipsis,
                    ),
                  ),
                  const MoleculeItemSpace(),
                ],
              ),
            ),
            const MoleculeItemSpace(),
            MoleculePrimaryButton(
              onTap: reached
                  ? () {
                      context.pop();
                      Future.delayed(const Duration(milliseconds: 400), () => _showRewardRequest(context, ref));
                    }
                  : null,
              titleText: LangKeys.buttonRequestReward.tr(),
            ),
            const MoleculeItemSpace(),
          ],
        ),
      ),
    );
  }

  void _showRewardRequest(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.scheme.mode == ThemeMode.dark;
    final rewardId = reward.programRewardId;
    final userCardId = userCard.userCardId;
    final code = F().qrBuilder.generateReachRequestReward(userCardId, rewardId);
    final width = MediaQuery.of(context).size.width * 0.8;
    modalBottomSheet(
      context,
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const MoleculeItemSpace(),
          MoleculeItemTitle(header: LangKeys.unreachableRewardTitle.tr()),
          const MoleculeItemSpace(),
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(isDarkMode ? 8 : 0)),
              child: Container(
                color: isDarkMode ? Colors.white : Colors.transparent,
                child: Padding(
                  padding: EdgeInsets.all(isDarkMode ? moleculeScreenPadding : 0),
                  //child: Container(color: Colors.white, child: SvgPicture.string(svg)),
                  child: Container(
                    color: Colors.white,
                    child: CodeWidget(
                      type: CodeType.qr,
                      code: code,
                      width: width,
                      height: width,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const MoleculeItemSpace(),
          const MoleculeItemSpace(),
          LangKeys.redeemInstruction.tr().text.color(ref.scheme.content).alignCenter,
          const MoleculeItemSpace(),
        ],
      ),
    );
  }
}

// eof
