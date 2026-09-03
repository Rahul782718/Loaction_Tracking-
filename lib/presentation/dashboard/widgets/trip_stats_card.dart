import 'package:flutter/material.dart';

class TripStatsCard extends StatelessWidget {
  final double distance;
  final Duration duration;

  const TripStatsCard({
    super.key,
    required this.distance,
    required this.duration,
  });

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    }
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StatItem(
            icon: Icons.directions_walk,
            value: (distance / 1000).toStringAsFixed(2),
            unit: 'km',
          ),
          Container(
            height: 30,
            width: 1,
            color: Colors.grey.shade300,
            margin: const EdgeInsets.symmetric(horizontal: 20),
          ),
          _StatItem(
            icon: Icons.timer,
            value: _formatDuration(duration),
            unit: duration.inHours > 0 ? '' : 'min',
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String unit;

  const _StatItem({required this.icon, required this.value, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blue.shade700),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 4),
        if (unit.isNotEmpty)
          Text(
            unit,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }
}
