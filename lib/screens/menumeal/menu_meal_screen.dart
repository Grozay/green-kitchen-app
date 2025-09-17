import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:green_kitchen_app/widgets/nav_bar.dart';
import 'package:green_kitchen_app/models/menu_meal.dart';
import 'package:green_kitchen_app/services/menu_meal_service.dart';
import 'package:green_kitchen_app/widgets/menu_meal/menu_list.dart';
import 'package:green_kitchen_app/widgets/menu_meal/tab_menu.dart';
import 'package:provider/provider.dart';
import '../../provider/provider.dart';
import '../../constants/app_constants.dart';

class MenuMealScreen extends StatefulWidget {
  const MenuMealScreen({Key? key}) : super(key: key);

  @override
  State<MenuMealScreen> createState() => _MenuMealScreenState();
}

class _MenuMealScreenState extends State<MenuMealScreen> with SingleTickerProviderStateMixin {
  List<MenuMeal> allMeals = [];
  List<MenuMeal> filteredMeals = [];
  bool loading = true;
  String selectedFilter = 'LOW';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);
    _loadMeals();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        selectedFilter = _getFilterFromIndex(_tabController.index);
        _filterMeals();
      });
    }
  }

  String _getFilterFromIndex(int index) {
    switch (index) {
      case 0: return 'LOW';
      case 1: return 'BALANCE';
      case 2: return 'HIGH';
      case 3: return 'VEGETARIAN';
      default: return 'LOW';
    }
  }

  void _loadMeals() async {
    try {
      final meals = await MenuMealService().getMenuMeals();
      setState(() {
        allMeals = meals;
        _filterMeals();
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  void _filterMeals() {
    filteredMeals = allMeals.where((meal) => meal.type == selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return NavBar(
          cartCount: cartProvider.cartItemCount,
          body: Container(
            color: Color(0xFFF5F5F5),
            child: CustomScrollView(
              slivers: [
                SliverPersistentHeader(
                  pinned: true, // Giữ cố định khi cuộn
                  delegate: _TabMenuDelegate(tabController: _tabController),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 32),
                        Text(
                          '$selectedFilter PROTEIN',
                          style: const TextStyle(
                            color: Color(0xFF4B0036),
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Meal List with cart functionality
                        MenuList(
                          meals: filteredMeals,
                          loading: loading,
                          quantities: _getMealQuantities(cartProvider),
                          onAddToCart: (meal) => _addToCart(context, cartProvider, meal),
                          onIncrease: (meal) => _increaseQuantity(context, cartProvider, meal),
                          onDecrease: (meal) => _decreaseQuantity(context, cartProvider, meal),
                          onTap: (meal) {
                            context.go('/menumeal/${meal.slug}');
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Map<int, int> _getMealQuantities(CartProvider cartProvider) {
    final quantities = <int, int>{};
    if (cartProvider.cart != null) {
      for (final cartItem in cartProvider.cart!.cartItems) {
        quantities[cartItem.menuMealId] = cartItem.quantity;
      }
    }
    return quantities;
  }

  void _addToCart(BuildContext context, CartProvider cartProvider, MenuMeal meal) {
    cartProvider.addMealToCart(CURRENT_CUSTOMER_ID, menuMealId: meal.id, quantity: 1);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${meal.title} đã được thêm vào giỏ hàng'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _increaseQuantity(BuildContext context, CartProvider cartProvider, MenuMeal meal) {
    final cartItem = cartProvider.getCartItemByMenuMealId(meal.id);
    if (cartItem != null) {
      cartProvider.increaseQuantity(CURRENT_CUSTOMER_ID, cartItem.id);
    }
  }

  void _decreaseQuantity(BuildContext context, CartProvider cartProvider, MenuMeal meal) {
    final cartItem = cartProvider.getCartItemByMenuMealId(meal.id);
    if (cartItem != null) {
      if (cartItem.quantity > 1) {
        cartProvider.decreaseQuantity(CURRENT_CUSTOMER_ID, cartItem.id);
      } else {
        cartProvider.removeFromCart(CURRENT_CUSTOMER_ID, cartItem.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${meal.title} đã được xóa khỏi giỏ hàng'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }
}

// Thêm class delegate cho SliverPersistentHeader
class _TabMenuDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabController;

  _TabMenuDelegate({required this.tabController});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Color(0xFFF5F5F5), // Màu nền khớp với body
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          const SizedBox(height: 15),
          tab_menu(tabController: tabController),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 80; // Chiều cao tối đa (điều chỉnh theo nhu cầu)

  @override
  double get minExtent => 80; // Chiều cao tối thiểu (giữ cố định)

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}


