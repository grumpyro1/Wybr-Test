import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wybr/provider/odoo_provder.dart';
import 'package:wybr/widgets/paginatedDataTableWidget.dart';

class WorkordersPage extends ConsumerStatefulWidget {
  const WorkordersPage({super.key});

  @override
  ConsumerState<WorkordersPage> createState() => _WorkordersPageState();
}

class _WorkordersPageState extends ConsumerState<WorkordersPage> {
  int currentPage = 0;
  final int rowsPerPage = 6;

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);

    return PaginatedTablePage(
      title: "Odoo Products",
      asyncData: productsAsync,
      columns: [
        const DataColumn(label: Text("Product Name", style: TextStyle(fontSize: 13))),
        const DataColumn(label: Text("SKU", style: TextStyle(fontSize: 13))),
        const DataColumn(label: Text("Price", style: TextStyle(fontSize: 13))),
      ],
      buildRows: (pageData, isNarrow) {
        return List<DataRow>.generate(pageData.length, (index) {
          final product = pageData[index];
          return DataRow(cells: [
            DataCell(Text(product.name, style: TextStyle(fontSize: isNarrow ? 11 : 12))),
            DataCell(Text(product.defaultCode ?? "-", style: TextStyle(fontSize: isNarrow ? 11 : 12))),
            DataCell(Text( product.listPrice != null ? product.listPrice!.toStringAsFixed(2) : "-",style: TextStyle(fontSize: isNarrow ? 11 : 12))),
          ]);
        });
      },
      currentPage: currentPage,
      rowsPerPage: rowsPerPage,
      onPrevious: () {
        if (currentPage > 0) setState(() => currentPage--);
      },
      onNext: () {
        final maxPage = ((productsAsync.value?.length ?? 0) / rowsPerPage).ceil() - 1;
        if (currentPage < maxPage) setState(() => currentPage++);
      },
    );
  }
}
