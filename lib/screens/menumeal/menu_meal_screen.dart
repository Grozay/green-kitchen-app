import 'package:flutter/material.dart';
import 'package:green_kitchen_app/widgets/nav_bar.dart';

class MenuMealScreen extends StatefulWidget {
  const MenuMealScreen({super.key});

  @override
  State<MenuMealScreen> createState() => _MenuMealScreenState();
}

class _MenuMealScreenState extends State<MenuMealScreen> {
  String selectedFilter = 'HIGH';

  @override
  Widget build(BuildContext context) {
    return NavBar(
      cartCount: 3,
      body: Container(
        color: Color(0xFFF5F5F5),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                // Filter Chips Container
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Color(0xFF7DD3C0),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildFilterChip('HIGH', selectedFilter == 'HIGH'),
                        _buildFilterChip('BALANCE', selectedFilter == 'BALANCE'),
                        _buildFilterChip('LOW', selectedFilter == 'LOW'),
                        _buildFilterChip('VEG', selectedFilter == 'VEG'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'HIGH PROTEIN',
                  style: TextStyle(
                    color: Color(0xFF4B0036),
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 24),
                // Meal Cards Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.8,
                  children: const [
                    MealCard(
                      tag: 'H1',
                      calories: 520,
                      name: 'High Protein Power Bowl',
                      protein: 45,
                      carbs: 25,
                      fat: 22,
                      price: 18.99,
                    ),
                    MealCard(
                      tag: 'H2',
                      calories: 550,
                      name: 'Double Chicken Quinoa Bowl',
                      protein: 48,
                      carbs: 28,
                      fat: 24,
                      price: 19.99,
                    ),
                    MealCard(
                      tag: 'H3',
                      calories: 580,
                      name: 'High Protein Power Bowl',
                      protein: 45,
                      carbs: 25,
                      fat: 22,
                      price: 18.99,
                    ),
                    MealCard(
                      tag: 'H4',
                      calories: 560,
                      name: 'Double Chicken Quinoa Bowl',
                      protein: 48,
                      carbs: 28,
                      fat: 24,
                      price: 19.99,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Color(0xFF4B0036) : Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class MealCard extends StatelessWidget {
  final String tag;
  final int calories;
  final String name;
  final int protein;
  final int carbs;
  final int fat;
  final double price;

  const MealCard({
    super.key,
    required this.tag,
    required this.calories,
    required this.name,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          // Image and Tag Section
          Stack(
            children: [
              Container(
                height: 100,
                width: double.infinity,
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=400&q=80',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Color(0xFF1CC29F),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      tag,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFF4B0036), width: 1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$calories CALORIES',
                style: const TextStyle(
                  color: Color(0xFF4B0036),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 6),
          
          // Meal Name
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              name,
              style: const TextStyle(
                color: Color(0xFF4B0036),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          const SizedBox(height: 6),
          
          // Dotted line
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SizedBox(
              height: 1,
              child: CustomPaint(
                painter: DottedLinePainter(),
                size: Size(double.infinity, 1),
              ),
            ),
          ),
          
          const SizedBox(height: 6),
          
          // Nutrition Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '$protein',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF4B0036),
                      ),
                    ),
                    Text(
                      'Protein',
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '$carbs',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF4B0036),
                      ),
                    ),
                    Text(
                      'Carbs',
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '$fat',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF4B0036),
                      ),
                    ),
                    Text(
                      'Fat',
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 6),
          
          // Price and Cart Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${price.toStringAsFixed(2)} VND',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF4B0036),
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Color(0xFF1CC29F),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.shopping_cart,
                      color: Colors.white,
                      size: 16,
                    ),
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      // Add to cart functionality
                    },
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
        ],
      ),
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
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
