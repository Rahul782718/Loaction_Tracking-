import '../data/local/trip_local_database.dart';
import '../data/models/location_point_model.dart';
import '../data/models/trip_model.dart';

class TripRepository {
  final TripLocalDatabase _db = TripLocalDatabase();

  Future<void> saveTrip(TripModel trip) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      await txn.insert('trips', trip.toMap());
      for (var point in trip.route) {
        final pointMap = point.toMap();
        pointMap['tripId'] = trip.id;
        await txn.insert('points', pointMap);
      }
    });
  }

  Future<List<TripModel>> getAllTrips() async {
    final db = await _db.database;
    final List<Map<String, dynamic>> tripMaps = await db.query('trips', orderBy: 'startTime DESC');
    
    List<TripModel> trips = [];
    for (var tripMap in tripMaps) {
      final List<Map<String, dynamic>> pointMaps = await db.query(
        'points',
        where: 'tripId = ?',
        whereArgs: [tripMap['id']],
        orderBy: 'timestamp ASC',
      );
      
      final route = pointMaps.map((p) => LocationPointModel.fromMap(p)).toList();
      final trip = TripModel.fromMap(tripMap);
      trip.route = route;
      trips.add(trip);
    }
    return trips;
  }
}
