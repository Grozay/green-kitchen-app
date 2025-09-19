import 'package:flutter/material.dart';
import '../../models/menu_meal.dart';

class MealCard extends StatelessWidget {
  final MenuMeal item;
  final int typeBasedIndex;
  final VoidCallback? onAddToCart;
  final VoidCallback? onIncrease;
  final VoidCallback? onDecrease;
  final int? quantity;
  final VoidCallback? onTap;

  const MealCard({
    super.key,
    required this.item,
    required this.typeBasedIndex,
    this.onAddToCart,
    this.onIncrease,
    this.onDecrease,
    this.quantity,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRect(
        child: Container(
          height: 420,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0),
                spreadRadius: 1,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image and Tag Section
              Stack(
                children: [
                  Container(
                    height: 160,
                    width: double.infinity,
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(item.image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${item.type}$typeBasedIndex',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4B0036),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Calories Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFF4B0036), width: 1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${item.calories.toInt()} CALORIES',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF4B0036),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 4),

              // Meal Name
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: 40,
                  ), // Reserve space for up to 2 lines of title
                  child: Text(
                    item.title,
                    style: const TextStyle(
                      color: Color(0xFF4B0036),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

              const SizedBox(height: 4),

              // Dotted line
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: CustomPaint(
                  size: Size(double.infinity, 1),
                  painter: DottedLinePainter(),
                ),
              ),

              const SizedBox(height: 4),

              // Nutrition Info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNutrient('Protein', '${item.protein.toInt()}g'),
                    _buildNutrient('Carbs', '${item.carbs.toInt()}g'),
                    _buildNutrient('Fat', '${item.fat.toInt()}g'),
                  ],
                ),
              ),

              const SizedBox(height: 4),

              // Spacer để push price xuống bottom
              Spacer(),

              // Price and Cart Section
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 12, bottom: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${item.price.toStringAsFixed(0)} VND',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4B0036),
                      ),
                    ),
                    // Cart buttons
                    if (quantity != null && quantity! > 0)
                      // Show quantity controls if item is in cart
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 16),
                              onPressed: onDecrease,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                '$quantity',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 16),
                              onPressed: onIncrease,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      )
                    else
                      // Show add to cart button if item is not in cart
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B35),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.add, size: 16, color: Colors.white),
                          onPressed: onAddToCart,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutrient(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4B0036),
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 8, color: Colors.grey)),
      ],
    );
  }
}

class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    var dashWidth = 5.0;
    var dashSpace = 3.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
