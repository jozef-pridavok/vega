import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:vega_app/enums/client_category_icon.dart";

import "../../strings.dart";
import "../screen_app.dart";

typedef CategoryPickedCallback = void Function(ClientCategory category);
typedef CategoryDetailCallback = Future<int> Function(ClientCategory category);

class CategoriesScreen extends AppScreen {
  final CategoryPickedCallback onCategoryPicked;
  final CategoryDetailCallback? onCategoryDetail;

  const CategoriesScreen({required this.onCategoryPicked, this.onCategoryDetail, super.key});

  @override
  createState() => _CategoriesState();
}

class _CategoriesState extends AppScreenState<CategoriesScreen> {
  final Map<ClientCategory, int> categoriesDetail = {for (final category in ClientCategory.values) category: -1};

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) => VegaAppBar(title: LangKeys.screenCategories.tr());

  Future<void> _getDetailCategories() async {
    //int number = await widget.onCategoryDetail!(ClientCategory.supermarket);
    //setState(() => categoriesDetail[ClientCategory.supermarket] = number);
    //return;
    for (ClientCategory category in ClientCategory.values) {
      if (categoriesDetail[category] != -1) continue;
      int number = await widget.onCategoryDetail!(category);
      if (mounted) setState(() => categoriesDetail[category] = number);
    }
    //int count = categoriesDetail.values.where((number) => number == -1).length;
    //if (count > 1) await _getDetailCategories();
  }

  @override
  void initState() {
    super.initState();
    if (widget.onCategoryDetail != null) Future.microtask(() => _getDetailCategories());
  }

  @override
  void didUpdateWidget(covariant CategoriesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.onCategoryDetail != null) Future.microtask(() => _getDetailCategories());
  }

  @override
  Widget buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
      child: ListView(
        physics: vegaScrollPhysic,
        children: [
          const SizedBox(height: 16),
          MoleculeItemTitle(
            header: LangKeys.sectionCategories.tr(),
          ),
          ...ClientCategory.values.map((category) => MoleculeItemCategory(
                icon: category.icon,
                title: category.localizedName,
                value: (categoriesDetail[category] ?? -1) > -1 ? categoriesDetail[category].toString() : null,
                onAction: () => widget.onCategoryPicked(category),
              )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// eof
