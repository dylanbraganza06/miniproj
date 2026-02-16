import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/driver_model.dart';
import '../providers/auth_provider.dart';
import '../services/location_service.dart';
import '../services/sos_service.dart';
import 'feedback_screen.dart';

class SosScreen extends StatefulWidget {
  final DriverModel driver;

  const SosScreen({super.key, required this.driver});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  final LocationService _locationService = LocationService();
  final SosService _sosService = SosService();

  Timer? _holdTimer;
  bool _alertSent = false;
  bool _sending = false;

  void _startHolding() {
    _alertSent = false;
    _holdTimer?.cancel();
    _holdTimer = Timer(const Duration(seconds: 3), _triggerSos);
  }

  void _stopHolding() {
    if (!_alertSent) {
      _holdTimer?.cancel();
    }
  }

  Future<void> _triggerSos() async {
    if (_sending) return;

    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    setState(() {
      _sending = true;
      _alertSent = true;
    });

    try {
      final position = await _locationService.getCurrentLocation();
      final now = DateTime.now();
      await _sosService.sendSosAlert(
        userId: user.uid,
        driverId: widget.driver.id,
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: now,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Emergency SOS sent successfully.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send SOS: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _sending = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SOS Ready')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onLongPressStart: (_) => _startHolding(),
                onLongPressEnd: (_) => _stopHolding(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 220,
                  height: 220,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 12),
                    ],
                  ),
                  child: Center(
                    child: _sending
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'SOS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 56,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Press & hold for 3 seconds',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => FeedbackScreen(driverId: widget.driver.id),
                      ),
                    );
                  },
                  child: const Text('End Ride / Arrived Safely'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
