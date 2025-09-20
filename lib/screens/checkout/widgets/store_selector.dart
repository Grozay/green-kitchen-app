import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class Store {
  final String id;
  final String name;
  final String address;
  final double distance;
  final String estimatedTime;

  const Store({
    required this.id,
    required this.name,
    required this.address,
    required this.distance,
    required this.estimatedTime,
  });
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
  // Mock store data - in real app this would come from API
  final List<Store> _stores = [
    const Store(
      id: '1',
      name: 'Green Kitchen - Nguyễn Du',
      address: '123 Nguyễn Du, Quận 1, TP.HCM',
      distance: 2.5,
      estimatedTime: '25-35 phút',
    ),
    const Store(
      id: '2',
      name: 'Green Kitchen - Lê Lợi',
      address: '456 Lê Lợi, Quận 3, TP.HCM',
      distance: 3.2,
      estimatedTime: '30-40 phút',
    ),
    const Store(
      id: '3',
      name: 'Green Kitchen - Võ Văn Tần',
      address: '789 Võ Văn Tần, Quận 3, TP.HCM',
      distance: 1.8,
      estimatedTime: '20-30 phút',
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
          Text(
            'Chọn cửa hàng gần nhất',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
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