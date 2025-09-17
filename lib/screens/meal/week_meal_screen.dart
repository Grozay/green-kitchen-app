import 'package:flutter/material.dart';
import 'package:green_kitchen_app/widgets/nav_bar.dart';

class WeekMealScreen extends StatefulWidget {
  const WeekMealScreen({super.key});

  @override
  State<WeekMealScreen> createState() => _WeekMealScreenState();
}

class _WeekMealScreenState extends State<WeekMealScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NavBar(
      cartCount: 3,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text(
                'THỰC ĐƠN LOW CALORIES',
                style: TextStyle(
                  color: Color(0xFF4B0036),
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.chevron_left, color: Color(0xFF4B0036)),
                    label: const Text('TUẦN TRƯỚC', style: TextStyle(color: Color(0xFF4B0036))),
                  ),
                  const Text(
                    '01/09 - 05/09',
                    style: TextStyle(
                      color: Color(0xFF4B0036),
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.chevron_right, color: Color(0xFF4B0036)),
                    label: const Text('TUẦN SAU', style: TextStyle(color: Color(0xFF4B0036))),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1CC29F),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  onPressed: () {},
                  child: const Text('Đặt Ngay', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),
              
              // Tab Bar cho các ngày
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: Colors.white,
                  unselectedLabelColor: Color(0xFF4B0036),
                  indicator: BoxDecoration(
                    color: Color(0xFF4B0036),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorPadding: EdgeInsets.all(4),
                  tabs: const [
                    Tab(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('T2', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('01.09', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    Tab(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('T3', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('02.09', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    Tab(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('T4', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('03.09', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    Tab(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('T5', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('04.09', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    Tab(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('T6', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('05.09', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Header meal types
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF4B0036),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, color: Colors.white, size: 18),
                            SizedBox(width: 6),
                            Text('NGÀY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            Icon(Icons.wb_sunny, color: Color(0xFF1CC29F), size: 18),
                            SizedBox(width: 6),
                            Text('MEAL 1 (6:00 - 10:00)', style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            Icon(Icons.lunch_dining, color: Color(0xFF1CC29F), size: 18),
                            SizedBox(width: 6),
                            Text('MEAL 2 (11:00 - 14:00)', style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            Icon(Icons.set_meal, color: Color(0xFF1CC29F), size: 18),
                            SizedBox(width: 6),
                            Text('MEAL 3 (17:00 - 20:00)', style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Tab View Content
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildDayMeals('Thứ 2', '01.09', _getMealsForDay(1)),
                    _buildDayMeals('Thứ 3', '02.09', _getMealsForDay(2)),
                    _buildDayMeals('Thứ 4', '03.09', _getMealsForDay(3)),
                    _buildDayMeals('Thứ 5', '04.09', _getMealsForDay(4)),
                    _buildDayMeals('Thứ 6', '05.09', _getMealsForDay(5)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayMeals(String dayName, String date, List<Map<String, dynamic>> meals) {
    return SingleChildScrollView(
      child: Column(
        children: meals.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> meal = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _MealCard(
              mealType: _getMealType(index),
              mealIcon: _getMealIcon(index),
              meal: meal,
              dayName: dayName,
              date: date,
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getMealType(int index) {
    switch (index) {
      case 0: return 'MEAL 1 (6:00 - 10:00)';
      case 1: return 'MEAL 2 (11:00 - 14:00)';
      case 2: return 'MEAL 3 (17:00 - 20:00)';
      default: return 'MEAL';
    }
  }

  IconData _getMealIcon(int index) {
    switch (index) {
      case 0: return Icons.wb_sunny;
      case 1: return Icons.lunch_dining;
      case 2: return Icons.set_meal;
      default: return Icons.restaurant;
    }
  }

  List<Map<String, dynamic>> _getMealsForDay(int day) {
    // Sample meal data for each day
    Map<int, List<Map<String, dynamic>>> mealsData = {
      1: [ // Monday
        {
          'title': 'Mediterranean Chicken Bowl',
          'desc': 'Grilled chicken with quinoa, cucumber, tomatoes and feta cheese',
          'calories': '420',
          'protein': '26g',
          'carbs': '32g',
          'fat': '16g',
          'price': '15.99',
        },
        {
          'title': 'Salmon Avocado Bowl',
          'desc': 'Fresh salmon with avocado, mixed greens and lemon dressing',
          'calories': '480',
          'protein': '30g',
          'carbs': '25g',
          'fat': '22g',
          'price': '18.99',
        },
        {
          'title': 'Turkey Sweet Potato Bowl',
          'desc': 'Lean turkey with roasted sweet potato and steamed broccoli',
          'calories': '390',
          'protein': '28g',
          'carbs': '35g',
          'fat': '14g',
          'price': '16.99',
        },
      ],
      2: [ // Tuesday
        {
          'title': 'Beef Brown Rice Bowl',
          'desc': 'Beef steak with brown rice and mixed vegetables',
          'calories': '460',
          'protein': '29g',
          'carbs': '36g',
          'fat': '19g',
          'price': '17.99',
        },
        {
          'title': 'Tuna Poke Bowl',
          'desc': 'Fresh tuna with rice, cucumber and edamame',
          'calories': '440',
          'protein': '32g',
          'carbs': '28g',
          'fat': '18g',
          'price': '19.99',
        },
        {
          'title': 'Chicken Caesar Salad',
          'desc': 'Grilled chicken with romaine, parmesan and caesar dressing',
          'calories': '380',
          'protein': '35g',
          'carbs': '15g',
          'fat': '20g',
          'price': '14.99',
        },
      ],
      3: [ // Wednesday  
        {
          'title': 'Shrimp Quinoa Bowl',
          'desc': 'Grilled shrimp with quinoa and mixed vegetables',
          'calories': '400',
          'protein': '25g',
          'carbs': '30g',
          'fat': '16g',
          'price': '18.99',
        },
        {
          'title': 'Chicken Teriyaki Bowl',
          'desc': 'Teriyaki chicken with steamed rice and vegetables',
          'calories': '450',
          'protein': '28g',
          'carbs': '38g',
          'fat': '17g',
          'price': '16.99',
        },
        {
          'title': 'Vegetarian Buddha Bowl',
          'desc': 'Mixed vegetables, tofu and quinoa with tahini dressing',
          'calories': '360',
          'protein': '18g',
          'carbs': '42g',
          'fat': '14g',
          'price': '13.99',
        },
      ],
      4: [ // Thursday
        {
          'title': 'Pork Tenderloin Bowl',
          'desc': 'Lean pork with wild rice and roasted vegetables',
          'calories': '470',
          'protein': '31g',
          'carbs': '34g',
          'fat': '19g',
          'price': '17.99',
        },
        {
          'title': 'Fish Tacos Bowl',
          'desc': 'White fish with cabbage slaw and avocado',
          'calories': '410',
          'protein': '27g',
          'carbs': '29g',
          'fat': '18g',
          'price': '16.99',
        },
        {
          'title': 'Lamb Mediterranean Bowl',
          'desc': 'Seasoned lamb with couscous and Mediterranean vegetables',
          'calories': '490',
          'protein': '33g',
          'carbs': '31g',
          'fat': '22g',
          'price': '21.99',
        },
      ],
      5: [ // Friday
        {
          'title': 'Cod Fish Bowl',
          'desc': 'Baked cod with quinoa and steamed asparagus',
          'calories': '380',
          'protein': '29g',
          'carbs': '28g',
          'fat': '15g',
          'price': '18.99',
        },
        {
          'title': 'Chicken Fajita Bowl',
          'desc': 'Seasoned chicken with peppers, onions and brown rice',
          'calories': '440',
          'protein': '30g',
          'carbs': '35g',
          'fat': '17g',
          'price': '15.99',
        },
        {
          'title': 'Steak Power Bowl',
          'desc': 'Grilled steak with sweet potato and green beans',
          'calories': '520',
          'protein': '35g',
          'carbs': '32g',
          'fat': '23g',
          'price': '22.99',
        },
      ],
    };
    
    return mealsData[day] ?? [];
  }
}

class _MealCard extends StatelessWidget {
  final String mealType;
  final IconData mealIcon;
  final Map<String, dynamic> meal;
  final String dayName;
  final String date;

  const _MealCard({
    required this.mealType,
    required this.mealIcon,
    required this.meal,
    required this.dayName,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(0xFF1CC29F),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(mealIcon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mealType,
                        style: const TextStyle(
                          color: Color(0xFF4B0036),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '$dayName, $date',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1CC29F),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  onPressed: () {
                    // Add to cart functionality
                  },
                  child: const Text(
                    'Thêm',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              meal['title'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF4B0036),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              meal['desc'],
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Calories: ${meal['calories']} | Protein: ${meal['protein']}',
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    Text(
                      'Carbs: ${meal['carbs']} | Fat: ${meal['fat']}',
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
                Text(
                  '${meal['price']} VNĐ',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4B0036),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
