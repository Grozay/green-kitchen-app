import 'package:flutter/material.dart';
import 'package:green_kitchen_app/models/week_meal.dart';
import 'package:green_kitchen_app/services/week_meal_service.dart';
import 'package:green_kitchen_app/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:green_kitchen_app/widgets/week_meal/week_meal_card.dart';

class WeekMealScreen extends StatefulWidget {
  const WeekMealScreen({super.key});

  @override
  State<WeekMealScreen> createState() => _WeekMealScreenState();
}

class _WeekMealScreenState extends State<WeekMealScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController; // Make it nullable
  WeekMeal? weekMeal; // New: Store fetched data
  bool loading = true; // New: Loading state
  String? error; // New: Error state

  @override
  void initState() {
    super.initState();
    _loadWeekMeal(); // New: Fetch data on init
  }

  @override
  void dispose() {
    _tabController?.dispose(); // Safe dispose
    super.dispose();
  }

  // New: Method to fetch week meal data
  Future<void> _loadWeekMeal() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      // Hardcoded type and date as per your example; make dynamic if needed
      weekMeal = await WeekMealService.getWeekMealPlan('low', '2025-08-25');
      // Initialize tab controller only once after data is loaded
      _tabController = TabController(
        length: weekMeal!.days.length,
        vsync: this,
      );
    } catch (e) {
      error = 'Failed to load week meal data: $e';
    } finally {
      setState(() => loading = false);
    }
  }

  String _getDayName(String day) {
    switch (day) {
      case 'T2':
        return 'Mon';
      case 'T3':
        return 'Tue';
      case 'T4':
        return 'Wed';
      case 'T5':
        return 'Thu';
      case 'T6':
        return 'Fri';
      case 'T7':
        return 'Sat';
      case 'CN':
        return 'Sun';
      default:
        return day;
    }
  }

  @override
  Widget build(BuildContext context) {
    // New: Handle loading and error states
    if (loading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () {
              GoRouter.of(context).pop();
            },
          ),
          title: const Text(
            'Week Meal Plan',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          centerTitle: false,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (error != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () {
              GoRouter.of(context).pop();
            },
          ),
          title: const Text(
            'Week Meal Plan',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          centerTitle: false,
        ),
        body: Center(child: Text(error!)),
      );
    }

    // Check if weekMeal and tabController are available
    if (weekMeal == null || _tabController == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () {
              GoRouter.of(context).pop();
            },
          ),
          title: const Text(
            'Week Meal Plan',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          centerTitle: false,
        ),
        body: const Center(child: Text('No data available')),
      );
    }

    // New: Dynamic title and date range from API
    String title =
        'MENU ${weekMeal?.type?.toUpperCase() ?? 'UNKNOWN'} CALORIES';
    String dateRange = weekMeal != null
        ? '${DateTime.parse(weekMeal!.weekStart).day.toString().padLeft(2, '0')}/${DateTime.parse(weekMeal!.weekStart).month.toString().padLeft(2, '0')} - ${DateTime.parse(weekMeal!.weekEnd).day.toString().padLeft(2, '0')}/${DateTime.parse(weekMeal!.weekEnd).month.toString().padLeft(2, '0')}'
        : '01/09 - 05/09'; // Fallback

    // Generate tabs dynamically
    List<Tab> tabs = weekMeal!.days.map((day) {
      String dayName = _getDayName(day.day);
      String date =
          '${DateTime.parse(day.date).day.toString().padLeft(2, '0')}/${DateTime.parse(day.date).month.toString().padLeft(2, '0')}';
      return Tab(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(dayName, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(date, style: const TextStyle(fontSize: 12)),
          ],
        ),
      );
    }).toList();

    // Generate tab view children dynamically
    List<Widget> tabViews = weekMeal!.days.map((day) {
      String dayName = _getDayName(day.day);
      String date = DateTime.parse(day.date).toString().split(' ')[0];
      int dayIndex = weekMeal!.days.indexOf(day) + 1;
      return _buildDayMeals(dayName, date, _getMealsForDay(dayIndex));
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () {
            GoRouter.of(context).pop();
          },
        ),
        title: const Text(
          'Week Meal Plan',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                title, // Dynamic title
                style: TextStyle(
                  color: AppColors.primary, // Use app primary color
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              // Improved UI for week navigation
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      dateRange, // Dynamic date range
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: TextButton.icon(
                            onPressed: () {},
                            icon: Icon(
                              Icons.chevron_left,
                              color: AppColors.primary,
                            ),
                            label: Text(
                              'PRE WEEK',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'NEXT WEEK',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors
                        .secondary, // Use app secondary color as main theme
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () {},
                  child: const Text(
                    'Order Now',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Tab Bar for days
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
                  controller: _tabController!, // Use the non-null assertion
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.primary, // Use app primary
                  indicator: BoxDecoration(
                    color: AppColors.primary, // Use app primary
                    borderRadius: BorderRadius.circular(12),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorPadding: EdgeInsets.all(4),
                  tabs: tabs, // Dynamic tabs
                ),
              ),
              const SizedBox(height: 16),

              // Tab View Content
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: TabBarView(
                  controller: _tabController!, // Use the non-null assertion
                  children: tabViews, // Dynamic tab views
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Updated: Use API data instead of hardcoded
  List<Map<String, dynamic>> _getMealsForDay(int day) {
    if (weekMeal == null || weekMeal!.days.length < day) {
      return []; // Fallback if no data
    }
    var dayData = weekMeal!.days[day - 1]; // day=1 -> days[0] (Mon)
    List<Map<String, dynamic>> meals = [];

    // Add meal1 if exists
    if (dayData.meal1 != null) {
      meals.add({
        'title': dayData.meal1!.title,
        'desc': dayData.meal1!.description,
        'calories': dayData.meal1!.calories.toString(),
        'protein': '${dayData.meal1!.protein}g',
        'carbs': '${dayData.meal1!.carbs}g',
        'fat': '${dayData.meal1!.fat}g',
        'price':
            dayData.meal1!.price?.toStringAsFixed(2) ??
            '0.00', // Handle null price
        'image': dayData.meal1!.image, // Add image
      });
    }
    // Add meal2 if exists
    if (dayData.meal2 != null) {
      meals.add({
        'title': dayData.meal2!.title,
        'desc': dayData.meal2!.description,
        'calories': dayData.meal2!.calories.toString(),
        'protein': '${dayData.meal2!.protein}g',
        'carbs': '${dayData.meal2!.carbs}g',
        'fat': '${dayData.meal2!.fat}g',
        'price': dayData.meal2!.price?.toStringAsFixed(2) ?? '0.00',
        'image': dayData.meal2!.image, // Add image
      });
    }
    // Add meal3 if exists
    if (dayData.meal3 != null) {
      meals.add({
        'title': dayData.meal3!.title,
        'desc': dayData.meal3!.description,
        'calories': dayData.meal3!.calories.toString(),
        'protein': '${dayData.meal3!.protein}g',
        'carbs': '${dayData.meal3!.carbs}g',
        'fat': '${dayData.meal3!.fat}g',
        'price': dayData.meal3!.price?.toStringAsFixed(2) ?? '0.00',
        'image': dayData.meal3!.image, // Add image
      });
    }
    return meals;
  }

  Widget _buildDayMeals(
    String dayName,
    String date,
    List<Map<String, dynamic>> meals,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: meals.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> meal = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: MealWeekCard(
              // Changed from _MealCard to MealCard
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
      case 0:
        return 'MEAL 1 (6:00 - 10:00)';
      case 1:
        return 'MEAL 2 (11:00 - 14:00)';
      case 2:
        return 'MEAL 3 (17:00 - 20:00)';
      default:
        return 'MEAL';
    }
  }

  IconData _getMealIcon(int index) {
    switch (index) {
      case 0:
        return Icons.wb_sunny;
      case 1:
        return Icons.lunch_dining;
      case 2:
        return Icons.set_meal;
      default:
        return Icons.restaurant;
    }
  }
}
