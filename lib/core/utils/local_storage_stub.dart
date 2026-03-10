// lib/core/utils/local_storage_stub.dart
// Non-web stub — reads/writes do nothing.

class LocalStorage {
  LocalStorage._();
  static String? read(String key) => null;
  static void write(String key, String value) {}
}
