import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wybr/provider/odoo_provder.dart';
import 'package:wybr/widgets/DialogWidget.dart';
import 'package:wybr/widgets/paginatedDataTableWidget.dart';

class Donepage extends ConsumerStatefulWidget {
  const Donepage({super.key});

  @override
  ConsumerState<Donepage> createState() => _DonepageState();
}

class _DonepageState extends ConsumerState<Donepage> {
  int currentPage = 0;
  final int rowsPerPage = 6;

  TextStyle tableTextStyle(bool isNarrow) => TextStyle(fontSize: isNarrow ? 11 : 12);

  @override
  Widget build(BuildContext context) {
    final donePickings = ref.watch(outgoingPickingsProvider("done"));

    return PaginatedTablePage(
      title: "Completed Outgoing Deliveries",
      asyncData: donePickings,
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
                      case 'view':
                        showDialog(
                          context: context,
                          builder: (_) => MovesDialog(item: item),
                        );
                        break;
                      case 'Return':
                        showDialog(
                          context: context,
                          builder: (_) => ReturnDialog(item: item),
                        );
                        break;
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'view', child: Text('View Details')),
                    PopupMenuItem(value: 'Return', child: Text('Return')),
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
