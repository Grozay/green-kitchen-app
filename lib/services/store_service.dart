import 'dart:math' as math;
import 'package:green_kitchen_app/apis/endpoint.dart';
import 'package:green_kitchen_app/models/store.dart';
import 'package:green_kitchen_app/services/service.dart';
import 'package:green_kitchen_app/utils/api_error.dart';

class StoreService {
  // Fake store data for demo purposes
  static final List<Map<String, dynamic>> _fakeStores = [
    {
      'id': '1',
      'name': 'Green Kitchen - Quận 1',
      'address': '123 Nguyễn Huệ, Quận 1, TP.HCM',
      'phone': '0123 456 789',
      'latitude': 10.7745,
      'longitude': 106.7019,
      'operatingHours': '6:00 - 22:00',
      'isActive': true,
    },
    {
      'id': '2',
      'name': 'Green Kitchen - Quận 3',
      'address': '456 Võ Văn Tần, Quận 3, TP.HCM',
      'phone': '0123 456 790',
      'latitude': 10.7845,
      'longitude': 106.6919,
      'operatingHours': '6:00 - 22:00',
      'isActive': true,
    },
    {
      'id': '3',
      'name': 'Green Kitchen - Bình Thạnh',
      'address': '789 Xô Viết Nghệ Tĩnh, Bình Thạnh, TP.HCM',
      'phone': '0123 456 791',
      'latitude': 10.8045,
      'longitude': 106.7119,
      'operatingHours': '6:00 - 22:00',
      'isActive': true,
    },
    {
      'id': '4',
      'name': 'Green Kitchen - Tân Bình',
      'address': '321 Cách Mạng Tháng 8, Tân Bình, TP.HCM',
      'phone': '0123 456 792',
      'latitude': 10.7945,
      'longitude': 106.6819,
      'operatingHours': '6:00 - 22:00',
      'isActive': true,
    },
  ];

  static Future<List<StoreModel>> getStores() async {
    final endpoints = ApiEndpoints();
    try {
      // Use central ApiService to include Authorization header if available
      final api = ApiService();
      final dynamic jsonData = await api.get(endpoints.stores, includeAuth: true);

      List<dynamic> items;
      if (jsonData is List) {
        items = jsonData;
      } else if (jsonData is Map<String, dynamic>) {
        // common wrapping patterns: { data: [...] } or { content: [...] }
        final dynamic maybeList = jsonData['data'] ?? jsonData['content'] ?? jsonData['items'];
        if (maybeList is List) {
          items = maybeList;
        } else {
          // if backend returns nested pagination structure
          final dynamic embedded = jsonData['payload'] ?? jsonData['result'];
          if (embedded is List) {
            items = embedded;
          } else {
            throw Exception('Unexpected stores response shape');
          }
        }
      } else {
        throw Exception('Invalid stores response');
      }

      return items
          .whereType<Map<String, dynamic>>()
          .map((e) => StoreModel.fromJson(e))
          .toList();
    } catch (e) {
      // Normalize error message
      if (e is ApiError) {
        throw Exception(e.toString());
      }
      throw Exception('Stores API error: ${e.toString()}');
    }
  }

  // Get all active stores (with fallback to fake data)
  static Future<List<Map<String, dynamic>>> getAllStores() async {
    try {
      // Try to get from API first
      final stores = await getStores();
      return stores.map((store) => {
        'id': store.id,
        'name': store.name,
        'address': store.address,
        'latitude': store.latitude,
        'longitude': store.longitude,
        'isActive': store.isActive,
      }).toList();
    } catch (e) {
      // Fallback to fake data if API fails
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      return _fakeStores.where((store) => store['isActive'] == true).toList();
    }
  }

  // Calculate distance between two coordinates using Haversine formula
  static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) * math.cos(lat2) * math.sin(dLon / 2) * math.sin(dLon / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    final double distance = earthRadius * c;

    return distance;
  }

  // Convert degrees to radians
  static double _degreesToRadians(double degrees) {
    return degrees * (3.141592653589793 / 180);
  }

  // Find nearest stores based on user location
  static Future<List<Map<String, dynamic>>> findNearestStores(
    double userLat,
    double userLon, {
    int limit = 3,
  }) async {
    try {
      final stores = await getAllStores();

      // Calculate distance for each store
      final storesWithDistance = stores.map((store) {
        final distance = calculateDistance(
          userLat,
          userLon,
          store['latitude'] as double,
          store['longitude'] as double,
        );

        return {
          ...store,
          'distance': distance,
        };
      }).toList();

      // Sort by distance and take the nearest ones
      storesWithDistance.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));

      return storesWithDistance.take(limit).toList();
    } catch (e) {
      throw Exception('Failed to find nearest stores: $e');
    }
  }

  // Get store by ID
  static Future<Map<String, dynamic>?> getStoreById(String storeId) async {
    try {
      final stores = await getAllStores();
      try {
        return stores.firstWhere(
          (store) => store['id'] == storeId,
        );
      } catch (e) {
        return null; // Store not found
      }
    } catch (e) {
      throw Exception('Failed to get store: $e');
    }
  }

  // Calculate delivery time estimate based on distance
  static Duration estimateDeliveryTime(double distance) {
    // Base time: 30 minutes
    const baseTime = Duration(minutes: 30);

    // Additional time based on distance: 5 minutes per km
    final additionalMinutes = (distance * 5).round();
    final additionalTime = Duration(minutes: additionalMinutes);

    return baseTime + additionalTime;
  }

  // Check if store is within delivery range
  static bool isWithinDeliveryRange(double distance, {double maxDistance = 20.0}) {
    return distance <= maxDistance;
  }

  // Get delivery fee based on distance and settings
  static double calculateDeliveryFee(
    double distance, {
    double baseFee = 15000,
    double additionalFeePerKm = 3000,
    double maxDistance = 20.0,
    bool hasFreeShipping = false,
  }) {
    if (hasFreeShipping) {
      return 0.0;
    }

    if (distance <= 0) {
      return baseFee;
    }

    // Cap the distance for fee calculation
    final effectiveDistance = distance > maxDistance ? maxDistance : distance;

    return baseFee + (effectiveDistance * additionalFeePerKm);
  }
}


