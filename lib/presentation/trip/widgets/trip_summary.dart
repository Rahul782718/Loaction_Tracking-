import 'package:flutter/material.dart';
import '../../../data/models/trip_model.dart';
import '../trip_detail_screen.dart';

class TripSummary extends StatelessWidget {
  final TripModel trip;

  const TripSummary({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.route, color: Colors.blue),
        ),
        title: Text(
          'Trip ${trip.startTime.toString().split('.')[0]}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Distance: ${(trip.distance / 1000).toStringAsFixed(2)} km'),
            Text('Points: ${trip.route.length} recorded'),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TripDetailScreen(trip: trip),
            ),
          );
        },
      ),
    );
  }
}
