import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../provider/auth_provider.dart';
import '../../theme/app_colors.dart';

class MembershipScreen extends StatefulWidget {
  const MembershipScreen({super.key});

  @override
  State<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends State<MembershipScreen> {
  int _visibleHistoryCount = 3;

  // Tier colors mapping
  static const Map<String, Color> tierColor = {
    'ENERGY': Color(0xFF32CD32), // #32CD32
    'VITALITY': Color(0xFFFF7043), // #FF7043
    'RADIANCE': Color(0xFFFFB300), // #FFB300
  };

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final customerDetails = authProvider.customerDetails;
    final membershipData = customerDetails?['membership'];
    final pointHistories = customerDetails?['pointHistories'] ?? [];
    final customerCoupons = customerDetails?['customerCoupons'] ?? [];

    // Sort point histories to show newest first
    final sortedPointHistories = List.from(pointHistories)
      ..sort((a, b) {
        final dateA = DateTime.tryParse(a['earnedAt'] ?? '') ?? DateTime.now();
        final dateB = DateTime.tryParse(b['earnedAt'] ?? '') ?? DateTime.now();
        return dateB.compareTo(dateA); // Newest first
      });

    // Get current tier color
    final currentTier = membershipData?['currentTier'] ?? 'ENERGY';
    final currentTierColor = tierColor[currentTier] ?? tierColor['ENERGY']!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Go Back',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/profile'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header với icon và text nổi bật
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: currentTierColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.card_membership,
                    color: currentTierColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Membership Status',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: currentTierColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your loyalty program details',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Current Membership Level - Full Width
            if (membershipData != null)
              SizedBox(
                width: double.infinity,
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [
                          currentTierColor.withValues(alpha: 0.1),
                          currentTierColor.withValues(alpha: 0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Icon(Icons.star, size: 48, color: currentTierColor),
                          const SizedBox(height: 16),
                          Text(
                            membershipData['currentTier'] ?? 'ENERGY',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: currentTierColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Current Membership Level',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Membership Statistics
            if (membershipData != null)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Membership Statistics',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildStatRow(
                        'Available Points',
                        '${membershipData['availablePoints']?.toString() ?? '0'} pts',
                      ),
                      _buildStatRow(
                        'Total Points Earned',
                        '${membershipData['totalPointsEarned']?.toString() ?? '0'} pts',
                      ),
                      _buildStatRow(
                        'Total Points Used',
                        '${membershipData['totalPointsUsed']?.toString() ?? '0'} pts',
                      ),
                      _buildStatRow(
                        'Total Spent (6 months)',
                        '${_formatCurrency(membershipData['totalSpentLast6Months'])} VND',
                      ),
                      _buildStatRow(
                        'Member Since',
                        _formatDate(membershipData['createdAt']),
                      ),
                      _buildStatRow(
                        'Tier Achieved',
                        _formatDate(membershipData['tierAchievedAt']),
                      ),
                      _buildStatRow(
                        'Last Updated',
                        _formatDate(membershipData['lastUpdatedAt']),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Customer Coupons Section
            if (customerCoupons.isNotEmpty)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.card_giftcard,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Your Coupons',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ..._buildCouponsList(
                        customerCoupons.take(3).toList(),
                      ), // Show first 3 coupons
                      if (customerCoupons.length > 3)
                        Center(
                          child: TextButton(
                            onPressed: () {
                              // TODO: Open full coupons list
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Full coupons list coming soon!',
                                  ),
                                ),
                              );
                            },
                            child: const Text('View All Coupons'),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Membership Benefits
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Membership Benefits',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildBenefitItem(
                      'Earn points on every order',
                      Icons.star_border,
                    ),
                    _buildBenefitItem(
                      'Exclusive promotions and discounts',
                      Icons.local_offer,
                    ),
                    _buildBenefitItem(
                      'Priority customer support',
                      Icons.support_agent,
                    ),
                    _buildBenefitItem(
                      'Free delivery on orders over 50,000 VND',
                      Icons.local_shipping,
                    ),
                    _buildBenefitItem('Birthday special offers', Icons.cake),
                    _buildBenefitItem(
                      'Early access to new menu items',
                      Icons.restaurant,
                    ),
                    _buildBenefitItem(
                      'Personalized meal recommendations',
                      Icons.recommend,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Points Progress
            if (membershipData != null)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Points Progress',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Available Points:',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            membershipData['availablePoints']?.toString() ??
                                '0',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: _calculateProgress(
                          membershipData['availablePoints'] ?? 0,
                        ),
                        backgroundColor: AppColors.inputBorder,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Keep earning points to maintain your ${membershipData['currentTier'] ?? 'Bronze'} status!',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Points History Section - Moved to bottom
            if (sortedPointHistories.isNotEmpty)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.history,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Points History',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ..._buildPointHistoryList(
                        sortedPointHistories
                            .take(_visibleHistoryCount)
                            .toList(),
                      ),
                      if (sortedPointHistories.length > _visibleHistoryCount)
                        Center(
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _visibleHistoryCount += 3;
                              });
                            },
                            child: const Text('Xem thêm'),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(String benefit, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              benefit,
              style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return '0';
    final numValue = amount is num
        ? amount
        : num.tryParse(amount.toString()) ?? 0;
    return numValue
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  double _calculateProgress(dynamic points) {
    final numPoints = points is num
        ? points
        : num.tryParse(points.toString()) ?? 0;
    // Assuming 10000 points for max tier (RADIANCE)
    return (numPoints / 10000).clamp(0.0, 1.0);
  }

  List<Widget> _buildPointHistoryList(List<dynamic> pointHistories) {
    return pointHistories.map((history) {
      final isEarned = history['transactionType'] == 'EARNED';
      final points = history['pointsEarned'] ?? 0;
      final description = history['description'] ?? 'Transaction';
      final date = _formatDate(history['earnedAt']);

      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isEarned ? Colors.green.shade50 : Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isEarned ? Colors.green.shade200 : Colors.red.shade200,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isEarned ? Icons.trending_up : Icons.trending_down,
              color: isEarned ? Colors.green : Colors.red,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${isEarned ? '+' : '-'}${points.abs()} pts',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isEarned ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _buildCouponsList(List<dynamic> coupons) {
    return coupons.map((coupon) {
      final isAvailable = coupon['status'] == 'AVAILABLE';
      final couponName = coupon['couponName'] ?? 'Coupon';
      final couponCode = coupon['couponCode'] ?? '';
      final discountValue = coupon['couponDiscountValue'] ?? 0;
      final discountType = coupon['couponType'] ?? 'FIXED_AMOUNT';
      final expiresAt = _formatDate(coupon['expiresAt']);

      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isAvailable ? Colors.blue.shade50 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isAvailable ? Colors.blue.shade200 : Colors.grey.shade200,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.card_giftcard,
                  color: isAvailable ? Colors.blue : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    couponName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Code: $couponCode',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            Text(
              'Discount: ${discountType == 'PERCENTAGE' ? '$discountValue%' : '${discountValue.toString()} VND'}',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            Text(
              'Expires: $expiresAt',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isAvailable ? Colors.green : Colors.grey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isAvailable ? 'Available' : 'Used',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
