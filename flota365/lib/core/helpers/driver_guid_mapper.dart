import 'package:shared_preferences/shared_preferences.dart';

class DriverGuidMapper {
  static const _keyPrefix = "driver_guid_";

  /// Guarda la conversión INT → GUID falso
  static Future<void> saveMapping(String intId, String guid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("$_keyPrefix$intId", guid);
  }

  /// Devuelve el GUID falso asociado a un INT
  static Future<String?> getGuid(String intId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("$_keyPrefix$intId");
  }
}
