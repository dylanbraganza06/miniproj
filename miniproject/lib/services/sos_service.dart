import 'dart:convert';

import 'package:http/http.dart' as http;

class SosService {
  static const String _functionUrl = String.fromEnvironment(
    'SEND_SOS_ALERT_URL',
    defaultValue: '',
  );

  Future<void> sendSosAlert({
    required String userId,
    required String driverId,
    required double latitude,
    required double longitude,
    required DateTime timestamp,
  }) async {
    if (_functionUrl.isEmpty) {
      throw Exception(
        'Cloud Function URL missing. Provide --dart-define=SEND_SOS_ALERT_URL=... when running the app.',
      );
    }

    final response = await http.post(
      Uri.parse(_functionUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'driverId': driverId,
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': timestamp.toIso8601String(),
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to send SOS alert: ${response.body}');
    }
  }
}
