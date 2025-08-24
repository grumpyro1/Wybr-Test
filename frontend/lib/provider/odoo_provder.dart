import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wybr/models/stock_move.dart';
import 'package:wybr/odooService.dart';
import '../models/products.dart';
import '../models/reference_wo.dart';

/// 🔹 Products Provider
final productsProvider = FutureProvider.autoDispose<List<ProductModel>>((ref) async {
  final results = await searchRead(
    model: 'product.product',
    fields: ["id", "name", "default_code", "list_price"],
    limit: 100,
  );
  return results.map((json) => ProductModel.fromJson(json)).toList();
});

/// 🔹 Reserved Outgoing Pickings Provider
final outgoingPickingsProvider = FutureProvider.family
    .autoDispose<List<ReferenceWorkOrder>, String>((ref, status) async {
  final results = await searchRead(
    model: 'stock.picking',
    domain: [
      ["picking_type_code", "=", "outgoing"],
      ["state", "=", status], // dynamic status
    ],
    fields: [
      "id",
      "name",
      "partner_id",
      "scheduled_date",
      "state",
      "origin",
      "note",
      "move_ids",
    ],
    limit: 100,
  );
  return results.map((json) => ReferenceWorkOrder.fromJson(json)).toList();
});

/// 🔹 Move Details Provider
final moveDetailsProvider = FutureProvider.family<List<StockMove>, List<int>>((ref, moveIds) async {
  if (moveIds.isEmpty) return [];

  final results = await searchRead(
    model: 'stock.move',
    domain: [
      ['id', 'in', moveIds],
    ],
    fields: [
      'id',
      'name',
      'product_id',
      'product_uom_qty',
      'product_uom',
      'location_id',
      'location_dest_id',
      'state',
    ],
  );
  return results.map((json) => StockMove.fromJson(json)).toList();
});

/// 🔹 Validate Picking Provider
final validatePickingProvider = FutureProvider.family<void, int>((ref, pickingId) async {
  await validatePicking(pickingId);
});
