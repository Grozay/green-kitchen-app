import 'package:green_kitchen_app/utils/api_error.dart';
import '../models/custom_meal.dart';  // Assuming you have a CustomMeal model
import '../apis/endpoint.dart';
import '../services/service.dart';

class CustomMealService {
  static final CustomMealService _instance = CustomMealService._internal();
  factory CustomMealService() => _instance;
  CustomMealService._internal();

  final ApiService _apiService = ApiService();

  // Initialize service
  Future<void> init() async {
    await _apiService.init();
  }

  // Create a custom meal
  Future<CustomMeal> createCustomMeal(Map<String, dynamic> data) async {
    try {
      final endpoints = ApiEndpoints();
      final response = await _apiService.post(endpoints.createCustomMeal, body: data);
      print('Response from createCustomMeal: $response'); // Debug response
      return CustomMeal.fromJson(response);
    } catch (e) {
      print('Error in createCustomMeal: $e'); // Debug error
      if (e is ApiError) {
        throw Exception('Failed to create custom meal: ${e.message}');
      }
      throw Exception('Failed to create custom meal: ${e.toString()}');
    }
  }

  // Get custom meal by ID
  Future<CustomMeal> getCustomMealById(String id) async {
    try {
      final endpoints = ApiEndpoints();
      final url = endpoints.getCustomMealById.replaceFirst(':id', id);
      final response = await _apiService.get(url);
      return CustomMeal.fromJson(response);
    } catch (e) {
      if (e is ApiError) {
        throw Exception('Failed to load custom meal: ${e.message}');
      }
      throw Exception('Failed to load custom meal: ${e.toString()}');
    }
  }
}