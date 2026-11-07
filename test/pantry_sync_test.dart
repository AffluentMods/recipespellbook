// Pantry sync between devices of one account: the first sync of a device
// merges, after that the copy changed last wins; a server without the
// pantry routes is skipped.
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:recipespellbook/services/pantry_service.dart';
import 'package:recipespellbook/services/pantry_sync.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The server side of GET/PUT /v1/sync/pantry, as the backend does it.
class FakeServer {
  Map<String, dynamic>? pantry;
  int? updatedAt;
  bool missing = false;

  Future<http.Response> get(String path) async => missing
      ? http.Response('{"error":"Not found"}', 404)
      : http.Response(jsonEncode({'pantry': pantry, 'updatedAt': updatedAt}), 200);

  Future<http.Response> put(String path, Map<String, dynamic> body) async {
    if (missing) return http.Response('{"error":"Not found"}', 404);
    final at = body['updatedAt'] as int;
    final accepted = updatedAt == null || updatedAt! < at;
    if (accepted) {
      pantry = jsonDecode(jsonEncode(body['pantry'])) as Map<String, dynamic>;
      updatedAt = at;
    }
    return http.Response(jsonEncode({'pantry': pantry, 'updatedAt': updatedAt, 'accepted': accepted}), 200);
  }
}

void main() {
  late FakeServer server;
  var clock = DateTime(2026, 11, 7, 9);
  final devices = <String, Map<String, Object>>{};
  String? current;

  /// Switch to another device: its own preferences, its own pantry.
  Future<PantryService> on(String device) async {
    if (current != null) {
      final prefs = await SharedPreferences.getInstance();
      devices[current!] = {for (final k in prefs.getKeys()) k: prefs.get(k)!};
    }
    SharedPreferences.setMockInitialValues(devices[device] ?? {});
    PantryService.resetForTesting();
    PantryService.instance.now = () => clock = clock.add(const Duration(seconds: 1));
    current = device;
    return PantryService.instance;
  }

  Future<void> sync() => PantrySync(server.get, server.put).run('user1');

  setUp(() {
    server = FakeServer();
    devices.clear();
    current = null;
  });

  test('two devices with a pantry each end up with both, then the latest change wins', () async {
    var phone = await on('phone');
    await phone.addItems(['eggs']);
    await phone.addBasic('flour');
    await sync();
    expect(server.pantry!['items'].map((i) => i['name']), ['eggs']);

    var laptop = await on('laptop');
    await laptop.addItems(['milk']);
    await sync(); // first sync here: merges
    expect(await laptop.getAll(), ['eggs', 'milk']);
    expect(await laptop.getBasics(), contains('flour'));

    phone = await on('phone');
    await sync(); // the laptop's merge is newer
    expect(await phone.getAll(), ['eggs', 'milk']);

    // Clear all on the phone reaches the laptop.
    await phone.clear();
    await sync();
    laptop = await on('laptop');
    await sync();
    expect(await laptop.getAll(), isEmpty);
    expect(await laptop.getBasics(), contains('flour'));
  });

  test('a push that lost to a newer copy takes the newer copy', () async {
    final phone = await on('phone');
    await phone.addItems(['eggs']);
    await sync();
    // Another device wrote later than anything here.
    server.pantry = {
      'items': [
        {'name': 'cheese', 'added': 1},
      ],
      'basics': ['salt'],
    };
    server.updatedAt = clock.add(const Duration(days: 1)).millisecondsSinceEpoch;
    await phone.addItems(['bread']); // a local edit, older than the server's
    await sync();
    expect(await phone.getAll(), ['cheese']);
  });

  test('a server without the pantry routes changes nothing', () async {
    server.missing = true;
    final phone = await on('phone');
    await phone.addItems(['eggs']);
    await sync();
    expect(await phone.getAll(), ['eggs']);
    server.missing = false;
    await sync(); // works once the server has them
    expect(server.pantry!['items'].map((i) => i['name']), ['eggs']);
  });

  test('backups and transfers merge: later dates win, nothing is lost', () async {
    final phone = await on('phone');
    await phone.addItems(['eggs', 'milk']);
    final eggsBefore = (await phone.getEntries()).firstWhere((e) => e.name == 'eggs').addedAt;
    await phone.mergeDoc({
      'items': [
        {'name': 'eggs', 'added': 1},
        {'name': 'ground beef', 'added': 5, 'frozen': true},
      ],
      'basics': ['cumin', 'milk'],
    });
    final entries = await phone.getEntries();
    expect([for (final e in entries) e.name], ['eggs', 'ground beef']);
    expect(entries.first.addedAt, eggsBefore, reason: 'the later date stays');
    expect(entries.last.frozen, isTrue);
    expect(await phone.getBasics(), containsAll(['cumin', 'milk']));
  });
}
