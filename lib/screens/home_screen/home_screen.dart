import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_layout.dart';
import '../../services/menu_meal_service.dart';
import '../../models/menu_meal.dart';
import '../../provider/cart_provider.dart';
import '../../provider/auth_provider.dart';
import '../../constants/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();

  bool _showLeftArrow = false;
  bool _showRightArrow = true;

  // Popular items state
  List<MenuMeal> _popularItems = [];
  bool _isLoadingPopular = true;
  String? _popularError;

  // Sample slider images
  final List<String> _sliderImages = [
    'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=800',
    'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800',
    'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=800',
    'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=800',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateArrowVisibility);
    _loadPopularItems();
  }

  Future<void> _loadPopularItems() async {
    try {
      setState(() {
        _isLoadingPopular = true;
        _popularError = null;
      });

      final menuMealService = MenuMealService();
      final popularItems = await menuMealService.getPopularMenuMeals();

      setState(() {
        _popularItems = popularItems;
        _isLoadingPopular = false;
      });
    } catch (e) {
      setState(() {
        _popularError = e.toString();
        _isLoadingPopular = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: 'GREEN KITCHEN',
      currentIndex: 0,
      body: _buildHomeContent(),
    );
  }

  void _updateArrowVisibility() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;

    setState(() {
      _showLeftArrow = currentScroll > 10; // Show when scrolled more than 10 pixels
      _showRightArrow = currentScroll < maxScroll - 10; // Show when not at the end
    });
  }

  Widget _buildHomeContent() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.1),
                    AppColors.primary.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome to',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w300,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Green Kitchen',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Healthy, delicious meals made with fresh ingredients',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Image Slider
            Container(
              height: 200,
              margin: const EdgeInsets.symmetric(vertical: 20),
              child: PageView.builder(
                controller: _pageController,
                itemCount: _sliderImages.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        _sliderImages[index],
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: AppColors.backgroundAlt,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            child: const Center(
                              child: Icon(
                                Icons.restaurant,
                                color: AppColors.primary,
                                size: 50,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),

            // Popular Items Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Popular Items',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          GoRouter.of(context).push('/menu-meal');
                        },
                        child: Text(
                          'View All',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Horizontal Scroll with subtle arrow indicators
                  Stack(
                    children: [
                      SizedBox(
                        height: 280,
                        child: _isLoadingPopular
                            ? const Center(child: CircularProgressIndicator())
                            : _popularError != null
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Failed to load popular items',
                                          style: TextStyle(color: AppColors.textSecondary),
                                        ),
                                        const SizedBox(height: 8),
                                        ElevatedButton(
                                          onPressed: _loadPopularItems,
                                          child: const Text('Retry'),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    controller: _scrollController,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _popularItems.length,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        margin: EdgeInsets.only(
                                          left: index == 0 ? 0 : 16,
                                          right: index == _popularItems.length - 1 ? 16 : 0,
                                        ),
                                        child: _buildMenuMealCard(_popularItems[index]),
                                      );
                                    },
                                  ),
                      ),

                      // Left Arrow - only visible when scrolled
                      if (_showLeftArrow)
                        Positioned(
                          left: 8,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: Icon(
                              Icons.chevron_left,
                              color: AppColors.primary.withValues(alpha: 0.7),
                              size: 24,
                            ),
                          ),
                        ),

                      // Right Arrow - only visible when can scroll right
                      if (_showRightArrow)
                        Positioned(
                          right: 8,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: Icon(
                              Icons.chevron_right,
                              color: AppColors.primary.withValues(alpha: 0.7),
                              size: 24,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Quick Actions
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
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
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionButton(
                          icon: Icons.restaurant_menu,
                          label: 'Browse Menu',
                          onTap: () {
                            GoRouter.of(context).push('/menu-meal');
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickActionButton(
                          icon: Icons.track_changes,
                          label: 'Track Order',
                          onTap: () {
                            GoRouter.of(context).push('/tracking'); 
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuMealCard(MenuMeal menuMeal) {
    return GestureDetector(
      onTap: () {
        // Navigate to menu detail screen
        GoRouter.of(context).push('/menu-meal/${menuMeal.slug}');
      },
      child: Container(
        width: 200, // Fixed width for horizontal scroll
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Food Image
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                child: Stack(
                  children: [
                    Image.network(
                      menuMeal.image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: AppColors.backgroundAlt,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          child: const Center(
                            child: Icon(
                              Icons.restaurant,
                              color: AppColors.primary,
                              size: 30,
                            ),
                          ),
                        );
                      },
                    ),
                    // Overlay gradient for better text readability
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.3),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Food Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          menuMeal.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '4.5', // Default rating since API doesn't provide it
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${menuMeal.calories.toInt()} cal',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${menuMeal.soldCount} sold',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${NumberFormat('#,###').format(menuMeal.price ?? 0)} VND',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            // Add to cart (không cần login)
                            final cartProvider = Provider.of<CartProvider>(context, listen: false);
                            final authProvider = Provider.of<AuthProvider>(context, listen: false);
                            final customerId = authProvider.customerDetails?['id'] ?? 0;
                            
                            final itemData = {
                              'isCustom': false,
                              'menuMealId': menuMeal.id,
                              'quantity': 1,
                              'unitPrice': menuMeal.price ?? 0.0,
                              'totalPrice': (menuMeal.price ?? 0.0) * 1,
                              'title': menuMeal.title,
                              'description': menuMeal.description,
                              'image': menuMeal.image,
                              'itemType': ORDER_TYPE_MENU_MEAL,
                              'calories': menuMeal.calories,
                              'protein': menuMeal.protein,
                              'carbs': menuMeal.carbs,
                              'fat': menuMeal.fat,
                            };
                            
                            try {
                              await cartProvider.addMealToCart(customerId, itemData);
                              
                              if (mounted) {
                                if (cartProvider.error != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: ${cartProvider.error}'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${menuMeal.title} added to cart!'),
                                      duration: const Duration(seconds: 2),
                                      backgroundColor: AppColors.primary,
                                    ),
                                  );
                                }
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to add ${menuMeal.title} to cart'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.add,
                              color: AppColors.primary,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
