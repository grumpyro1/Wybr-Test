import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pagination.dart';

class PaginatedTablePage extends ConsumerWidget {
  final String title;
  final AsyncValue<List<dynamic>> asyncData;
  final List<DataColumn> columns;
  final List<DataRow> Function(List<dynamic> pageData, bool isNarrow) buildRows;
  final int currentPage;
  final int rowsPerPage;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final String emptyMessage;

  const PaginatedTablePage({
    super.key,
    required this.title,
    required this.asyncData,
    required this.columns,
    required this.buildRows,
    required this.currentPage,
    required this.rowsPerPage,
    required this.onPrevious,
    required this.onNext,
    this.emptyMessage = "No data found",
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: asyncData.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text("Error: $err")),
              data: (list) {
                if (list.isEmpty) {
                  return Center(child: Text(emptyMessage));
                }

                final paginatedData = list
                    .skip(currentPage * rowsPerPage)
                    .take(rowsPerPage)
                    .toList();

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 600;
                    return Scrollbar(
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints:
                              BoxConstraints(minWidth: constraints.maxWidth),
                          child: DataTable(
                            headingRowColor:
                                MaterialStateProperty.all(Colors.grey[300]),
                            columnSpacing: isNarrow ? 15 : 30,
                            dataRowMinHeight: 40,
                            dataRowMaxHeight: 50,
                            headingRowHeight: 45,
                            columns: columns,
                            rows: buildRows(paginatedData, isNarrow),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Pagination(
            currentPage: currentPage,
            totalItems: asyncData.value?.length ?? 0,
            rowsPerPage: rowsPerPage,
            onPrevious: onPrevious,
            onNext: onNext,
          ),
        ],
      ),
    );
  }
}
