import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:green_kitchen_app/models/ingredient.dart';
import 'package:green_kitchen_app/apis/endpoint.dart';

class IngredientService {
  static Future<Map<String, List<Ingredient>>> getIngredients() async {
    final endpoints = ApiEndpoints();
    final response = await http.get(Uri.parse(endpoints.ingredients));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      Map<String, List<Ingredient>> categorizedIngredients = {};

      data.forEach((key, value) {
        if (value is List) {
          categorizedIngredients[key] = value.map((item) => Ingredient.fromJson(item)).toList();
        }
      });

      return categorizedIngredients;
    } else {
      throw Exception('Failed to load ingredients');
    }
  }
}