import 'package:flutter/material.dart';
import 'package:green_kitchen_app/widgets/nav_bar.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NavBar(
      cartCount: 3,
      onCartTap: () {},
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.shopping_cart, color: Color(0xFF4B0036)),
                  SizedBox(width: 8),
                  Text(
                    'Giỏ mua hàng (3 sản phẩm)',
                    style: TextStyle(
                      color: Color(0xFF4B0036),
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Cart Item 1
              _CartItem(
                imageUrl: null,
                title: 'My Custom Bowl',
                subtitle: 'Custom meal with selected ingredients',
                price: '100,000 VNĐ',
                oldPrice: '120,000 VNĐ',
                calories: 253,
                protein: 26,
                carbs: 2,
                fat: 17,
                ingredients: const ['Salmon Fillet', 'Cilantro Lime Sauce'],
                quantity: 1,
              ),
              const SizedBox(height: 16),
              // Cart Item 2
              _CartItem(
                imageUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=400&q=80',
                title: 'Triple Protein Bowl',
                subtitle: 'Triple protein bowl with chicken, tofu and nuts',
                price: '20.99 VNĐ',
                oldPrice: '25.100 VNĐ',
                calories: 560,
                protein: 50,
                carbs: 26,
                fat: 25,
                quantity: 1,
              ),
              const SizedBox(height: 16),
              // Cart Item 3
              _CartItem(
                imageUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=400&q=80',
                title: 'THỰC ĐƠN LOW CALORIES',
                subtitle: 'Tuần ăn từ 2025-09-01 đến 2025-09-05, loại: LOW',
                price: '772.9 VNĐ',
                oldPrice: '927.40 VNĐ',
                calories: null,
                protein: null,
                carbs: null,
                fat: null,
                quantity: 1,
                isLowCalories: true,
              ),
              const SizedBox(height: 24),
              
              // Summary Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Delivery Address
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DELIVERY ADDRESS',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '2118 Thornridge Cir, Syracuse',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'EDIT',
                            style: TextStyle(
                              color: Color(0xFFFF6B35),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Total Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TOTAL:',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              '\$96',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () {},
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Breakdown',
                                    style: TextStyle(
                                      color: Color(0xFFFF6B35),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: Color(0xFFFF6B35),
                                    size: 12,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Place Order Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFF6B35),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          // Handle place order
                        },
                        child: Text(
                          'PLACE ORDER',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartItem extends StatelessWidget {
  final String? imageUrl;
  final String title;
  final String subtitle;
  final String price;
  final String? oldPrice;
  final int? calories;
  final int? protein;
  final int? carbs;
  final int? fat;
  final List<String>? ingredients;
  final int quantity;
  final bool isLowCalories;

  const _CartItem({
    Key? key,
    this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.price,
    this.oldPrice,
    this.calories,
    this.protein,
    this.carbs,
    this.fat,
    this.ingredients,
    required this.quantity,
    this.isLowCalories = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image or placeholder
          imageUrl == null
              ? CircleAvatar(radius: 40, backgroundColor: Colors.grey[400], child: const Text('M', style: TextStyle(fontSize: 32, color: Colors.white)))
              : ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Image.network(imageUrl!, width: 80, height: 80, fit: BoxFit.cover),
                ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text(subtitle, style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    if (oldPrice != null) ...[
                      const SizedBox(width: 8),
                      Text(oldPrice!, style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.black38)),
                    ],
                  ],
                ),
                if (!isLowCalories) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (ingredients != null) ...[
                        const Text('Ingredients', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: ingredients!.map((e) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(e, style: const TextStyle(fontSize: 12)),
                                )).toList(),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (calories != null) 
                        Expanded(child: Text('$calories Calories', style: const TextStyle(fontWeight: FontWeight.bold))),
                      if (protein != null) 
                        Expanded(child: Text('${protein}g Protein')),
                      if (carbs != null) 
                        Expanded(child: Text('${carbs}g Carbs')),
                      if (fat != null) 
                        Expanded(child: Text('${fat}g Fat')),
                    ],
                  ),
                ],
                if (isLowCalories) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Quantity:', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black26),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('$quantity'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          // Quantity and delete
          Column(
            children: [
              Row(
                children: [
                  IconButton(icon: const Icon(Icons.remove), onPressed: () {}),
                  Text('$quantity', style: const TextStyle(fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.add), onPressed: () {}),
                  IconButton(icon: const Icon(Icons.delete_outline), onPressed: () {}),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
