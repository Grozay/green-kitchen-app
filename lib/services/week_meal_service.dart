import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:green_kitchen_app/models/week_meal.dart';
import 'package:green_kitchen_app/apis/endpoint.dart';

class WeekMealService {
  // Changed return type from List<WeekMeal> to WeekMeal to match the API response (single object)
  static Future<WeekMeal> getWeekMealPlan(String type, String date) async {
    final endpoints = ApiEndpoints();
    final url = '${endpoints.getWeekMealPlan}?type=$type&date=$date';
    final response = await http.get(Uri.parse(url));
    print(response.body);
    if (response.statusCode == 200) {
      // Parse as single WeekMeal object, not a list
      return WeekMeal.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load week meal plan');
    }
  }

  static Future<WeekMeal> getByIdWeekMeal(int id) async {
    final endpoints = ApiEndpoints();
    final url = endpoints.getByIdWeekMeal.replaceAll(':id', id.toString());
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return WeekMeal.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load week meal by id');
    }
  }

  static Future<List<WeekMealDay>> getWeekMealDays(int weekMealId) async {
    final endpoints = ApiEndpoints();
    final url = endpoints.getWeekMealDays.replaceAll(':weekMealId', weekMealId.toString());
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => WeekMealDay.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load week meal days');
    }
  }

  static Future<WeekMealDay> getWeekMealDayById(int weekMealId, int dayId) async {
    final endpoints = ApiEndpoints();
    final url = endpoints.getWeekMealDayById.replaceAll(':weekMealId', weekMealId.toString()).replaceAll(':dayId', dayId.toString());
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return WeekMealDay.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load week meal day by id');
    }
  }
}