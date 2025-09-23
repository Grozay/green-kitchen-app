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
      return CustomMeal.fromJson(response);
    } catch (e) {
      print('Error in createCustomMeal: $e');
      if (e is ApiError) {
        throw Exception('Failed to create custom meal: ${e.message}');
      }
      throw Exception('Failed to create custom meal: ${e.toString()}');
    }
  }

  // Update a custom meal
  Future<CustomMeal> updateCustomMeal(int id, Map<String, dynamic> data) async {
    try {
      final endpoints = ApiEndpoints();
      final url = endpoints.updateCustomMeal.replaceFirst(':id', id.toString());
      final response = await _apiService.put(url, body: data);
      return CustomMeal.fromJson(response);
    } catch (e) {
      print('Error in updateCustomMeal: $e');
      if (e is ApiError) {
        throw Exception('Failed to update custom meal: ${e.message}');
      }
      throw Exception('Failed to update custom meal: ${e.toString()}');
    }
  }

  // Delete a custom meal
  Future<void> deleteCustomMeal(int id) async {
    try {
      final endpoints = ApiEndpoints();
      final url = endpoints.deleteCustomMeal.replaceFirst(':id', id.toString());
      await _apiService.delete(url);
    } catch (e) {
      print('Error in deleteCustomMeal: $e');
      if (e is ApiError) {
        throw Exception('Failed to delete custom meal: ${e.message}');
      }
      throw Exception('Failed to delete custom meal: ${e.toString()}');
    }
  }

  // Get all custom meals for a customer
  Future<List<CustomMeal>> getCustomMealsForCustomer(int customerId) async {
    try {
      final endpoints = ApiEndpoints();
      final url = endpoints.getCustomMealsForCustomer.replaceFirst(':customerId', customerId.toString()); // Giả định endpoint này tồn tại
      final response = await _apiService.get(url);
      // Giả định response là List<Map<String, dynamic>>
      return (response as List).map((json) => CustomMeal.fromJson(json)).toList();
    } catch (e) {
      if (e is ApiError) {
        throw Exception('Failed to load custom meals: ${e.message}');
      }
      throw Exception('Failed to load custom meals: ${e.toString()}');
    }
  }
}