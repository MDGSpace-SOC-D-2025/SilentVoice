import 'package:shared_preferences/shared_preferences.dart';

class FakeCallPrefs {
  static const _callerNameKey = 'fake_call_caller_name';

  static Future<String> getCallerName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_callerNameKey) ?? 'Mom';
  }

  static Future<void> setCallerName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_callerNameKey, name);
  }

  static const _callerNumberKey = 'fake_call_caller_number';

  static Future<String> getCallerNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_callerNumberKey) ?? 'Unknown';
  }

  static Future<void> setCallerNumber(String number) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_callerNumberKey, number);
  }
}
