import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:green_kitchen_app/apis/endpoint.dart';
import 'package:green_kitchen_app/models/store.dart';
import 'package:green_kitchen_app/services/service.dart';
import 'package:green_kitchen_app/utils/api_error.dart';

class StoreService {
  static Future<List<StoreModel>> getStores() async {
    final endpoints = ApiEndpoints();
    try {
      // Use central ApiService to include Authorization header if available
      final api = ApiService();
      final dynamic jsonData = await api.get(endpoints.stores, includeAuth: true);

      List<dynamic> items;
      if (jsonData is List) {
        items = jsonData;
      } else if (jsonData is Map<String, dynamic>) {
        // common wrapping patterns: { data: [...] } or { content: [...] }
        final dynamic maybeList = jsonData['data'] ?? jsonData['content'] ?? jsonData['items'];
        if (maybeList is List) {
          items = maybeList;
        } else {
          // if backend returns nested pagination structure
          final dynamic embedded = jsonData['payload'] ?? jsonData['result'];
          if (embedded is List) {
            items = embedded;
          } else {
            throw Exception('Unexpected stores response shape');
          }
        }
      } else {
        throw Exception('Invalid stores response');
      }

      return items
          .whereType<Map<String, dynamic>>()
          .map((e) => StoreModel.fromJson(e))
          .toList();
    } catch (e) {
      // Normalize error message
      if (e is ApiError) {
        throw Exception(e.toString());
      }
      throw Exception('Stores API error: ${e.toString()}');
    }
  }
}


