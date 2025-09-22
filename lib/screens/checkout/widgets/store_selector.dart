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
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
    );
  }
}

class StoreSelector extends StatefulWidget {
  final Store? selectedStore;
  final Function(Store) onStoreSelected;
  final double? userLatitude;
  final double? userLongitude;

  const StoreSelector({
    super.key,
    this.selectedStore,
    required this.onStoreSelected,
    this.userLatitude,
    this.userLongitude,
  });

  @override
  State<StoreSelector> createState() => _StoreSelectorState();
}

class _StoreSelectorState extends State<StoreSelector> {
  List<Store> _stores = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStores();
  }

  @override
  void didUpdateWidget(StoreSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload stores if user coordinates changed
    if (oldWidget.userLatitude != widget.userLatitude ||
        oldWidget.userLongitude != widget.userLongitude) {
      _loadStores();
    }
  }

  Future<void> _loadStores() async {
    // Don't load if no user coordinates
    if (widget.userLatitude == null || widget.userLongitude == null) {
      setState(() {
        _stores = [];
        _isLoading = false;
        _error = 'Please confirm your address to find the nearest store';
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Get nearest stores from StoreService using user coordinates
      final storesData = await StoreService.findNearestStores(
        widget.userLatitude!,
        widget.userLongitude!,
        limit: 3,
      );

      final stores = storesData.map((storeData) {
        return Store.fromMap(storeData, widget.userLatitude!, widget.userLongitude!);
      }).toList();

      setState(() {
        _stores = stores;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Unable to load store list: $e';
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
              Text('Loading store list...'),
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
              child: const Text('Try Again'),
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
                'Select Nearest Store',
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
                tooltip: 'Refresh',
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