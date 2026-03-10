// lib/core/utils/local_storage_web.dart
// Web implementation using package:web (not deprecated).

import 'package:web/web.dart' as web;

class LocalStorage {
  LocalStorage._();

  static String? read(String key) {
    try {
      return web.window.localStorage.getItem(key);
    } catch (_) {
      return null;
    }
  }

  static void write(String key, String value) {
    try {
      web.window.localStorage.setItem(key, value);
    } catch (_) {}
  }
}
