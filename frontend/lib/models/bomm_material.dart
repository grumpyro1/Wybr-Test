// models/bom_material.dart
class BOMMaterial {
  final int itemCode;
  final String description;
  final int quantity;
  final double totalCost;
  final String uom;
  final int? externalId;

  BOMMaterial({
    required this.itemCode,
    required this.description,
    required this.quantity,
    required this.totalCost,
    required this.uom,
    this.externalId,
  });

  factory BOMMaterial.fromJson(Map<String, dynamic> json) {
    return BOMMaterial(
      itemCode: json["item_code"],
      description: json["description"] ?? "",
      quantity: json["quantity"] ?? 0,
      totalCost: (json["total_cost"] ?? 0).toDouble(),
      uom: json["uom"] ?? "",
      externalId: json["external_id"] != null ? (json["external_id"] as int) : null,
    );
  }
}

class BOMGroup {
  final String title;
  final List<BOMMaterial> items;

  BOMGroup({
    required this.title,
    required this.items,
  });

  factory BOMGroup.fromJson(Map<String, dynamic> json) {
    return BOMGroup(
      title: json["cu_title"] ?? "",
      items: (json["items"] as List<dynamic>).map((e) => BOMMaterial.fromJson(e)).toList(),
    );
  }
}
