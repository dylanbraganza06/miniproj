import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/driver_model.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import 'driver_result_screen.dart';

class DriverCheckScreen extends StatefulWidget {
  const DriverCheckScreen({super.key});

  @override
  State<DriverCheckScreen> createState() => _DriverCheckScreenState();
}

class _DriverCheckScreenState extends State<DriverCheckScreen> {
  final _cabController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;

  @override
  void dispose() {
    _cabController.dispose();
    super.dispose();
  }

  Future<void> _startRide() async {
    if (_cabController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter Cab Number')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final DriverModel driver =
          await _firestoreService.getDriverByCabNumber(_cabController.text.trim());

      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DriverResultScreen(driver: driver),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Check'),
        actions: [
          IconButton(
            onPressed: () => context.read<AuthProvider>().logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Driver Check',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _cabController,
                  decoration: const InputDecoration(
                    labelText: 'Enter Cab Number',
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _startRide,
                    child: const Text('Start Ride'),
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
