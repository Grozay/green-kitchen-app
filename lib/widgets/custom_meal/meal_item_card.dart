import 'package:flutter/material.dart';
import 'package:green_kitchen_app/models/ingredient.dart';

class MealItemCard extends StatelessWidget {
  final Ingredient item;
  final int quantity;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const MealItemCard({
    Key? key,
    required this.item,
    required this.quantity,
    required this.onIncrease,
    required this.onDecrease,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300, // Fixed height to prevent overflow
      decoration: BoxDecoration(
        color: quantity > 0 ? Color(0xFF7DD3C0) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image at the top
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Color(0xFFE8B678),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.network(
                  item.image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.fastfood, color: Colors.white, size: 18),
                ),
              ),
            ),

            const SizedBox(height: 2),

            // Item name - constrained height
            SizedBox(
              height: 24,
              child: Text(
                item.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 8,
                  color: Color(0xFF4B0036),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 1),

            // Price
            Text(
              '\$${item.price.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 7,
                color: Color(0xFF4B0036).withValues(alpha: 0.7),
              ),
            ),

            const Spacer(), // Push quantity controls to bottom

            // Quantity controls at bottom
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.remove,
                      color: Color(0xFF4B0036),
                      size: 10,
                    ),
                    onPressed: quantity > 0 ? onDecrease : null,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                  ),
                  Container(
                    width: 14,
                    alignment: Alignment.center,
                    child: Text(
                      '$quantity',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4B0036),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.add,
                      color: Color(0xFF4B0036),
                      size: 10,
                    ),
                    onPressed: onIncrease,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
