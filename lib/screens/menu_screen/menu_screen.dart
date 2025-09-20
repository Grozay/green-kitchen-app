import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:green_kitchen_app/provider/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_colors.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Choose Your Meal',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Discover delicious and healthy meal options',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 1,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2,
                  children: [
                    _buildMenuCard(
                      context,
                      title: 'Daily Menu',
                      subtitle: 'Fresh meals prepared daily',
                      icon: Icons.restaurant_menu,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap: () => GoRouter.of(context).push('/menu-meal'),
                    ),
                    _buildMenuCard(
                      context,
                      title: 'Custom Meals',
                      subtitle: 'Create your perfect meal',
                      icon: Icons.create,
                      gradient: LinearGradient(
                        colors: [Colors.green.shade400, Colors.green.shade300],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap: () => GoRouter.of(context).push('/custom-meal'),
                    ),
                    if (Provider.of<AuthProvider>(context).isAuthenticated)
                      _buildMenuCard(
                        context,
                        title: 'Your Custom Meals', // Changed title
                        subtitle: 'View and manage your saved custom meals',
                        icon: Icons.restaurant_menu, // Changed icon
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.shade400,
                            Colors.blue.shade300,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        onTap: () => GoRouter.of(
                          context,
                        ).push('/saved-custom-meal'), // Changed route
                      ),
                    _buildMenuCard(
                      context,
                      title: 'Weekly Plans',
                      subtitle: 'Plan your meals for the week',
                      icon: Icons.calendar_view_week,
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange.shade400,
                          Colors.orange.shade300,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap: () async {
                        bool? shouldOpenWeb = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Open Web Version?'),
                              content: const Text(
                                'Do you want to open the web version of Weekly Meal Planner?',
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('No'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text('Yes'),
                                ),
                              ],
                            );
                          },
                        );
                        if (shouldOpenWeb == true) {
                          final Uri url = Uri.parse(
                            'http://localhost:5173/week-meal-planner',
                          );
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Could not launch URL'),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 8,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 24, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      'Explore',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
