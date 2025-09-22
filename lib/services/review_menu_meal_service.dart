import 'package:green_kitchen_app/utils/api_error.dart';
import '../models/menu_meal_review.dart';  // Assuming you have a MenuMealReview model
import '../models/customer_order.dart';  // Thêm import cho Customer model (nếu chưa có, tạo file models/customer.dart)
import '../apis/endpoint.dart';
import '../services/service.dart';

class ReviewMenuMealService {
  static final ReviewMenuMealService _instance = ReviewMenuMealService._internal();
  factory ReviewMenuMealService() => _instance;
  ReviewMenuMealService._internal();

  final ApiService _apiService = ApiService();

  // Initialize service
  Future<void> init() async {
    await _apiService.init();
  }

  // Get reviews for a menu meal
  Future<List<MenuMealReview>> getMenuMealReviews(int menuMealId) async {
    try {
      final endpoints = ApiEndpoints();
      final url = endpoints.getMenuMealReviews.replaceFirst(':menuMealId', menuMealId.toString());
      final response = await _apiService.get(url);
      // Assuming response is List<Map<String, dynamic>>
      return (response as List).map((json) => MenuMealReview.fromJson(json)).toList();
    } catch (e) {
      print('Error in getMenuMealReviews: $e');
      if (e is ApiError) {
        throw Exception('Failed to load reviews: ${e.message}');
      }
      throw Exception('Failed to load reviews: ${e.toString()}');
    }
  }

  // Create a new review for a menu meal
  Future<MenuMealReview> createMenuMealReview(Map<String, dynamic> data) async {
    try {
      final endpoints = ApiEndpoints();
      final response = await _apiService.post(endpoints.createMenuMealReview, body: data);
      return MenuMealReview.fromJson(response);
    } catch (e) {
      print('Error in createMenuMealReview: $e');
      if (e is ApiError) {
        throw Exception('Failed to create review: ${e.message}');
      }
      throw Exception('Failed to create review: ${e.toString()}');
    }
  }

  // Update an existing review
  Future<MenuMealReview> updateMenuMealReview(int reviewId, Map<String, dynamic> data) async {
    try {
      final endpoints = ApiEndpoints();
      final url = endpoints.updateMenuMealReview.replaceFirst(':reviewId', reviewId.toString());
      final response = await _apiService.put(url, body: data);
      return MenuMealReview.fromJson(response);
    } catch (e) {
      print('Error in updateMenuMealReview: $e');
      if (e is ApiError) {
        throw Exception('Failed to update review: ${e.message}');
      }
      throw Exception('Failed to update review: ${e.toString()}');
    }
  }

  // Thêm method fetch customer details (để check purchase)
  Future<Customer> fetchCustomerDetails(String email) async {
    try {
      // Sử dụng endpoint getProfile từ ApiEndpoints
      final url = ApiEndpoints.getProfile(email);
      final response = await _apiService.get(url);
      return Customer.fromJson(response);  // Parse response thành Customer
    } catch (e) {
      print('Error in fetchCustomerDetails: $e');
      if (e is ApiError) {
        throw Exception('Failed to fetch customer details: ${e.message}');
      }
      throw Exception('Failed to fetch customer details: ${e.toString()}');
    }
  }
}