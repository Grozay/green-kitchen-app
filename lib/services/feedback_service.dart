import 'package:green_kitchen_app/services/service.dart';
import 'package:green_kitchen_app/apis/endpoint.dart';

class FeedbackService {
  static final ApiService _apiService = ApiService();

  // Submit feedback
  static Future<bool> submitFeedback({
    required String type,
    required int? rating,
    required String title,
    required String description,
    String? contactEmail,
    String? fromEmail,
  }) async {
    try {
      await _apiService.init();
      final response = await _apiService.post(
        ApiEndpoints.submitFeedback,
        body: {
          'type': type,
          'rating': rating,
          'title': title,
          'description': description,
          'contactEmail': contactEmail,
          'fromEmail': fromEmail,
        },
      );

      // Check if response is successful
      print('🎯 Feedback response type: ${response.runtimeType}');
      print('🎯 Feedback response content: $response');

      if (response is Map && response['success'] == true) {
        print('✅ Feedback success: Map response with success=true');
        return true;
      }
      if (response is String && response.toLowerCase().contains('submitted')) {
        print('✅ Feedback success: String response contains "submitted"');
        return true;
      }
      print('❌ Feedback failed: Response does not indicate success');
      return false;
    } catch (e) {
      print('Error submitting feedback: $e');
      throw e;
    }
  }

  // Submit support request
  static Future<bool> submitSupportRequest({
    required String issueType,
    required String priority,
    required String subject,
    required String description,
    required String contactMethod,
    String? contactValue,
  }) async {
    try {
      await _apiService.init();
      final response = await _apiService.post(
        ApiEndpoints.submitSupportRequest,
        body: {
          'issueType': issueType,
          'priority': priority,
          'subject': subject,
          'description': description,
          'contactMethod': contactMethod,
          'contactValue': contactValue ?? 'N/A',
        },
      );

      // Check if response is successful
      print('🎯 Support response type: ${response.runtimeType}');
      print('🎯 Support response content: $response');

      if (response is Map && response['success'] == true) {
        print('✅ Support success: Map response with success=true');
        return true;
      }
      if (response is String && response.toLowerCase().contains('submitted')) {
        print('✅ Support success: String response contains "submitted"');
        return true;
      }
      print('❌ Support failed: Response does not indicate success');
      return false;
    } catch (e) {
      print('Error submitting support request: $e');
      throw e;
    }
  }
}
