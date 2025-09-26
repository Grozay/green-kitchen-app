import 'package:green_kitchen_app/screens/auth_screen/email_verification_screen.dart';
import 'package:green_kitchen_app/screens/auth_screen/reset_password_web_screen.dart';
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
import 'package:green_kitchen_app/screens/home_screen/home_screen.dart';
import 'package:green_kitchen_app/screens/profile/profile_screen.dart';
import 'package:green_kitchen_app/screens/other_screens/faq_tab.dart';
import 'package:green_kitchen_app/screens/other_screens/location_tab.dart';
import 'package:green_kitchen_app/screens/other_screens/feedback_tab.dart';
import 'package:green_kitchen_app/screens/other_screens/about_tab.dart';
import 'package:green_kitchen_app/screens/other_screens/policy_tab.dart';
import 'package:green_kitchen_app/screens/profile/membership_screen.dart';
import 'package:green_kitchen_app/screens/profile/order_history_screen.dart';
import 'package:green_kitchen_app/screens/menu_screen/menu_screen.dart';

import 'package:green_kitchen_app/screens/menumeal/menu_meal_screen.dart';
// import 'package:green_kitchen_app/screens/week_meal/week_meal_screen.dart';

import 'package:green_kitchen_app/screens/menumeal/menu_detail_screen.dart';

import 'package:green_kitchen_app/screens/cart/cart_screen.dart';
import 'package:green_kitchen_app/screens/checkout/checkout_screen.dart';
import 'package:green_kitchen_app/screens/chat/chat_screen.dart';
import 'package:green_kitchen_app/screens/more_screen/more_screen.dart';
import 'package:green_kitchen_app/screens/tracking_screen/tracking_screen.dart';

/// Helper function to create custom page transitions
CustomTransitionPage<T> createCustomTransitionPage<T>({
  required LocalKey key,
  required Widget child,
  Offset begin = const Offset(1.0, 0.0),
  Offset end = Offset.zero,
  Curve curve = Curves.easeInOutCubic,
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
    },
  );
}

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => createCustomTransitionPage(
        key: state.pageKey,
        child: const HomeScreen(),
        begin: Offset.zero,
        end: Offset.zero,
      ),
    ),
    GoRoute(
      path: '/chat',
      pageBuilder: (context, state) => createCustomTransitionPage(
        key: state.pageKey,
        child: const ChatScreen(),
      ),
    ),
    GoRoute(
      path: '/auth/login',
      pageBuilder: (context, state) => createCustomTransitionPage(
        key: state.pageKey,
        child: const LoginScreen(),
        begin: const Offset(0.0, 1.0),
      ),
    ),
    GoRoute(
      path: '/auth/register',
      pageBuilder: (context, state) => createCustomTransitionPage(
        key: state.pageKey,
        child: const RegisterScreen(),
        begin: const Offset(0.0, 1.0),
      ),
    ),
    GoRoute(
      path: '/auth/phone-login',
      pageBuilder: (context, state) => createCustomTransitionPage(
        key: state.pageKey,
        child: const PhoneLoginScreen(),
        begin: const Offset(0.0, 1.0),
      ),
    ),
    GoRoute(
      path: '/auth/email-verification',
      pageBuilder: (context, state) => createCustomTransitionPage(
        key: state.pageKey,
        child: const EmailVerificationScreen(),
        begin: const Offset(0.0, 1.0),
      ),
    ),
    GoRoute(
      path: '/auth/reset-password-web',
      pageBuilder: (context, state) => createCustomTransitionPage(
        key: state.pageKey,
        child: const ResetPasswordWebScreen(),
        begin: const Offset(0.0, 1.0),
      ),
    ),
    GoRoute(
      path: '/menu-meal',
      pageBuilder: (context, state) => createCustomTransitionPage(
        key: state.pageKey,
        child: const MenuMealScreen(),
      ),
      routes: <RouteBase>[
        GoRoute(
          path: '/:slug',
          pageBuilder: (context, state) {
            final slug = state.pathParameters['slug']!;
            return createCustomTransitionPage(
              key: state.pageKey,
              child: MenuDetailScreen(slug: slug),
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: '/cart',
      pageBuilder: (context, state) => createCustomTransitionPage(
        key: state.pageKey,
        child: const CartScreen(),
      ),
    ),
    // GoRoute(
    //   path: '/weekmeal',
    //   builder: (BuildContext context, GoRouterState state) {
    //     return const WeekMealScreen();
    //   },
    // ),
    GoRoute(
      path: '/ai-chat',
      pageBuilder: (context, state) => createCustomTransitionPage(
        key: state.pageKey,
        child: Scaffold(
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
        ),
      ),
    ),
    GoRoute(
      path: '/profile',
      pageBuilder: (context, state) => createCustomTransitionPage(
        key: state.pageKey,
        child: const ProfileScreen(),
        begin: const Offset(0.0, 1.0),
      ),
    ),
    GoRoute(
      path: '/profile/accountinfo',
      pageBuilder: (context, state) => createCustomTransitionPage(
        key: state.pageKey,
        child: const ProfileScreen(),
        begin: const Offset(0.0, 1.0),
      ),
    ),
    GoRoute(
      path: '/profile/membership',
      pageBuilder: (context, state) => createCustomTransitionPage(
        key: state.pageKey,
        child: const MembershipScreen(),
        begin: const Offset(0.0, 1.0),
      ),
    ),
    GoRoute(
      path: '/profile/orderhistory',
      pageBuilder: (context, state) => createCustomTransitionPage(
        key: state.pageKey,
        child: const OrderHistoryScreen(),
        begin: const Offset(0.0, 1.0),
      ),
    ),
    GoRoute(
      path: '/faq',
      pageBuilder: (context, state) => createCustomTransitionPage(
        key: state.pageKey,
        child: const FaqTab(),
        begin: const Offset(0.0, 1.0),
      ),
    ),
    GoRoute(
      path: '/location',
      pageBuilder: (context, state) => createCustomTransitionPage(
        key: state.pageKey,
        child: const LocationTab(),
        begin: const Offset(0.0, 1.0),
      ),
    ),
    GoRoute(
      path: '/feedback',
      pageBuilder: (context, state) => createCustomTransitionPage(
        key: state.pageKey,
        child: const FeedbackTab(),
        begin: const Offset(0.0, 1.0),
      ),
    ),
    GoRoute(
      path: '/about',
      pageBuilder: (context, state) => createCustomTransitionPage(
        key: state.pageKey,
        child: const AboutTab(),
        begin: const Offset(0.0, 1.0),
      ),
    ),
    GoRoute(
      path: '/policy',
      pageBuilder: (context, state) => createCustomTransitionPage(
        key: state.pageKey,
        child: const PolicyTab(),
        begin: const Offset(0.0, 1.0),
      ),
    ),
    GoRoute(
      path: '/custom-meal',
      pageBuilder: (context, state) => createCustomTransitionPage(
        key: state.pageKey,
        child: const CustomMealScreen(),
      ),
      routes: <RouteBase>[
        GoRoute(
          path: '/review',
          pageBuilder: (context, state) => createCustomTransitionPage(
            key: state.pageKey,
            child: const CustomMealReviewScreen(),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/saved-custom-meal',
      pageBuilder: (context, state) => createCustomTransitionPage(
        key: state.pageKey,
        child: const SavedCustomMealsScreen(),
      ),
      routes: <RouteBase>[
        GoRoute(
          path: '/create',
          pageBuilder: (context, state) => createCustomTransitionPage(
            key: state.pageKey,
            child: const YourCustomMealScreen(),
          ),
        ),
        GoRoute(
          path: '/review/:id',
          pageBuilder: (context, state) => createCustomTransitionPage(
            key: state.pageKey,
            child: const SaveCustomMealReviewScreen(),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/checkout',
      pageBuilder: (context, state) => createCustomTransitionPage(
        key: state.pageKey,
        child: const CheckoutScreen(),
      ),
    ),
    GoRoute(
      path: '/more',
      pageBuilder: (context, state) => createCustomTransitionPage(
        key: state.pageKey,
        child: const MoreScreen(),
        begin: const Offset(0.0, 1.0),
      ),
    ),
    GoRoute(
      path: '/menu',
      pageBuilder: (context, state) => createCustomTransitionPage(
        key: state.pageKey,
        child: const MenuScreen(),
      ),
    ),
    GoRoute(
      path: '/tracking',
      pageBuilder: (context, state) => createCustomTransitionPage(
        key: state.pageKey,
        child: const TrackingScreen(),
      ),
    ),
    GoRoute(
      path: '/tracking/:orderCode',
      pageBuilder: (context, state) {
        final orderCode = state.pathParameters['orderCode'];
        return createCustomTransitionPage(
          key: state.pageKey,
          child: TrackingScreen(orderCode: orderCode),
        );
      },
    ),
  ],
);
