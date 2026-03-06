import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

/// Unified database connection that works on all platforms:
/// - Native (Android/iOS/Windows/macOS/Linux): SQLite via FFI
/// - Web: WASM-compiled sqlite3 with IndexedDB persistence
QueryExecutor openConnection() => driftDatabase(name: 'recipespellbook');
