import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wybr/provider/odoo_provder.dart';
import 'package:wybr/widgets/DialogWidget.dart';
import 'package:wybr/widgets/paginatedDataTableWidget.dart';

class Referencewopage extends ConsumerStatefulWidget {
  const Referencewopage({super.key});

  @override
  ConsumerState<Referencewopage> createState() => _ReferencewopageState();
}

class _ReferencewopageState extends ConsumerState<Referencewopage> {
  int currentPage = 0;
  final int rowsPerPage = 6;

  TextStyle tableTextStyle(bool isNarrow) => TextStyle(fontSize: isNarrow ? 11 : 12);



  @override
  Widget build(BuildContext context) {
    final assignedPickings = ref.watch(outgoingPickingsProvider("assigned"));
    return PaginatedTablePage(
      title: "Reserved Outgoing Deliveries",
      asyncData: assignedPickings,
      columns: const [
        DataColumn(label: Text("ID", style: TextStyle(fontSize: 13))),
        DataColumn(label: Text("Name", style: TextStyle(fontSize: 13))),
        DataColumn(label: Text("Note", style: TextStyle(fontSize: 13))),
        DataColumn(label: Text("Partner", style: TextStyle(fontSize: 13))),
        DataColumn(label: Text("Action", style: TextStyle(fontSize: 13))),
      ],
      buildRows: (pageData, isNarrow) {
        return pageData.map<DataRow>((item) {
          return DataRow(
            cells: [
              DataCell(Text(item.id.toString(), style: tableTextStyle(isNarrow))),
              DataCell(Text(item.name, style: tableTextStyle(isNarrow))),
              DataCell(Text(item.note ?? "", style: tableTextStyle(isNarrow))),
              DataCell(Text(item.partnerName ?? "", style: tableTextStyle(isNarrow))),
              DataCell(
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 20),
                  onSelected: (value) {
                    switch (value) {
                      case 'view':showDialog(
                          context: context,
                          builder: (_) => MovesDialog(item: item),
                        );
                        break;
                      case 'validate':
                        ref.read(validatePickingProvider(item.id).future).then((_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Picking ${item.name} validated successfully")),
                          );
                          ref.invalidate(outgoingPickingsProvider("assigned"));

                        }).catchError((e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Validation failed: $e")),
                          );
                        });
                        break;
                    }
                  },

                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'view', child: Text('View Details')),
                    PopupMenuItem(value: 'validate', child: Text('Validate')),
                  ],
                ),
              ),
            ],
          );
        }).toList();
      },
      currentPage: currentPage,
      rowsPerPage: rowsPerPage,
      onPrevious: () => setState(() => currentPage--),
      onNext: () => setState(() => currentPage++),
    );
  }
}
