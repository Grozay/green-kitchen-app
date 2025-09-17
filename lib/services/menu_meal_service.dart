import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/menu_meal.dart';
import '../apis/endpoint.dart';

class MenuMealService {
  Future<List<MenuMeal>> getMenuMeals() async {
    try {
      final response = await http.get(Uri.parse(menuMeals));
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => MenuMeal.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load menu meals');
      }
    } catch (e) {
      print('Error: $e');
      throw e;
    }
  }

  static Future<MenuMeal> getMenuMealBySlug(String slug) async {
    final url = menuMealBySlug.replaceFirst(':slug', slug);
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return MenuMeal.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load menu meal');
    }
  }
}