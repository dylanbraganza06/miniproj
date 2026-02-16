import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/review_model.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import 'driver_check_screen.dart';

class FeedbackScreen extends StatefulWidget {
  final String driverId;

  const FeedbackScreen({super.key, required this.driverId});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _reviewController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();

  int _safetyRating = 5;
  int _rashRating = 5;
  bool _submitting = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Widget _ratingSelector({
    required String label,
    required int selected,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: List.generate(5, (index) {
            final value = index + 1;
            return IconButton.filledTonal(
              onPressed: () => onChanged(value),
              icon: Icon(
                value <= selected ? Icons.star : Icons.star_border,
                color: Colors.amber[700],
              ),
            );
          }),
        ),
      ],
    );
  }

  Future<void> _submitFeedback() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    setState(() => _submitting = true);
    try {
      final review = ReviewModel(
        driverId: widget.driverId,
        userId: user.uid,
        safetyRating: _safetyRating,
        rashRating: _rashRating,
        reviewText: _reviewController.text.trim(),
        timestamp: DateTime.now(),
      );

      await _firestoreService.submitReview(review);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feedback submitted. Thank you!')),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DriverCheckScreen()),
        (route) => false,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit feedback: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ride Feedback')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ratingSelector(
                    label: 'Safety Rating',
                    selected: _safetyRating,
                    onChanged: (value) => setState(() => _safetyRating = value),
                  ),
                  const SizedBox(height: 12),
                  _ratingSelector(
                    label: 'Rash Driving Rating',
                    selected: _rashRating,
                    onChanged: (value) => setState(() => _rashRating = value),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _reviewController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Write your review',
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _submitFeedback,
                      child: const Text('Submit'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
