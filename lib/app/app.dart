import 'package:flutter/material.dart';
import 'routes.dart';

class RouteTrackerApp extends StatelessWidget {
  const RouteTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Route Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useSystemColors: true,
      ),
      initialRoute: AppRoutes.dashboard,
      routes: AppRoutes.routes,
    );
  }
}
