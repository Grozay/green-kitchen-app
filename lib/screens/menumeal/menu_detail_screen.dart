import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:green_kitchen_app/constants/constants.dart';
import 'package:green_kitchen_app/models/menu_meal.dart';
import 'package:green_kitchen_app/models/menu_meal_review.dart';
import 'package:provider/provider.dart';
import '../../provider/cart_provider.dart';
import '../../provider/auth_provider.dart';
import '../../theme/app_colors.dart';
import 'package:flutter_rating/flutter_rating.dart';
import '../../services/review_menu_meal_service.dart';
import '../../services/menu_meal_service.dart';
import '../../widgets/menu_detail/average_rating_widget.dart';
import '../../widgets/menu_detail/review_form_widget.dart';
import '../../widgets/menu_detail/review_list_widget.dart';
import '../../widgets/menu_detail/nutrient_info_widget.dart';
import '../../widgets/menu_detail/bottom_bar_widget.dart';

class MenuDetailScreen extends StatefulWidget {
  final String slug;

  const MenuDetailScreen({super.key, required this.slug});

  @override
  State<MenuDetailScreen> createState() => _MenuDetailScreenState();
}

class _MenuDetailScreenState extends State<MenuDetailScreen> {
  MenuMeal? menuMeal;
  bool loading = true;
  int quantity = 1;
  List<MenuMealReview> reviews = [];
  bool reviewsLoading = false;
  bool submittingReview = false;
  bool hasPurchased = false;
  bool checkingPurchase = false;

  // Thêm state cho form create
  double rating = 0.0;
  TextEditingController commentController = TextEditingController();

  bool get hasAlreadyReviewed {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final customerId = int.tryParse(authProvider.currentUser?.id ?? '') ?? 0;
    return reviews.any((review) => review.customerId == customerId);
  }

  @override
  void initState() {
    super.initState();
    _loadMenuMeal();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final customerId = (authProvider.currentUser?.id as int?) ?? 0;
      cartProvider.fetchCart(customerId);
    });
  }

  void _loadMenuMeal() async {
    try {
      final meal = await MenuMealService().getMenuMealBySlug(widget.slug);
      setState(() {
        menuMeal = meal;
        loading = false;
      });
      if (menuMeal != null) {
        await _fetchReviews();
        await _checkUserPurchase();
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _fetchReviews() async {
    if (menuMeal == null) return;
    setState(() => reviewsLoading = true);
    try {
      final fetchedReviews = await ReviewMenuMealService().getMenuMealReviews(
        menuMeal!.id,
      );
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final customerId = authProvider.currentUser?.id;
      fetchedReviews.sort((a, b) {
        if (customerId != null) {
          if (a.customerId == int.parse(customerId) &&
              b.customerId != int.parse(customerId))
            return -1;
          if (b.customerId == int.parse(customerId) &&
              a.customerId != int.parse(customerId))
            return 1;
        }
        return DateTime.parse(
          b.createdAt ?? '',
        ).compareTo(DateTime.parse(a.createdAt ?? ''));
      });
      setState(() => reviews = fetchedReviews);
    } catch (e) {
    } finally {
      setState(() => reviewsLoading = false);
    }
  }

  Future<void> _checkUserPurchase() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final customerEmail = authProvider.currentUser?.email;
    if (customerEmail == null || menuMeal == null) return;
    setState(() => checkingPurchase = true);
    try {
      final customerData = await ReviewMenuMealService().fetchCustomerDetails(
        customerEmail,
      );
      final hasBought =
          customerData.orders?.any(
            (order) =>
                order.orderItems?.any(
                  (item) => item.title == menuMeal!.title,
                ) ??
                false,
          ) ??
          false;
      setState(() => hasPurchased = hasBought);
    } catch (e) {
      setState(() => hasPurchased = false);
    } finally {
      setState(() => checkingPurchase = false);
    }
  }

  // Thêm method để submit create review
  Future<void> _submitReview() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final customerIdStr = authProvider.currentUser?.id;
    if (customerIdStr == null || menuMeal == null) return;
    final customerId = int.tryParse(customerIdStr) ?? 0;
    if (customerId == 0 || rating == 0 || commentController.text.trim().isEmpty) return;
    if (!hasPurchased) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must purchase this item to review')),
      );
      return;
    }
    setState(() => submittingReview = true);
    try {
      final reviewData = {
        'menuMealId': menuMeal!.id,
        'customerId': customerId,
        'rating': rating.toInt(),
        'comment': commentController.text.trim(),
      };
      await ReviewMenuMealService().createMenuMealReview(reviewData);
      setState(() {
        rating = 0.0;
        commentController.clear();
      });
      await _fetchReviews(); // Refresh reviews
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => submittingReview = false);
    }
  }

  double get averageRating => reviews.isNotEmpty
      ? reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length
      : 0.0;

  @override
  Widget build(BuildContext context) {
    return Consumer2<CartProvider, AuthProvider>(
      builder: (context, cartProvider, authProvider, child) {
        if (loading) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.background,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.textPrimary,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: const Text(
                'Loading...',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
            ),
            body: Center(
              child: CircularProgressIndicator(color: AppColors.secondary),
            ),
          );
        }

        if (menuMeal == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.background,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.textPrimary,
                ),
                onPressed: () {
                  GoRouter.of(context).push('/menu-meal');
                },
              ),
              title: const Text(
                'Error',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
            ),
            body: Center(child: Text('Meal not found')),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Text(
              menuMeal!.title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
            centerTitle: false,
            actions: [
              Consumer<CartProvider>(
                builder: (context, cartProvider, child) {
                  return Stack(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.shopping_cart,
                          color: AppColors.textPrimary,
                        ),
                        onPressed: () {
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
                            constraints: const BoxConstraints(
                              minWidth: 15,
                              minHeight: 15,
                            ),
                            child: Text(
                              '${cartProvider.cartItemCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image
                          Container(
                            height: 380,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              image: DecorationImage(
                                image: NetworkImage(menuMeal!.image),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Title
                          Text(
                            menuMeal!.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Description
                          Text(
                            menuMeal!.description,
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Nutritional Info
                          const Text(
                            'Nutritional Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          NutrientInfoWidget(
                            calories: menuMeal!.calories,
                            protein: menuMeal!.protein,
                            carbs: menuMeal!.carbs,
                            fat: menuMeal!.fat,
                          ),
                          const SizedBox(height: 16),
                          // Rating
                          AverageRatingWidget(
                            averageRating: averageRating,
                            reviewCount: reviews.length,
                          ),
                          const SizedBox(height: 16),
                          // Reviews & Comments
                          const Text(
                            'Reviews & Comments',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Chỉ hiện form nếu chưa review và đã mua
                          if (!hasAlreadyReviewed)
                            ReviewFormWidget(
                              hasPurchased: hasPurchased,
                              submittingReview: submittingReview,
                              rating: rating, // Truyền state
                              commentController: commentController, // Truyền controller
                              onRatingChanged: (r) => setState(() => rating = r), // Cập nhật rating
                              onSubmit: _submitReview, // Gọi method submit
                              onCancel: () => setState(() {
                                rating = 0.0;
                                commentController.clear();
                              }), // Reset
                              hasAlreadyReviewed: hasAlreadyReviewed,
                            ),
                          const SizedBox(height: 16),
                          // Review List
                          ReviewListWidget(
                            reviews: reviews,
                            reviewsLoading: reviewsLoading,
                            onEdit: (updatedReview) async {
                              setState(() => submittingReview = true);
                              try {
                                await ReviewMenuMealService().updateMenuMealReview(
                                  updatedReview.id,
                                  {
                                    'menuMealId': menuMeal!.id,
                                    'customerId': updatedReview.customerId,
                                    'rating': updatedReview.rating,
                                    'comment': updatedReview.comment,
                                  },
                                );
                                await _fetchReviews();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Review updated!')),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              } finally {
                                setState(() => submittingReview = false);
                              }
                            },
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomBarWidget(
            menuMeal: menuMeal!,
            quantity: quantity,
            onQuantityChanged: (q) => setState(() => quantity = q),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    commentController.dispose(); // Dispose controller
    super.dispose();
  }
}
