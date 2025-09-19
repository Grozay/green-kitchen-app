import 'menu_meal.dart';

class WeekMeal {
  final int id;
  final String? type; // Made nullable to handle null in JSON
  final String weekStart;
  final String weekEnd;
  final List<WeekMealDay> days;

  WeekMeal({
    required this.id,
    required this.type,
    required this.weekStart,
    required this.weekEnd,
    required this.days,
  });

  factory WeekMeal.fromJson(Map<String, dynamic> json) {
    return WeekMeal(
      id: json['id'],
      type: json['type'] as String?, // Handle null
      weekStart: json['weekStart'],
      weekEnd: json['weekEnd'],
      days: (json['days'] as List).map((e) => WeekMealDay.fromJson(e)).toList(),
    );
  }
}

class WeekMealDay {
  final int id;
  final String day;
  final String date;
  final String? type; // Made nullable to handle null in JSON
  final MenuMeal? meal1;
  final MenuMeal? meal2;
  final MenuMeal? meal3;

  WeekMealDay({
    required this.id,
    required this.day,
    required this.date,
    required this.type,
    this.meal1,
    this.meal2,
    this.meal3,
  });

  factory WeekMealDay.fromJson(Map<String, dynamic> json) {
    return WeekMealDay(
      id: json['id'],
      day: json['day'],
      date: json['date'],
      type: json['type'] as String?, // Handle null
      meal1: json['meal1'] != null ? MenuMeal.fromJson(json['meal1']) : null,
      meal2: json['meal2'] != null ? MenuMeal.fromJson(json['meal2']) : null,
      meal3: json['meal3'] != null ? MenuMeal.fromJson(json['meal3']) : null,
    );
  }
}