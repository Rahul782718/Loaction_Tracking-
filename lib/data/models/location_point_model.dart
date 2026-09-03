class LocationPointModel {
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double? altitude;
  final double? speed;
  final String? address;

  LocationPointModel({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.altitude,
    this.speed,
    this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
      'altitude': altitude,
      'speed': speed,
      'address': address,
    };
  }

  factory LocationPointModel.fromMap(Map<String, dynamic> map) {
    return LocationPointModel(
      latitude: map['latitude'],
      longitude: map['longitude'],
      timestamp: DateTime.parse(map['timestamp']),
      altitude: map['altitude'],
      speed: map['speed'],
      address: map['address'],
    );
  }
}
