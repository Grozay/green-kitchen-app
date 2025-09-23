import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../provider/auth_provider.dart';
import '../../widgets/app_layout.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  void _logout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    if (context.mounted) {
      context.go('/auth/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return AppLayout(
      title: 'MORE',
      currentIndex: 4,
      body: _buildMoreContent(context, authProvider),
    );
  }

  Widget _buildMoreContent(BuildContext context, AuthProvider authProvider) {
    return SafeArea(
      child: Column(
        children: [
          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
              children: [
                _buildMenuCard(
                  context,
                  icon: Icons.chat,
                  title: 'Chat Support',
                  onTap: () => context.go('/chat'),
                ),
                const SizedBox(height: 8),

                _buildMenuCard(
                  context,
                  icon: Icons.location_on,
                  title: 'Store Location',
                  onTap: () => context.go('/location'),
                ),
                const SizedBox(height: 8),

                _buildMenuCard(
                  context,
                  icon: Icons.info,
                  title: 'About Us',
                  onTap: () => context.go('/about'),
                ),
                const SizedBox(height: 8),

                _buildMenuCard(
                  context,
                  icon: Icons.contact_mail,
                  title: 'Contact',
                  onTap: () => context.go('/feedback'),
                ),
                const SizedBox(height: 8),

                _buildMenuCard(
                  context,
                  icon: Icons.help,
                  title: 'FAQ',
                  onTap: () => context.go('/faq'),
                ),
                const SizedBox(height: 8),

                _buildMenuCard(
                  context,
                  icon: Icons.policy,
                  title: 'Policy',
                  onTap: () => context.go('/policy'),
                ),
                const SizedBox(height: 8),

                // Logout Button - Only show if user is authenticated
                if (authProvider.isAuthenticated) _buildLogoutCard(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutCard(BuildContext context) {
    return GestureDetector(
      onTap: () => _logout(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.red.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.logout,
                color: Colors.red,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Logout',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.red,
              size: 14,
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
        padding: const EdgeInsets.all(16),
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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textSecondary,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
