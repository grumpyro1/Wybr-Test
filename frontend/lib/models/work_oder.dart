// models/work_order.dart
class WorkOrder {
  final int woNumber;
  final String? description;
  final String? location;
  final String? projectName;
  final String? planner;
  final String? plannerCode;
  final String? priorityLevel;
  final String? status;
  final String? type;

  WorkOrder({
    required this.woNumber,
    this.description,
    this.location,
    this.projectName,
    this.planner,
    this.plannerCode,
    this.priorityLevel,
    this.status,
    this.type,
  });

  factory WorkOrder.fromJson(Map<String, dynamic> json) {
    return WorkOrder(
      woNumber: json["wo_number"],
      description: json["wo_description"],
      location: json["wo_location"],
      projectName: json["project_name"],
      planner: json["wo_planner"],
      plannerCode: json["wo_planner_code"],
      priorityLevel: json["wo_priority_level"],
      status: json["wo_status"],
      type: json["wo_type"],
    );
  }
}
