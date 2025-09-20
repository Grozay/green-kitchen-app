import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../services/store_service.dart';

class Store {
  final String id;
  final String name;
  final String address;
  final double distance;
  final String estimatedTime;
  final double latitude;
  final double longitude;

  const Store({
    required this.id,
    required this.name,
    required this.address,
    required this.distance,
    required this.estimatedTime,
    required this.latitude,
    required this.longitude,
  });

  factory Store.fromMap(Map<String, dynamic> map, double userLat, double userLon) {
    final distance = StoreService.calculateDistance(
      userLat,
      userLon,
      map['latitude'] as double,
      map['longitude'] as double,
    );

    final deliveryTime = StoreService.estimateDeliveryTime(distance);
    final estimatedTime = '${deliveryTime.inMinutes}-${deliveryTime.inMinutes + 10} phút';

    return Store(
      id: map['id'].toString(),
      name: map['name'] as String,
      address: map['address'] as String,
      distance: double.parse(distance.toStringAsFixed(1)),
      estimatedTime: estimatedTime,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
    );
  }
}

class StoreSelector extends StatefulWidget {
  final Store? selectedStore;
  final Function(Store) onStoreSelected;

  const StoreSelector({
    super.key,
    this.selectedStore,
    required this.onStoreSelected,
  });

  @override
  State<StoreSelector> createState() => _StoreSelectorState();
}

class _StoreSelectorState extends State<StoreSelector> {
  List<Store> _stores = [];
  bool _isLoading = true;
  String? _error;

  // Mock user location (TP.HCM center for demo)
  final double _userLat = 10.762622;
  final double _userLon = 106.660172;

  @override
  void initState() {
    super.initState();
    _loadStores();
  }

  Future<void> _loadStores() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Get nearest stores from StoreService
      final storesData = await StoreService.findNearestStores(
        _userLat,
        _userLon,
        limit: 3,
      );

      final stores = storesData.map((storeData) {
        return Store.fromMap(storeData, _userLat, _userLon);
      }).toList();

      setState(() {
        _stores = stores;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Không thể tải danh sách cửa hàng: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Đang tải danh sách cửa hàng...'),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadStores,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Chọn cửa hàng gần nhất',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _loadStores,
                icon: const Icon(Icons.refresh),
                tooltip: 'Làm mới',
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._stores.map((store) => _buildStoreOption(store)),
        ],
      ),
    );
  }

  Widget _buildStoreOption(Store store) {
    final isSelected = widget.selectedStore?.id == store.id;

    return GestureDetector(
      onTap: () {
        widget.onStoreSelected(store);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.secondary : AppColors.inputBorder,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? AppColors.secondary.withValues(alpha: 0.05) : Colors.white,
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.secondary.withValues(alpha: 0.1) : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.store,
                color: isSelected ? AppColors.secondary : AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.secondary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    store.address,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${store.distance}km • ${store.estimatedTime}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: store.id,
              groupValue: widget.selectedStore?.id,
              onChanged: (String? value) {
                if (value != null) {
                  final selectedStore = _stores.firstWhere((s) => s.id == value);
                  widget.onStoreSelected(selectedStore);
                }
              },
              activeColor: AppColors.secondary,
            ),
          ],
        ),
      ),
    );
  }
}