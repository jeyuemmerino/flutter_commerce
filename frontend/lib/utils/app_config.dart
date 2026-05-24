import 'package:flutter/foundation.dart';

const String _overrideBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');

String get apiBaseUrl {
  if (_overrideBaseUrl.isNotEmpty) {
    return _overrideBaseUrl;
  }

  if (kIsWeb) {
    return 'http://localhost:5000';
  }

  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return 'http://10.0.2.2:5000';
    default:
      return 'http://localhost:5000';
  }
}