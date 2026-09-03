import 'location_point_model.dart';

class TripModel {
  final String id;
  final DateTime startTime;
  DateTime? endTime;
  double distance; // in meters
  List<LocationPointModel> route;

  TripModel({
    required this.id,
    required this.startTime,
    this.endTime,
    this.distance = 0.0,
    this.route = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'distance': distance,
    };
  }

  factory TripModel.fromMap(Map<String, dynamic> map) {
    return TripModel(
      id: map['id'],
      startTime: DateTime.parse(map['startTime']),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
      distance: map['distance'] ?? 0.0,
    );
  }
}
