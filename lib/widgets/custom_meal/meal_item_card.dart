import 'package:flutter/material.dart';
import 'package:green_kitchen_app/models/ingredient.dart';
import 'package:intl/intl.dart';  // Add this import for NumberFormat

class MealItemCard extends StatefulWidget {
  final Ingredient item;
  final int quantity;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const MealItemCard({
    super.key,
    required this.item,
    required this.quantity,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  State<MealItemCard> createState() => _MealItemCardState();
}

class _MealItemCardState extends State<MealItemCard> {
  bool isFlipped = false;

  void _flipCard() {
    setState(() {
      isFlipped = !isFlipped;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flipCard,
      child: isFlipped ? _buildBackSide() : _buildFrontSide(),
    );
  }

  Widget _buildFrontSide() {
    return Container(
      // height: 550, // Removed fixed height to prevent overflow
      decoration: BoxDecoration(
        color: widget.quantity > 0 ? Color(0xFF7DD3C0) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Color(0xFFE8B678),
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: Image.network(
                        widget.item.image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.fastfood, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Item name
                  SizedBox(
                    height: 24,
                    child: Text(
                      widget.item.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
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
                    '${NumberFormat('#,###', 'vi_VN').format(widget.item.price)} VND',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                      color: Color(0xFF4B0036).withOpacity(0.7),
                    ),
                  ),
                  // Out of stock text
                  // if (widget.item.stock == 0)
                  //   Text(
                  //     'Out of Stock',
                  //     style: TextStyle(
                  //       fontSize: 10,
                  //       color: Colors.red,
                  //       fontWeight: FontWeight.bold,
                  //     ),
                  //   ),
                ],
              ),
            ),
          ),
          // Quantity controls
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildQuantityControls(),
          ),
        ],
      ),
    );
  }

  Widget _buildBackSide() {
    return Container(
      // height: 550, // Removed fixed height to prevent overflow
      decoration: BoxDecoration(
        color: widget.quantity > 0 ? Color(0xFF7DD3C0) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Nutrition info
                  _buildNutrientRow('Calories', '${widget.item.calories}'),
                  _buildNutrientRow('Protein', '${widget.item.protein}g'),
                  _buildNutrientRow('Carbs', '${widget.item.carbs}g'),
                  _buildNutrientRow('Fat', '${widget.item.fat}g'),
                  const SizedBox(height: 16),
                  // Description
                  if (widget.item.description.isNotEmpty)
                    Text(
                      '"${widget.item.description}"',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 10,
                        color: Color(0xFF4B0036),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  // Out of stock text
                  if (widget.item.stock != null && widget.item.stock == 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Out of Stock',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Quantity controls
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildQuantityControls(),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Color(0xFF4B0036),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4B0036),
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityControls() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 0.5, vertical: 0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              Icons.remove,
              color: widget.quantity > 0 ? Color(0xFF4B0036) : Colors.grey,
              size: 24,
            ),
            onPressed: widget.quantity > 0 ? widget.onDecrease : null,
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(
              minWidth: 24,
              minHeight: 24,
            ),
          ),
          Container(
            width: 24,
            alignment: Alignment.center,
            child: Text(
              '${widget.quantity}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4B0036),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.add,
              color: (widget.item.stock == null || widget.item.stock! > widget.quantity) ? Color(0xFF4B0036) : Colors.grey,
              size: 24,
            ),
            onPressed: (widget.item.stock == null || widget.item.stock! > widget.quantity) ? widget.onIncrease : null,
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(
              minWidth: 24,
              minHeight: 24,
            ),
          ),
        ],
      ),
    );
  }
}
