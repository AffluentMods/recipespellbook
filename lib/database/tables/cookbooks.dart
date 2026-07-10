import 'package:drift/drift.dart';

class Cookbooks extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get imagePath => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  /// Set when this cookbook was pulled in via a share (the owner's user id).
  /// Non-null ⇒ this is a shared-in cookbook: it must NOT be re-pushed through
  /// the owner-only premium `/sync` channel, and editing is gated by the
  /// member's collab permission.
  TextColumn get sharedOwnerId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}