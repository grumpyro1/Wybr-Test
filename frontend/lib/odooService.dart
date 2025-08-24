import 'dart:convert';
import 'package:http/http.dart' as http;

/// Base constants for Odoo connection
const _odooUrl = 'https://cors-anywhere.herokuapp.com/https://jongsugbo-odoo-wybr-integrations.odoo.com/jsonrpc';
const _odooDb = 'jongsugbo-odoo-wybr-integrations-prod-22303786';
const _odooUid = 6;
const _odooPassword = 'roanmiles123';

/// 🔹 Core function to handle Odoo JSON-RPC calls
Future<dynamic> _callOdoo({
  required String model,
  required String method,
  required List<dynamic> args,
  Map<String, dynamic>? kwargs,
}) async {
  final body = jsonEncode({
    "jsonrpc": "2.0",
    "id": DateTime.now().millisecondsSinceEpoch, // unique request id
    "method": "call",
    "params": {
      "service": "object",
      "method": "execute_kw",
      "args": [
        _odooDb,
        _odooUid,
        _odooPassword,
        model,
        method,
        args,
        if (kwargs != null) kwargs,
      ]
    },
  });

  final response = await http.post(
    Uri.parse(_odooUrl),
    headers: {"Content-Type": "application/json"},
    body: body,
  );

  if (response.statusCode != 200) {
    throw Exception('❌ Odoo call failed: HTTP ${response.statusCode}');
  }

  final json = jsonDecode(response.body);
  if (json['error'] != null) {
    throw Exception('❌ Odoo error: ${json['error']}');
  }

  return json['result'];
}

/// 🔹 Search/Read helper
Future<List<dynamic>> searchRead({
  required String model,
  List<dynamic> domain = const [],
  List<String> fields = const [],
  int limit = 100,
}) async {
  return await _callOdoo(
    model: model,
    method: 'search_read',
    args: [domain],
    kwargs: {"fields": fields, "limit": limit},
  ) as List<dynamic>;
}

/// 🔹 Create stock.picking record
Future<int> createPicking(List<List<dynamic>> moveIds, String note) async {
  final pickingId = await _callOdoo(
    model: 'stock.picking',
    method: 'create',
    args: [
      {
        "partner_id": 7,
        "origin": false,
        "picking_type_id": 2,
        "location_dest_id": 5,
        "move_ids": moveIds,
        "note": note,
      }
    ],
  );
  return pickingId as int;
}

/// 🔹 Assign picking
Future<void> assignPicking(int pickingId) async {
  await _callOdoo(
    model: 'stock.picking',
    method: 'action_assign',
    args: [[pickingId]],
  );
}

/// 🔹 Validate picking
Future<void> validatePicking(int pickingId) async {
  await _callOdoo(
    model: 'stock.picking',
    method: 'button_validate',
    args: [[pickingId]],
  );
}

/// 🔹 Get picking name by ID
Future<String> getPickingName(int pickingId) async {
  final result = await _callOdoo(
    model: 'stock.picking',
    method: 'read',
    args: [
      [pickingId],
      ["name"]
    ],
  );

  if (result is List && result.isNotEmpty) {
    return result[0]["name"] as String;
  }
  throw Exception("Picking not found for id $pickingId");
}

/// 🔹 Create return picking (does NOT validate)
Future<int> createReturnPicking({
  required int originalPickingId,
  required List<Map<String, dynamic>> lines,
}) async {
  const receiptPickingTypeId = 1;

  // Fetch original picking name
  final originalPickingName = await getPickingName(originalPickingId);

  // Build move lines
  final moveLines = lines.map((line) {
    final productId = int.tryParse(line['product'].toString());
    final uomId = int.tryParse(line['uom'].toString());
    final qty = double.tryParse(line['qty'].toString());

    if (productId == null || uomId == null || qty == null) {
      throw Exception("Invalid line detected: $line");
    }

    return [
      0,
      0,
      {
        "product_id": productId,
        "product_uom_qty": qty,
        "product_uom": uomId,
        "name": "Return",
        "location_id": 5,
        "location_dest_id": 8,
      }
    ];
  }).toList();

  final payload = {
    "partner_id": 7,
    "picking_type_id": receiptPickingTypeId,
    "location_id": 5,
    "location_dest_id": 8,
    "origin": "Return of $originalPickingName",
    "move_ids": moveLines,
  };

  print("📦 Return Picking Payload: $payload");

  final pickingId = await _callOdoo(
    model: 'stock.picking',
    method: 'create',
    args: [payload],
  );

  return pickingId as int;
}
