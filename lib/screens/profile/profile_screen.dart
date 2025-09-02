import 'package:flutter/material.dart';
import 'package:green_kitchen_app/widgets/nav_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                      backgroundImage: NetworkImage(
                        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=150&q=80',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Vishal Khadok',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'I love fast food',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
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
        onTap: () {
          // Handle navigation
        },
      ),
    );
  }
}
