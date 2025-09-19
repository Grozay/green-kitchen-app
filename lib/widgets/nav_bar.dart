import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:green_kitchen_app/provider/cart_provider_v2.dart';
import 'package:provider/provider.dart';
import 'package:green_kitchen_app/provider/auth_provider.dart';
import 'package:green_kitchen_app/provider/cart_provider.dart';
import 'package:green_kitchen_app/constants/app_constants.dart';
import 'package:green_kitchen_app/theme/app_colors.dart';

class NavBar extends StatefulWidget {
  final int cartCount;
  final VoidCallback? onCartTap;
  final Widget body;
  final int currentIndex;

  const NavBar({
    super.key,
    this.cartCount = 0,
    this.onCartTap,
    required this.body,
    this.currentIndex = 0,
  });

  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cartProvider = Provider.of<CartProviderV2>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final customerId = authProvider.currentUser?.id ?? CURRENT_CUSTOMER_ID;
      if (customerId != null) {
        // cartProvider.initializeCart(customerId as int);
      }
    });
  }

  void _onBottomNavTap(int index) {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/menumeal');
        break;
      case 1:
        GoRouter.of(context).go('/menumeal');
        break;
      case 2:
        GoRouter.of(context).go('/custommeal');
        break;
      case 3:
        GoRouter.of(context).go('/weekmeal');
        break;
      case 4:
        GoRouter.of(context).go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Material(
              elevation: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: AppColors.background,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        GoRouter.of(context).go('/profile');
                      },
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.secondary,
                        child: user?.fullName != null && user!.fullName!.isNotEmpty
                            ? Text(
                                user.fullName![0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              )
                            : const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 24,
                              ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: const Text(
                          'GREEN KITCHEN',
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                    Consumer<CartProviderV2>(
                      builder: (context, cartProvider, child) {
                        return Stack(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.shopping_cart,
                                color: AppColors.textPrimary,
                              ),
                              onPressed: widget.onCartTap ?? () {
                                GoRouter.of(context).push('/cart');
                              },
                            ),
                            if (cartProvider.cartItemCount > 0)
                              Positioned(
                                right: 6,
                                top: 6,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: AppColors.secondary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${cartProvider.cartItemCount}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            Expanded(child: widget.body),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: widget.currentIndex,
          onTap: _onBottomNavTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.secondary,
          unselectedItemColor: AppColors.textSecondary,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu),
              label: 'Menu',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.food_bank),
              label: 'Custom Meal',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Week Meal',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }
}
