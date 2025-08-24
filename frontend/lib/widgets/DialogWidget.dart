// moves_return_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wybr/models/products.dart';
import 'package:wybr/models/stock_move.dart';
import 'package:wybr/odooService.dart';
import 'package:wybr/provider/odoo_provder.dart';
import 'package:wybr/models/reference_wo.dart';

/// Moves Dialog
class MovesDialog extends ConsumerWidget {
  final ReferenceWorkOrder item;
  const MovesDialog({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncMoves = ref.watch(moveDetailsProvider(item.moveIds));

    return AlertDialog(
      title: Text("Moves for ${item.name}"),
      content: SizedBox(
        width: double.maxFinite,
        child: asyncMoves.when(
          data: (moves) {
            if (moves.isEmpty) return const Text("No stock moves found.");
            return ListView.builder(
              shrinkWrap: true,
              itemCount: moves.length,
              itemBuilder: (context, index) {
                final move = moves[index];
                return ListTile(
                  title: Text(move.productName),
                  subtitle: Text(
                    "Qty: ${move.quantity} ${move.uomName}\n"
                    "From: ${move.locationName} → To: ${move.locationDestName}\n"
                    "State: ${move.state}",
                  ),
                );
              },
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 15),
                Text("Loading moves..."),
              ],
            ),
          ),
          error: (err, _) => Text("Error: $err"),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Close"),
        ),
      ],
    );
  }
}

/// Return Dialog
class ReturnDialog extends ConsumerStatefulWidget {
  final ReferenceWorkOrder item;
  const ReturnDialog({super.key, required this.item});

  @override
  ConsumerState<ReturnDialog> createState() => _ReturnDialogState();
}

class _ReturnDialogState extends ConsumerState<ReturnDialog> {
  final Map<int, double> returnQuantities = {};
  final List<Map<String, dynamic>> extraLines = [];
  final Map<int, TextEditingController> _controllers = {};

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submitReturn({bool fullReturn = false}) async {
    final moves = ref.read(moveDetailsProvider(widget.item.moveIds)).value ?? [];
    final lines = <Map<String, dynamic>>[];

    if (fullReturn) {
      for (final move in moves) {
        lines.add({
          "product": move.productId,
          "qty": move.quantity,
          "uom": move.uomId,
        });
      }
    } else {
      for (final move in moves) {
        final qty = returnQuantities[move.id] ??
            double.tryParse(_controllers[move.id]?.text ?? "0") ??
            0.0;
        if (qty > 0) {
          lines.add({
            "product": move.productId,
            "qty": qty,
            "uom": move.uomId,
          });
        }
      }

      for (var line in extraLines) {
        if (line['product'] != null && (line['qty'] ?? 0) > 0 && line['uom'] != null) {
          lines.add({
            "product": line['product'],
            "qty": line['qty'],
            "uom": line['uom'] ?? 1,
          });
        } else {
          debugPrint("⚠️ Skipping invalid extra line: $line");
        }
      }
    }

    if (lines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ No products selected for return.")),
      );
      return;
    }

    debugPrint("📦 Submitting return lines: $lines");

    try {
      final pickingId = await createReturnPicking(
        originalPickingId: widget.item.id,
        lines: lines,
      );

      // Optional: assign picking to stay in "assigned"
      await assignPicking(pickingId);

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Return Receipt $pickingId created (state: assigned)")),
      );
    } catch (e, stacktrace) {
      if (!mounted) return;
      debugPrint("❌ Return failed: $e");
      debugPrint("STACKTRACE: $stacktrace");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Return failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncMoves = ref.watch(moveDetailsProvider(widget.item.moveIds));
    final asyncProducts = ref.watch(productsProvider);

    return AlertDialog(
      title: const Text("Return"),
      content: SizedBox(
        width: 700,
        child: asyncMoves.when(
          data: (moves) {
            if (moves.isEmpty) return const Text("No products to return.");

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      // Original moves
                      ...moves.map((move) {
                        _controllers.putIfAbsent(
                          move.id,
                          () => TextEditingController(text: move.quantity.toString()),
                        );

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  move.productName,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(
                                width: 120,
                                child: TextField(
                                  controller: _controllers[move.id],
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    suffixText: move.uomName,
                                    border: const OutlineInputBorder(),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                  ),
                                  // --- inside original moves TextField ---
                                  onChanged: (val) {
                                    final parsed = val.trim().isEmpty ? 0.0 : double.tryParse(val) ?? 0.0;
                                    setState(() {
                                      returnQuantities[move.id] = parsed;
                                      // keep controller text synced
                                      if (val.trim().isEmpty) {
                                        _controllers[move.id]?.text = "0";
                                        _controllers[move.id]?.selection = TextSelection.fromPosition(
                                          TextPosition(offset: _controllers[move.id]!.text.length),
                                        );
                                      }
                                    });
                                  },

                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),

                      // Extra lines
                      ...extraLines.map((line) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Expanded(
                                child: asyncProducts.when(
                                  data: (products) {
                                    return Autocomplete<ProductModel>(
                                      displayStringForOption: (p) => p.name,
                                      optionsBuilder: (textEditingValue) {
                                        if (textEditingValue.text.isEmpty) {
                                          return const Iterable<ProductModel>.empty();
                                        }
                                        return products.where((p) =>
                                            p.name.toLowerCase().contains(textEditingValue.text.toLowerCase()) ||
                                            (p.defaultCode ?? '').toLowerCase().contains(textEditingValue.text.toLowerCase()));
                                      },
                                      onSelected: (selected) {
                                        setState(() {
                                          line['product'] = selected.id;
                                          line['uom'] = selected.uomId ?? 1;
                                          line['name'] = selected.name;
                                        });
                                      },
                                      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                                        if (line['name'] != null && controller.text.isEmpty) {
                                          controller.text = line['name'];
                                        }
                                        return TextField(
                                          controller: controller,
                                          focusNode: focusNode,
                                          decoration: const InputDecoration(
                                            hintText: "Search Product",
                                            border: OutlineInputBorder(),
                                            isDense: true,
                                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  loading: () => const LinearProgressIndicator(),
                                  error: (err, _) => Text("Error: $err"),
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 120,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    hintText: "0.00",
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                  onChanged: (val) => line['qty'] = double.tryParse(val) ?? 0.0,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      TextButton(
                        onPressed: () {
                          setState(() {
                            extraLines.add({"product": null, "uom": null, "qty": 0.0, "name": null});
                          });
                        },
                        child: const Align(
                          alignment: Alignment.centerLeft,
                          child: Text("+ Add a line"),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (err, _) => Text("Error: $err"),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: () => _submitReturn(fullReturn: false),
          child: const Text("Return"),
        ),
        ElevatedButton(
          onPressed: () => _submitReturn(fullReturn: true),
          child: const Text("Return All"),
        ),
      ],
    );
  }
}
