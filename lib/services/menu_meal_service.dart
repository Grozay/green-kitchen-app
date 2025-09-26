import 'package:green_kitchen_app/utils/api_error.dart';
import '../models/menu_meal.dart';
import '../apis/endpoint.dart';
import '../services/service.dart';

class MenuMealService {
  static final MenuMealService _instance = MenuMealService._internal();
  factory MenuMealService() => _instance;
  MenuMealService._internal();

  final ApiService _apiService = ApiService();

  // Initialize service
  Future<void> init() async {
    await _apiService.init();
  }

  // Get list of menu meals
  Future<List<MenuMeal>> getMenuMeals() async {
    try {
      final endpoints = ApiEndpoints();
      final response = await _apiService.get(endpoints.menuMeals);

      if (response is Map<String, dynamic>) {
        if (response.containsKey('data')) {
          List<dynamic> data = response['data'] as List<dynamic>;
          return data.map((json) => MenuMeal.fromJson(json)).toList();
        } else {
          throw Exception('Response does not contain "data" key');
        }
      } else if (response is List<dynamic>) {
        return response.map((json) => MenuMeal.fromJson(json)).toList();
      } else {
        throw Exception('Unexpected response type: ${response.runtimeType}');
      }
    } catch (e) {
      // print('Error in getMenuMeals: $e'); // Debug error
      if (e is ApiError) {
        throw Exception('Failed to load menu meals: ${e.message}');
      }
      throw Exception('Failed to load menu meals: ${e.toString()}');
    }
  }

  // Get menu meal by slug
  Future<MenuMeal> getMenuMealBySlug(String slug) async {
    try {
      final endpoints = ApiEndpoints();
      final url = endpoints.menuMealBySlug.replaceFirst(':slug', slug);
      final response = await _apiService.get(url);
      return MenuMeal.fromJson(response);
    } catch (e) {
      if (e is ApiError) {
        throw Exception('Failed to load menu meal: ${e.message}');
      }
      throw Exception('Failed to load menu meal: ${e.toString()}');
    }
  }

  // Get popular menu meals
  Future<List<MenuMeal>> getPopularMenuMeals() async {
    try {
      final endpoints = ApiEndpoints();
      final response = await _apiService.get('${endpoints.menuMeals}/popular');

      if (response is Map<String, dynamic>) {
        if (response.containsKey('data')) {
          List<dynamic> data = response['data'] as List<dynamic>;
          return data.map((json) => MenuMeal.fromJson(json)).toList();
        } else {
          throw Exception('Response does not contain "data" key');
        }
      } else if (response is List<dynamic>) {
        return response.map((json) => MenuMeal.fromJson(json)).toList();
      } else {
        throw Exception('Unexpected response type: ${response.runtimeType}');
      }
    } catch (e) {
      // print('Error in getPopularMenuMeals: $e'); // Debug error
      if (e is ApiError) {
        throw Exception('Failed to load popular menu meals: ${e.message}');
      }
      throw Exception('Failed to load popular menu meals: ${e.toString()}');
    }
  }
}
