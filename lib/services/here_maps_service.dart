import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/env_config.dart';

class HereMapsService {
  // Here Maps API Key from environment variables
  static String get _apiKey => EnvConfig.hereMapsApiKey;

  // Get coordinates from address
  static Future<Map<String, double>?> getCoordinates(String address) async {
    try {
      final encodedAddress = Uri.encodeComponent(address);
      // Use HERE Maps Geocoding API with Vietnam focus coordinates
      final url = 'https://geocode.search.hereapi.com/v1/geocode?q=$encodedAddress&apiKey=$_apiKey&limit=1&lang=vi&at=10.8231,106.6297';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['items'] != null && data['items'].isNotEmpty) {
          final position = data['items'][0]['position'];
          return {
            'latitude': position['lat'] as double,
            'longitude': position['lng'] as double,
          };
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error getting coordinates: $e');
      return null;
    }
  }

  // Get address suggestions using HERE Maps Autosuggest API
  static Future<List<Map<String, dynamic>>> getAddressSuggestions(
    String query, {
    String? ward,
    String? district,
    String? city,
  }) async {
    try {
      // Build search query with context - include ward and district for better results
      final searchQuery = query.isNotEmpty && ward != null && district != null && city != null
        ? '$query, $ward, $district, $city'
        : query.isNotEmpty && ward != null && district != null
          ? '$query, $ward, $district, TP. Hồ Chí Minh'
          : query;

      final params = {
        'q': searchQuery,
        'apiKey': _apiKey,
        'limit': '5',
        'lang': 'vi',
        'at': '10.8231,106.6297', // Ho Chi Minh City coordinates for Vietnam focus
      };

      final uri = Uri.https('autosuggest.search.hereapi.com', '/v1/autosuggest', params);
      debugPrint('HERE Maps API URL: $uri');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final items = data['items'] as List<dynamic>;
        debugPrint('HERE Maps API returned ${items.length} raw suggestions');

        // Filter suggestions based on district and ward if provided
        final filteredItems = items.where((item) {
          final itemData = item as Map<String, dynamic>;
          final address = itemData['address'] as Map<String, dynamic>?;

          if (address == null) return true;

          // Temporarily disable district filtering to test
          // If we have selected district, only show suggestions from that district
          // if (district != null && district.isNotEmpty) {
          //   final districtMatch = itemDistrict.toLowerCase().contains(district.toLowerCase()) ||
          //                        district.toLowerCase().contains(itemDistrict.toLowerCase());
          //   debugPrint('District filter: "$itemDistrict" matches "$district"? $districtMatch');
          //   if (!districtMatch) return false;
          // }

          // For ward, be less restrictive - just prefer but don't filter out completely
          // This allows suggestions from nearby areas too
          return true;
        }).toList();

        debugPrint('After filtering: ${filteredItems.length} suggestions remain');

        // Convert filtered HERE Maps results to our format
        return filteredItems.map((item) {
          final itemData = item as Map<String, dynamic>;
          final address = itemData['address'] as Map<String, dynamic>?;
          final position = itemData['position'] as Map<String, dynamic>?;

          return {
            'id': itemData['id'] ?? '',
            'street': itemData['title'] ?? query,
            'address': address?['label'] ?? itemData['title'] ?? '',
            'lat': position?['lat'] ?? 0.0,
            'lng': position?['lng'] ?? 0.0,
            'district': address?['district'] ?? address?['county'] ?? '',
            'ward': address?['subdistrict'] ?? address?['city'] ?? '',
          };
        }).toList();
      } else {
        throw Exception('Failed to load address suggestions: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error in getAddressSuggestions: $e');
      return [];
    }
  }

  // Get address from coordinates (reverse geocoding)
  static Future<String?> getAddressFromCoordinates(double lat, double lng) async {
    try {
      final url = 'https://revgeocode.search.hereapi.com/v1/revgeocode?at=$lat,$lng&apiKey=$_apiKey&lang=vi';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['items'] != null && data['items'].isNotEmpty) {
          final address = data['items'][0]['address'];
          return address['label'] ?? '';
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error getting address: $e');
      return null;
    }
  }
}