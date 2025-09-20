import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  void _navigateToPage(BuildContext context, String pageName) {
    // TODO: Implement navigation to respective pages
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Navigate to $pageName')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Text(
                'More',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            // Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildMenuCard(
                    context,
                    icon: Icons.chat,
                    title: 'Chat Support',
                    onTap: () => context.go('/chat'),
                  ),
                  const SizedBox(height: 16),

                  _buildMenuCard(
                    context,
                    icon: Icons.location_on,
                    title: 'Store Location',
                    onTap: () => context.go('/profile/location'),
                  ),
                  const SizedBox(height: 16),

                  _buildMenuCard(
                    context,
                    icon: Icons.info,
                    title: 'About Us',
                    onTap: () => context.go('/profile/faq'),
                  ),
                  const SizedBox(height: 16),

                  _buildMenuCard(
                    context,
                    icon: Icons.contact_mail,
                    title: 'Contact',
                    onTap: () => context.go('/profile/feedback'),
                  ),
                  const SizedBox(height: 16),

                  _buildMenuCard(
                    context,
                    icon: Icons.help,
                    title: 'FAQ',
                    onTap: () => context.go('/profile/faq'),
                  ),
                  const SizedBox(height: 16),

                  _buildMenuCard(
                    context,
                    icon: Icons.policy,
                    title: 'Policy',
                    onTap: () => _navigateToPage(context, 'Policy'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
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
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
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
}