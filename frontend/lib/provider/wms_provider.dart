import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wybr/models/work_oder.dart';
import 'package:wybr/service.dart';
import '../models/bomm_material.dart';

// Service Provider
final wmsApiServiceProvider = Provider<WmsApiService>((ref) { // a way to use the WmsApiService
  return WmsApiService();
});

// Work Orders Provider (Auto Dispose) = autoDispose means if no one is listening to this data, Riverpod will automatically clean it up to save memory
final workOrdersProvider = FutureProvider.autoDispose<List<WorkOrder>>((ref) async { // fetches a list of work orders from the API
  final service = ref.watch(wmsApiServiceProvider);
  final data = await service.getWorkOrders( // etWorkOrders with fixed filters: work order type "FWO", status "New", and org code "V1E"
    woType: "FWO",
    status: "New",
    orgCode: "V1E",
  );
  return data.map((e) => WorkOrder.fromJson(e)).toList(); // converts each JSON item into a WorkOrder
});

// BOM Materials Provider (Auto Dispose, needs woNumber)
final bomMaterialsProvider = FutureProvider.family.autoDispose<List<BOMGroup>, int>((ref, woNumber) async { // etches BOM materials for a specific work order number (woNumber)
  final service = ref.watch(wmsApiServiceProvider);
  final data = await service.getBOMMaterials(
    orgCode: "V1E",
    woNumber: woNumber, 
  );

  final materials = data["materials"] as List<dynamic>;
  List<BOMGroup> groups = [];

  // if it has groups (cu_groups), it converts each group into a BOMGroup object and collects them into a list
  for (var material in materials) {
    if (material["cu_groups"] != null &&
        (material["cu_groups"] as List).isNotEmpty) {
      for (var group in material["cu_groups"]) {
        groups.add(BOMGroup.fromJson(group));
      }
    }
  }

  return groups;
});

/// 🔹 Provider for Beeceptor/Proxy API
final dataProvider = FutureProvider.family.autoDispose<List<dynamic>, String>((ref, endpoint) async {
  return await ApiService.fetchData(endpoint);
});

/// 🔹 Provider for Odoo Products
final odooProductsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  return await ApiService.fetchOdooProducts();
});
