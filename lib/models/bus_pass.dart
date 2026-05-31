import 'dart:convert';

/// Represents a single digital bus pass owned by a passenger.
///
/// Dates are stored as ISO-8601 strings (e.g. "2026-05-28") inside JSON so
/// they survive being written to SharedPreferences and encoded in a QR code.
class BusPass {
  final String passId;
  final String fullName;
  final String phone;
  final String route;
  final String passType; // Daily, Weekly or Monthly
  final DateTime startDate;
  final DateTime expiryDate;

  const BusPass({
    required this.passId,
    required this.fullName,
    required this.phone,
    required this.route,
    required this.passType,
    required this.startDate,
    required this.expiryDate,
  });

  /// True when the expiry date is in the past (compared by calendar day).
  bool get isExpired {
    final now = DateTime.now();
    // Treat the pass as valid for the whole of its expiry day.
    final endOfExpiry = DateTime(
      expiryDate.year,
      expiryDate.month,
      expiryDate.day,
      23,
      59,
      59,
    );
    return now.isAfter(endOfExpiry);
  }

  /// Human readable status used across the UI.
  String get status => isExpired ? 'Expired' : 'Active';

  /// Converts this pass into a JSON-ready map.
  Map<String, dynamic> toJson() {
    return {
      'passId': passId,
      'fullName': fullName,
      'phone': phone,
      'route': route,
      'passType': passType,
      'startDate': startDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
    };
  }

  /// Builds a pass from a JSON map. Throws if required fields are missing.
  factory BusPass.fromJson(Map<String, dynamic> json) {
    return BusPass(
      passId: json['passId'] as String,
      fullName: json['fullName'] as String,
      phone: json['phone'] as String,
      route: json['route'] as String,
      passType: json['passType'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      expiryDate: DateTime.parse(json['expiryDate'] as String),
    );
  }

  /// Encodes the pass as a JSON string (used for storage and QR codes).
  String toJsonString() => jsonEncode(toJson());

  /// Decodes a pass from a JSON string.
  factory BusPass.fromJsonString(String source) =>
      BusPass.fromJson(jsonDecode(source) as Map<String, dynamic>);
}
