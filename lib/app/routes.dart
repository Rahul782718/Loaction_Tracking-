import 'package:flutter/material.dart';
import '../presentation/dashboard/dashboard_screen.dart';
import '../presentation/trip/trip_history_screen.dart';

class AppRoutes {
  static const String dashboard = '/';
  static const String tripHistory = '/history';

  static Map<String, WidgetBuilder> get routes => {
    dashboard: (context) => const DashboardScreen(),
    tripHistory: (context) => const TripHistoryScreen(),
  };
}
