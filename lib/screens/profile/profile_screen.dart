import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:green_kitchen_app/provider/auth_provider.dart';
import 'package:green_kitchen_app/widgets/nav_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _handleLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await authProvider.logout();

      if (mounted) {
        // Navigate back to login screen
        context.go('/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return NavBar(
      cartCount: 3,
      body: Container(
        color: Color(0xFFF5F5F5),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // Profile Header
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundImage: user?.avatar != null
                          ? NetworkImage(user!.avatar!)
                          : NetworkImage(
                              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=150&q=80',
                            ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.fullName ?? user?.firstName ?? 'User',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? 'user@example.com',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),                const SizedBox(height: 32),

                // Menu Items
                _buildMenuItem(
                  icon: Icons.person_outline,
                  color: Colors.orange,
                  title: 'Personal Info',
                ),

                _buildMenuItem(
                  icon: Icons.location_on_outlined,
                  color: Colors.purple,
                  title: 'Addresses',
                ),

                _buildMenuItem(
                  icon: Icons.shopping_cart_outlined,
                  color: Colors.blue,
                  title: 'Cart',
                ),

                _buildMenuItem(
                  icon: Icons.favorite_outline,
                  color: Colors.pink,
                  title: 'Favourite',
                ),

                _buildMenuItem(
                  icon: Icons.notifications_outlined,
                  color: Colors.amber,
                  title: 'Notifications',
                ),

                _buildMenuItem(
                  icon: Icons.payment_outlined,
                  color: Colors.blue,
                  title: 'Payment Method',
                ),

                const SizedBox(height: 16),

                _buildMenuItem(
                  icon: Icons.help_outline,
                  color: Colors.orange,
                  title: 'FAQs',
                ),

                _buildMenuItem(
                  icon: Icons.star_outline,
                  color: Colors.teal,
                  title: 'User Reviews',
                ),

                _buildMenuItem(
                  icon: Icons.settings_outlined,
                  color: Colors.purple,
                  title: 'Settings',
                ),

                const SizedBox(height: 16),

                _buildMenuItem(
                  icon: Icons.logout,
                  color: Colors.red,
                  title: 'Log Out',
                  isLogout: true,
                  onTap: _handleLogout,
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color color,
    required String title,
    bool isLogout = false,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: isLogout ? Colors.red : Colors.black87,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey,
          size: 16,
        ),
        onTap: onTap ?? () {
          // Handle navigation for other items
        },
      ),
    );
  }
}
