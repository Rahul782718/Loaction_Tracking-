import 'package:flutter/material.dart';
import 'app/app.dart';
import 'core/services/location_background_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  LocationBackgroundService.init();
  runApp(const RouteTrackerApp());
}
