// lib/core/utils/local_storage.dart
//
// Conditional import: uses package:web on web, no-op stub elsewhere.

export 'local_storage_stub.dart'
    if (dart.library.js_interop) 'local_storage_web.dart';
