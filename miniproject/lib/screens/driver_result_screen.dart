import 'package:flutter/material.dart';

import '../models/driver_model.dart';
import 'sos_screen.dart';

class DriverResultScreen extends StatelessWidget {
  final DriverModel driver;

  const DriverResultScreen({super.key, required this.driver});

  Color _riskColor() {
    switch (driver.riskLevel) {
      case 'LOW':
        return Colors.green;
      case 'MEDIUM':
        return Colors.orange;
      case 'HIGH':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Driver Safety Result')),
      body: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shield, size: 90, color: _riskColor()),
                const SizedBox(height: 16),
                const Text(
                  'Driver Risk Level',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  driver.riskLevel,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: _riskColor(),
                  ),
                ),
                const SizedBox(height: 12),
                Text('Safety Score: ${driver.safetyScore}/100'),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SosScreen(driver: driver),
                        ),
                      );
                    },
                    child: const Text('Proceed to Ride (SOS Ready)'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
