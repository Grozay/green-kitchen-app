import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationService {
  static const String _baseUrl = 'https://provinces.open-api.vn';

  // Get districts of Ho Chi Minh City (code: 79)
  static Future<List<Map<String, dynamic>>> getDistricts() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/p/79?depth=2'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data['districts'] != null) {
          return List<Map<String, dynamic>>.from(data['districts']);
        }
      }
      return [];
    } catch (e) {
      // debugPrint('Error fetching districts: $e');
      return [];
    }
  }

  // Get wards of a district
  static Future<List<Map<String, dynamic>>> getWards(String districtCode) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/d/$districtCode?depth=2'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data['wards'] != null) {
          return List<Map<String, dynamic>>.from(data['wards']);
        }
      }
      return [];
    } catch (e) {
      // debugPrint('Error fetching wards: $e');
      return [];
    }
  }
}