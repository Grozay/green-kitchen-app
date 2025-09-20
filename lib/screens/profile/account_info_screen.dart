import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../provider/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/edit_profile_dialog.dart';
import '../../widgets/reset_password_dialog.dart';

class AccountInfoScreen extends StatelessWidget {
  const AccountInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final customerDetails = authProvider.customerDetails;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header với avatar và thông tin user
          Center(
            child: Column(
              children: [
                // Avatar lớn hơn
                if (customerDetails?['avatar'] != null && customerDetails!['avatar'].isNotEmpty)
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(60),
                      border: Border.all(color: AppColors.primary, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: Image.network(
                        customerDetails['avatar'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            child: const Center(
                              child: Icon(Icons.person, color: Colors.white, size: 60),
                            ),
                          );
                        },
                      ),
                    ),
                  )
                else
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(60),
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryHover],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.person, color: Colors.white, size: 60),
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  user?.fullName ?? 'User',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user?.email ?? user?.phone ?? '',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Quick Actions - Full Width
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton('Edit Profile', Icons.edit, () {
                          showDialog(
                            context: context,
                            builder: (context) => const EditProfileDialog(),
                          );
                        }),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _buildActionButton('Change PW', Icons.lock, () {
                          showDialog(
                            context: context,
                            builder: (context) => const ResetPasswordDialog(),
                          );
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Navigation Cards
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
                    'More Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildNavigationCard(
                    context,
                    'Membership',
                    'View your membership details and benefits',
                    Icons.card_membership,
                    () => context.go('/profile/membership'),
                  ),
                  const SizedBox(height: 12),
                  _buildNavigationCard(
                    context,
                    'Order History',
                    'View your past orders and track current ones',
                    Icons.history,
                    () => context.go('/profile/orderhistory'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
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
                    'Account Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Full Name', user?.fullName ?? 'N/A'),
                  _buildInfoRow('Email', user?.email ?? 'N/A'),
                  _buildInfoRow('Phone', customerDetails?['phone'] ?? user?.phone ?? 'N/A'),
                  if (customerDetails != null) ...[
                    _buildInfoRow('Member ID', customerDetails['id']?.toString() ?? 'N/A'),
                    _buildInfoRow('Birth Date', _formatDate(customerDetails['birthDate'])),
                    _buildInfoRow('Gender', _formatGender(customerDetails['gender'])),
                    _buildInfoRow('OAuth Provider', customerDetails['oauthProvider'] ?? 'N/A'),
                    _buildInfoRow('Join Date', _formatDate(customerDetails['createdAt'])),
                    _buildInfoRow('Status', customerDetails['isActive'] == true ? 'Active' : 'Inactive'),
                    if (customerDetails['customerTDEEs'] != null && customerDetails['customerTDEEs'].isNotEmpty)
                      _buildInfoRow('Age', customerDetails['customerTDEEs'][0]['age']?.toString() ?? 'N/A'),
                    if (customerDetails['customerTDEEs'] != null && customerDetails['customerTDEEs'].isNotEmpty)
                      _buildInfoRow('Height', '${customerDetails['customerTDEEs'][0]['height']?.toString() ?? 'N/A'} cm'),
                    if (customerDetails['customerTDEEs'] != null && customerDetails['customerTDEEs'].isNotEmpty)
                      _buildInfoRow('Weight', '${customerDetails['customerTDEEs'][0]['weight']?.toString() ?? 'N/A'} kg'),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // TDEE Information Section
          if (customerDetails != null && customerDetails['customerTDEEs'] != null && customerDetails['customerTDEEs'].isNotEmpty)
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
                        Icon(Icons.fitness_center, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          'Fitness Information',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ..._buildTDEEInfo(customerDetails['customerTDEEs'][0]),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 16),

        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: AppColors.primary),
      label: Text(
        title,
        style: TextStyle(color: AppColors.primary),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        elevation: 0,
        side: BorderSide(color: AppColors.inputBorder),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        alignment: Alignment.center,
      ),
    );
  }

  List<Widget> _buildTDEEInfo(Map<String, dynamic> tdeeData) {
    return [
      _buildInfoRow('Age', tdeeData['age']?.toString() ?? 'N/A'),
      _buildInfoRow('Height', '${tdeeData['height']?.toString() ?? 'N/A'} cm'),
      _buildInfoRow('Weight', '${tdeeData['weight']?.toString() ?? 'N/A'} kg'),
      _buildInfoRow('Activity Level', _formatActivityLevel(tdeeData['activityLevel'])),
      _buildInfoRow('TDEE', '${tdeeData['tdee']?.toString() ?? 'N/A'} kcal'),
      _buildInfoRow('BMR', '${tdeeData['bmr']?.toString() ?? 'N/A'} kcal'),
    ];
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

  String _formatGender(String? gender) {
    if (gender == null || gender.isEmpty) return 'N/A';
    switch (gender.toUpperCase()) {
      case 'MALE':
        return 'Male';
      case 'FEMALE':
        return 'Female';
      case 'OTHER':
        return 'Other';
      default:
        return gender;
    }
  }

  Widget _buildNavigationCard(BuildContext context, String title, String subtitle, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  String _formatActivityLevel(String? level) {
    if (level == null || level.isEmpty) return 'N/A';
    switch (level.toUpperCase()) {
      case 'SEDENTARY':
        return 'Sedentary';
      case 'LIGHTLY_ACTIVE':
        return 'Lightly Active';
      case 'MODERATELY_ACTIVE':
        return 'Moderately Active';
      case 'VERY_ACTIVE':
        return 'Very Active';
      case 'EXTREMELY_ACTIVE':
        return 'Extremely Active';
      default:
        return level.replaceAll('_', ' ').toLowerCase();
    }
  }
}