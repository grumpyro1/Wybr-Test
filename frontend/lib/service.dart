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
  // Replace with your LAN IP of Flask backend
  static const String baseUrl = "http://192.168.254.102:5000";

  // 🔹 Fetch from proxy (Beeceptor / any external API)
  static Future<List<dynamic>> fetchData(String endpoint) async {
    final url = Uri.parse("$baseUrl/proxy/$endpoint");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load data from $endpoint");
    }
  }

  // 🔹 Fetch products from Odoo via Flask
  static Future<List<dynamic>> fetchOdooProducts() async {
    final url = Uri.parse("$baseUrl/odoo/products");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> result = jsonDecode(response.body);

      // Odoo JSON-RPC response format: {"jsonrpc": "2.0", "id": 3, "result": [...]}
      if (result.containsKey("result")) {
        return result["result"]; // this is the list of products
      } else if (result.containsKey("error")) {
        throw Exception("Odoo Error: ${result["error"]}");
      } else {
        throw Exception("Unexpected Odoo response format");
      }
    } else {
      throw Exception("Failed to fetch Odoo products");
    }
  }

  // 🔹 Add new product to Odoo
  static Future<int> addOdooProduct(Map<String, dynamic> productData) async {
    final url = Uri.parse("$baseUrl/odoo/add_product");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(productData),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> result = jsonDecode(response.body);
      if (result.containsKey("result")) {
        return result["result"]; // Odoo returns the new product ID
      } else {
        throw Exception("Odoo Error: ${result["error"]}");
      }
    } else {
      throw Exception("Failed to add product: ${response.body}");
    }
  }

}