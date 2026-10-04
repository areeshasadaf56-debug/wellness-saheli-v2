import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the app-wide language ('en' or 'ur') and remembers the choice.
class LanguageProvider extends ChangeNotifier {
  static const _key = 'appLanguage';
  // The AI Check-in screen already stores its own language under this key,
  // so we keep it in sync and the chat replies in the same language.
  static const _chatKey = 'ai_checkin_language';

  /// Static mirror of the current language so plain functions (like tr())
  /// can translate without a BuildContext.
  static bool urdu = false;

  String _code = 'en';
  String get code => _code;
  bool get isUrdu => _code == 'ur';
  Locale get locale => Locale(_code);

  LanguageProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    if (saved == 'ur' || saved == 'en') {
      _code = saved!;
      urdu = _code == 'ur';
      notifyListeners();
    }
  }

  Future<void> setLanguage(String code) async {
    if (code != 'en' && code != 'ur') return;
    _code = code;
    urdu = code == 'ur';
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, code);
    await prefs.setString(_chatKey, code);
  }

  Future<void> toggle() => setLanguage(isUrdu ? 'en' : 'ur');
}
