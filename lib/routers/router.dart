import 'package:green_kitchen_app/screens/auth_screen/email_verification_screen.dart';
//routers
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:green_kitchen_app/screens/auth_screen/login_screen.dart';
import 'package:green_kitchen_app/screens/auth_screen/register_screen.dart';
import 'package:green_kitchen_app/screens/auth_screen/phone_login_screen.dart';
import 'package:green_kitchen_app/screens/custom_meal/custom_meal_review_screen.dart';
import 'package:green_kitchen_app/screens/custom_meal/custom_meal_screen.dart';
import 'package:green_kitchen_app/screens/custom_meal/save_custom_meal/save_custom_meal_review_screen.dart';
import 'package:green_kitchen_app/screens/custom_meal/save_custom_meal/save_custom_meal_screen.dart';
import 'package:green_kitchen_app/screens/custom_meal/save_custom_meal/your_custom_meal_screen.dart';
import 'package:green_kitchen_app/screens/main_layout.dart';
import 'package:green_kitchen_app/screens/profile/profile_screen.dart';
import 'package:green_kitchen_app/screens/profile/tabs/faq_tab.dart';
import 'package:green_kitchen_app/screens/profile/tabs/location_tab.dart';
import 'package:green_kitchen_app/screens/profile/tabs/feedback_tab.dart';
import 'package:green_kitchen_app/screens/profile/tabs/about_tab.dart';
import 'package:green_kitchen_app/screens/profile/tabs/policy_tab.dart';
import 'package:green_kitchen_app/screens/profile/membership_screen.dart';
import 'package:green_kitchen_app/screens/profile/order_history_screen.dart';

import 'package:green_kitchen_app/screens/menumeal/menu_meal_screen.dart';
// import 'package:green_kitchen_app/screens/week_meal/week_meal_screen.dart';

import 'package:green_kitchen_app/screens/menumeal/menu_detail_screen.dart';

import 'package:green_kitchen_app/screens/cart/cart_screen.dart';
import 'package:green_kitchen_app/screens/payment/payment_screen.dart';
import 'package:green_kitchen_app/screens/chat/chat_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const MainLayout(initialIndex: 0);
      },
    ),
    GoRoute(
      path: '/chat',
      builder: (BuildContext context, GoRouterState state) {
        return const ChatScreen();
      },
    ),
    GoRoute(
      path: '/auth/login',
      builder: (BuildContext context, GoRouterState state) {
        return const LoginScreen();
      },
    ),
    GoRoute(
      path: '/auth/register',
      builder: (BuildContext context, GoRouterState state) {
        return const RegisterScreen();
      },
    ),
    GoRoute(
      path: '/auth/phone-login',
      builder: (BuildContext context, GoRouterState state) {
        return const PhoneLoginScreen();
      },
    ),
    GoRoute(
      path: '/auth/email-verification',
      builder: (BuildContext context, GoRouterState state) {
        return const EmailVerificationScreen();
      },
    ),
    GoRoute(
      path: '/menu-meal',
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
    // GoRoute(
    //   path: '/weekmeal',
    //   builder: (BuildContext context, GoRouterState state) {
    //     return const WeekMealScreen();
    //   },
    // ),
    GoRoute(
      path: '/ai-chat',
      builder: (BuildContext context, GoRouterState state) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              'AI Chat',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/'),
            ),
          ),
          body: const Center(child: Text('AI Chat Screen - Coming Soon!')),
        );
      },
    ),
    GoRoute(
      path: '/profile',
      builder: (BuildContext context, GoRouterState state) {
        return const ProfileScreen();
      },
    ),
    GoRoute(
      path: '/profile/accountinfo',
      builder: (BuildContext context, GoRouterState state) {
        return const ProfileScreen();
      },
    ),
    GoRoute(
      path: '/profile/membership',
      builder: (BuildContext context, GoRouterState state) {
        return const MembershipScreen();
      },
    ),
    GoRoute(
      path: '/profile/orderhistory',
      builder: (BuildContext context, GoRouterState state) {
        return const OrderHistoryScreen();
      },
    ),
    GoRoute(
      path: '/faq',
      builder: (BuildContext context, GoRouterState state) {
        return const FaqTab();
      },
    ),
    GoRoute(
      path: '/location',
      builder: (BuildContext context, GoRouterState state) {
        return const LocationTab();
      },
    ),
    GoRoute(
      path: '/feedback',
      builder: (BuildContext context, GoRouterState state) {
        return const FeedbackTab();
      },
    ),
    GoRoute(

      path: '/about',
      builder: (BuildContext context, GoRouterState state) {
        return const AboutTab();
      },
    ),
    GoRoute(
      path: '/policy',
      builder: (BuildContext context, GoRouterState state) {
        return const PolicyTab();
      },
    ),
    GoRoute(
      path: '/custom-meal',

      builder: (BuildContext context, GoRouterState state) {
        // return const SavedCustomMealsScreen();
        return const MenuMealScreen();
      },
      routes: <RouteBase>[
        GoRoute(
          path: '/review',
          builder: (BuildContext context, GoRouterState state) {
            return const CustomMealReviewScreen();
          },
        ),
      ],
    ),
    GoRoute(
      path: '/saved-custom-meal',
      builder: (BuildContext context, GoRouterState state) {
        return const SavedCustomMealsScreen(); // Keep this for saved meals
      },
      routes: <RouteBase>[
        GoRoute(
          path: '/create', // Add this subroute for creation
          builder: (BuildContext context, GoRouterState state) {
            return const YourCustomMealScreen(); // Your custom meal creation screen
          },
        ),
        GoRoute(
          path: '/review/:id',
          builder: (BuildContext context, GoRouterState state) {
            return const SaveCustomMealReviewScreen();
          },
        ),
      ],
    ),
    GoRoute(
      path: '/payment',
      builder: (BuildContext context, GoRouterState state) {
        return const PaymentScreen();
      },
    ),
  ],
);
