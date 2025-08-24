class ProductModel {
  final int id;
  final String name;
  final String? defaultCode;
  final double? listPrice;
  final int? uomId;
  final String? uomName;

  ProductModel({
    required this.id,
    required this.name,
    this.defaultCode,
    this.listPrice,
    this.uomId,
    this.uomName,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    String safeString(dynamic value) {
      if (value == null) return '';
      if (value is bool) return '';
      if (value is String) return value;
      return value.toString();
    }

    double? safeDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    // Handle uom_id (Many2one = [id, name])
    int? parsedUomId;
    String? parsedUomName;
    if (json['uom_id'] != null && json['uom_id'] is List && json['uom_id'].length >= 2) {
      parsedUomId = json['uom_id'][0] as int?;
      parsedUomName = json['uom_id'][1] as String?;
    }

    return ProductModel(
      id: json['id'] ?? 0,
      name: safeString(json['name']),
      defaultCode: safeString(json['default_code']).isEmpty ? null : safeString(json['default_code']),
      listPrice: safeDouble(json['list_price']),
      uomId: parsedUomId,
      uomName: parsedUomName,
    );
  }
}
