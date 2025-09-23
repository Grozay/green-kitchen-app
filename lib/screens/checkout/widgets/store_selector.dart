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
  List<Store> _allStores = [];
  bool _isLoading = true;
  bool _showAllStores = false;
  int _currentDisplayCount = 1; // Start with 1 store (nearest)
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

      // Get all stores from StoreService using user coordinates
      final storesData = await StoreService.findNearestStores(
        widget.userLatitude!,
        widget.userLongitude!,
        limit: 10, // Get more stores for "view more" option
      );

      final stores = storesData.map((storeData) {
        return Store.fromMap(storeData, widget.userLatitude!, widget.userLongitude!);
      }).toList();

      setState(() {
        _allStores = stores;
        _stores = stores.isNotEmpty ? [stores.first] : []; // Show only nearest store initially
        _currentDisplayCount = 1;
        _isLoading = false;
      });

      // Auto-select nearest store if no store is selected
      if (widget.selectedStore == null && stores.isNotEmpty) {
        widget.onStoreSelected(stores.first);
      }
    } catch (e) {
      setState(() {
        _error = 'Unable to load store list: $e';
        _isLoading = false;
      });
    }
  }

  void _toggleShowMoreStores() {
    setState(() {
      _showAllStores = !_showAllStores;
      if (_showAllStores) {
        // Show all stores
        _stores = _allStores;
        _currentDisplayCount = _allStores.length;
      } else {
        // Show only nearest store
        _stores = _allStores.isNotEmpty ? [_allStores.first] : [];
        _currentDisplayCount = 1;
      }
    });
  }

  void _showMoreStores() {
    setState(() {
      _currentDisplayCount += 2; // Show 2 more stores each time
      if (_currentDisplayCount > _allStores.length) {
        _currentDisplayCount = _allStores.length;
      }
      _stores = _allStores.take(_currentDisplayCount).toList();
    });
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
                _showAllStores ? 'Select Store' : 'Nearest Store',
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
          
          // Show "View more stores" button if there are more stores to show
          if (!_showAllStores && _currentDisplayCount < _allStores.length) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _showMoreStores,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.expand_more,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'View more stores (${_allStores.length - _currentDisplayCount} more)',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          
          // Show "View all stores" button when showing some but not all
          if (_currentDisplayCount < _allStores.length && _currentDisplayCount > 1) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _toggleShowMoreStores,
                child: Text(
                  'View all stores',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
          
          // Show "Show less" button when showing all stores
          if (_showAllStores && _allStores.length > 1) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _toggleShowMoreStores,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: AppColors.textSecondary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.expand_less,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Show less',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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