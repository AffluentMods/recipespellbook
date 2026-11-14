import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:drift/drift.dart';
import 'package:drift/web.dart';

const _name = 'recipespellbook';

/// The web database lives in IndexedDB. It used to live in localStorage,
/// which holds about 5 MB for the whole site (preferences included), so a
/// library of a few hundred recipes ran out of room. Where a browser has no
/// IndexedDB it stays in localStorage.
QueryExecutor openConnection() {
  return LazyDatabase(() async {
    final storage = await DriftWebStorage.indexedDbIfSupported(_name);
    if (await DriftWebStorage.supportsIndexedDb()) await _dropLocalStorageCopy(storage);
    return WebDatabase.withStorage(storage);
  });
}

/// Opening the IndexedDB storage the first time copies the localStorage
/// database over (drift does this). Once the copy is there, the old one is
/// removed, which gives localStorage its room back.
Future<void> _dropLocalStorageCopy(DriftWebStorage storage) async {
  try {
    final local = globalContext.getProperty<JSObject?>('localStorage'.toJS);
    if (local == null) return;
    const key = 'moor_db_str_$_name';
    if (local.callMethod<JSAny?>('getItem'.toJS, key.toJS) == null) return;
    await storage.open();
    final copied = await storage.restore();
    await storage.close();
    if (copied == null || copied.isEmpty) return;
    local.callMethod<JSAny?>('removeItem'.toJS, key.toJS);
    local.callMethod<JSAny?>('removeItem'.toJS, 'moor_db_version_$_name'.toJS);
  } catch (_) {
    // The old copy stays; nothing reads it any more.
  }
}
