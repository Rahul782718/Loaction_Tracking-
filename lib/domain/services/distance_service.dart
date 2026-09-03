import 'package:geolocator/geolocator.dart';

class DistanceService {
  double calculateDistance(double startLat, double startLng, double endLat, double endLng) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  double calculateTotalDistance(List<Map<String, double>> points) {
    double totalDistance = 0;
    for (int i = 0; i < points.length - 1; i++) {
      totalDistance += calculateDistance(
        points[i]['lat']!, points[i]['lng']!,
        points[i+1]['lat']!, points[i+1]['lng']!
      );
    }
    return totalDistance;
  }
}
