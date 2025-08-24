import 'dart:convert';
import 'package:http/http.dart' as http;

class WmsApiService {
  final String baseUrl = "https://wms-api.wybr.net";

  /// Fetch list of work orders
  Future<List<dynamic>> getWorkOrders({ // asks the server for a list of work orders
    required String woType,
    required String status,
    required String orgCode,
  }) async {
    final url = Uri.parse("$baseUrl/getworkorders?wo_type=$woType&status=$status&org_code=$orgCode",);

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData["result"] != null) {
        return jsonData["result"] as List;
      }
    }
    throw Exception("Failed to fetch work orders");
  }

  /// Fetch BOM materials for a given Work Order Number
  Future<Map<String, dynamic>> getBOMMaterials({
    required String orgCode,
    required int woNumber,
  }) async {
    final url = Uri.parse("$baseUrl/getbommaterials?org_code=$orgCode&wo_number=$woNumber");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData["result"] != null) {
        return jsonData["result"] as Map<String, dynamic>;
      }
    }
    throw Exception("Failed to fetch BOM materials");
  }

}

class ApiService {
  // static const String baseUrl = "http://127.0.0.1:5000/proxy";
  static const String baseUrl = "http://192.168.254.102:5000/proxy";

  // Fetch any endpoint from the proxy
  static Future<List<dynamic>> fetchData(String endpoint) async {
    final url = Uri.parse("$baseUrl/$endpoint");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // returns JSON list
    } else {
      throw Exception("Failed to load data from $endpoint");
    }
  }
}

