import 'package:flutter/material.dart';
import 'package:green_kitchen_app/widgets/nav_bar.dart';

class CustomMealScreen extends StatefulWidget {
  const CustomMealScreen({Key? key}) : super(key: key);

  @override
  State<CustomMealScreen> createState() => _CustomMealScreenState();
}

class _CustomMealScreenState extends State<CustomMealScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NavBar(
      body: Container(
        color: Color(0xFFF5EFE7),
        child: Column(
          children: [
            const SizedBox(height: 24),
            
            // Custom Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Color(0xFF7DD3C0),
                borderRadius: BorderRadius.circular(30),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                labelColor: Color(0xFF4B0036),
                unselectedLabelColor: Colors.white,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'PROTEIN'),
                  Tab(text: 'CARBS'),
                  Tab(text: 'SIDE'),
                  Tab(text: 'SAUCE'),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // TabBarView with scrollable content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _MealPartSelector(title: 'SELECT PROTEIN'),
                  _MealPartSelector(title: 'SELECT CARBS'),
                  _MealPartSelector(title: 'SELECT SIDE'),
                  _MealPartSelector(title: 'SELECT SAUCE'),
                ],
              ),
            ),
            
            // Nutrition info and Suggest button at bottom
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      _NutritionInfo(value: '40', label: 'Calories'),
                      _NutritionInfo(value: '1g', label: 'Protein'),
                      _NutritionInfo(value: '9g', label: 'Carbs'),
                      _NutritionInfo(value: '0g', label: 'Fat'),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF1CC29F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {},
                      child: const Text(
                        'Suggest Sauce',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
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

class _MealPartSelector extends StatelessWidget {
  final String title;
  const _MealPartSelector({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFFF5EFE7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Color(0xFF4B0036),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '1',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF4B0036),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.9,
                children: [
                  _MealItemCard(
                    selected: true,
                    name: 'test 12',
                    count: 1,
                  ),
                  _MealItemCard(
                    selected: false,
                    name: 'Chicken Breast',
                    count: 0,
                  ),
                  _MealItemCard(
                    selected: false,
                    name: 'Salmon Fillet',
                    count: 0,
                  ),
                  _MealItemCard(
                    selected: false,
                    name: 'Organic Tofu',
                    count: 0,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MealItemCard extends StatelessWidget {
  final bool selected;
  final String name;
  final int count;
  
  const _MealItemCard({
    this.selected = false,
    required this.name,
    this.count = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: selected ? Color(0xFF7DD3C0) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Color(0xFFE8B678),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.network(
                  'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=200&q=80',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.fastfood, color: Colors.white, size: 40),
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF4B0036),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.remove,
                      color: Color(0xFF4B0036),
                      size: 20,
                    ),
                    onPressed: () {},
                    padding: EdgeInsets.all(4),
                    constraints: BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                  Container(
                    width: 32,
                    alignment: Alignment.center,
                    child: Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4B0036),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.add,
                      color: Color(0xFF4B0036),
                      size: 20,
                    ),
                    onPressed: () {},
                    padding: EdgeInsets.all(4),
                    constraints: BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
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

class _NutritionInfo extends StatelessWidget {
  final String value;
  final String label;
  const _NutritionInfo({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF4B0036),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
