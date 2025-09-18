import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:green_kitchen_app/constants/app_constants.dart';
import 'package:green_kitchen_app/widgets/nav_bar.dart';
import 'package:green_kitchen_app/models/menu_meal.dart';
import 'package:green_kitchen_app/services/menu_meal_service.dart';
import 'package:provider/provider.dart';
import '../../provider/cart_provider.dart';
import '../../services/cart_service.dart';

class MenuDetailScreen extends StatefulWidget {
  final String slug;

  const MenuDetailScreen({Key? key, required this.slug}) : super(key: key);

  @override
  State<MenuDetailScreen> createState() => _MenuDetailScreenState();
}

class _MenuDetailScreenState extends State<MenuDetailScreen> {
  MenuMeal? menuMeal;
  bool loading = true;
  int quantity = 1;
  List<MenuMeal> suggestedMeals = [];

  @override
  void initState() {
    super.initState();
    _loadMenuMeal();
  }

  void _loadMenuMeal() async {
    try {
      final meal = await MenuMealService().getMenuMealBySlug(widget.slug);
      setState(() {
        menuMeal = meal;
      });
      _loadSuggestedMeals();
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  void _loadSuggestedMeals() async {
    try {
      final allMeals = await MenuMealService().getMenuMeals();
      setState(() {
        suggestedMeals = allMeals
            .where((meal) => meal.slug != widget.slug)
            .take(5)
            .toList();
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        if (loading) {
          return NavBar(
            cartCount: cartProvider.cartItemCount,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (menuMeal == null) {
          return NavBar(
            cartCount: cartProvider.cartItemCount,
            body: Center(child: Text('Meal not found')),
          );
        }

        return NavBar(
          cartCount: cartProvider.cartItemCount,
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sửa Row: Thêm icon cart bên cạnh nút back
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.arrow_back, color: Color(0xFF4B0036)),
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                  const SizedBox(height: 16),
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
                      color: Color(0xFF4B0036),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Description
                  Text(
                    menuMeal!.description,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  // Nutritional Info
                  Text(
                    'Nutritional Information',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4B0036),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNutrient(
                        'Calories',
                        '${menuMeal!.calories.toInt()}',
                      ),
                      _buildNutrient(
                        'Protein',
                        '${menuMeal!.protein.toInt()}g',
                      ),
                      _buildNutrient('Carbs', '${menuMeal!.carbs.toInt()}g'),
                      _buildNutrient('Fat', '${menuMeal!.fat.toInt()}g'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Price and Add to Cart
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Price: ${menuMeal!.price.toStringAsFixed(0)} VND',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4B0036),
                        ),
                      ),
                      // Kiểm tra stock: Nếu stock = 0, hiển thị text thay vì button
                      if (menuMeal!.stock == 0)
                        const Text(
                          'Out of Stock',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      else
                        ElevatedButton(
                          onPressed: () {
                            _showQuantityBottomSheet(context, cartProvider);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF4B0036),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Add to Cart',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Rating
                  Row(
                    children: [
                      const Text(
                        'Rating: ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4B0036),
                        ),
                      ),
                      ...List.generate(5, (index) {
                        return Icon(
                          index < 4 ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 20,
                        );
                      }),
                      const SizedBox(width: 8),
                      const Text(
                        '4.5 (120 reviews)',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Suggested Products
                  const Text(
                    'Suggested Products',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4B0036),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: suggestedMeals.length,
                      itemBuilder: (context, index) {
                        final suggestedMeal = suggestedMeals[index];
                        return GestureDetector(
                          onTap: () {
                            context.go('/menumeal/${suggestedMeal.slug}');
                          },
                          child: Container(
                            width: 150,
                            margin: const EdgeInsets.only(right: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(12),
                                    ),
                                    image: DecorationImage(
                                      image: NetworkImage(suggestedMeal.image),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        suggestedMeal.title,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF4B0036),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${suggestedMeal.price.toStringAsFixed(0)} VND',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showQuantityBottomSheet(
    BuildContext context,
    CartProvider cartProvider,
  ) {
    int selectedQuantity = quantity;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Select Quantity',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4B0036),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Available Stock: ${menuMeal!.stock}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (selectedQuantity > 1) {
                            setState(() {
                              selectedQuantity--;
                            });
                          }
                        },
                        icon: Icon(Icons.remove),
                      ),
                      Text(
                        '$selectedQuantity',
                        style: const TextStyle(fontSize: 20),
                      ),
                      IconButton(
                        onPressed: () {
                          if (selectedQuantity < menuMeal!.stock) {
                            setState(() {
                              selectedQuantity++;
                            });
                          }
                        },
                        icon: Icon(Icons.add),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      // Kiểm tra stock trước khi add cart
                      if (selectedQuantity > menuMeal!.stock) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Cannot add more than available stock (${menuMeal!.stock})',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return; // Không add nếu vượt stock
                      }
                      Navigator.pop(context);
                      try {
                        await cartProvider.addMealToCart(
                          CURRENT_CUSTOMER_ID, // Giả định có constant này
                          menuMealId: menuMeal!.id,
                          quantity: selectedQuantity,
                          unitPrice: menuMeal!.price,
                          title: menuMeal!.title,
                          description: menuMeal!.description,
                          image: menuMeal!.image,
                          calories: menuMeal!.calories.toInt(),
                          protein: menuMeal!.protein,
                          carbs: menuMeal!.carbs,
                          fat: menuMeal!.fat,
                        );
                        // await cartProvider.loadCart(CURRENT_CUSTOMER_ID);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Added $selectedQuantity ${menuMeal!.title} to cart',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to add to cart: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4B0036),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Confirm',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNutrient(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4B0036),
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
