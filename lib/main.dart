import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:green_kitchen_app/routers/router.dart';
import 'package:green_kitchen_app/provider/provider.dart';
import 'package:green_kitchen_app/provider/auth_provider.dart'; 

void main() async {
  //custom lock screen orientation to portrait only
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

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
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
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => CustomMealProvider()),
      ],
      child: MaterialApp.router(
        title: 'Green Kitchen',
        routerConfig: router,
      ),
    );
  }
}
