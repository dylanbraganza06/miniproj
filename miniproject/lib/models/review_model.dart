class ReviewModel {
  final String driverId;
  final String userId;
  final int safetyRating;
  final int rashRating;
  final String reviewText;
  final DateTime timestamp;

  const ReviewModel({
    required this.driverId,
    required this.userId,
    required this.safetyRating,
    required this.rashRating,
    required this.reviewText,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'driverId': driverId,
      'userId': userId,
      'safetyRating': safetyRating,
      'rashRating': rashRating,
      'reviewText': reviewText,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
