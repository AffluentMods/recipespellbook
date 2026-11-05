// Planned servings and Cloud Sync. Today's server keeps only the meal-plan
// fields it knows and drops the rest, so the number of people stays on the
// device: the app sends it, and a pulled meal without it must not clear it.
// A server that does carry it is followed.
import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/services/auth_service.dart';
import 'package:recipespellbook/services/collab_service.dart';
import 'package:recipespellbook/services/sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'backup_restore_support.dart';

/// The server, as far as these syncs need one.
class _Server {
  /// The meal plans last pushed, by id.
  final pushed = <String, Map<String, dynamic>>{};

  /// The meal plans it sends back with every push.
  List<Map<String, dynamic>> mealPlansToPull = [];

  http.Client get client => MockClient((request) async {
        http.Response json(Object body, [int status = 200]) =>
            http.Response(jsonEncode(body), status, headers: {'content-type': 'application/json'});
        final now = DateTime.now().toUtc().toIso8601String();
        switch (request.url.path) {
          case '/v1/sync/push':
            final sent = jsonDecode(request.body) as Map<String, dynamic>;
            for (final m in (sent['mealPlans'] as List? ?? const []).cast<Map<String, dynamic>>()) {
              pushed[m['id'] as String] = m;
            }
            return json({'serverTime': now, 'cursor': now, 'mealPlans': mealPlansToPull});
          case '/v1/family/shared':
            return json({'serverTime': now, 'shares': <Object>[]});
        }
        return json({'error': 'Not found'}, 404);
      });
}

void main() {
  final phones = Phones.install();
  late _Server server;
  late Phone phone;

  Future<void> sync() async {
    final result = await SyncService.instance.sync();
    expect(result.success, isTrue, reason: result.error);
  }

  Future<MealPlan> meal(String id) =>
      (phone.db.select(phone.db.mealPlans)..where((m) => m.id.equals(id))).getSingle();

  /// The meal as today's server sends it back: only the fields it stores.
  Map<String, dynamic> fromServer({String notes = 'From the laptop', Object? servings = #absent}) {
    final later = DateTime.now().toUtc().add(const Duration(minutes: 5)).toIso8601String();
    return {
      'id': 'dinner',
      'userId': 'user1',
      'date': '2026-11-02T00:00:00.000',
      'time': null,
      'name': null,
      'mealType': 'Dinner',
      'customMeal': 'Chili night',
      'recipeId': null,
      'notes': notes,
      'cardColor': null,
      'alertEnabled': false,
      'alertSent': false,
      'createdAt': '2026-11-01T00:00:00.000Z',
      'updatedAt': later,
      'deletedAt': null,
      if (servings != #absent) 'servings': servings,
    };
  }

  setUp(() async {
    server = _Server();
    SharedPreferences.setMockInitialValues({});
    phone = phones('phone')..use();
    AuthService.instance.debugSetSession(
      AuthUser(id: 'user1', email: 'cook@example.com', tier: 'premium'),
      'token',
    );
    SyncService.instance.setDatabase(phone.db);
    await CollabService.instance.load();
    CollabService.instance.setDatabase(phone.db);
    await phone.db.mealPlanDao.insertMealPlan(MealPlansCompanion.insert(
      id: 'dinner',
      date: DateTime(2026, 11, 2),
      customMeal: const Value('Chili night'),
      servings: const Value(6),
      // Planned a while ago, so a second sync has no reason to push it again
      // (a meal pushed in the same sync is not taken back from the server).
      createdAt: Value(DateTime(2026, 11, 1)),
      updatedAt: Value(DateTime(2026, 11, 1)),
    ));
  });

  tearDown(() {
    AuthService.instance.debugSetSession(null, null);
  });

  test('a planned meal goes up with its number of people', () async {
    await http.runWithClient(() async {
      await sync();
      expect(server.pushed['dinner']?['servings'], 6);
      expect(server.pushed['dinner']?['customMeal'], 'Chili night');
    }, () => server.client);
  });

  test('a meal pulled without it keeps the number planned here', () async {
    await http.runWithClient(() async {
      await sync();
      server.mealPlansToPull = [fromServer()];
      await sync();
      final row = await meal('dinner');
      expect(row.notes, 'From the laptop', reason: 'the pulled meal was applied');
      expect(row.servings, 6);
    }, () => server.client);
  });

  test('a server that carries it is followed', () async {
    await http.runWithClient(() async {
      await sync();
      server.mealPlansToPull = [fromServer(servings: 3)];
      await sync();
      expect((await meal('dinner')).servings, 3);

      server.mealPlansToPull = [fromServer(notes: 'Back to the recipe', servings: null)];
      await sync();
      final row = await meal('dinner');
      expect(row.notes, 'Back to the recipe');
      expect(row.servings, isNull);
    }, () => server.client);
  });

  test('nonsense from a server is not taken as a number of people', () async {
    await http.runWithClient(() async {
      await sync();
      server.mealPlansToPull = [fromServer(servings: 'lots')];
      await sync();
      expect((await meal('dinner')).servings, isNull);
    }, () => server.client);
  });
}
