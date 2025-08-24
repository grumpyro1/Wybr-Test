import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wybr/models/work_oder.dart';
import 'package:wybr/pages/materialListPage.dart';
import 'package:wybr/provider/wms_provider.dart';
import 'package:wybr/widgets/paginatedDataTableWidget.dart';

class MaterialIssuancePage extends ConsumerStatefulWidget {
  const MaterialIssuancePage({super.key});

  @override
  ConsumerState<MaterialIssuancePage> createState() => _MaterialIssuancePageState();
}

class _MaterialIssuancePageState extends ConsumerState<MaterialIssuancePage> {
  int currentPage = 0;
  final int rowsPerPage = 6;

  void handleAction(String action, WorkOrder workOrder) async {
    if (action == 'reserve') {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Materiallistpage(workOrder: workOrder),
        ),
      );
      if (result == true) {
        ref.invalidate(workOrdersProvider); // refresh list
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final workOrdersAsync = ref.watch(workOrdersProvider);

    return PaginatedTablePage(
      title: "Material Issuance",
      asyncData: workOrdersAsync,
      columns: const [
        DataColumn(label: Text("WO No.", style: TextStyle(fontSize: 13))),
        DataColumn(label: Text("Work Order Description", style: TextStyle(fontSize: 13))),
        DataColumn(label: Text("Location", style: TextStyle(fontSize: 13))),
        DataColumn(label: Text("Project", style: TextStyle(fontSize: 13))),
        DataColumn(label: Text("Planner", style: TextStyle(fontSize: 13))),
        DataColumn(label: Text("Action", style: TextStyle(fontSize: 13))),
      ],
      buildRows: (pageData, isNarrow) {
        return List<DataRow>.generate(pageData.length, (index) {
          final item = pageData[index] as WorkOrder;
          return DataRow(
            cells: [
              DataCell(Text(item.woNumber.toString(),style: TextStyle(fontSize: isNarrow ? 11 : 12))),
              DataCell(Text(item.description ?? "", style: TextStyle(fontSize: isNarrow ? 11 : 12))),
              DataCell(Text(item.location ?? "",style: TextStyle(fontSize: isNarrow ? 11 : 12))),
              DataCell(Text(item.projectName ?? "",style: TextStyle(fontSize: isNarrow ? 11 : 12))),
              DataCell(Text(item.planner ?? "",style: TextStyle(fontSize: isNarrow ? 11 : 12))),
              DataCell(
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 20),
                  onSelected: (value) => handleAction(value, item),
                  itemBuilder: (context) => const [
                    PopupMenuItem<String>(
                      value: 'reserve',
                      child: Text('Reserve for Issuance'),
                    ),
                  ],
                ),
              ),
            ],
          );
        });
      },
      currentPage: currentPage,
      rowsPerPage: rowsPerPage,
      onPrevious: () => setState(() => currentPage--),
      onNext: () => setState(() => currentPage++),
    );
  }
}
