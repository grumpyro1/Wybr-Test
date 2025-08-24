class ReferenceWorkOrder {
  final int id;
  final String name;
  final String partnerName;
  final String? note;
  final List<int> moveIds;

  ReferenceWorkOrder({
    required this.id,
    required this.name,
    required this.partnerName,
    this.note,
    required this.moveIds,
  });

  factory ReferenceWorkOrder.fromJson(Map<String, dynamic> json) {
    return ReferenceWorkOrder(
      id: json['id'] is int ? json['id'] : 0,
      name: json['name'] is String ? json['name'] : '',
      partnerName: (json['partner_id'] is List && json['partner_id'].length > 1)? json['partner_id'][1]: '',
      note: json['note'] is String ? json['note'] : null,
      moveIds: (json['move_ids'] is List)? List<int>.from(json['move_ids']): [],
    );
  }
}
