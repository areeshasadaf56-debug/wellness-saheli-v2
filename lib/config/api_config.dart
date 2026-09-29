// api_config.dart
//
// Single source of truth for the backend base URL. Every API service
// (eligibility_api_service.dart, and any prediction service) should read
// from ApiConfig.baseUrl rather than hardcoding a URL directly.

class ApiConfig {
  // --- LIVE BACKEND (PythonAnywhere) ---
  // This is what the app currently points at.
  static const String baseUrl = 'https://areeshasadaf56.pythonanywhere.com';

  // --- LOCAL DEV ALTERNATIVES ---
  // Uncomment one of these instead of the line above if you're running
  // main.py locally (e.g. `python main.py` or `flask run`) and want the
  // app to talk to your own machine instead of the live server.
  //
  // Android emulator (10.0.2.2 maps to your computer's localhost):
  // static const String baseUrl = 'http://10.0.2.2:8000';
  //
  // iOS simulator (localhost works directly):
  // static const String baseUrl = 'http://127.0.0.1:8000';
  //
  // Physical device on the same Wi-Fi as your computer (replace with your
  // computer's actual LAN IP, found via `ipconfig` on Windows or
  // `ifconfig`/`ip a` on Mac/Linux):
  // static const String baseUrl = 'http://192.168.1.42:8000';
}
