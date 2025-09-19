import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:green_kitchen_app/provider/cart_provider_v2.dart';
import 'package:green_kitchen_app/widgets/nav_bar.dart';
import 'package:green_kitchen_app/models/menu_meal.dart';
import 'package:green_kitchen_app/services/menu_meal_service.dart';
import 'package:green_kitchen_app/widgets/menu_meal/menu_list.dart';
import 'package:green_kitchen_app/widgets/menu_meal/tab_menu.dart';
import 'package:provider/provider.dart';
import '../../provider/cart_provider.dart';
import '../../constants/app_constants.dart';
import '../../theme/app_colors.dart';

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
      print(meals);
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
    return Consumer<CartProviderV2>(
      builder: (context, cartProvider, child) {
        return NavBar(
          currentIndex: 0,
          cartCount: cartProvider.cartItemCount,
          body: Container(
            color: AppColors.background,
            child: CustomScrollView(
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
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
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 24),
                        MenuList(
                          meals: filteredMeals,
                          loading: loading,
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
}

// Thêm class delegate cho SliverPersistentHeader
class _TabMenuDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabController;

  _TabMenuDelegate({required this.tabController});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.background,
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
  double get maxExtent => 80;

  @override
  double get minExtent => 80;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}


