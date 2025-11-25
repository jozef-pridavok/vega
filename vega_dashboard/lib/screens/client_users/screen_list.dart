import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../enums/translated_user_role.dart";
import "../../states/client_user_patch.dart";
import "../../states/client_users.dart";
import "../../states/providers.dart";
import "../../strings.dart";
import "../../widgets/button_refresh.dart";
import "../../widgets/data_grid.dart";
import "../../widgets/notifications.dart";
import "../../widgets/state_error.dart";
import "../dialog.dart";
import "../screen_app.dart";
import "popup_menu_items.dart";
import "screen_edit.dart";

class ClientUsersScreen extends VegaScreen {
  final Client client;

  const ClientUsersScreen(this.client, {super.showDrawer, super.key});

  @override
  createState() => _UsersState();
}

class _UsersState extends VegaScreenState<ClientUsersScreen> with SingleTickerProviderStateMixin {
  Client get _client => widget.client;
  String get _clientId => _client.clientId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(clientUsersLogic(_clientId).notifier).load());
  }

  @override
  String? getTitle() => LangKeys.screenClientUsersTitle.tr();

  @override
  List<Widget>? buildAppBarActions() {
    final clients = ref.watch(clientUsersLogic(_clientId));
    final isRefreshing = clients is ClientUsersRefreshing;
    return [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: moleculeScreenPadding / 2),
        child: NotificationsWidget(),
      ),
      const MoleculeItemHorizontalSpace(),
      IconButton(
        icon: const VegaIcon(name: AtomIcons.add),
        onPressed: () => context.push(
          EditClientUserScreen(
            client: _client,
            user: User(
              userId: uuid(),
              clientId: _clientId,
              roles: [UserRole.pos],
              userType: UserType.client,
            ),
            isNew: true,
          ),
        ),
      ),
      VegaRefreshButton(
        onPressed: () => ref.read(clientUsersLogic(_clientId).notifier).reload(),
        isRotating: isRefreshing,
      ),
      const SizedBox(width: moleculeScreenPadding),
    ];
  }

  @override
  Widget buildBody(BuildContext context) {
    final state = ref.watch(clientUsersLogic(_clientId));
    if (state is ClientUsersFailed)
      return StateErrorWidget(
        clientUsersLogic(_clientId),
        onReload: () => ref.read(clientUsersLogic(_clientId).notifier).reload(),
      );
    else if (state is SellerClientsSucceed)
      return _GridWidget(_client);
    else
      return const CenteredWaitIndicator();
  }
}

class _GridWidget extends ConsumerWidget {
  final Client client;
  const _GridWidget(this.client);

  String get _clientId => client.clientId;

  static const _columnName = "name";
  static const _columnLogin = "login";
  static const _columnCategories = LangKeys.categories;

  void _listenToPatchLogic(BuildContext context, WidgetRef ref) {
    ref.listen<ClientUserPatchState>(clientUserPatchLogic, (previous, next) {
      if (next is ClientUserPatched || next is ClientUserPatchFailed) {
        closeWaitDialog(context, ref);
        ref.read(clientUserPatchLogic.notifier).reset();
        ref.read(clientUsersLogic(_clientId).notifier).reload();
        if (next is ClientUserPatchFailed) toastCoreError(ref, next.error);
      }
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _listenToPatchLogic(context, ref);
    final succeed = ref.watch(clientUsersLogic(_clientId)) as SellerClientsSucceed;
    final users = succeed.users;
    return Padding(
      padding: const EdgeInsets.all(moleculeScreenPadding),
      child: PullToRefresh(
        onRefresh: () async => await ref.read(clientUsersLogic(_clientId).notifier).reload(),
        child: DataGrid<User>(
          rows: users,
          columns: [
            DataGridColumn(name: _columnLogin, label: LangKeys.columnLogin.tr()),
            DataGridColumn(name: _columnName, label: LangKeys.columnName.tr()),
            DataGridColumn(name: _columnCategories, label: LangKeys.columnRoles.tr()),
          ],
          onBuildCell: (column, user) => _buildCell(context, ref, column, user),
          onRowTapUp: (column, user, details) => _popupOperations(context, ref, user, details),
        ),
      ),
    );
  }

  Widget _buildCell(BuildContext context, WidgetRef ref, String column, User user) {
    final maxRoles = 3;
    final roles = user.roles;
    final headRoles = roles.map((role) => role.localizedName.toString()).take(maxRoles);
    final remainingRoles = roles.length - headRoles.length;

    final columnMap = <String?, ThemedText>{
      _columnLogin: user.login.text,
      _columnName: user.nick.text,
      _columnCategories: (headRoles.join(", ") + (remainingRoles > 0 ? " +$remainingRoles" : "")).text,
    };

    final cell = columnMap[column] ?? "?".text.color(ref.scheme.content);
    return user.blocked ? cell.lineThrough : cell;
  }

  void _popupOperations(BuildContext context, WidgetRef ref, User user, TapUpDetails details) async {
    // user.nick or user.login
    final userName = (user.nick?.isNotEmpty ?? true) ? user.nick : user.login;
    showVegaPopupMenu(
      context: context,
      ref: ref,
      details: details,
      title: userName ?? "",
      items: [
        ClientUsersMenuItems.edit(context, ref, user, client),
        if (kDebugMode) ClientUsersMenuItems.changePassword(context, ref, user, client),
        ClientUsersMenuItems.block(context, ref, user),
        ClientUsersMenuItems.archive(context, ref, user),
      ],
    );
  }
}

// eof
