// lib/models/stock_move.dart
class StockMove {
  final int id;
  final String name;
  final int productId;
  final String productName;
  final double quantity;
  final int uomId;
  final String uomName;
  final int locationId;
  final String locationName;
  final int locationDestId;
  final String locationDestName;
  final String state;

  StockMove({
    required this.id,
    required this.name,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.uomId,
    required this.uomName,
    required this.locationId,
    required this.locationName,
    required this.locationDestId,
    required this.locationDestName,
    required this.state,
  });

  factory StockMove.fromJson(Map<String, dynamic> json) {
    return StockMove(
      id: json['id'] as int,
      name: json['name'] as String,
      productId: json['product_id'][0] as int,
      productName: json['product_id'][1] as String,
      quantity: (json['product_uom_qty'] as num).toDouble(),
      uomId: json['product_uom'][0] as int,
      uomName: json['product_uom'][1] as String,
      locationId: json['location_id'][0] as int,
      locationName: json['location_id'][1] as String,
      locationDestId: json['location_dest_id'][0] as int,
      locationDestName: json['location_dest_id'][1] as String,
      state: json['state'] as String,
    );
  }
}
