import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class PaymentMethodSelector extends StatelessWidget {
  final String selectedMethod;
  final Function(String) onMethodChanged;

  const PaymentMethodSelector({
    super.key,
    required this.selectedMethod,
    required this.onMethodChanged,
  });

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
        children: [
          _buildPaymentOption(
            'cod',
            'Cash on Delivery (COD)',
            Icons.local_shipping,
            'Pay with cash when you receive your order',
            AppColors.primary,
          ),
          const SizedBox(height: 12),
          _buildPaymentOption(
            'paypal',
            'PayPal Payment',
            Icons.payment,
            'Secure payment via PayPal with card or PayPal account',
            const Color(0xFF0070ba),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String value, String title, IconData icon, String description, Color iconColor) {
    final isSelected = selectedMethod == value;

    return GestureDetector(
      onTap: () => onMethodChanged(value),
      child: Container(
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
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? iconColor.withValues(alpha: 0.1) : AppColors.backgroundAlt,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? iconColor : AppColors.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.secondary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: selectedMethod,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  onMethodChanged(newValue);
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