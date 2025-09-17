import 'package:green_kitchen_app/screens/profile/profile_screen.dart';
//routers
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:green_kitchen_app/screens/authScreen/loginScreen.dart';
import 'package:green_kitchen_app/screens/authScreen/registerScreen.dart';

import 'package:green_kitchen_app/screens/menumeal/menu_meal_screen.dart';
import 'package:green_kitchen_app/screens/meal/week_meal_screen.dart';

import 'package:green_kitchen_app/screens/menumeal/menu_detail_screen.dart';
import 'package:green_kitchen_app/screens/meal/custom_meal_screen.dart';

import 'package:green_kitchen_app/screens/cart/cart_screen.dart';
import 'package:green_kitchen_app/screens/post/post_screen.dart';
import 'package:green_kitchen_app/screens/payment/payment_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return LoginScreen();
      },
    ),
    GoRoute(
      path: '/register',
      builder: (BuildContext context, GoRouterState state) {
        return const RegisterScreen();
      },
    ),
    GoRoute(
      path: '/menumeal',
      builder: (BuildContext context, GoRouterState state) {
        return const MenuMealScreen();
      },
      routes: <RouteBase>[
        GoRoute(
          path: '/:slug',
          builder: (context, state) {
            final slug = state.pathParameters['slug']!;
            return MenuDetailScreen(slug: slug);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/cart',
      builder: (BuildContext context, GoRouterState state) {
        return const CartScreen();
      },
    ),
    GoRoute(
      path: '/articles',
      builder: (BuildContext context, GoRouterState state) {
        return const PostScreen();
      },
    ),
    GoRoute(
      path: '/weekmeal',
      builder: (BuildContext context, GoRouterState state) {
        return const WeekMealScreen();
      },
    ),
    GoRoute(
      path: '/profile',
      builder: (BuildContext context, GoRouterState state) {
        return const ProfileScreen();
      },
    ),
    GoRoute(
      path: '/custommeal',
      builder: (BuildContext context, GoRouterState state) {
        return const CustomMealScreen();
      },
    ),
    // GoRoute(
    //   path: '/meal-detail',
    //   builder: (BuildContext context, GoRouterState state) {
    //     return const MealDetailScreen();
    //   },
    // ),
    GoRoute(
      path: '/payment',
      builder: (BuildContext context, GoRouterState state) {
        return const PaymentScreen();
      },
    ),
  ],
);
