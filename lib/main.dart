import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:green_kitchen_app/provider/cart_provider.dart';
import 'package:green_kitchen_app/provider/custom_meal_provider.dart';
import 'package:green_kitchen_app/provider/save_custom_meal_provider.dart';
import 'package:green_kitchen_app/services/custom_meal_service.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:green_kitchen_app/routers/router.dart';
// import 'package:green_kitchen_app/provider/cart_provider.dart';
import 'package:green_kitchen_app/provider/auth_provider.dart';
import 'package:green_kitchen_app/provider/chat_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase (without options - will use google-services.json)
  await Firebase.initializeApp();

  // Initialize AuthProvider
  final authProvider = AuthProvider();
  await authProvider.init();
  
  // Load user data if already logged in
  await authProvider.loadUserData();

  // Initialize CartProvider
  final cartProvider = CartProvider();
  await cartProvider.initialize();

  // Initialize CustomMealService (add this line)
  await CustomMealService().init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: cartProvider),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => CustomMealProvider()),
        ChangeNotifierProvider(create: (_) => SavedCustomMealsProvider()),

      ],
      child: MaterialApp.router(title: 'Green Kitchen', routerConfig: router),
    );
  }
}
