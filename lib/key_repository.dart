import 'package:shared_preferences/shared_preferences.dart';

class KeyRepository {
  static const String KEY_HANDLE_KEY = 'KEY_HANDLE';

  static Future<String> loadKeyHandle(String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = prefs.getString('${KeyRepository.KEY_HANDLE_KEY}#$username');
    return key;
  }

  static Future<void> storeKeyHandle(String keyHandle, String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String k = '${KeyRepository.KEY_HANDLE_KEY}#$username';
    await prefs.setString(k, keyHandle);
  }

  static Future<String> removeAllKeys() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.getKeys().forEach((key) => prefs.remove(key));
  }
}