class DriverModel {
  final String id;
  final String driverName;
  final String cabNumber;
  final int safetyScore;
  final String riskLevel;

  const DriverModel({
    required this.id,
    required this.driverName,
    required this.cabNumber,
    required this.safetyScore,
    required this.riskLevel,
  });

  factory DriverModel.fromMap(String id, Map<String, dynamic> data) {
    return DriverModel(
      id: id,
      driverName: data['driverName'] as String? ?? 'Unknown Driver',
      cabNumber: data['cabNumber'] as String? ?? id,
      safetyScore: (data['safetyScore'] as num?)?.toInt() ?? 50,
      riskLevel: (data['riskLevel'] as String? ?? 'MEDIUM').toUpperCase(),
    );
  }
}
