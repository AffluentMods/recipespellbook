import 'package:drift/drift.dart';

class Cookbooks extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get imagePath => text().nullable()();

  /// The cover's copy in the cloud, "userId/hash.ext" (sync-only). imagePath
  /// stays the file this device shows, as for recipes.
  TextColumn get imageServerPath => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  /// Set when this cookbook was pulled in via a share (the owner's user id).
  /// Non-null ⇒ this is a shared-in cookbook: it must NOT be re-pushed through
  /// the owner-only premium `/sync` channel, and editing is gated by the
  /// member's collab permission.
  TextColumn get sharedOwnerId => text().nullable()();

  /// The Community publication this cookbook was downloaded from, whole and
  /// as a new cookbook. Null for every other cookbook (the user's own, ones
  /// published from here, partial downloads, shared-in ones). Device-local:
  /// sync and transfers do not carry it.
  TextColumn get communitySourceId => text().nullable()();

  /// The publication's content version this copy is based on. Null when not
  /// known (a download from before versions, matched later by its photos).
  IntColumn get communitySourceVersion => integer().nullable()();

  /// A newer version found by the update check that really changes
  /// something here; drives "Update available". Null when there is none.
  IntColumn get communityUpdateVersion => integer().nullable()();

  /// JSON (`CommunitySourceManifest`): which local recipe came from which
  /// Community recipe and their fingerprints at the time, so an update can
  /// tell the publisher's changes from the user's own edits.
  TextColumn get communityManifest => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}