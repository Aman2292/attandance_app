import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';



void main() {
  runApp(const MaterialApp(home: AttendanceMapScreen()));
}

class AttendanceMapScreen extends StatelessWidget {
  const AttendanceMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LatLng officeLocation = LatLng(19.194721, 72.945430); // Replace with your office coordinates

    return Scaffold(
      appBar: AppBar(title: const Text('Attendance')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Tabs
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(8),
                    alignment: Alignment.center,
                    child: const Text(
                      'Todays Attendance',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(8),
                    alignment: Alignment.center,
                    child: const Text('Attendance List'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '12 Feb, 2024',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ),

            const SizedBox(height: 12),
            const Text('Start Time', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                TimeDisplay(time: '09'),
                TimeDisplay(time: '00'),
                TimeDisplay(time: 'PM'),
              ],
            ),

            const SizedBox(height: 12),
            const Text('📍 Kuwaiti Mosque Rd, Dhaka 1212'),

            const SizedBox(height: 12),

            // 🗺️ MAP SECTION
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 200,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: officeLocation,
                    initialZoom: 15.0,
                    maxZoom: 18.0,
                  ),
                  children: [
                    
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: officeLocation,
                          width: 60,
                          height: 60,
                          child: const Icon(Icons.location_on, size: 40, color: Colors.deepPurple),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ✅ Check In Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: () {
                // Add check-in logic here
              },
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Check In', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

class TimeDisplay extends StatelessWidget {
  final String time;
  const TimeDisplay({super.key, required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        time,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }
}
