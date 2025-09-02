import 'package:flutter/material.dart';
import 'package:green_kitchen_app/routers/router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Green Kitchen',
      routerConfig: router,
    );
  }
}


