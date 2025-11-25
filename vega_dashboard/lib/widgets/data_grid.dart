import "package:collection/collection.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

// TODO: check https://pub.dev/packages/flutter_expandable_table

typedef DataGridCellBuild = Widget Function(String column, dynamic data);
typedef DataGridRowTapUp = void Function(int column, dynamic data, TapUpDetails details);
typedef DataGridSort = int Function(dynamic a, dynamic b);

class DataGridColumn {
  final String name;
  final String label;

  /// ( = double.nan; max width)
  /// ( > 0; fixed width )
  /// ( < 0; flex width )
  /// ( = 0; auto width - header should be larger than content)
  final double width;
  final Alignment alignment;
  final DataGridSort? sort;

  const DataGridColumn({
    required this.name,
    required this.label,
    this.width = double.nan,
    this.alignment = Alignment.centerLeft,
    this.sort,
  });
}

class DataGrid<T> extends ConsumerStatefulWidget {
  final List<T> rows;
  final List<DataGridColumn> columns;

  final DataGridCellBuild onBuildCell;
  final DataGridRowTapUp? onRowTapUp;
  final ReorderCallback? onReorder;

  final double rowHeight;

  const DataGrid({
    required this.rows,
    required this.columns,
    required this.onBuildCell,
    this.onReorder,
    this.onRowTapUp,
    this.rowHeight = 65,
    super.key,
  });

  @override
  createState() => _DataGridState<T>();
}

//@override
//void initState() {
//  // find longest text in columns
//  super.initState();
//}

class _DataGridStateNew<T> extends ConsumerState<DataGrid> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: widget.columns
            .mapIndexed((index, column) {
              if (column.width.isNaN) return FlexColumnWidth();
              if (column.width == 0) return IntrinsicColumnWidth();
              //if (column.width < 0) return index.to(column.width.toInt().abs());
              return FixedColumnWidth(column.width);
            })
            .toList()
            .asMap(),
        children: [
          TableRow(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: ref.scheme.content10,
                  width: 0, //TODO: hairLine,
                ),
              ),
            ),
            children: widget.columns
                .map(
                  (column) => TableCell(
                    child: column.label.textBold,
                  ),
                )
                .toList(),
          ),
          ...widget.rows.mapIndexed((index, row) => _buildRow(context, index)).toList(),
        ],
      ),
    );
  }

  TableRow _buildRow(BuildContext context, int index) {
    return TableRow(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: ref.scheme.content10,
            width: 0, //TODO: hairLine,
          ),
        ),
      ),
      children: widget.columns
          .map(
            (column) => TableCell(
              child: widget.onBuildCell(column.name, widget.rows[index]),
            ),
          )
          .toList(),
    );
  }
}

class _DataGridState<T> extends ConsumerState<DataGrid> {
  @override
  Widget build(BuildContext context) {
    final onReorder = widget.onReorder;
    return Column(
      children: [
        _buildColumns(context),
        Expanded(
          child: onReorder != null
              ? ReorderableListView.builder(
                  itemBuilder: (context, index) => _buildReorderableRow(context, index),
                  itemCount: widget.rows.length,
                  onReorder: onReorder,
                  buildDefaultDragHandles: false,
                )
              : ListView.builder(
                  itemBuilder: (context, index) => _buildReorderableRow(context, index),
                  itemCount: widget.rows.length,
                ),
        ),
      ],
    );
  }

  Widget _buildColumns(BuildContext context) {
    return SizedBox(
      height: 40, //widget.rowHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: widget.columns.map((column) => _buildColumn(context, column)).toList(),
      ),
    );
  }

  Widget _buildReorderableRow(BuildContext context, int index) {
    return ReorderableDelayedDragStartListener(
      index: index,
      key: Key("row-$index"),
      child: MouseRegion(
        cursor: widget.onRowTapUp != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: _buildRow(context, index),
      ),
    );
  }

  //

  Widget _buildRow(BuildContext context, int index) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: (details) => widget.onRowTapUp?.call(index, widget.rows[index], details),
      child: SizedBox(
        height: widget.rowHeight,
        child: Row(
          children: widget.columns.map((column) => _buildCell(context, column, index)).toList(),
        ),
      ),
    );
  }

  Widget _buildColumn(BuildContext context, DataGridColumn column) {
    final text = Container(
      decoration: BoxDecoration(
        //color: Colors.amberAccent,
        border: Border(
          bottom: BorderSide(
            color: ref.scheme.content10,
            width: 0, //TODO: hairLine,
          ),
        ),
      ),
      alignment: column.alignment,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: column.label.textBold.overflowEllipsis.color(ref.scheme.content),
      ),
    );
    if (column.width.isNaN) return Expanded(child: text);
    if (column.width == 0) return Flexible(child: text, flex: 0);
    if (column.width < 0) return Flexible(flex: column.width.toInt().abs(), child: text);
    return SizedBox(width: column.width, child: text);
  }

  Widget _buildCell(BuildContext context, DataGridColumn column, int index) {
    final text = Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: ref.scheme.content10,
            width: 0, //TODO: hairLine,
          ),
        ),
      ),
      alignment: column.alignment,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: widget.onBuildCell(column.name, widget.rows[index]),
      ),
    );
    if (column.width.isNaN) return Expanded(child: text);
    if (column.width == 0) return Flexible(child: text, flex: 0);
    if (column.width < 0) return Flexible(flex: column.width.toInt().abs(), child: text);
    return SizedBox(width: column.width, child: text);
  }
}

// eof
