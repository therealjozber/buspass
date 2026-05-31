import 'package:shared_preferences/shared_preferences.dart';

import '../models/bus_pass.dart';

/// Handles saving and loading the bus pass to local device storage.
///
/// Only one active pass is kept at a time (creating/renewing overwrites it),
/// which keeps the assignment simple and matches the "renew" requirement.
class PassStorageService {
  static const String _passKey = 'bus_pass';

  /// Saves the given pass as a JSON string.
  Future<void> savePass(BusPass pass) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_passKey, pass.toJsonString());
  }

  /// Loads the saved pass, or null if none exists / data is corrupted.
  Future<BusPass?> loadPass() async {
    final prefs = await SharedPreferences.getInstance();
    final source = prefs.getString(_passKey);
    if (source == null || source.isEmpty) return null;
    try {
      return BusPass.fromJsonString(source);
    } catch (_) {
      // Corrupted data: treat as no pass rather than crashing.
      return null;
    }
  }

  /// Removes the saved pass.
  Future<void> clearPass() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_passKey);
  }
}
