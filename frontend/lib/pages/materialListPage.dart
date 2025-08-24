import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:wybr/models/bomm_material.dart';
import 'package:wybr/models/work_oder.dart';
import 'package:wybr/odooService.dart';
import '../provider/wms_provider.dart';

class Materiallistpage extends ConsumerStatefulWidget {
  final WorkOrder workOrder;
  const Materiallistpage({super.key, required this.workOrder});

  @override
  ConsumerState<Materiallistpage> createState() => _MateriallistpageState();
}

class _MateriallistpageState extends ConsumerState<Materiallistpage> {
  bool _isLoading = false; // to disable button while loading

  void showMaterialsDialog() {
    final bomAsync = ref.read(bomMaterialsProvider(widget.workOrder.woNumber));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "${widget.workOrder.description} - List of Materials",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: bomAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Text("Error: $err"),
              data: (groups) {
                return ListView(
                  shrinkWrap: true,
                  children: groups.expand<Widget>((group) {
                    return [
                      ...group.items.map((material) {
                        return ListTile(
                          title: Text(material.description),
                          subtitle: Text("Qty: ${material.quantity} ${material.uom}"),
                        );
                      }).toList(),
                    ];
                  }).toList(),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  Future<void> markAsReserve(List<BOMGroup> groups) async {
    setState(() => _isLoading = true);
    try {
      List<List<dynamic>> moveIds = [];

      for (var group in groups) {
        for (var material in group.items) {
          if (material.externalId != null) {
            moveIds.add([
              0,
              0,
              {
                "name": "Move for product ${material.externalId}",
                "product_id": material.externalId,
                "product_uom_qty": material.quantity, // from BOM material
                "product_uom": 1,
                "location_id": 8,
                "location_dest_id": 5,
              }
            ]);
          }
        }
      }

      // Create picking
      final pickingId = await createPicking(moveIds, widget.workOrder.description ?? "");

      // Immediately mark as ready (assign)
      await assignPicking(pickingId);

      if (mounted) Navigator.pop(context); // Close loading dialog
      _showMessage("✅ Reservation created & marked as Ready! Picking ID: $pickingId");
    } catch (e) {
      if (mounted) Navigator.pop(context); // Close loading dialog
      _showMessage("❌ Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bomAsync = ref.watch(bomMaterialsProvider(widget.workOrder.woNumber));

    return Scaffold(
      appBar: AppBar(title: Text("Design & Cost Estimate for Work Order ${widget.workOrder.woNumber}")),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: "Materials"),
                Tab(text: "Bill of Quantities"),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // ------------------ Materials Tab ------------------
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                            color: Colors.lightBlue.shade100,
                            child: Center(child: Text('Available Work Packages', style: Theme.of(context).textTheme.titleMedium)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Selected Work Packages", style: Theme.of(context).textTheme.titleMedium),
                                      const SizedBox(height: 8),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Card(
                                          child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Row(
                                              children: [
                                                Expanded(child: Text(widget.workOrder.description.toString(), overflow: TextOverflow.ellipsis)),
                                                IconButton(
                                                  icon: const Icon(Icons.menu),
                                                  color: Colors.green.shade700,
                                                  tooltip: 'Project Options',
                                                  onPressed: showMaterialsDialog,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: Container(
                                  color: Colors.orange.shade100,
                                  child: Center(
                                    child: Text("Selected Custom Resources", style: Theme.of(context).textTheme.titleMedium),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ------------------ Bill of Quantities Tab ------------------
                  bomAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Center(child: Text("Error: $err")),
                    data: (groups) {
                      return Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              itemCount: groups.length,
                              itemBuilder: (context, index) {
                                final group = groups[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                  child: ExpansionTile(
                                    title: Text(group.title),
                                    children: group.items.map((material) {
                                      return ListTile(
                                        title: Text(material.description),
                                        subtitle: Text("Qty: ${material.quantity} ${material.uom} || External ID: ${material.externalId ?? 'N/A'}"),
                                        trailing: Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text("Unit: ${material.totalCost}"),
                                            Text("Total: ${material.totalCost}"),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: _isLoading || groups.isEmpty ? null : () => markAsReserve(groups),
                                child: _isLoading
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : const Text('Confirm', style: TextStyle(color: Colors.black)),
                              ),
                            ),
                          )
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
