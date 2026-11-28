// A family pantry: members who turn on "Share my pantry" use one pantry kept
// on the family. Moving into or out of it merges afresh, so nobody's items
// are lost, whether the switch happened on this device or another one.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/services/auth_service.dart';
import 'package:recipespellbook/services/family_service.dart';
import 'package:recipespellbook/services/pantry_service.dart';
import 'package:recipespellbook/services/pantry_sync.dart';
import 'package:recipespellbook/ui/screens/premium/family_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// GET/PUT /v1/sync/pantry with a personal and a family pantry, and
/// PUT /v1/sync/pantry/sharing, as the backend does them.
class FakeServer {
  final docs = <String, Map<String, dynamic>?>{'personal': null, 'family': null};
  final at = <String, int?>{'personal': null, 'family': null};
  String scope = 'personal';

  /// What GET answers without a scope (a server from before family pantries).
  bool oldServer = false;

  Future<http.Response> get(String path) async => http.Response(
      jsonEncode({
        'pantry': docs[scope],
        'updatedAt': at[scope],
        if (!oldServer) 'scope': scope,
      }),
      200);

  Future<http.Response> put(String path, Map<String, dynamic> body) async {
    if (path == '/v1/sync/pantry/sharing') {
      scope = body['shared'] == true ? 'family' : 'personal';
      return http.Response(jsonEncode({'shared': scope == 'family', 'scope': scope}), 200);
    }
    final when = body['updatedAt'] as int;
    final accepted = at[scope] == null || at[scope]! < when;
    if (accepted) {
      docs[scope] = jsonDecode(jsonEncode(body['pantry'])) as Map<String, dynamic>;
      at[scope] = when;
    }
    return http.Response(jsonEncode({'pantry': docs[scope], 'updatedAt': at[scope], 'scope': scope, 'accepted': accepted}), 200);
  }
}

List<String> names(Map<String, dynamic>? doc) => [for (final i in (doc?['items'] as List? ?? [])) i['name'] as String];

Map<String, dynamic> pantryOf(List<String> items, int added) => {
      'items': [for (final n in items) {'name': n, 'added': added}],
      'basics': <String>[],
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FakeServer server;
  var clock = DateTime(2026, 11, 27, 9);

  Future<PantryService> device() async {
    PantryService.resetForTesting();
    PantryService.instance.now = () => clock = clock.add(const Duration(seconds: 1));
    return PantryService.instance;
  }

  Future<bool> sync() => PantrySync(server.get, server.put).run('user1');

  setUp(() {
    server = FakeServer();
    SharedPreferences.setMockInitialValues({});
  });

  group('syncing', () {
    test('moving into the family pantry on another device keeps both pantries', () async {
      final pantry = await device();
      await pantry.addItems(['eggs', 'butter']);
      await sync();
      expect(names(server.docs['personal']), ['butter', 'eggs']);
      expect(await PantrySync.usesFamilyPantry('user1'), isFalse);

      // Turned on elsewhere; another member's pantry is already there.
      server.docs['family'] = pantryOf(['milk'], DateTime(2026, 11, 26).millisecondsSinceEpoch);
      server.at['family'] = DateTime(2026, 11, 26).millisecondsSinceEpoch;
      server.scope = 'family';
      expect(await sync(), isTrue);

      // The copy from the personal sync must not read as "removed there".
      expect(await pantry.getAll(), ['butter', 'eggs', 'milk']);
      expect(names(server.docs['family']), ['butter', 'eggs', 'milk']);
      expect(await PantrySync.usesFamilyPantry('user1'), isTrue);
    });

    test('in the family pantry, what another member uses up goes here too', () async {
      final pantry = await device();
      await pantry.addItems(['eggs']);
      server.scope = 'family';
      await sync();
      await PantrySync.switchedTo('user1', 'family');
      await sync();

      // Someone else used up the eggs and bought milk.
      final later = clock.add(const Duration(hours: 1)).millisecondsSinceEpoch;
      server.docs['family'] = pantryOf(['milk'], later);
      server.at['family'] = later;
      await sync();
      expect(await pantry.getAll(), ['milk']);
    });

    test('moving back to a pantry of one\'s own keeps a copy of the family items', () async {
      final pantry = await device();
      await pantry.addItems(['eggs']);
      server.scope = 'family';
      server.docs['family'] = pantryOf(['milk'], 1);
      server.at['family'] = 1;
      await sync();
      expect(await pantry.getAll(), ['eggs', 'milk']);

      // An old personal copy is still on the server.
      server.docs['personal'] = pantryOf(['flour'], 1);
      server.at['personal'] = 1;
      server.scope = 'personal';
      await sync();
      expect(await pantry.getAll(), ['eggs', 'flour', 'milk']);
      expect(names(server.docs['personal']), ['eggs', 'flour', 'milk']);
      expect(await PantrySync.usesFamilyPantry('user1'), isFalse);
    });

    test('a server from before family pantries counts as the own pantry', () async {
      server.oldServer = true;
      final pantry = await device();
      await pantry.addItems(['eggs', 'butter']);
      await sync();
      // Removed on another device: still removed here, the usual way.
      final later = clock.add(const Duration(hours: 1)).millisecondsSinceEpoch;
      server.docs['personal'] = pantryOf(['eggs'], (await pantry.toDoc())['items'][1]['added'] as int);
      server.at['personal'] = later;
      await sync();
      expect(await pantry.getAll(), ['eggs']);
    });
  });

  group('the family screen', () {
    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
        (_) async => null,
      );
      AuthService.instance.debugSetSession(const AuthUser(id: 'user1', email: 'me@example.com'), 'jwt');
    });
    tearDown(() => AuthService.instance.debugSetSession(null, null));

    testWidgets('Share my pantry turns on the family pantry and merges into it', (tester) async {
      tester.view.physicalSize = const Size(500, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      SharedPreferences.setMockInitialValues({'pantry_items': jsonEncode(['eggs'])});
      PantryService.resetForTesting();
      server.docs['family'] = pantryOf(['milk'], 1);
      server.at['family'] = 1;

      Map<String, dynamic> member(String id, String name, String role, bool shares) =>
          {'userId': id, 'name': name, 'role': role, 'sharePantry': shares};
      MockClient client() => MockClient((request) async {
            final path = request.url.path;
            if (path == '/v1/family') {
              return http.Response(
                  jsonEncode({
                    'family': {
                      'id': 'f1', 'name': 'Home', 'ownerId': 'user2', 'inviteCode': 'ABC123',
                      'maxMembers': 5, 'myRole': 'member',
                      'members': [
                        member('user2', 'Sam', 'owner', true),
                        member('user1', 'Me', 'member', server.scope == 'family'),
                      ],
                    }
                  }),
                  200);
            }
            if (path.startsWith('/v1/sync/pantry')) {
              final body = request.body.isEmpty ? <String, dynamic>{} : jsonDecode(request.body) as Map<String, dynamic>;
              return request.method == 'GET' ? server.get(path) : server.put(path, body);
            }
            return http.Response('{}', 404);
          });

      Future<void> settle() async {
        for (var i = 0; i < 6; i++) {
          await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 5)));
          await tester.pump(const Duration(milliseconds: 100));
        }
      }

      await http.runWithClient(() async {
        await tester.pumpWidget(const ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: FamilyScreen(),
          ),
        ));
        await settle();
        expect(find.text('Share my pantry with the family'), findsOneWidget);
        expect(find.text('Sharing the pantry: Sam'), findsOneWidget);
        expect(tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value, isFalse);

        await tester.tap(find.text('Share my pantry with the family'));
        await settle();
        await settle();
      }, client);

      expect(server.scope, 'family');
      expect(names(server.docs['family']), ['eggs', 'milk']);
      expect(await tester.runAsync(() => PantryService.instance.getAll()), ['eggs', 'milk']);
      expect(find.text('Sharing the pantry: Sam, You'), findsOneWidget);
      expect(find.text('Your pantry is now the family pantry.'), findsOneWidget);
      // Let the message time out.
      await tester.pump(const Duration(seconds: 6));
      await tester.pump(const Duration(seconds: 1));
    });
  });

  test('the family list says who shares the pantry', () {
    final m = FamilyMemberInfo.fromJson({'userId': 'u', 'role': 'member', 'sharePantry': true});
    expect(m.sharePantry, isTrue);
    expect(FamilyMemberInfo.fromJson({'userId': 'u', 'role': 'member'}).sharePantry, isFalse);
  });
}
