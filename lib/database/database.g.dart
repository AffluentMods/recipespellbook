// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CookbooksTable extends Cookbooks
    with TableInfo<$CookbooksTable, Cookbook> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CookbooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _imagePathMeta =
      const VerificationMeta('imagePath');
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
      'image_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, description, imagePath, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cookbooks';
  @override
  VerificationContext validateIntegrity(Insertable<Cookbook> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('image_path')) {
      context.handle(_imagePathMeta,
          imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Cookbook map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Cookbook(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      imagePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_path']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
    );
  }

  @override
  $CookbooksTable createAlias(String alias) {
    return $CookbooksTable(attachedDatabase, alias);
  }
}

class Cookbook extends DataClass implements Insertable<Cookbook> {
  final String id;
  final String name;
  final String? description;
  final String? imagePath;
  final DateTime createdAt;
  final DateTime? updatedAt;
  const Cookbook(
      {required this.id,
      required this.name,
      this.description,
      this.imagePath,
      required this.createdAt,
      this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  CookbooksCompanion toCompanion(bool nullToAbsent) {
    return CookbooksCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory Cookbook.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Cookbook(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'imagePath': serializer.toJson<String?>(imagePath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  Cookbook copyWith(
          {String? id,
          String? name,
          Value<String?> description = const Value.absent(),
          Value<String?> imagePath = const Value.absent(),
          DateTime? createdAt,
          Value<DateTime?> updatedAt = const Value.absent()}) =>
      Cookbook(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        imagePath: imagePath.present ? imagePath.value : this.imagePath,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
      );
  Cookbook copyWithCompanion(CookbooksCompanion data) {
    return Cookbook(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Cookbook(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('imagePath: $imagePath, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, description, imagePath, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Cookbook &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.imagePath == this.imagePath &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CookbooksCompanion extends UpdateCompanion<Cookbook> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<String?> imagePath;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const CookbooksCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CookbooksCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<Cookbook> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? imagePath,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (imagePath != null) 'image_path': imagePath,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CookbooksCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? description,
      Value<String?>? imagePath,
      Value<DateTime>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<int>? rowid}) {
    return CookbooksCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CookbooksCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('imagePath: $imagePath, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecipesTable extends Recipes with TableInfo<$RecipesTable, Recipe> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cookbookIdMeta =
      const VerificationMeta('cookbookId');
  @override
  late final GeneratedColumn<String> cookbookId = GeneratedColumn<String>(
      'cookbook_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES cookbooks (id)'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _servingsMeta =
      const VerificationMeta('servings');
  @override
  late final GeneratedColumn<String> servings = GeneratedColumn<String>(
      'servings', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _prepTimeMinutesMeta =
      const VerificationMeta('prepTimeMinutes');
  @override
  late final GeneratedColumn<int> prepTimeMinutes = GeneratedColumn<int>(
      'prep_time_minutes', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _cookTimeMinutesMeta =
      const VerificationMeta('cookTimeMinutes');
  @override
  late final GeneratedColumn<int> cookTimeMinutes = GeneratedColumn<int>(
      'cook_time_minutes', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _sourceUrlMeta =
      const VerificationMeta('sourceUrl');
  @override
  late final GeneratedColumn<String> sourceUrl = GeneratedColumn<String>(
      'source_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _imagePathMeta =
      const VerificationMeta('imagePath');
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
      'image_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _courseIdMeta =
      const VerificationMeta('courseId');
  @override
  late final GeneratedColumn<String> courseId = GeneratedColumn<String>(
      'course_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
      'category_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
      'rating', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nutritionJsonMeta =
      const VerificationMeta('nutritionJson');
  @override
  late final GeneratedColumn<String> nutritionJson = GeneratedColumn<String>(
      'nutrition_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isFavoriteMeta =
      const VerificationMeta('isFavorite');
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
      'is_favorite', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_favorite" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isPinnedMeta =
      const VerificationMeta('isPinned');
  @override
  late final GeneratedColumn<bool> isPinned = GeneratedColumn<bool>(
      'is_pinned', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_pinned" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _lastViewedAtMeta =
      const VerificationMeta('lastViewedAt');
  @override
  late final GeneratedColumn<DateTime> lastViewedAt = GeneratedColumn<DateTime>(
      'last_viewed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        cookbookId,
        title,
        description,
        servings,
        prepTimeMinutes,
        cookTimeMinutes,
        sourceUrl,
        imagePath,
        courseId,
        categoryId,
        rating,
        notes,
        nutritionJson,
        isFavorite,
        isPinned,
        deletedAt,
        lastViewedAt,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recipes';
  @override
  VerificationContext validateIntegrity(Insertable<Recipe> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('cookbook_id')) {
      context.handle(
          _cookbookIdMeta,
          cookbookId.isAcceptableOrUnknown(
              data['cookbook_id']!, _cookbookIdMeta));
    } else if (isInserting) {
      context.missing(_cookbookIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('servings')) {
      context.handle(_servingsMeta,
          servings.isAcceptableOrUnknown(data['servings']!, _servingsMeta));
    }
    if (data.containsKey('prep_time_minutes')) {
      context.handle(
          _prepTimeMinutesMeta,
          prepTimeMinutes.isAcceptableOrUnknown(
              data['prep_time_minutes']!, _prepTimeMinutesMeta));
    }
    if (data.containsKey('cook_time_minutes')) {
      context.handle(
          _cookTimeMinutesMeta,
          cookTimeMinutes.isAcceptableOrUnknown(
              data['cook_time_minutes']!, _cookTimeMinutesMeta));
    }
    if (data.containsKey('source_url')) {
      context.handle(_sourceUrlMeta,
          sourceUrl.isAcceptableOrUnknown(data['source_url']!, _sourceUrlMeta));
    }
    if (data.containsKey('image_path')) {
      context.handle(_imagePathMeta,
          imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta));
    }
    if (data.containsKey('course_id')) {
      context.handle(_courseIdMeta,
          courseId.isAcceptableOrUnknown(data['course_id']!, _courseIdMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    }
    if (data.containsKey('rating')) {
      context.handle(_ratingMeta,
          rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('nutrition_json')) {
      context.handle(
          _nutritionJsonMeta,
          nutritionJson.isAcceptableOrUnknown(
              data['nutrition_json']!, _nutritionJsonMeta));
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
          _isFavoriteMeta,
          isFavorite.isAcceptableOrUnknown(
              data['is_favorite']!, _isFavoriteMeta));
    }
    if (data.containsKey('is_pinned')) {
      context.handle(_isPinnedMeta,
          isPinned.isAcceptableOrUnknown(data['is_pinned']!, _isPinnedMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('last_viewed_at')) {
      context.handle(
          _lastViewedAtMeta,
          lastViewedAt.isAcceptableOrUnknown(
              data['last_viewed_at']!, _lastViewedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Recipe map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Recipe(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      cookbookId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cookbook_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      servings: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}servings']),
      prepTimeMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}prep_time_minutes']),
      cookTimeMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cook_time_minutes']),
      sourceUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_url']),
      imagePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_path']),
      courseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}course_id']),
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_id']),
      rating: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}rating']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      nutritionJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nutrition_json']),
      isFavorite: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_favorite'])!,
      isPinned: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_pinned'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      lastViewedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_viewed_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $RecipesTable createAlias(String alias) {
    return $RecipesTable(attachedDatabase, alias);
  }
}

class Recipe extends DataClass implements Insertable<Recipe> {
  final String id;
  final String cookbookId;
  final String title;
  final String? description;
  final String? servings;
  final int? prepTimeMinutes;
  final int? cookTimeMinutes;
  final String? sourceUrl;
  final String? imagePath;
  final String? courseId;
  final String? categoryId;
  final int? rating;
  final String? notes;
  final String? nutritionJson;
  final bool isFavorite;
  final bool isPinned;
  final DateTime? deletedAt;
  final DateTime? lastViewedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Recipe(
      {required this.id,
      required this.cookbookId,
      required this.title,
      this.description,
      this.servings,
      this.prepTimeMinutes,
      this.cookTimeMinutes,
      this.sourceUrl,
      this.imagePath,
      this.courseId,
      this.categoryId,
      this.rating,
      this.notes,
      this.nutritionJson,
      required this.isFavorite,
      required this.isPinned,
      this.deletedAt,
      this.lastViewedAt,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['cookbook_id'] = Variable<String>(cookbookId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || servings != null) {
      map['servings'] = Variable<String>(servings);
    }
    if (!nullToAbsent || prepTimeMinutes != null) {
      map['prep_time_minutes'] = Variable<int>(prepTimeMinutes);
    }
    if (!nullToAbsent || cookTimeMinutes != null) {
      map['cook_time_minutes'] = Variable<int>(cookTimeMinutes);
    }
    if (!nullToAbsent || sourceUrl != null) {
      map['source_url'] = Variable<String>(sourceUrl);
    }
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    if (!nullToAbsent || courseId != null) {
      map['course_id'] = Variable<String>(courseId);
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    if (!nullToAbsent || rating != null) {
      map['rating'] = Variable<int>(rating);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || nutritionJson != null) {
      map['nutrition_json'] = Variable<String>(nutritionJson);
    }
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['is_pinned'] = Variable<bool>(isPinned);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || lastViewedAt != null) {
      map['last_viewed_at'] = Variable<DateTime>(lastViewedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RecipesCompanion toCompanion(bool nullToAbsent) {
    return RecipesCompanion(
      id: Value(id),
      cookbookId: Value(cookbookId),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      servings: servings == null && nullToAbsent
          ? const Value.absent()
          : Value(servings),
      prepTimeMinutes: prepTimeMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(prepTimeMinutes),
      cookTimeMinutes: cookTimeMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(cookTimeMinutes),
      sourceUrl: sourceUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceUrl),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      courseId: courseId == null && nullToAbsent
          ? const Value.absent()
          : Value(courseId),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      rating:
          rating == null && nullToAbsent ? const Value.absent() : Value(rating),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      nutritionJson: nutritionJson == null && nullToAbsent
          ? const Value.absent()
          : Value(nutritionJson),
      isFavorite: Value(isFavorite),
      isPinned: Value(isPinned),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      lastViewedAt: lastViewedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastViewedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Recipe.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Recipe(
      id: serializer.fromJson<String>(json['id']),
      cookbookId: serializer.fromJson<String>(json['cookbookId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      servings: serializer.fromJson<String?>(json['servings']),
      prepTimeMinutes: serializer.fromJson<int?>(json['prepTimeMinutes']),
      cookTimeMinutes: serializer.fromJson<int?>(json['cookTimeMinutes']),
      sourceUrl: serializer.fromJson<String?>(json['sourceUrl']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      courseId: serializer.fromJson<String?>(json['courseId']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      rating: serializer.fromJson<int?>(json['rating']),
      notes: serializer.fromJson<String?>(json['notes']),
      nutritionJson: serializer.fromJson<String?>(json['nutritionJson']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      isPinned: serializer.fromJson<bool>(json['isPinned']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      lastViewedAt: serializer.fromJson<DateTime?>(json['lastViewedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'cookbookId': serializer.toJson<String>(cookbookId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'servings': serializer.toJson<String?>(servings),
      'prepTimeMinutes': serializer.toJson<int?>(prepTimeMinutes),
      'cookTimeMinutes': serializer.toJson<int?>(cookTimeMinutes),
      'sourceUrl': serializer.toJson<String?>(sourceUrl),
      'imagePath': serializer.toJson<String?>(imagePath),
      'courseId': serializer.toJson<String?>(courseId),
      'categoryId': serializer.toJson<String?>(categoryId),
      'rating': serializer.toJson<int?>(rating),
      'notes': serializer.toJson<String?>(notes),
      'nutritionJson': serializer.toJson<String?>(nutritionJson),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'isPinned': serializer.toJson<bool>(isPinned),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'lastViewedAt': serializer.toJson<DateTime?>(lastViewedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Recipe copyWith(
          {String? id,
          String? cookbookId,
          String? title,
          Value<String?> description = const Value.absent(),
          Value<String?> servings = const Value.absent(),
          Value<int?> prepTimeMinutes = const Value.absent(),
          Value<int?> cookTimeMinutes = const Value.absent(),
          Value<String?> sourceUrl = const Value.absent(),
          Value<String?> imagePath = const Value.absent(),
          Value<String?> courseId = const Value.absent(),
          Value<String?> categoryId = const Value.absent(),
          Value<int?> rating = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          Value<String?> nutritionJson = const Value.absent(),
          bool? isFavorite,
          bool? isPinned,
          Value<DateTime?> deletedAt = const Value.absent(),
          Value<DateTime?> lastViewedAt = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Recipe(
        id: id ?? this.id,
        cookbookId: cookbookId ?? this.cookbookId,
        title: title ?? this.title,
        description: description.present ? description.value : this.description,
        servings: servings.present ? servings.value : this.servings,
        prepTimeMinutes: prepTimeMinutes.present
            ? prepTimeMinutes.value
            : this.prepTimeMinutes,
        cookTimeMinutes: cookTimeMinutes.present
            ? cookTimeMinutes.value
            : this.cookTimeMinutes,
        sourceUrl: sourceUrl.present ? sourceUrl.value : this.sourceUrl,
        imagePath: imagePath.present ? imagePath.value : this.imagePath,
        courseId: courseId.present ? courseId.value : this.courseId,
        categoryId: categoryId.present ? categoryId.value : this.categoryId,
        rating: rating.present ? rating.value : this.rating,
        notes: notes.present ? notes.value : this.notes,
        nutritionJson:
            nutritionJson.present ? nutritionJson.value : this.nutritionJson,
        isFavorite: isFavorite ?? this.isFavorite,
        isPinned: isPinned ?? this.isPinned,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        lastViewedAt:
            lastViewedAt.present ? lastViewedAt.value : this.lastViewedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Recipe copyWithCompanion(RecipesCompanion data) {
    return Recipe(
      id: data.id.present ? data.id.value : this.id,
      cookbookId:
          data.cookbookId.present ? data.cookbookId.value : this.cookbookId,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      servings: data.servings.present ? data.servings.value : this.servings,
      prepTimeMinutes: data.prepTimeMinutes.present
          ? data.prepTimeMinutes.value
          : this.prepTimeMinutes,
      cookTimeMinutes: data.cookTimeMinutes.present
          ? data.cookTimeMinutes.value
          : this.cookTimeMinutes,
      sourceUrl: data.sourceUrl.present ? data.sourceUrl.value : this.sourceUrl,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      courseId: data.courseId.present ? data.courseId.value : this.courseId,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      rating: data.rating.present ? data.rating.value : this.rating,
      notes: data.notes.present ? data.notes.value : this.notes,
      nutritionJson: data.nutritionJson.present
          ? data.nutritionJson.value
          : this.nutritionJson,
      isFavorite:
          data.isFavorite.present ? data.isFavorite.value : this.isFavorite,
      isPinned: data.isPinned.present ? data.isPinned.value : this.isPinned,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      lastViewedAt: data.lastViewedAt.present
          ? data.lastViewedAt.value
          : this.lastViewedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Recipe(')
          ..write('id: $id, ')
          ..write('cookbookId: $cookbookId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('servings: $servings, ')
          ..write('prepTimeMinutes: $prepTimeMinutes, ')
          ..write('cookTimeMinutes: $cookTimeMinutes, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('imagePath: $imagePath, ')
          ..write('courseId: $courseId, ')
          ..write('categoryId: $categoryId, ')
          ..write('rating: $rating, ')
          ..write('notes: $notes, ')
          ..write('nutritionJson: $nutritionJson, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isPinned: $isPinned, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('lastViewedAt: $lastViewedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      cookbookId,
      title,
      description,
      servings,
      prepTimeMinutes,
      cookTimeMinutes,
      sourceUrl,
      imagePath,
      courseId,
      categoryId,
      rating,
      notes,
      nutritionJson,
      isFavorite,
      isPinned,
      deletedAt,
      lastViewedAt,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Recipe &&
          other.id == this.id &&
          other.cookbookId == this.cookbookId &&
          other.title == this.title &&
          other.description == this.description &&
          other.servings == this.servings &&
          other.prepTimeMinutes == this.prepTimeMinutes &&
          other.cookTimeMinutes == this.cookTimeMinutes &&
          other.sourceUrl == this.sourceUrl &&
          other.imagePath == this.imagePath &&
          other.courseId == this.courseId &&
          other.categoryId == this.categoryId &&
          other.rating == this.rating &&
          other.notes == this.notes &&
          other.nutritionJson == this.nutritionJson &&
          other.isFavorite == this.isFavorite &&
          other.isPinned == this.isPinned &&
          other.deletedAt == this.deletedAt &&
          other.lastViewedAt == this.lastViewedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class RecipesCompanion extends UpdateCompanion<Recipe> {
  final Value<String> id;
  final Value<String> cookbookId;
  final Value<String> title;
  final Value<String?> description;
  final Value<String?> servings;
  final Value<int?> prepTimeMinutes;
  final Value<int?> cookTimeMinutes;
  final Value<String?> sourceUrl;
  final Value<String?> imagePath;
  final Value<String?> courseId;
  final Value<String?> categoryId;
  final Value<int?> rating;
  final Value<String?> notes;
  final Value<String?> nutritionJson;
  final Value<bool> isFavorite;
  final Value<bool> isPinned;
  final Value<DateTime?> deletedAt;
  final Value<DateTime?> lastViewedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const RecipesCompanion({
    this.id = const Value.absent(),
    this.cookbookId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.servings = const Value.absent(),
    this.prepTimeMinutes = const Value.absent(),
    this.cookTimeMinutes = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.courseId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.rating = const Value.absent(),
    this.notes = const Value.absent(),
    this.nutritionJson = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.lastViewedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecipesCompanion.insert({
    required String id,
    required String cookbookId,
    required String title,
    this.description = const Value.absent(),
    this.servings = const Value.absent(),
    this.prepTimeMinutes = const Value.absent(),
    this.cookTimeMinutes = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.courseId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.rating = const Value.absent(),
    this.notes = const Value.absent(),
    this.nutritionJson = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.lastViewedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        cookbookId = Value(cookbookId),
        title = Value(title);
  static Insertable<Recipe> custom({
    Expression<String>? id,
    Expression<String>? cookbookId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? servings,
    Expression<int>? prepTimeMinutes,
    Expression<int>? cookTimeMinutes,
    Expression<String>? sourceUrl,
    Expression<String>? imagePath,
    Expression<String>? courseId,
    Expression<String>? categoryId,
    Expression<int>? rating,
    Expression<String>? notes,
    Expression<String>? nutritionJson,
    Expression<bool>? isFavorite,
    Expression<bool>? isPinned,
    Expression<DateTime>? deletedAt,
    Expression<DateTime>? lastViewedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cookbookId != null) 'cookbook_id': cookbookId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (servings != null) 'servings': servings,
      if (prepTimeMinutes != null) 'prep_time_minutes': prepTimeMinutes,
      if (cookTimeMinutes != null) 'cook_time_minutes': cookTimeMinutes,
      if (sourceUrl != null) 'source_url': sourceUrl,
      if (imagePath != null) 'image_path': imagePath,
      if (courseId != null) 'course_id': courseId,
      if (categoryId != null) 'category_id': categoryId,
      if (rating != null) 'rating': rating,
      if (notes != null) 'notes': notes,
      if (nutritionJson != null) 'nutrition_json': nutritionJson,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (isPinned != null) 'is_pinned': isPinned,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (lastViewedAt != null) 'last_viewed_at': lastViewedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecipesCompanion copyWith(
      {Value<String>? id,
      Value<String>? cookbookId,
      Value<String>? title,
      Value<String?>? description,
      Value<String?>? servings,
      Value<int?>? prepTimeMinutes,
      Value<int?>? cookTimeMinutes,
      Value<String?>? sourceUrl,
      Value<String?>? imagePath,
      Value<String?>? courseId,
      Value<String?>? categoryId,
      Value<int?>? rating,
      Value<String?>? notes,
      Value<String?>? nutritionJson,
      Value<bool>? isFavorite,
      Value<bool>? isPinned,
      Value<DateTime?>? deletedAt,
      Value<DateTime?>? lastViewedAt,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return RecipesCompanion(
      id: id ?? this.id,
      cookbookId: cookbookId ?? this.cookbookId,
      title: title ?? this.title,
      description: description ?? this.description,
      servings: servings ?? this.servings,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
      cookTimeMinutes: cookTimeMinutes ?? this.cookTimeMinutes,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      imagePath: imagePath ?? this.imagePath,
      courseId: courseId ?? this.courseId,
      categoryId: categoryId ?? this.categoryId,
      rating: rating ?? this.rating,
      notes: notes ?? this.notes,
      nutritionJson: nutritionJson ?? this.nutritionJson,
      isFavorite: isFavorite ?? this.isFavorite,
      isPinned: isPinned ?? this.isPinned,
      deletedAt: deletedAt ?? this.deletedAt,
      lastViewedAt: lastViewedAt ?? this.lastViewedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (cookbookId.present) {
      map['cookbook_id'] = Variable<String>(cookbookId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (servings.present) {
      map['servings'] = Variable<String>(servings.value);
    }
    if (prepTimeMinutes.present) {
      map['prep_time_minutes'] = Variable<int>(prepTimeMinutes.value);
    }
    if (cookTimeMinutes.present) {
      map['cook_time_minutes'] = Variable<int>(cookTimeMinutes.value);
    }
    if (sourceUrl.present) {
      map['source_url'] = Variable<String>(sourceUrl.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (courseId.present) {
      map['course_id'] = Variable<String>(courseId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (nutritionJson.present) {
      map['nutrition_json'] = Variable<String>(nutritionJson.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (isPinned.present) {
      map['is_pinned'] = Variable<bool>(isPinned.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (lastViewedAt.present) {
      map['last_viewed_at'] = Variable<DateTime>(lastViewedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecipesCompanion(')
          ..write('id: $id, ')
          ..write('cookbookId: $cookbookId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('servings: $servings, ')
          ..write('prepTimeMinutes: $prepTimeMinutes, ')
          ..write('cookTimeMinutes: $cookTimeMinutes, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('imagePath: $imagePath, ')
          ..write('courseId: $courseId, ')
          ..write('categoryId: $categoryId, ')
          ..write('rating: $rating, ')
          ..write('notes: $notes, ')
          ..write('nutritionJson: $nutritionJson, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isPinned: $isPinned, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('lastViewedAt: $lastViewedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IngredientsTable extends Ingredients
    with TableInfo<$IngredientsTable, Ingredient> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IngredientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _recipeIdMeta =
      const VerificationMeta('recipeId');
  @override
  late final GeneratedColumn<String> recipeId = GeneratedColumn<String>(
      'recipe_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<String> amount = GeneratedColumn<String>(
      'amount', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
      'unit', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 200),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, recipeId, sortOrder, amount, unit, name, notes];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ingredients';
  @override
  VerificationContext validateIntegrity(Insertable<Ingredient> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('recipe_id')) {
      context.handle(_recipeIdMeta,
          recipeId.isAcceptableOrUnknown(data['recipe_id']!, _recipeIdMeta));
    } else if (isInserting) {
      context.missing(_recipeIdMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    }
    if (data.containsKey('unit')) {
      context.handle(
          _unitMeta, unit.isAcceptableOrUnknown(data['unit']!, _unitMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Ingredient map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Ingredient(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      recipeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}recipe_id'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}amount']),
      unit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit']),
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
    );
  }

  @override
  $IngredientsTable createAlias(String alias) {
    return $IngredientsTable(attachedDatabase, alias);
  }
}

class Ingredient extends DataClass implements Insertable<Ingredient> {
  final String id;
  final String recipeId;
  final int sortOrder;
  final String? amount;
  final String? unit;
  final String name;
  final String? notes;
  const Ingredient(
      {required this.id,
      required this.recipeId,
      required this.sortOrder,
      this.amount,
      this.unit,
      required this.name,
      this.notes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['recipe_id'] = Variable<String>(recipeId);
    map['sort_order'] = Variable<int>(sortOrder);
    if (!nullToAbsent || amount != null) {
      map['amount'] = Variable<String>(amount);
    }
    if (!nullToAbsent || unit != null) {
      map['unit'] = Variable<String>(unit);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  IngredientsCompanion toCompanion(bool nullToAbsent) {
    return IngredientsCompanion(
      id: Value(id),
      recipeId: Value(recipeId),
      sortOrder: Value(sortOrder),
      amount:
          amount == null && nullToAbsent ? const Value.absent() : Value(amount),
      unit: unit == null && nullToAbsent ? const Value.absent() : Value(unit),
      name: Value(name),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
    );
  }

  factory Ingredient.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Ingredient(
      id: serializer.fromJson<String>(json['id']),
      recipeId: serializer.fromJson<String>(json['recipeId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      amount: serializer.fromJson<String?>(json['amount']),
      unit: serializer.fromJson<String?>(json['unit']),
      name: serializer.fromJson<String>(json['name']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'recipeId': serializer.toJson<String>(recipeId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'amount': serializer.toJson<String?>(amount),
      'unit': serializer.toJson<String?>(unit),
      'name': serializer.toJson<String>(name),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  Ingredient copyWith(
          {String? id,
          String? recipeId,
          int? sortOrder,
          Value<String?> amount = const Value.absent(),
          Value<String?> unit = const Value.absent(),
          String? name,
          Value<String?> notes = const Value.absent()}) =>
      Ingredient(
        id: id ?? this.id,
        recipeId: recipeId ?? this.recipeId,
        sortOrder: sortOrder ?? this.sortOrder,
        amount: amount.present ? amount.value : this.amount,
        unit: unit.present ? unit.value : this.unit,
        name: name ?? this.name,
        notes: notes.present ? notes.value : this.notes,
      );
  Ingredient copyWithCompanion(IngredientsCompanion data) {
    return Ingredient(
      id: data.id.present ? data.id.value : this.id,
      recipeId: data.recipeId.present ? data.recipeId.value : this.recipeId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      amount: data.amount.present ? data.amount.value : this.amount,
      unit: data.unit.present ? data.unit.value : this.unit,
      name: data.name.present ? data.name.value : this.name,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Ingredient(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('amount: $amount, ')
          ..write('unit: $unit, ')
          ..write('name: $name, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, recipeId, sortOrder, amount, unit, name, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Ingredient &&
          other.id == this.id &&
          other.recipeId == this.recipeId &&
          other.sortOrder == this.sortOrder &&
          other.amount == this.amount &&
          other.unit == this.unit &&
          other.name == this.name &&
          other.notes == this.notes);
}

class IngredientsCompanion extends UpdateCompanion<Ingredient> {
  final Value<String> id;
  final Value<String> recipeId;
  final Value<int> sortOrder;
  final Value<String?> amount;
  final Value<String?> unit;
  final Value<String> name;
  final Value<String?> notes;
  final Value<int> rowid;
  const IngredientsCompanion({
    this.id = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.amount = const Value.absent(),
    this.unit = const Value.absent(),
    this.name = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IngredientsCompanion.insert({
    required String id,
    required String recipeId,
    required int sortOrder,
    this.amount = const Value.absent(),
    this.unit = const Value.absent(),
    required String name,
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        recipeId = Value(recipeId),
        sortOrder = Value(sortOrder),
        name = Value(name);
  static Insertable<Ingredient> custom({
    Expression<String>? id,
    Expression<String>? recipeId,
    Expression<int>? sortOrder,
    Expression<String>? amount,
    Expression<String>? unit,
    Expression<String>? name,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recipeId != null) 'recipe_id': recipeId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (amount != null) 'amount': amount,
      if (unit != null) 'unit': unit,
      if (name != null) 'name': name,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IngredientsCompanion copyWith(
      {Value<String>? id,
      Value<String>? recipeId,
      Value<int>? sortOrder,
      Value<String?>? amount,
      Value<String?>? unit,
      Value<String>? name,
      Value<String?>? notes,
      Value<int>? rowid}) {
    return IngredientsCompanion(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      sortOrder: sortOrder ?? this.sortOrder,
      amount: amount ?? this.amount,
      unit: unit ?? this.unit,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (recipeId.present) {
      map['recipe_id'] = Variable<String>(recipeId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (amount.present) {
      map['amount'] = Variable<String>(amount.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IngredientsCompanion(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('amount: $amount, ')
          ..write('unit: $unit, ')
          ..write('name: $name, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StepsTable extends Steps with TableInfo<$StepsTable, Step> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StepsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _recipeIdMeta =
      const VerificationMeta('recipeId');
  @override
  late final GeneratedColumn<String> recipeId = GeneratedColumn<String>(
      'recipe_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _instructionMeta =
      const VerificationMeta('instruction');
  @override
  late final GeneratedColumn<String> instruction = GeneratedColumn<String>(
      'instruction', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _durationMinutesMeta =
      const VerificationMeta('durationMinutes');
  @override
  late final GeneratedColumn<int> durationMinutes = GeneratedColumn<int>(
      'duration_minutes', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _imagePathMeta =
      const VerificationMeta('imagePath');
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
      'image_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, recipeId, sortOrder, instruction, durationMinutes, imagePath];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'steps';
  @override
  VerificationContext validateIntegrity(Insertable<Step> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('recipe_id')) {
      context.handle(_recipeIdMeta,
          recipeId.isAcceptableOrUnknown(data['recipe_id']!, _recipeIdMeta));
    } else if (isInserting) {
      context.missing(_recipeIdMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('instruction')) {
      context.handle(
          _instructionMeta,
          instruction.isAcceptableOrUnknown(
              data['instruction']!, _instructionMeta));
    } else if (isInserting) {
      context.missing(_instructionMeta);
    }
    if (data.containsKey('duration_minutes')) {
      context.handle(
          _durationMinutesMeta,
          durationMinutes.isAcceptableOrUnknown(
              data['duration_minutes']!, _durationMinutesMeta));
    }
    if (data.containsKey('image_path')) {
      context.handle(_imagePathMeta,
          imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Step map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Step(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      recipeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}recipe_id'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      instruction: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}instruction'])!,
      durationMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_minutes']),
      imagePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_path']),
    );
  }

  @override
  $StepsTable createAlias(String alias) {
    return $StepsTable(attachedDatabase, alias);
  }
}

class Step extends DataClass implements Insertable<Step> {
  final String id;
  final String recipeId;
  final int sortOrder;
  final String instruction;
  final int? durationMinutes;
  final String? imagePath;
  const Step(
      {required this.id,
      required this.recipeId,
      required this.sortOrder,
      required this.instruction,
      this.durationMinutes,
      this.imagePath});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['recipe_id'] = Variable<String>(recipeId);
    map['sort_order'] = Variable<int>(sortOrder);
    map['instruction'] = Variable<String>(instruction);
    if (!nullToAbsent || durationMinutes != null) {
      map['duration_minutes'] = Variable<int>(durationMinutes);
    }
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    return map;
  }

  StepsCompanion toCompanion(bool nullToAbsent) {
    return StepsCompanion(
      id: Value(id),
      recipeId: Value(recipeId),
      sortOrder: Value(sortOrder),
      instruction: Value(instruction),
      durationMinutes: durationMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMinutes),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
    );
  }

  factory Step.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Step(
      id: serializer.fromJson<String>(json['id']),
      recipeId: serializer.fromJson<String>(json['recipeId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      instruction: serializer.fromJson<String>(json['instruction']),
      durationMinutes: serializer.fromJson<int?>(json['durationMinutes']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'recipeId': serializer.toJson<String>(recipeId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'instruction': serializer.toJson<String>(instruction),
      'durationMinutes': serializer.toJson<int?>(durationMinutes),
      'imagePath': serializer.toJson<String?>(imagePath),
    };
  }

  Step copyWith(
          {String? id,
          String? recipeId,
          int? sortOrder,
          String? instruction,
          Value<int?> durationMinutes = const Value.absent(),
          Value<String?> imagePath = const Value.absent()}) =>
      Step(
        id: id ?? this.id,
        recipeId: recipeId ?? this.recipeId,
        sortOrder: sortOrder ?? this.sortOrder,
        instruction: instruction ?? this.instruction,
        durationMinutes: durationMinutes.present
            ? durationMinutes.value
            : this.durationMinutes,
        imagePath: imagePath.present ? imagePath.value : this.imagePath,
      );
  Step copyWithCompanion(StepsCompanion data) {
    return Step(
      id: data.id.present ? data.id.value : this.id,
      recipeId: data.recipeId.present ? data.recipeId.value : this.recipeId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      instruction:
          data.instruction.present ? data.instruction.value : this.instruction,
      durationMinutes: data.durationMinutes.present
          ? data.durationMinutes.value
          : this.durationMinutes,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Step(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('instruction: $instruction, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('imagePath: $imagePath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, recipeId, sortOrder, instruction, durationMinutes, imagePath);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Step &&
          other.id == this.id &&
          other.recipeId == this.recipeId &&
          other.sortOrder == this.sortOrder &&
          other.instruction == this.instruction &&
          other.durationMinutes == this.durationMinutes &&
          other.imagePath == this.imagePath);
}

class StepsCompanion extends UpdateCompanion<Step> {
  final Value<String> id;
  final Value<String> recipeId;
  final Value<int> sortOrder;
  final Value<String> instruction;
  final Value<int?> durationMinutes;
  final Value<String?> imagePath;
  final Value<int> rowid;
  const StepsCompanion({
    this.id = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.instruction = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StepsCompanion.insert({
    required String id,
    required String recipeId,
    required int sortOrder,
    required String instruction,
    this.durationMinutes = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        recipeId = Value(recipeId),
        sortOrder = Value(sortOrder),
        instruction = Value(instruction);
  static Insertable<Step> custom({
    Expression<String>? id,
    Expression<String>? recipeId,
    Expression<int>? sortOrder,
    Expression<String>? instruction,
    Expression<int>? durationMinutes,
    Expression<String>? imagePath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recipeId != null) 'recipe_id': recipeId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (instruction != null) 'instruction': instruction,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (imagePath != null) 'image_path': imagePath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StepsCompanion copyWith(
      {Value<String>? id,
      Value<String>? recipeId,
      Value<int>? sortOrder,
      Value<String>? instruction,
      Value<int?>? durationMinutes,
      Value<String?>? imagePath,
      Value<int>? rowid}) {
    return StepsCompanion(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      sortOrder: sortOrder ?? this.sortOrder,
      instruction: instruction ?? this.instruction,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      imagePath: imagePath ?? this.imagePath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (recipeId.present) {
      map['recipe_id'] = Variable<String>(recipeId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (instruction.present) {
      map['instruction'] = Variable<String>(instruction.value);
    }
    if (durationMinutes.present) {
      map['duration_minutes'] = Variable<int>(durationMinutes.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StepsCompanion(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('instruction: $instruction, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('imagePath: $imagePath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isDefaultMeta =
      const VerificationMeta('isDefault');
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
      'is_default', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_default" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isHiddenMeta =
      const VerificationMeta('isHidden');
  @override
  late final GeneratedColumn<bool> isHidden = GeneratedColumn<bool>(
      'is_hidden', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_hidden" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, sortOrder, isDefault, isHidden, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(Insertable<Category> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('is_default')) {
      context.handle(_isDefaultMeta,
          isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta));
    }
    if (data.containsKey('is_hidden')) {
      context.handle(_isHiddenMeta,
          isHidden.isAcceptableOrUnknown(data['is_hidden']!, _isHiddenMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      isDefault: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_default'])!,
      isHidden: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_hidden'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final String id;
  final String name;
  final int sortOrder;
  final bool isDefault;
  final bool isHidden;
  final DateTime createdAt;
  const Category(
      {required this.id,
      required this.name,
      required this.sortOrder,
      required this.isDefault,
      required this.isHidden,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_default'] = Variable<bool>(isDefault);
    map['is_hidden'] = Variable<bool>(isHidden);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      sortOrder: Value(sortOrder),
      isDefault: Value(isDefault),
      isHidden: Value(isHidden),
      createdAt: Value(createdAt),
    );
  }

  factory Category.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      isHidden: serializer.fromJson<bool>(json['isHidden']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isDefault': serializer.toJson<bool>(isDefault),
      'isHidden': serializer.toJson<bool>(isHidden),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Category copyWith(
          {String? id,
          String? name,
          int? sortOrder,
          bool? isDefault,
          bool? isHidden,
          DateTime? createdAt}) =>
      Category(
        id: id ?? this.id,
        name: name ?? this.name,
        sortOrder: sortOrder ?? this.sortOrder,
        isDefault: isDefault ?? this.isDefault,
        isHidden: isHidden ?? this.isHidden,
        createdAt: createdAt ?? this.createdAt,
      );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      isHidden: data.isHidden.present ? data.isHidden.value : this.isHidden,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isDefault: $isDefault, ')
          ..write('isHidden: $isHidden, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, sortOrder, isDefault, isHidden, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.name == this.name &&
          other.sortOrder == this.sortOrder &&
          other.isDefault == this.isDefault &&
          other.isHidden == this.isHidden &&
          other.createdAt == this.createdAt);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> sortOrder;
  final Value<bool> isDefault;
  final Value<bool> isHidden;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.isHidden = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required String name,
    this.sortOrder = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.isHidden = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<Category> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? sortOrder,
    Expression<bool>? isDefault,
    Expression<bool>? isHidden,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isDefault != null) 'is_default': isDefault,
      if (isHidden != null) 'is_hidden': isHidden,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<int>? sortOrder,
      Value<bool>? isDefault,
      Value<bool>? isHidden,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      isDefault: isDefault ?? this.isDefault,
      isHidden: isHidden ?? this.isHidden,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (isHidden.present) {
      map['is_hidden'] = Variable<bool>(isHidden.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isDefault: $isDefault, ')
          ..write('isHidden: $isHidden, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ShoppingCategoriesTable extends ShoppingCategories
    with TableInfo<$ShoppingCategoriesTable, ShoppingCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShoppingCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _iconNameMeta =
      const VerificationMeta('iconName');
  @override
  late final GeneratedColumn<String> iconName = GeneratedColumn<String>(
      'icon_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isDefaultMeta =
      const VerificationMeta('isDefault');
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
      'is_default', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_default" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isHiddenMeta =
      const VerificationMeta('isHidden');
  @override
  late final GeneratedColumn<bool> isHidden = GeneratedColumn<bool>(
      'is_hidden', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_hidden" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, iconName, sortOrder, isDefault, isHidden, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shopping_categories';
  @override
  VerificationContext validateIntegrity(Insertable<ShoppingCategory> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon_name')) {
      context.handle(_iconNameMeta,
          iconName.isAcceptableOrUnknown(data['icon_name']!, _iconNameMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('is_default')) {
      context.handle(_isDefaultMeta,
          isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta));
    }
    if (data.containsKey('is_hidden')) {
      context.handle(_isHiddenMeta,
          isHidden.isAcceptableOrUnknown(data['is_hidden']!, _isHiddenMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShoppingCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShoppingCategory(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      iconName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon_name']),
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      isDefault: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_default'])!,
      isHidden: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_hidden'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ShoppingCategoriesTable createAlias(String alias) {
    return $ShoppingCategoriesTable(attachedDatabase, alias);
  }
}

class ShoppingCategory extends DataClass
    implements Insertable<ShoppingCategory> {
  final String id;
  final String name;
  final String? iconName;
  final int sortOrder;
  final bool isDefault;
  final bool isHidden;
  final DateTime createdAt;
  const ShoppingCategory(
      {required this.id,
      required this.name,
      this.iconName,
      required this.sortOrder,
      required this.isDefault,
      required this.isHidden,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || iconName != null) {
      map['icon_name'] = Variable<String>(iconName);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_default'] = Variable<bool>(isDefault);
    map['is_hidden'] = Variable<bool>(isHidden);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ShoppingCategoriesCompanion toCompanion(bool nullToAbsent) {
    return ShoppingCategoriesCompanion(
      id: Value(id),
      name: Value(name),
      iconName: iconName == null && nullToAbsent
          ? const Value.absent()
          : Value(iconName),
      sortOrder: Value(sortOrder),
      isDefault: Value(isDefault),
      isHidden: Value(isHidden),
      createdAt: Value(createdAt),
    );
  }

  factory ShoppingCategory.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShoppingCategory(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      iconName: serializer.fromJson<String?>(json['iconName']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      isHidden: serializer.fromJson<bool>(json['isHidden']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'iconName': serializer.toJson<String?>(iconName),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isDefault': serializer.toJson<bool>(isDefault),
      'isHidden': serializer.toJson<bool>(isHidden),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ShoppingCategory copyWith(
          {String? id,
          String? name,
          Value<String?> iconName = const Value.absent(),
          int? sortOrder,
          bool? isDefault,
          bool? isHidden,
          DateTime? createdAt}) =>
      ShoppingCategory(
        id: id ?? this.id,
        name: name ?? this.name,
        iconName: iconName.present ? iconName.value : this.iconName,
        sortOrder: sortOrder ?? this.sortOrder,
        isDefault: isDefault ?? this.isDefault,
        isHidden: isHidden ?? this.isHidden,
        createdAt: createdAt ?? this.createdAt,
      );
  ShoppingCategory copyWithCompanion(ShoppingCategoriesCompanion data) {
    return ShoppingCategory(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      iconName: data.iconName.present ? data.iconName.value : this.iconName,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      isHidden: data.isHidden.present ? data.isHidden.value : this.isHidden,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShoppingCategory(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconName: $iconName, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isDefault: $isDefault, ')
          ..write('isHidden: $isHidden, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, name, iconName, sortOrder, isDefault, isHidden, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShoppingCategory &&
          other.id == this.id &&
          other.name == this.name &&
          other.iconName == this.iconName &&
          other.sortOrder == this.sortOrder &&
          other.isDefault == this.isDefault &&
          other.isHidden == this.isHidden &&
          other.createdAt == this.createdAt);
}

class ShoppingCategoriesCompanion extends UpdateCompanion<ShoppingCategory> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> iconName;
  final Value<int> sortOrder;
  final Value<bool> isDefault;
  final Value<bool> isHidden;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ShoppingCategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.iconName = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.isHidden = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShoppingCategoriesCompanion.insert({
    required String id,
    required String name,
    this.iconName = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.isHidden = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<ShoppingCategory> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? iconName,
    Expression<int>? sortOrder,
    Expression<bool>? isDefault,
    Expression<bool>? isHidden,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (iconName != null) 'icon_name': iconName,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isDefault != null) 'is_default': isDefault,
      if (isHidden != null) 'is_hidden': isHidden,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShoppingCategoriesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? iconName,
      Value<int>? sortOrder,
      Value<bool>? isDefault,
      Value<bool>? isHidden,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return ShoppingCategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      sortOrder: sortOrder ?? this.sortOrder,
      isDefault: isDefault ?? this.isDefault,
      isHidden: isHidden ?? this.isHidden,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (iconName.present) {
      map['icon_name'] = Variable<String>(iconName.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (isHidden.present) {
      map['is_hidden'] = Variable<bool>(isHidden.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShoppingCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconName: $iconName, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isDefault: $isDefault, ')
          ..write('isHidden: $isHidden, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ShoppingListsTable extends ShoppingLists
    with TableInfo<$ShoppingListsTable, ShoppingList> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShoppingListsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
      'color', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isDefaultMeta =
      const VerificationMeta('isDefault');
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
      'is_default', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_default" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, color, isDefault, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shopping_lists';
  @override
  VerificationContext validateIntegrity(Insertable<ShoppingList> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    if (data.containsKey('is_default')) {
      context.handle(_isDefaultMeta,
          isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShoppingList map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShoppingList(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color']),
      isDefault: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_default'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ShoppingListsTable createAlias(String alias) {
    return $ShoppingListsTable(attachedDatabase, alias);
  }
}

class ShoppingList extends DataClass implements Insertable<ShoppingList> {
  final String id;
  final String name;
  final String? color;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ShoppingList(
      {required this.id,
      required this.name,
      this.color,
      required this.isDefault,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    map['is_default'] = Variable<bool>(isDefault);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ShoppingListsCompanion toCompanion(bool nullToAbsent) {
    return ShoppingListsCompanion(
      id: Value(id),
      name: Value(name),
      color:
          color == null && nullToAbsent ? const Value.absent() : Value(color),
      isDefault: Value(isDefault),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ShoppingList.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShoppingList(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<String?>(json['color']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<String?>(color),
      'isDefault': serializer.toJson<bool>(isDefault),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ShoppingList copyWith(
          {String? id,
          String? name,
          Value<String?> color = const Value.absent(),
          bool? isDefault,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      ShoppingList(
        id: id ?? this.id,
        name: name ?? this.name,
        color: color.present ? color.value : this.color,
        isDefault: isDefault ?? this.isDefault,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  ShoppingList copyWithCompanion(ShoppingListsCompanion data) {
    return ShoppingList(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShoppingList(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('isDefault: $isDefault, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, color, isDefault, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShoppingList &&
          other.id == this.id &&
          other.name == this.name &&
          other.color == this.color &&
          other.isDefault == this.isDefault &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ShoppingListsCompanion extends UpdateCompanion<ShoppingList> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> color;
  final Value<bool> isDefault;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ShoppingListsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShoppingListsCompanion.insert({
    required String id,
    required String name,
    this.color = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<ShoppingList> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? color,
    Expression<bool>? isDefault,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (isDefault != null) 'is_default': isDefault,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShoppingListsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? color,
      Value<bool>? isDefault,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return ShoppingListsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShoppingListsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('isDefault: $isDefault, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomCoursesTable extends CustomCourses
    with TableInfo<$CustomCoursesTable, CustomCourse> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomCoursesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cookbookIdMeta =
      const VerificationMeta('cookbookId');
  @override
  late final GeneratedColumn<String> cookbookId = GeneratedColumn<String>(
      'cookbook_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
      'emoji', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('🍽️'));
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, cookbookId, name, emoji, sortOrder, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_courses';
  @override
  VerificationContext validateIntegrity(Insertable<CustomCourse> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('cookbook_id')) {
      context.handle(
          _cookbookIdMeta,
          cookbookId.isAcceptableOrUnknown(
              data['cookbook_id']!, _cookbookIdMeta));
    } else if (isInserting) {
      context.missing(_cookbookIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('emoji')) {
      context.handle(
          _emojiMeta, emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomCourse map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomCourse(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      cookbookId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cookbook_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      emoji: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}emoji'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $CustomCoursesTable createAlias(String alias) {
    return $CustomCoursesTable(attachedDatabase, alias);
  }
}

class CustomCourse extends DataClass implements Insertable<CustomCourse> {
  final String id;
  final String cookbookId;
  final String name;
  final String emoji;
  final int sortOrder;
  final DateTime createdAt;
  const CustomCourse(
      {required this.id,
      required this.cookbookId,
      required this.name,
      required this.emoji,
      required this.sortOrder,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['cookbook_id'] = Variable<String>(cookbookId);
    map['name'] = Variable<String>(name);
    map['emoji'] = Variable<String>(emoji);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CustomCoursesCompanion toCompanion(bool nullToAbsent) {
    return CustomCoursesCompanion(
      id: Value(id),
      cookbookId: Value(cookbookId),
      name: Value(name),
      emoji: Value(emoji),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
    );
  }

  factory CustomCourse.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomCourse(
      id: serializer.fromJson<String>(json['id']),
      cookbookId: serializer.fromJson<String>(json['cookbookId']),
      name: serializer.fromJson<String>(json['name']),
      emoji: serializer.fromJson<String>(json['emoji']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'cookbookId': serializer.toJson<String>(cookbookId),
      'name': serializer.toJson<String>(name),
      'emoji': serializer.toJson<String>(emoji),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CustomCourse copyWith(
          {String? id,
          String? cookbookId,
          String? name,
          String? emoji,
          int? sortOrder,
          DateTime? createdAt}) =>
      CustomCourse(
        id: id ?? this.id,
        cookbookId: cookbookId ?? this.cookbookId,
        name: name ?? this.name,
        emoji: emoji ?? this.emoji,
        sortOrder: sortOrder ?? this.sortOrder,
        createdAt: createdAt ?? this.createdAt,
      );
  CustomCourse copyWithCompanion(CustomCoursesCompanion data) {
    return CustomCourse(
      id: data.id.present ? data.id.value : this.id,
      cookbookId:
          data.cookbookId.present ? data.cookbookId.value : this.cookbookId,
      name: data.name.present ? data.name.value : this.name,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomCourse(')
          ..write('id: $id, ')
          ..write('cookbookId: $cookbookId, ')
          ..write('name: $name, ')
          ..write('emoji: $emoji, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, cookbookId, name, emoji, sortOrder, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomCourse &&
          other.id == this.id &&
          other.cookbookId == this.cookbookId &&
          other.name == this.name &&
          other.emoji == this.emoji &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt);
}

class CustomCoursesCompanion extends UpdateCompanion<CustomCourse> {
  final Value<String> id;
  final Value<String> cookbookId;
  final Value<String> name;
  final Value<String> emoji;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CustomCoursesCompanion({
    this.id = const Value.absent(),
    this.cookbookId = const Value.absent(),
    this.name = const Value.absent(),
    this.emoji = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomCoursesCompanion.insert({
    required String id,
    required String cookbookId,
    required String name,
    this.emoji = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        cookbookId = Value(cookbookId),
        name = Value(name);
  static Insertable<CustomCourse> custom({
    Expression<String>? id,
    Expression<String>? cookbookId,
    Expression<String>? name,
    Expression<String>? emoji,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cookbookId != null) 'cookbook_id': cookbookId,
      if (name != null) 'name': name,
      if (emoji != null) 'emoji': emoji,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomCoursesCompanion copyWith(
      {Value<String>? id,
      Value<String>? cookbookId,
      Value<String>? name,
      Value<String>? emoji,
      Value<int>? sortOrder,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return CustomCoursesCompanion(
      id: id ?? this.id,
      cookbookId: cookbookId ?? this.cookbookId,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (cookbookId.present) {
      map['cookbook_id'] = Variable<String>(cookbookId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomCoursesCompanion(')
          ..write('id: $id, ')
          ..write('cookbookId: $cookbookId, ')
          ..write('name: $name, ')
          ..write('emoji: $emoji, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomCategoriesTable extends CustomCategories
    with TableInfo<$CustomCategoriesTable, CustomCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cookbookIdMeta =
      const VerificationMeta('cookbookId');
  @override
  late final GeneratedColumn<String> cookbookId = GeneratedColumn<String>(
      'cookbook_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
      'emoji', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('🏷️'));
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, cookbookId, name, emoji, sortOrder, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_categories';
  @override
  VerificationContext validateIntegrity(Insertable<CustomCategory> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('cookbook_id')) {
      context.handle(
          _cookbookIdMeta,
          cookbookId.isAcceptableOrUnknown(
              data['cookbook_id']!, _cookbookIdMeta));
    } else if (isInserting) {
      context.missing(_cookbookIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('emoji')) {
      context.handle(
          _emojiMeta, emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomCategory(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      cookbookId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cookbook_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      emoji: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}emoji'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $CustomCategoriesTable createAlias(String alias) {
    return $CustomCategoriesTable(attachedDatabase, alias);
  }
}

class CustomCategory extends DataClass implements Insertable<CustomCategory> {
  final String id;
  final String cookbookId;
  final String name;
  final String emoji;
  final int sortOrder;
  final DateTime createdAt;
  const CustomCategory(
      {required this.id,
      required this.cookbookId,
      required this.name,
      required this.emoji,
      required this.sortOrder,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['cookbook_id'] = Variable<String>(cookbookId);
    map['name'] = Variable<String>(name);
    map['emoji'] = Variable<String>(emoji);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CustomCategoriesCompanion toCompanion(bool nullToAbsent) {
    return CustomCategoriesCompanion(
      id: Value(id),
      cookbookId: Value(cookbookId),
      name: Value(name),
      emoji: Value(emoji),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
    );
  }

  factory CustomCategory.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomCategory(
      id: serializer.fromJson<String>(json['id']),
      cookbookId: serializer.fromJson<String>(json['cookbookId']),
      name: serializer.fromJson<String>(json['name']),
      emoji: serializer.fromJson<String>(json['emoji']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'cookbookId': serializer.toJson<String>(cookbookId),
      'name': serializer.toJson<String>(name),
      'emoji': serializer.toJson<String>(emoji),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CustomCategory copyWith(
          {String? id,
          String? cookbookId,
          String? name,
          String? emoji,
          int? sortOrder,
          DateTime? createdAt}) =>
      CustomCategory(
        id: id ?? this.id,
        cookbookId: cookbookId ?? this.cookbookId,
        name: name ?? this.name,
        emoji: emoji ?? this.emoji,
        sortOrder: sortOrder ?? this.sortOrder,
        createdAt: createdAt ?? this.createdAt,
      );
  CustomCategory copyWithCompanion(CustomCategoriesCompanion data) {
    return CustomCategory(
      id: data.id.present ? data.id.value : this.id,
      cookbookId:
          data.cookbookId.present ? data.cookbookId.value : this.cookbookId,
      name: data.name.present ? data.name.value : this.name,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomCategory(')
          ..write('id: $id, ')
          ..write('cookbookId: $cookbookId, ')
          ..write('name: $name, ')
          ..write('emoji: $emoji, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, cookbookId, name, emoji, sortOrder, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomCategory &&
          other.id == this.id &&
          other.cookbookId == this.cookbookId &&
          other.name == this.name &&
          other.emoji == this.emoji &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt);
}

class CustomCategoriesCompanion extends UpdateCompanion<CustomCategory> {
  final Value<String> id;
  final Value<String> cookbookId;
  final Value<String> name;
  final Value<String> emoji;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CustomCategoriesCompanion({
    this.id = const Value.absent(),
    this.cookbookId = const Value.absent(),
    this.name = const Value.absent(),
    this.emoji = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomCategoriesCompanion.insert({
    required String id,
    required String cookbookId,
    required String name,
    this.emoji = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        cookbookId = Value(cookbookId),
        name = Value(name);
  static Insertable<CustomCategory> custom({
    Expression<String>? id,
    Expression<String>? cookbookId,
    Expression<String>? name,
    Expression<String>? emoji,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cookbookId != null) 'cookbook_id': cookbookId,
      if (name != null) 'name': name,
      if (emoji != null) 'emoji': emoji,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomCategoriesCompanion copyWith(
      {Value<String>? id,
      Value<String>? cookbookId,
      Value<String>? name,
      Value<String>? emoji,
      Value<int>? sortOrder,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return CustomCategoriesCompanion(
      id: id ?? this.id,
      cookbookId: cookbookId ?? this.cookbookId,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (cookbookId.present) {
      map['cookbook_id'] = Variable<String>(cookbookId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('cookbookId: $cookbookId, ')
          ..write('name: $name, ')
          ..write('emoji: $emoji, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ShoppingListItemsTable extends ShoppingListItems
    with TableInfo<$ShoppingListItemsTable, ShoppingListItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShoppingListItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _listIdMeta = const VerificationMeta('listId');
  @override
  late final GeneratedColumn<String> listId = GeneratedColumn<String>(
      'list_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 200),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<String> quantity = GeneratedColumn<String>(
      'quantity', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
      'unit', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _shoppingCategoryIdMeta =
      const VerificationMeta('shoppingCategoryId');
  @override
  late final GeneratedColumn<String> shoppingCategoryId =
      GeneratedColumn<String>('shopping_category_id', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isCheckedMeta =
      const VerificationMeta('isChecked');
  @override
  late final GeneratedColumn<bool> isChecked = GeneratedColumn<bool>(
      'is_checked', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_checked" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isFavoriteMeta =
      const VerificationMeta('isFavorite');
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
      'is_favorite', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_favorite" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _useCountMeta =
      const VerificationMeta('useCount');
  @override
  late final GeneratedColumn<int> useCount = GeneratedColumn<int>(
      'use_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _recipeIdMeta =
      const VerificationMeta('recipeId');
  @override
  late final GeneratedColumn<String> recipeId = GeneratedColumn<String>(
      'recipe_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        listId,
        name,
        quantity,
        unit,
        shoppingCategoryId,
        isChecked,
        isFavorite,
        useCount,
        note,
        sortOrder,
        recipeId,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shopping_list_items';
  @override
  VerificationContext validateIntegrity(Insertable<ShoppingListItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('list_id')) {
      context.handle(_listIdMeta,
          listId.isAcceptableOrUnknown(data['list_id']!, _listIdMeta));
    } else if (isInserting) {
      context.missing(_listIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    }
    if (data.containsKey('unit')) {
      context.handle(
          _unitMeta, unit.isAcceptableOrUnknown(data['unit']!, _unitMeta));
    }
    if (data.containsKey('shopping_category_id')) {
      context.handle(
          _shoppingCategoryIdMeta,
          shoppingCategoryId.isAcceptableOrUnknown(
              data['shopping_category_id']!, _shoppingCategoryIdMeta));
    }
    if (data.containsKey('is_checked')) {
      context.handle(_isCheckedMeta,
          isChecked.isAcceptableOrUnknown(data['is_checked']!, _isCheckedMeta));
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
          _isFavoriteMeta,
          isFavorite.isAcceptableOrUnknown(
              data['is_favorite']!, _isFavoriteMeta));
    }
    if (data.containsKey('use_count')) {
      context.handle(_useCountMeta,
          useCount.isAcceptableOrUnknown(data['use_count']!, _useCountMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('recipe_id')) {
      context.handle(_recipeIdMeta,
          recipeId.isAcceptableOrUnknown(data['recipe_id']!, _recipeIdMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShoppingListItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShoppingListItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      listId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}list_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}quantity']),
      unit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit']),
      shoppingCategoryId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}shopping_category_id']),
      isChecked: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_checked'])!,
      isFavorite: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_favorite'])!,
      useCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}use_count'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      recipeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}recipe_id']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ShoppingListItemsTable createAlias(String alias) {
    return $ShoppingListItemsTable(attachedDatabase, alias);
  }
}

class ShoppingListItem extends DataClass
    implements Insertable<ShoppingListItem> {
  final String id;
  final String listId;
  final String name;
  final String? quantity;
  final String? unit;
  final String? shoppingCategoryId;
  final bool isChecked;
  final bool isFavorite;
  final int useCount;
  final String? note;
  final int sortOrder;
  final String? recipeId;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ShoppingListItem(
      {required this.id,
      required this.listId,
      required this.name,
      this.quantity,
      this.unit,
      this.shoppingCategoryId,
      required this.isChecked,
      required this.isFavorite,
      required this.useCount,
      this.note,
      required this.sortOrder,
      this.recipeId,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['list_id'] = Variable<String>(listId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || quantity != null) {
      map['quantity'] = Variable<String>(quantity);
    }
    if (!nullToAbsent || unit != null) {
      map['unit'] = Variable<String>(unit);
    }
    if (!nullToAbsent || shoppingCategoryId != null) {
      map['shopping_category_id'] = Variable<String>(shoppingCategoryId);
    }
    map['is_checked'] = Variable<bool>(isChecked);
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['use_count'] = Variable<int>(useCount);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    if (!nullToAbsent || recipeId != null) {
      map['recipe_id'] = Variable<String>(recipeId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ShoppingListItemsCompanion toCompanion(bool nullToAbsent) {
    return ShoppingListItemsCompanion(
      id: Value(id),
      listId: Value(listId),
      name: Value(name),
      quantity: quantity == null && nullToAbsent
          ? const Value.absent()
          : Value(quantity),
      unit: unit == null && nullToAbsent ? const Value.absent() : Value(unit),
      shoppingCategoryId: shoppingCategoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(shoppingCategoryId),
      isChecked: Value(isChecked),
      isFavorite: Value(isFavorite),
      useCount: Value(useCount),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      sortOrder: Value(sortOrder),
      recipeId: recipeId == null && nullToAbsent
          ? const Value.absent()
          : Value(recipeId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ShoppingListItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShoppingListItem(
      id: serializer.fromJson<String>(json['id']),
      listId: serializer.fromJson<String>(json['listId']),
      name: serializer.fromJson<String>(json['name']),
      quantity: serializer.fromJson<String?>(json['quantity']),
      unit: serializer.fromJson<String?>(json['unit']),
      shoppingCategoryId:
          serializer.fromJson<String?>(json['shoppingCategoryId']),
      isChecked: serializer.fromJson<bool>(json['isChecked']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      useCount: serializer.fromJson<int>(json['useCount']),
      note: serializer.fromJson<String?>(json['note']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      recipeId: serializer.fromJson<String?>(json['recipeId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'listId': serializer.toJson<String>(listId),
      'name': serializer.toJson<String>(name),
      'quantity': serializer.toJson<String?>(quantity),
      'unit': serializer.toJson<String?>(unit),
      'shoppingCategoryId': serializer.toJson<String?>(shoppingCategoryId),
      'isChecked': serializer.toJson<bool>(isChecked),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'useCount': serializer.toJson<int>(useCount),
      'note': serializer.toJson<String?>(note),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'recipeId': serializer.toJson<String?>(recipeId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ShoppingListItem copyWith(
          {String? id,
          String? listId,
          String? name,
          Value<String?> quantity = const Value.absent(),
          Value<String?> unit = const Value.absent(),
          Value<String?> shoppingCategoryId = const Value.absent(),
          bool? isChecked,
          bool? isFavorite,
          int? useCount,
          Value<String?> note = const Value.absent(),
          int? sortOrder,
          Value<String?> recipeId = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      ShoppingListItem(
        id: id ?? this.id,
        listId: listId ?? this.listId,
        name: name ?? this.name,
        quantity: quantity.present ? quantity.value : this.quantity,
        unit: unit.present ? unit.value : this.unit,
        shoppingCategoryId: shoppingCategoryId.present
            ? shoppingCategoryId.value
            : this.shoppingCategoryId,
        isChecked: isChecked ?? this.isChecked,
        isFavorite: isFavorite ?? this.isFavorite,
        useCount: useCount ?? this.useCount,
        note: note.present ? note.value : this.note,
        sortOrder: sortOrder ?? this.sortOrder,
        recipeId: recipeId.present ? recipeId.value : this.recipeId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  ShoppingListItem copyWithCompanion(ShoppingListItemsCompanion data) {
    return ShoppingListItem(
      id: data.id.present ? data.id.value : this.id,
      listId: data.listId.present ? data.listId.value : this.listId,
      name: data.name.present ? data.name.value : this.name,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unit: data.unit.present ? data.unit.value : this.unit,
      shoppingCategoryId: data.shoppingCategoryId.present
          ? data.shoppingCategoryId.value
          : this.shoppingCategoryId,
      isChecked: data.isChecked.present ? data.isChecked.value : this.isChecked,
      isFavorite:
          data.isFavorite.present ? data.isFavorite.value : this.isFavorite,
      useCount: data.useCount.present ? data.useCount.value : this.useCount,
      note: data.note.present ? data.note.value : this.note,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      recipeId: data.recipeId.present ? data.recipeId.value : this.recipeId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShoppingListItem(')
          ..write('id: $id, ')
          ..write('listId: $listId, ')
          ..write('name: $name, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('shoppingCategoryId: $shoppingCategoryId, ')
          ..write('isChecked: $isChecked, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('useCount: $useCount, ')
          ..write('note: $note, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('recipeId: $recipeId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      listId,
      name,
      quantity,
      unit,
      shoppingCategoryId,
      isChecked,
      isFavorite,
      useCount,
      note,
      sortOrder,
      recipeId,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShoppingListItem &&
          other.id == this.id &&
          other.listId == this.listId &&
          other.name == this.name &&
          other.quantity == this.quantity &&
          other.unit == this.unit &&
          other.shoppingCategoryId == this.shoppingCategoryId &&
          other.isChecked == this.isChecked &&
          other.isFavorite == this.isFavorite &&
          other.useCount == this.useCount &&
          other.note == this.note &&
          other.sortOrder == this.sortOrder &&
          other.recipeId == this.recipeId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ShoppingListItemsCompanion extends UpdateCompanion<ShoppingListItem> {
  final Value<String> id;
  final Value<String> listId;
  final Value<String> name;
  final Value<String?> quantity;
  final Value<String?> unit;
  final Value<String?> shoppingCategoryId;
  final Value<bool> isChecked;
  final Value<bool> isFavorite;
  final Value<int> useCount;
  final Value<String?> note;
  final Value<int> sortOrder;
  final Value<String?> recipeId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ShoppingListItemsCompanion({
    this.id = const Value.absent(),
    this.listId = const Value.absent(),
    this.name = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.shoppingCategoryId = const Value.absent(),
    this.isChecked = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.useCount = const Value.absent(),
    this.note = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShoppingListItemsCompanion.insert({
    required String id,
    required String listId,
    required String name,
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.shoppingCategoryId = const Value.absent(),
    this.isChecked = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.useCount = const Value.absent(),
    this.note = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        listId = Value(listId),
        name = Value(name);
  static Insertable<ShoppingListItem> custom({
    Expression<String>? id,
    Expression<String>? listId,
    Expression<String>? name,
    Expression<String>? quantity,
    Expression<String>? unit,
    Expression<String>? shoppingCategoryId,
    Expression<bool>? isChecked,
    Expression<bool>? isFavorite,
    Expression<int>? useCount,
    Expression<String>? note,
    Expression<int>? sortOrder,
    Expression<String>? recipeId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (listId != null) 'list_id': listId,
      if (name != null) 'name': name,
      if (quantity != null) 'quantity': quantity,
      if (unit != null) 'unit': unit,
      if (shoppingCategoryId != null)
        'shopping_category_id': shoppingCategoryId,
      if (isChecked != null) 'is_checked': isChecked,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (useCount != null) 'use_count': useCount,
      if (note != null) 'note': note,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (recipeId != null) 'recipe_id': recipeId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShoppingListItemsCompanion copyWith(
      {Value<String>? id,
      Value<String>? listId,
      Value<String>? name,
      Value<String?>? quantity,
      Value<String?>? unit,
      Value<String?>? shoppingCategoryId,
      Value<bool>? isChecked,
      Value<bool>? isFavorite,
      Value<int>? useCount,
      Value<String?>? note,
      Value<int>? sortOrder,
      Value<String?>? recipeId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return ShoppingListItemsCompanion(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      shoppingCategoryId: shoppingCategoryId ?? this.shoppingCategoryId,
      isChecked: isChecked ?? this.isChecked,
      isFavorite: isFavorite ?? this.isFavorite,
      useCount: useCount ?? this.useCount,
      note: note ?? this.note,
      sortOrder: sortOrder ?? this.sortOrder,
      recipeId: recipeId ?? this.recipeId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (listId.present) {
      map['list_id'] = Variable<String>(listId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<String>(quantity.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (shoppingCategoryId.present) {
      map['shopping_category_id'] = Variable<String>(shoppingCategoryId.value);
    }
    if (isChecked.present) {
      map['is_checked'] = Variable<bool>(isChecked.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (useCount.present) {
      map['use_count'] = Variable<int>(useCount.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (recipeId.present) {
      map['recipe_id'] = Variable<String>(recipeId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShoppingListItemsCompanion(')
          ..write('id: $id, ')
          ..write('listId: $listId, ')
          ..write('name: $name, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('shoppingCategoryId: $shoppingCategoryId, ')
          ..write('isChecked: $isChecked, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('useCount: $useCount, ')
          ..write('note: $note, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('recipeId: $recipeId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MealPlansTable extends MealPlans
    with TableInfo<$MealPlansTable, MealPlan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MealPlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumn<DateTime> time = GeneratedColumn<DateTime>(
      'time', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _mealTypeMeta =
      const VerificationMeta('mealType');
  @override
  late final GeneratedColumn<String> mealType = GeneratedColumn<String>(
      'meal_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Dinner'));
  static const VerificationMeta _customMealMeta =
      const VerificationMeta('customMeal');
  @override
  late final GeneratedColumn<String> customMeal = GeneratedColumn<String>(
      'custom_meal', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _recipeIdMeta =
      const VerificationMeta('recipeId');
  @override
  late final GeneratedColumn<String> recipeId = GeneratedColumn<String>(
      'recipe_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _alertEnabledMeta =
      const VerificationMeta('alertEnabled');
  @override
  late final GeneratedColumn<bool> alertEnabled = GeneratedColumn<bool>(
      'alert_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("alert_enabled" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _alertSentMeta =
      const VerificationMeta('alertSent');
  @override
  late final GeneratedColumn<bool> alertSent = GeneratedColumn<bool>(
      'alert_sent', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("alert_sent" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        date,
        time,
        name,
        mealType,
        customMeal,
        recipeId,
        notes,
        alertEnabled,
        alertSent,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meal_plans';
  @override
  VerificationContext validateIntegrity(Insertable<MealPlan> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('time')) {
      context.handle(
          _timeMeta, time.isAcceptableOrUnknown(data['time']!, _timeMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    }
    if (data.containsKey('meal_type')) {
      context.handle(_mealTypeMeta,
          mealType.isAcceptableOrUnknown(data['meal_type']!, _mealTypeMeta));
    }
    if (data.containsKey('custom_meal')) {
      context.handle(
          _customMealMeta,
          customMeal.isAcceptableOrUnknown(
              data['custom_meal']!, _customMealMeta));
    }
    if (data.containsKey('recipe_id')) {
      context.handle(_recipeIdMeta,
          recipeId.isAcceptableOrUnknown(data['recipe_id']!, _recipeIdMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('alert_enabled')) {
      context.handle(
          _alertEnabledMeta,
          alertEnabled.isAcceptableOrUnknown(
              data['alert_enabled']!, _alertEnabledMeta));
    }
    if (data.containsKey('alert_sent')) {
      context.handle(_alertSentMeta,
          alertSent.isAcceptableOrUnknown(data['alert_sent']!, _alertSentMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MealPlan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MealPlan(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      time: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}time']),
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name']),
      mealType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}meal_type'])!,
      customMeal: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}custom_meal']),
      recipeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}recipe_id']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      alertEnabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}alert_enabled'])!,
      alertSent: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}alert_sent'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $MealPlansTable createAlias(String alias) {
    return $MealPlansTable(attachedDatabase, alias);
  }
}

class MealPlan extends DataClass implements Insertable<MealPlan> {
  final String id;
  final DateTime date;
  final DateTime? time;
  final String? name;
  final String mealType;
  final String? customMeal;
  final String? recipeId;
  final String? notes;
  final bool alertEnabled;
  final bool alertSent;
  final DateTime createdAt;
  final DateTime updatedAt;
  const MealPlan(
      {required this.id,
      required this.date,
      this.time,
      this.name,
      required this.mealType,
      this.customMeal,
      this.recipeId,
      this.notes,
      required this.alertEnabled,
      required this.alertSent,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || time != null) {
      map['time'] = Variable<DateTime>(time);
    }
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    map['meal_type'] = Variable<String>(mealType);
    if (!nullToAbsent || customMeal != null) {
      map['custom_meal'] = Variable<String>(customMeal);
    }
    if (!nullToAbsent || recipeId != null) {
      map['recipe_id'] = Variable<String>(recipeId);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['alert_enabled'] = Variable<bool>(alertEnabled);
    map['alert_sent'] = Variable<bool>(alertSent);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MealPlansCompanion toCompanion(bool nullToAbsent) {
    return MealPlansCompanion(
      id: Value(id),
      date: Value(date),
      time: time == null && nullToAbsent ? const Value.absent() : Value(time),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      mealType: Value(mealType),
      customMeal: customMeal == null && nullToAbsent
          ? const Value.absent()
          : Value(customMeal),
      recipeId: recipeId == null && nullToAbsent
          ? const Value.absent()
          : Value(recipeId),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      alertEnabled: Value(alertEnabled),
      alertSent: Value(alertSent),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory MealPlan.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MealPlan(
      id: serializer.fromJson<String>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      time: serializer.fromJson<DateTime?>(json['time']),
      name: serializer.fromJson<String?>(json['name']),
      mealType: serializer.fromJson<String>(json['mealType']),
      customMeal: serializer.fromJson<String?>(json['customMeal']),
      recipeId: serializer.fromJson<String?>(json['recipeId']),
      notes: serializer.fromJson<String?>(json['notes']),
      alertEnabled: serializer.fromJson<bool>(json['alertEnabled']),
      alertSent: serializer.fromJson<bool>(json['alertSent']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'date': serializer.toJson<DateTime>(date),
      'time': serializer.toJson<DateTime?>(time),
      'name': serializer.toJson<String?>(name),
      'mealType': serializer.toJson<String>(mealType),
      'customMeal': serializer.toJson<String?>(customMeal),
      'recipeId': serializer.toJson<String?>(recipeId),
      'notes': serializer.toJson<String?>(notes),
      'alertEnabled': serializer.toJson<bool>(alertEnabled),
      'alertSent': serializer.toJson<bool>(alertSent),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  MealPlan copyWith(
          {String? id,
          DateTime? date,
          Value<DateTime?> time = const Value.absent(),
          Value<String?> name = const Value.absent(),
          String? mealType,
          Value<String?> customMeal = const Value.absent(),
          Value<String?> recipeId = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          bool? alertEnabled,
          bool? alertSent,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      MealPlan(
        id: id ?? this.id,
        date: date ?? this.date,
        time: time.present ? time.value : this.time,
        name: name.present ? name.value : this.name,
        mealType: mealType ?? this.mealType,
        customMeal: customMeal.present ? customMeal.value : this.customMeal,
        recipeId: recipeId.present ? recipeId.value : this.recipeId,
        notes: notes.present ? notes.value : this.notes,
        alertEnabled: alertEnabled ?? this.alertEnabled,
        alertSent: alertSent ?? this.alertSent,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  MealPlan copyWithCompanion(MealPlansCompanion data) {
    return MealPlan(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      time: data.time.present ? data.time.value : this.time,
      name: data.name.present ? data.name.value : this.name,
      mealType: data.mealType.present ? data.mealType.value : this.mealType,
      customMeal:
          data.customMeal.present ? data.customMeal.value : this.customMeal,
      recipeId: data.recipeId.present ? data.recipeId.value : this.recipeId,
      notes: data.notes.present ? data.notes.value : this.notes,
      alertEnabled: data.alertEnabled.present
          ? data.alertEnabled.value
          : this.alertEnabled,
      alertSent: data.alertSent.present ? data.alertSent.value : this.alertSent,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MealPlan(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('time: $time, ')
          ..write('name: $name, ')
          ..write('mealType: $mealType, ')
          ..write('customMeal: $customMeal, ')
          ..write('recipeId: $recipeId, ')
          ..write('notes: $notes, ')
          ..write('alertEnabled: $alertEnabled, ')
          ..write('alertSent: $alertSent, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, time, name, mealType, customMeal,
      recipeId, notes, alertEnabled, alertSent, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MealPlan &&
          other.id == this.id &&
          other.date == this.date &&
          other.time == this.time &&
          other.name == this.name &&
          other.mealType == this.mealType &&
          other.customMeal == this.customMeal &&
          other.recipeId == this.recipeId &&
          other.notes == this.notes &&
          other.alertEnabled == this.alertEnabled &&
          other.alertSent == this.alertSent &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MealPlansCompanion extends UpdateCompanion<MealPlan> {
  final Value<String> id;
  final Value<DateTime> date;
  final Value<DateTime?> time;
  final Value<String?> name;
  final Value<String> mealType;
  final Value<String?> customMeal;
  final Value<String?> recipeId;
  final Value<String?> notes;
  final Value<bool> alertEnabled;
  final Value<bool> alertSent;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const MealPlansCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.time = const Value.absent(),
    this.name = const Value.absent(),
    this.mealType = const Value.absent(),
    this.customMeal = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.notes = const Value.absent(),
    this.alertEnabled = const Value.absent(),
    this.alertSent = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MealPlansCompanion.insert({
    required String id,
    required DateTime date,
    this.time = const Value.absent(),
    this.name = const Value.absent(),
    this.mealType = const Value.absent(),
    this.customMeal = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.notes = const Value.absent(),
    this.alertEnabled = const Value.absent(),
    this.alertSent = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        date = Value(date);
  static Insertable<MealPlan> custom({
    Expression<String>? id,
    Expression<DateTime>? date,
    Expression<DateTime>? time,
    Expression<String>? name,
    Expression<String>? mealType,
    Expression<String>? customMeal,
    Expression<String>? recipeId,
    Expression<String>? notes,
    Expression<bool>? alertEnabled,
    Expression<bool>? alertSent,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (time != null) 'time': time,
      if (name != null) 'name': name,
      if (mealType != null) 'meal_type': mealType,
      if (customMeal != null) 'custom_meal': customMeal,
      if (recipeId != null) 'recipe_id': recipeId,
      if (notes != null) 'notes': notes,
      if (alertEnabled != null) 'alert_enabled': alertEnabled,
      if (alertSent != null) 'alert_sent': alertSent,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MealPlansCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? date,
      Value<DateTime?>? time,
      Value<String?>? name,
      Value<String>? mealType,
      Value<String?>? customMeal,
      Value<String?>? recipeId,
      Value<String?>? notes,
      Value<bool>? alertEnabled,
      Value<bool>? alertSent,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return MealPlansCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      time: time ?? this.time,
      name: name ?? this.name,
      mealType: mealType ?? this.mealType,
      customMeal: customMeal ?? this.customMeal,
      recipeId: recipeId ?? this.recipeId,
      notes: notes ?? this.notes,
      alertEnabled: alertEnabled ?? this.alertEnabled,
      alertSent: alertSent ?? this.alertSent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (time.present) {
      map['time'] = Variable<DateTime>(time.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (mealType.present) {
      map['meal_type'] = Variable<String>(mealType.value);
    }
    if (customMeal.present) {
      map['custom_meal'] = Variable<String>(customMeal.value);
    }
    if (recipeId.present) {
      map['recipe_id'] = Variable<String>(recipeId.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (alertEnabled.present) {
      map['alert_enabled'] = Variable<bool>(alertEnabled.value);
    }
    if (alertSent.present) {
      map['alert_sent'] = Variable<bool>(alertSent.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MealPlansCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('time: $time, ')
          ..write('name: $name, ')
          ..write('mealType: $mealType, ')
          ..write('customMeal: $customMeal, ')
          ..write('recipeId: $recipeId, ')
          ..write('notes: $notes, ')
          ..write('alertEnabled: $alertEnabled, ')
          ..write('alertSent: $alertSent, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, Tag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
      'color', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
      'icon', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isBuiltInMeta =
      const VerificationMeta('isBuiltIn');
  @override
  late final GeneratedColumn<bool> isBuiltIn = GeneratedColumn<bool>(
      'is_built_in', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_built_in" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, color, icon, sortOrder, isBuiltIn, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(Insertable<Tag> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    if (data.containsKey('icon')) {
      context.handle(
          _iconMeta, icon.isAcceptableOrUnknown(data['icon']!, _iconMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('is_built_in')) {
      context.handle(
          _isBuiltInMeta,
          isBuiltIn.isAcceptableOrUnknown(
              data['is_built_in']!, _isBuiltInMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tag(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color']),
      icon: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon']),
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      isBuiltIn: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_built_in'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class Tag extends DataClass implements Insertable<Tag> {
  /// Unique tag ID
  final String id;

  /// Tag display name (e.g., "Vegan", "Gluten-Free")
  final String name;

  /// Optional color for the tag (hex string like "#FF5722")
  final String? color;

  /// Optional icon name
  final String? icon;

  /// Sort order for display
  final int sortOrder;

  /// Whether this is a built-in tag
  final bool isBuiltIn;

  /// When this tag was created
  final DateTime createdAt;
  const Tag(
      {required this.id,
      required this.name,
      this.color,
      this.icon,
      required this.sortOrder,
      required this.isBuiltIn,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_built_in'] = Variable<bool>(isBuiltIn);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      name: Value(name),
      color:
          color == null && nullToAbsent ? const Value.absent() : Value(color),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      sortOrder: Value(sortOrder),
      isBuiltIn: Value(isBuiltIn),
      createdAt: Value(createdAt),
    );
  }

  factory Tag.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tag(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<String?>(json['color']),
      icon: serializer.fromJson<String?>(json['icon']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isBuiltIn: serializer.fromJson<bool>(json['isBuiltIn']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<String?>(color),
      'icon': serializer.toJson<String?>(icon),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isBuiltIn': serializer.toJson<bool>(isBuiltIn),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Tag copyWith(
          {String? id,
          String? name,
          Value<String?> color = const Value.absent(),
          Value<String?> icon = const Value.absent(),
          int? sortOrder,
          bool? isBuiltIn,
          DateTime? createdAt}) =>
      Tag(
        id: id ?? this.id,
        name: name ?? this.name,
        color: color.present ? color.value : this.color,
        icon: icon.present ? icon.value : this.icon,
        sortOrder: sortOrder ?? this.sortOrder,
        isBuiltIn: isBuiltIn ?? this.isBuiltIn,
        createdAt: createdAt ?? this.createdAt,
      );
  Tag copyWithCompanion(TagsCompanion data) {
    return Tag(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
      icon: data.icon.present ? data.icon.value : this.icon,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isBuiltIn: data.isBuiltIn.present ? data.isBuiltIn.value : this.isBuiltIn,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tag(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('icon: $icon, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isBuiltIn: $isBuiltIn, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, color, icon, sortOrder, isBuiltIn, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tag &&
          other.id == this.id &&
          other.name == this.name &&
          other.color == this.color &&
          other.icon == this.icon &&
          other.sortOrder == this.sortOrder &&
          other.isBuiltIn == this.isBuiltIn &&
          other.createdAt == this.createdAt);
}

class TagsCompanion extends UpdateCompanion<Tag> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> color;
  final Value<String?> icon;
  final Value<int> sortOrder;
  final Value<bool> isBuiltIn;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.icon = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isBuiltIn = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TagsCompanion.insert({
    required String id,
    required String name,
    this.color = const Value.absent(),
    this.icon = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isBuiltIn = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<Tag> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? color,
    Expression<String>? icon,
    Expression<int>? sortOrder,
    Expression<bool>? isBuiltIn,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (icon != null) 'icon': icon,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isBuiltIn != null) 'is_built_in': isBuiltIn,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TagsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? color,
      Value<String?>? icon,
      Value<int>? sortOrder,
      Value<bool>? isBuiltIn,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return TagsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      sortOrder: sortOrder ?? this.sortOrder,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isBuiltIn.present) {
      map['is_built_in'] = Variable<bool>(isBuiltIn.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('icon: $icon, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isBuiltIn: $isBuiltIn, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecipeTagsTable extends RecipeTags
    with TableInfo<$RecipeTagsTable, RecipeTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipeTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _recipeIdMeta =
      const VerificationMeta('recipeId');
  @override
  late final GeneratedColumn<String> recipeId = GeneratedColumn<String>(
      'recipe_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<String> tagId = GeneratedColumn<String>(
      'tag_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [recipeId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recipe_tags';
  @override
  VerificationContext validateIntegrity(Insertable<RecipeTag> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('recipe_id')) {
      context.handle(_recipeIdMeta,
          recipeId.isAcceptableOrUnknown(data['recipe_id']!, _recipeIdMeta));
    } else if (isInserting) {
      context.missing(_recipeIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
          _tagIdMeta, tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta));
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {recipeId, tagId};
  @override
  RecipeTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecipeTag(
      recipeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}recipe_id'])!,
      tagId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tag_id'])!,
    );
  }

  @override
  $RecipeTagsTable createAlias(String alias) {
    return $RecipeTagsTable(attachedDatabase, alias);
  }
}

class RecipeTag extends DataClass implements Insertable<RecipeTag> {
  /// Recipe ID
  final String recipeId;

  /// Tag ID
  final String tagId;
  const RecipeTag({required this.recipeId, required this.tagId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['recipe_id'] = Variable<String>(recipeId);
    map['tag_id'] = Variable<String>(tagId);
    return map;
  }

  RecipeTagsCompanion toCompanion(bool nullToAbsent) {
    return RecipeTagsCompanion(
      recipeId: Value(recipeId),
      tagId: Value(tagId),
    );
  }

  factory RecipeTag.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecipeTag(
      recipeId: serializer.fromJson<String>(json['recipeId']),
      tagId: serializer.fromJson<String>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'recipeId': serializer.toJson<String>(recipeId),
      'tagId': serializer.toJson<String>(tagId),
    };
  }

  RecipeTag copyWith({String? recipeId, String? tagId}) => RecipeTag(
        recipeId: recipeId ?? this.recipeId,
        tagId: tagId ?? this.tagId,
      );
  RecipeTag copyWithCompanion(RecipeTagsCompanion data) {
    return RecipeTag(
      recipeId: data.recipeId.present ? data.recipeId.value : this.recipeId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecipeTag(')
          ..write('recipeId: $recipeId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(recipeId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecipeTag &&
          other.recipeId == this.recipeId &&
          other.tagId == this.tagId);
}

class RecipeTagsCompanion extends UpdateCompanion<RecipeTag> {
  final Value<String> recipeId;
  final Value<String> tagId;
  final Value<int> rowid;
  const RecipeTagsCompanion({
    this.recipeId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecipeTagsCompanion.insert({
    required String recipeId,
    required String tagId,
    this.rowid = const Value.absent(),
  })  : recipeId = Value(recipeId),
        tagId = Value(tagId);
  static Insertable<RecipeTag> custom({
    Expression<String>? recipeId,
    Expression<String>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (recipeId != null) 'recipe_id': recipeId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecipeTagsCompanion copyWith(
      {Value<String>? recipeId, Value<String>? tagId, Value<int>? rowid}) {
    return RecipeTagsCompanion(
      recipeId: recipeId ?? this.recipeId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (recipeId.present) {
      map['recipe_id'] = Variable<String>(recipeId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<String>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecipeTagsCompanion(')
          ..write('recipeId: $recipeId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserIngredientMappingsTable extends UserIngredientMappings
    with TableInfo<$UserIngredientMappingsTable, UserIngredientMapping> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserIngredientMappingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ingredientMeta =
      const VerificationMeta('ingredient');
  @override
  late final GeneratedColumn<String> ingredient = GeneratedColumn<String>(
      'ingredient', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _shoppingCategoryIdMeta =
      const VerificationMeta('shoppingCategoryId');
  @override
  late final GeneratedColumn<String> shoppingCategoryId =
      GeneratedColumn<String>('shopping_category_id', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [ingredient, shoppingCategoryId, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_ingredient_mappings';
  @override
  VerificationContext validateIntegrity(
      Insertable<UserIngredientMapping> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('ingredient')) {
      context.handle(
          _ingredientMeta,
          ingredient.isAcceptableOrUnknown(
              data['ingredient']!, _ingredientMeta));
    } else if (isInserting) {
      context.missing(_ingredientMeta);
    }
    if (data.containsKey('shopping_category_id')) {
      context.handle(
          _shoppingCategoryIdMeta,
          shoppingCategoryId.isAcceptableOrUnknown(
              data['shopping_category_id']!, _shoppingCategoryIdMeta));
    } else if (isInserting) {
      context.missing(_shoppingCategoryIdMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {ingredient};
  @override
  UserIngredientMapping map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserIngredientMapping(
      ingredient: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ingredient'])!,
      shoppingCategoryId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}shopping_category_id'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $UserIngredientMappingsTable createAlias(String alias) {
    return $UserIngredientMappingsTable(attachedDatabase, alias);
  }
}

class UserIngredientMapping extends DataClass
    implements Insertable<UserIngredientMapping> {
  /// The normalized ingredient name (lowercase, trimmed)
  final String ingredient;

  /// The shopping category ID to use for this ingredient
  final String shoppingCategoryId;

  /// When this mapping was created/updated
  final DateTime updatedAt;
  const UserIngredientMapping(
      {required this.ingredient,
      required this.shoppingCategoryId,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['ingredient'] = Variable<String>(ingredient);
    map['shopping_category_id'] = Variable<String>(shoppingCategoryId);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserIngredientMappingsCompanion toCompanion(bool nullToAbsent) {
    return UserIngredientMappingsCompanion(
      ingredient: Value(ingredient),
      shoppingCategoryId: Value(shoppingCategoryId),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserIngredientMapping.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserIngredientMapping(
      ingredient: serializer.fromJson<String>(json['ingredient']),
      shoppingCategoryId:
          serializer.fromJson<String>(json['shoppingCategoryId']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ingredient': serializer.toJson<String>(ingredient),
      'shoppingCategoryId': serializer.toJson<String>(shoppingCategoryId),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserIngredientMapping copyWith(
          {String? ingredient,
          String? shoppingCategoryId,
          DateTime? updatedAt}) =>
      UserIngredientMapping(
        ingredient: ingredient ?? this.ingredient,
        shoppingCategoryId: shoppingCategoryId ?? this.shoppingCategoryId,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  UserIngredientMapping copyWithCompanion(
      UserIngredientMappingsCompanion data) {
    return UserIngredientMapping(
      ingredient:
          data.ingredient.present ? data.ingredient.value : this.ingredient,
      shoppingCategoryId: data.shoppingCategoryId.present
          ? data.shoppingCategoryId.value
          : this.shoppingCategoryId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserIngredientMapping(')
          ..write('ingredient: $ingredient, ')
          ..write('shoppingCategoryId: $shoppingCategoryId, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(ingredient, shoppingCategoryId, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserIngredientMapping &&
          other.ingredient == this.ingredient &&
          other.shoppingCategoryId == this.shoppingCategoryId &&
          other.updatedAt == this.updatedAt);
}

class UserIngredientMappingsCompanion
    extends UpdateCompanion<UserIngredientMapping> {
  final Value<String> ingredient;
  final Value<String> shoppingCategoryId;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const UserIngredientMappingsCompanion({
    this.ingredient = const Value.absent(),
    this.shoppingCategoryId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserIngredientMappingsCompanion.insert({
    required String ingredient,
    required String shoppingCategoryId,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : ingredient = Value(ingredient),
        shoppingCategoryId = Value(shoppingCategoryId);
  static Insertable<UserIngredientMapping> custom({
    Expression<String>? ingredient,
    Expression<String>? shoppingCategoryId,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ingredient != null) 'ingredient': ingredient,
      if (shoppingCategoryId != null)
        'shopping_category_id': shoppingCategoryId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserIngredientMappingsCompanion copyWith(
      {Value<String>? ingredient,
      Value<String>? shoppingCategoryId,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return UserIngredientMappingsCompanion(
      ingredient: ingredient ?? this.ingredient,
      shoppingCategoryId: shoppingCategoryId ?? this.shoppingCategoryId,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ingredient.present) {
      map['ingredient'] = Variable<String>(ingredient.value);
    }
    if (shoppingCategoryId.present) {
      map['shopping_category_id'] = Variable<String>(shoppingCategoryId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserIngredientMappingsCompanion(')
          ..write('ingredient: $ingredient, ')
          ..write('shoppingCategoryId: $shoppingCategoryId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UsdaFoodsTable extends UsdaFoods
    with TableInfo<$UsdaFoodsTable, UsdaFood> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsdaFoodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _fdcIdMeta = const VerificationMeta('fdcId');
  @override
  late final GeneratedColumn<int> fdcId = GeneratedColumn<int>(
      'fdc_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dataTypeMeta =
      const VerificationMeta('dataType');
  @override
  late final GeneratedColumn<String> dataType = GeneratedColumn<String>(
      'data_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _brandNameMeta =
      const VerificationMeta('brandName');
  @override
  late final GeneratedColumn<String> brandName = GeneratedColumn<String>(
      'brand_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _brandOwnerMeta =
      const VerificationMeta('brandOwner');
  @override
  late final GeneratedColumn<String> brandOwner = GeneratedColumn<String>(
      'brand_owner', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _gtinUpcMeta =
      const VerificationMeta('gtinUpc');
  @override
  late final GeneratedColumn<String> gtinUpc = GeneratedColumn<String>(
      'gtin_upc', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _servingSizeMeta =
      const VerificationMeta('servingSize');
  @override
  late final GeneratedColumn<double> servingSize = GeneratedColumn<double>(
      'serving_size', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _servingSizeUnitMeta =
      const VerificationMeta('servingSizeUnit');
  @override
  late final GeneratedColumn<String> servingSizeUnit = GeneratedColumn<String>(
      'serving_size_unit', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _householdServingMeta =
      const VerificationMeta('householdServing');
  @override
  late final GeneratedColumn<String> householdServing = GeneratedColumn<String>(
      'household_serving', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nutrientsJsonMeta =
      const VerificationMeta('nutrientsJson');
  @override
  late final GeneratedColumn<String> nutrientsJson = GeneratedColumn<String>(
      'nutrients_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _foodCategoryMeta =
      const VerificationMeta('foodCategory');
  @override
  late final GeneratedColumn<String> foodCategory = GeneratedColumn<String>(
      'food_category', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ingredientsMeta =
      const VerificationMeta('ingredients');
  @override
  late final GeneratedColumn<String> ingredients = GeneratedColumn<String>(
      'ingredients', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isBundledMeta =
      const VerificationMeta('isBundled');
  @override
  late final GeneratedColumn<bool> isBundled = GeneratedColumn<bool>(
      'is_bundled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_bundled" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _searchKeywordsMeta =
      const VerificationMeta('searchKeywords');
  @override
  late final GeneratedColumn<String> searchKeywords = GeneratedColumn<String>(
      'search_keywords', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _cachedAtMeta =
      const VerificationMeta('cachedAt');
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
      'cached_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        fdcId,
        description,
        dataType,
        brandName,
        brandOwner,
        gtinUpc,
        servingSize,
        servingSizeUnit,
        householdServing,
        nutrientsJson,
        foodCategory,
        ingredients,
        isBundled,
        searchKeywords,
        cachedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'usda_foods';
  @override
  VerificationContext validateIntegrity(Insertable<UsdaFood> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('fdc_id')) {
      context.handle(
          _fdcIdMeta, fdcId.isAcceptableOrUnknown(data['fdc_id']!, _fdcIdMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('data_type')) {
      context.handle(_dataTypeMeta,
          dataType.isAcceptableOrUnknown(data['data_type']!, _dataTypeMeta));
    }
    if (data.containsKey('brand_name')) {
      context.handle(_brandNameMeta,
          brandName.isAcceptableOrUnknown(data['brand_name']!, _brandNameMeta));
    }
    if (data.containsKey('brand_owner')) {
      context.handle(
          _brandOwnerMeta,
          brandOwner.isAcceptableOrUnknown(
              data['brand_owner']!, _brandOwnerMeta));
    }
    if (data.containsKey('gtin_upc')) {
      context.handle(_gtinUpcMeta,
          gtinUpc.isAcceptableOrUnknown(data['gtin_upc']!, _gtinUpcMeta));
    }
    if (data.containsKey('serving_size')) {
      context.handle(
          _servingSizeMeta,
          servingSize.isAcceptableOrUnknown(
              data['serving_size']!, _servingSizeMeta));
    }
    if (data.containsKey('serving_size_unit')) {
      context.handle(
          _servingSizeUnitMeta,
          servingSizeUnit.isAcceptableOrUnknown(
              data['serving_size_unit']!, _servingSizeUnitMeta));
    }
    if (data.containsKey('household_serving')) {
      context.handle(
          _householdServingMeta,
          householdServing.isAcceptableOrUnknown(
              data['household_serving']!, _householdServingMeta));
    }
    if (data.containsKey('nutrients_json')) {
      context.handle(
          _nutrientsJsonMeta,
          nutrientsJson.isAcceptableOrUnknown(
              data['nutrients_json']!, _nutrientsJsonMeta));
    } else if (isInserting) {
      context.missing(_nutrientsJsonMeta);
    }
    if (data.containsKey('food_category')) {
      context.handle(
          _foodCategoryMeta,
          foodCategory.isAcceptableOrUnknown(
              data['food_category']!, _foodCategoryMeta));
    }
    if (data.containsKey('ingredients')) {
      context.handle(
          _ingredientsMeta,
          ingredients.isAcceptableOrUnknown(
              data['ingredients']!, _ingredientsMeta));
    }
    if (data.containsKey('is_bundled')) {
      context.handle(_isBundledMeta,
          isBundled.isAcceptableOrUnknown(data['is_bundled']!, _isBundledMeta));
    }
    if (data.containsKey('search_keywords')) {
      context.handle(
          _searchKeywordsMeta,
          searchKeywords.isAcceptableOrUnknown(
              data['search_keywords']!, _searchKeywordsMeta));
    }
    if (data.containsKey('cached_at')) {
      context.handle(_cachedAtMeta,
          cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {fdcId};
  @override
  UsdaFood map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UsdaFood(
      fdcId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}fdc_id'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      dataType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}data_type']),
      brandName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}brand_name']),
      brandOwner: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}brand_owner']),
      gtinUpc: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}gtin_upc']),
      servingSize: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}serving_size']),
      servingSizeUnit: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}serving_size_unit']),
      householdServing: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}household_serving']),
      nutrientsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nutrients_json'])!,
      foodCategory: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}food_category']),
      ingredients: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ingredients']),
      isBundled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_bundled'])!,
      searchKeywords: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}search_keywords']),
      cachedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}cached_at'])!,
    );
  }

  @override
  $UsdaFoodsTable createAlias(String alias) {
    return $UsdaFoodsTable(attachedDatabase, alias);
  }
}

class UsdaFood extends DataClass implements Insertable<UsdaFood> {
  /// USDA FDC ID (primary key)
  final int fdcId;

  /// Food description (e.g., "Chicken, breast, boneless, skinless, raw")
  final String description;

  /// Data type: 'Foundation', 'SR Legacy', 'Survey (FNDDS)', 'Branded'
  final String? dataType;

  /// Brand name for branded foods
  final String? brandName;

  /// Brand owner for branded foods
  final String? brandOwner;

  /// GTIN/UPC code for branded foods
  final String? gtinUpc;

  /// Serving size amount (e.g., 100 for "per 100g")
  final double? servingSize;

  /// Serving size unit (e.g., "g", "ml")
  final String? servingSizeUnit;

  /// Household serving text (e.g., "1 cup", "3 oz")
  final String? householdServing;

  /// JSON-encoded nutrients map: {nutrientId: amount}
  /// All values are per 100g
  final String nutrientsJson;

  /// Food category (e.g., "Poultry Products", "Vegetables")
  final String? foodCategory;

  /// Ingredients list for processed foods
  final String? ingredients;

  /// Whether this is from bundled data (common ingredients)
  final bool isBundled;

  /// Search keywords for better matching (lowercase, space-separated)
  final String? searchKeywords;

  /// When this record was cached/last updated
  final DateTime cachedAt;
  const UsdaFood(
      {required this.fdcId,
      required this.description,
      this.dataType,
      this.brandName,
      this.brandOwner,
      this.gtinUpc,
      this.servingSize,
      this.servingSizeUnit,
      this.householdServing,
      required this.nutrientsJson,
      this.foodCategory,
      this.ingredients,
      required this.isBundled,
      this.searchKeywords,
      required this.cachedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['fdc_id'] = Variable<int>(fdcId);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || dataType != null) {
      map['data_type'] = Variable<String>(dataType);
    }
    if (!nullToAbsent || brandName != null) {
      map['brand_name'] = Variable<String>(brandName);
    }
    if (!nullToAbsent || brandOwner != null) {
      map['brand_owner'] = Variable<String>(brandOwner);
    }
    if (!nullToAbsent || gtinUpc != null) {
      map['gtin_upc'] = Variable<String>(gtinUpc);
    }
    if (!nullToAbsent || servingSize != null) {
      map['serving_size'] = Variable<double>(servingSize);
    }
    if (!nullToAbsent || servingSizeUnit != null) {
      map['serving_size_unit'] = Variable<String>(servingSizeUnit);
    }
    if (!nullToAbsent || householdServing != null) {
      map['household_serving'] = Variable<String>(householdServing);
    }
    map['nutrients_json'] = Variable<String>(nutrientsJson);
    if (!nullToAbsent || foodCategory != null) {
      map['food_category'] = Variable<String>(foodCategory);
    }
    if (!nullToAbsent || ingredients != null) {
      map['ingredients'] = Variable<String>(ingredients);
    }
    map['is_bundled'] = Variable<bool>(isBundled);
    if (!nullToAbsent || searchKeywords != null) {
      map['search_keywords'] = Variable<String>(searchKeywords);
    }
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  UsdaFoodsCompanion toCompanion(bool nullToAbsent) {
    return UsdaFoodsCompanion(
      fdcId: Value(fdcId),
      description: Value(description),
      dataType: dataType == null && nullToAbsent
          ? const Value.absent()
          : Value(dataType),
      brandName: brandName == null && nullToAbsent
          ? const Value.absent()
          : Value(brandName),
      brandOwner: brandOwner == null && nullToAbsent
          ? const Value.absent()
          : Value(brandOwner),
      gtinUpc: gtinUpc == null && nullToAbsent
          ? const Value.absent()
          : Value(gtinUpc),
      servingSize: servingSize == null && nullToAbsent
          ? const Value.absent()
          : Value(servingSize),
      servingSizeUnit: servingSizeUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(servingSizeUnit),
      householdServing: householdServing == null && nullToAbsent
          ? const Value.absent()
          : Value(householdServing),
      nutrientsJson: Value(nutrientsJson),
      foodCategory: foodCategory == null && nullToAbsent
          ? const Value.absent()
          : Value(foodCategory),
      ingredients: ingredients == null && nullToAbsent
          ? const Value.absent()
          : Value(ingredients),
      isBundled: Value(isBundled),
      searchKeywords: searchKeywords == null && nullToAbsent
          ? const Value.absent()
          : Value(searchKeywords),
      cachedAt: Value(cachedAt),
    );
  }

  factory UsdaFood.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UsdaFood(
      fdcId: serializer.fromJson<int>(json['fdcId']),
      description: serializer.fromJson<String>(json['description']),
      dataType: serializer.fromJson<String?>(json['dataType']),
      brandName: serializer.fromJson<String?>(json['brandName']),
      brandOwner: serializer.fromJson<String?>(json['brandOwner']),
      gtinUpc: serializer.fromJson<String?>(json['gtinUpc']),
      servingSize: serializer.fromJson<double?>(json['servingSize']),
      servingSizeUnit: serializer.fromJson<String?>(json['servingSizeUnit']),
      householdServing: serializer.fromJson<String?>(json['householdServing']),
      nutrientsJson: serializer.fromJson<String>(json['nutrientsJson']),
      foodCategory: serializer.fromJson<String?>(json['foodCategory']),
      ingredients: serializer.fromJson<String?>(json['ingredients']),
      isBundled: serializer.fromJson<bool>(json['isBundled']),
      searchKeywords: serializer.fromJson<String?>(json['searchKeywords']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'fdcId': serializer.toJson<int>(fdcId),
      'description': serializer.toJson<String>(description),
      'dataType': serializer.toJson<String?>(dataType),
      'brandName': serializer.toJson<String?>(brandName),
      'brandOwner': serializer.toJson<String?>(brandOwner),
      'gtinUpc': serializer.toJson<String?>(gtinUpc),
      'servingSize': serializer.toJson<double?>(servingSize),
      'servingSizeUnit': serializer.toJson<String?>(servingSizeUnit),
      'householdServing': serializer.toJson<String?>(householdServing),
      'nutrientsJson': serializer.toJson<String>(nutrientsJson),
      'foodCategory': serializer.toJson<String?>(foodCategory),
      'ingredients': serializer.toJson<String?>(ingredients),
      'isBundled': serializer.toJson<bool>(isBundled),
      'searchKeywords': serializer.toJson<String?>(searchKeywords),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  UsdaFood copyWith(
          {int? fdcId,
          String? description,
          Value<String?> dataType = const Value.absent(),
          Value<String?> brandName = const Value.absent(),
          Value<String?> brandOwner = const Value.absent(),
          Value<String?> gtinUpc = const Value.absent(),
          Value<double?> servingSize = const Value.absent(),
          Value<String?> servingSizeUnit = const Value.absent(),
          Value<String?> householdServing = const Value.absent(),
          String? nutrientsJson,
          Value<String?> foodCategory = const Value.absent(),
          Value<String?> ingredients = const Value.absent(),
          bool? isBundled,
          Value<String?> searchKeywords = const Value.absent(),
          DateTime? cachedAt}) =>
      UsdaFood(
        fdcId: fdcId ?? this.fdcId,
        description: description ?? this.description,
        dataType: dataType.present ? dataType.value : this.dataType,
        brandName: brandName.present ? brandName.value : this.brandName,
        brandOwner: brandOwner.present ? brandOwner.value : this.brandOwner,
        gtinUpc: gtinUpc.present ? gtinUpc.value : this.gtinUpc,
        servingSize: servingSize.present ? servingSize.value : this.servingSize,
        servingSizeUnit: servingSizeUnit.present
            ? servingSizeUnit.value
            : this.servingSizeUnit,
        householdServing: householdServing.present
            ? householdServing.value
            : this.householdServing,
        nutrientsJson: nutrientsJson ?? this.nutrientsJson,
        foodCategory:
            foodCategory.present ? foodCategory.value : this.foodCategory,
        ingredients: ingredients.present ? ingredients.value : this.ingredients,
        isBundled: isBundled ?? this.isBundled,
        searchKeywords:
            searchKeywords.present ? searchKeywords.value : this.searchKeywords,
        cachedAt: cachedAt ?? this.cachedAt,
      );
  UsdaFood copyWithCompanion(UsdaFoodsCompanion data) {
    return UsdaFood(
      fdcId: data.fdcId.present ? data.fdcId.value : this.fdcId,
      description:
          data.description.present ? data.description.value : this.description,
      dataType: data.dataType.present ? data.dataType.value : this.dataType,
      brandName: data.brandName.present ? data.brandName.value : this.brandName,
      brandOwner:
          data.brandOwner.present ? data.brandOwner.value : this.brandOwner,
      gtinUpc: data.gtinUpc.present ? data.gtinUpc.value : this.gtinUpc,
      servingSize:
          data.servingSize.present ? data.servingSize.value : this.servingSize,
      servingSizeUnit: data.servingSizeUnit.present
          ? data.servingSizeUnit.value
          : this.servingSizeUnit,
      householdServing: data.householdServing.present
          ? data.householdServing.value
          : this.householdServing,
      nutrientsJson: data.nutrientsJson.present
          ? data.nutrientsJson.value
          : this.nutrientsJson,
      foodCategory: data.foodCategory.present
          ? data.foodCategory.value
          : this.foodCategory,
      ingredients:
          data.ingredients.present ? data.ingredients.value : this.ingredients,
      isBundled: data.isBundled.present ? data.isBundled.value : this.isBundled,
      searchKeywords: data.searchKeywords.present
          ? data.searchKeywords.value
          : this.searchKeywords,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UsdaFood(')
          ..write('fdcId: $fdcId, ')
          ..write('description: $description, ')
          ..write('dataType: $dataType, ')
          ..write('brandName: $brandName, ')
          ..write('brandOwner: $brandOwner, ')
          ..write('gtinUpc: $gtinUpc, ')
          ..write('servingSize: $servingSize, ')
          ..write('servingSizeUnit: $servingSizeUnit, ')
          ..write('householdServing: $householdServing, ')
          ..write('nutrientsJson: $nutrientsJson, ')
          ..write('foodCategory: $foodCategory, ')
          ..write('ingredients: $ingredients, ')
          ..write('isBundled: $isBundled, ')
          ..write('searchKeywords: $searchKeywords, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      fdcId,
      description,
      dataType,
      brandName,
      brandOwner,
      gtinUpc,
      servingSize,
      servingSizeUnit,
      householdServing,
      nutrientsJson,
      foodCategory,
      ingredients,
      isBundled,
      searchKeywords,
      cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UsdaFood &&
          other.fdcId == this.fdcId &&
          other.description == this.description &&
          other.dataType == this.dataType &&
          other.brandName == this.brandName &&
          other.brandOwner == this.brandOwner &&
          other.gtinUpc == this.gtinUpc &&
          other.servingSize == this.servingSize &&
          other.servingSizeUnit == this.servingSizeUnit &&
          other.householdServing == this.householdServing &&
          other.nutrientsJson == this.nutrientsJson &&
          other.foodCategory == this.foodCategory &&
          other.ingredients == this.ingredients &&
          other.isBundled == this.isBundled &&
          other.searchKeywords == this.searchKeywords &&
          other.cachedAt == this.cachedAt);
}

class UsdaFoodsCompanion extends UpdateCompanion<UsdaFood> {
  final Value<int> fdcId;
  final Value<String> description;
  final Value<String?> dataType;
  final Value<String?> brandName;
  final Value<String?> brandOwner;
  final Value<String?> gtinUpc;
  final Value<double?> servingSize;
  final Value<String?> servingSizeUnit;
  final Value<String?> householdServing;
  final Value<String> nutrientsJson;
  final Value<String?> foodCategory;
  final Value<String?> ingredients;
  final Value<bool> isBundled;
  final Value<String?> searchKeywords;
  final Value<DateTime> cachedAt;
  const UsdaFoodsCompanion({
    this.fdcId = const Value.absent(),
    this.description = const Value.absent(),
    this.dataType = const Value.absent(),
    this.brandName = const Value.absent(),
    this.brandOwner = const Value.absent(),
    this.gtinUpc = const Value.absent(),
    this.servingSize = const Value.absent(),
    this.servingSizeUnit = const Value.absent(),
    this.householdServing = const Value.absent(),
    this.nutrientsJson = const Value.absent(),
    this.foodCategory = const Value.absent(),
    this.ingredients = const Value.absent(),
    this.isBundled = const Value.absent(),
    this.searchKeywords = const Value.absent(),
    this.cachedAt = const Value.absent(),
  });
  UsdaFoodsCompanion.insert({
    this.fdcId = const Value.absent(),
    required String description,
    this.dataType = const Value.absent(),
    this.brandName = const Value.absent(),
    this.brandOwner = const Value.absent(),
    this.gtinUpc = const Value.absent(),
    this.servingSize = const Value.absent(),
    this.servingSizeUnit = const Value.absent(),
    this.householdServing = const Value.absent(),
    required String nutrientsJson,
    this.foodCategory = const Value.absent(),
    this.ingredients = const Value.absent(),
    this.isBundled = const Value.absent(),
    this.searchKeywords = const Value.absent(),
    this.cachedAt = const Value.absent(),
  })  : description = Value(description),
        nutrientsJson = Value(nutrientsJson);
  static Insertable<UsdaFood> custom({
    Expression<int>? fdcId,
    Expression<String>? description,
    Expression<String>? dataType,
    Expression<String>? brandName,
    Expression<String>? brandOwner,
    Expression<String>? gtinUpc,
    Expression<double>? servingSize,
    Expression<String>? servingSizeUnit,
    Expression<String>? householdServing,
    Expression<String>? nutrientsJson,
    Expression<String>? foodCategory,
    Expression<String>? ingredients,
    Expression<bool>? isBundled,
    Expression<String>? searchKeywords,
    Expression<DateTime>? cachedAt,
  }) {
    return RawValuesInsertable({
      if (fdcId != null) 'fdc_id': fdcId,
      if (description != null) 'description': description,
      if (dataType != null) 'data_type': dataType,
      if (brandName != null) 'brand_name': brandName,
      if (brandOwner != null) 'brand_owner': brandOwner,
      if (gtinUpc != null) 'gtin_upc': gtinUpc,
      if (servingSize != null) 'serving_size': servingSize,
      if (servingSizeUnit != null) 'serving_size_unit': servingSizeUnit,
      if (householdServing != null) 'household_serving': householdServing,
      if (nutrientsJson != null) 'nutrients_json': nutrientsJson,
      if (foodCategory != null) 'food_category': foodCategory,
      if (ingredients != null) 'ingredients': ingredients,
      if (isBundled != null) 'is_bundled': isBundled,
      if (searchKeywords != null) 'search_keywords': searchKeywords,
      if (cachedAt != null) 'cached_at': cachedAt,
    });
  }

  UsdaFoodsCompanion copyWith(
      {Value<int>? fdcId,
      Value<String>? description,
      Value<String?>? dataType,
      Value<String?>? brandName,
      Value<String?>? brandOwner,
      Value<String?>? gtinUpc,
      Value<double?>? servingSize,
      Value<String?>? servingSizeUnit,
      Value<String?>? householdServing,
      Value<String>? nutrientsJson,
      Value<String?>? foodCategory,
      Value<String?>? ingredients,
      Value<bool>? isBundled,
      Value<String?>? searchKeywords,
      Value<DateTime>? cachedAt}) {
    return UsdaFoodsCompanion(
      fdcId: fdcId ?? this.fdcId,
      description: description ?? this.description,
      dataType: dataType ?? this.dataType,
      brandName: brandName ?? this.brandName,
      brandOwner: brandOwner ?? this.brandOwner,
      gtinUpc: gtinUpc ?? this.gtinUpc,
      servingSize: servingSize ?? this.servingSize,
      servingSizeUnit: servingSizeUnit ?? this.servingSizeUnit,
      householdServing: householdServing ?? this.householdServing,
      nutrientsJson: nutrientsJson ?? this.nutrientsJson,
      foodCategory: foodCategory ?? this.foodCategory,
      ingredients: ingredients ?? this.ingredients,
      isBundled: isBundled ?? this.isBundled,
      searchKeywords: searchKeywords ?? this.searchKeywords,
      cachedAt: cachedAt ?? this.cachedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (fdcId.present) {
      map['fdc_id'] = Variable<int>(fdcId.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (dataType.present) {
      map['data_type'] = Variable<String>(dataType.value);
    }
    if (brandName.present) {
      map['brand_name'] = Variable<String>(brandName.value);
    }
    if (brandOwner.present) {
      map['brand_owner'] = Variable<String>(brandOwner.value);
    }
    if (gtinUpc.present) {
      map['gtin_upc'] = Variable<String>(gtinUpc.value);
    }
    if (servingSize.present) {
      map['serving_size'] = Variable<double>(servingSize.value);
    }
    if (servingSizeUnit.present) {
      map['serving_size_unit'] = Variable<String>(servingSizeUnit.value);
    }
    if (householdServing.present) {
      map['household_serving'] = Variable<String>(householdServing.value);
    }
    if (nutrientsJson.present) {
      map['nutrients_json'] = Variable<String>(nutrientsJson.value);
    }
    if (foodCategory.present) {
      map['food_category'] = Variable<String>(foodCategory.value);
    }
    if (ingredients.present) {
      map['ingredients'] = Variable<String>(ingredients.value);
    }
    if (isBundled.present) {
      map['is_bundled'] = Variable<bool>(isBundled.value);
    }
    if (searchKeywords.present) {
      map['search_keywords'] = Variable<String>(searchKeywords.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsdaFoodsCompanion(')
          ..write('fdcId: $fdcId, ')
          ..write('description: $description, ')
          ..write('dataType: $dataType, ')
          ..write('brandName: $brandName, ')
          ..write('brandOwner: $brandOwner, ')
          ..write('gtinUpc: $gtinUpc, ')
          ..write('servingSize: $servingSize, ')
          ..write('servingSizeUnit: $servingSizeUnit, ')
          ..write('householdServing: $householdServing, ')
          ..write('nutrientsJson: $nutrientsJson, ')
          ..write('foodCategory: $foodCategory, ')
          ..write('ingredients: $ingredients, ')
          ..write('isBundled: $isBundled, ')
          ..write('searchKeywords: $searchKeywords, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }
}

class $IngredientUsdaMappingsTable extends IngredientUsdaMappings
    with TableInfo<$IngredientUsdaMappingsTable, IngredientUsdaMapping> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IngredientUsdaMappingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ingredientNameMeta =
      const VerificationMeta('ingredientName');
  @override
  late final GeneratedColumn<String> ingredientName = GeneratedColumn<String>(
      'ingredient_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fdcIdMeta = const VerificationMeta('fdcId');
  @override
  late final GeneratedColumn<int> fdcId = GeneratedColumn<int>(
      'fdc_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _gramsPerMeta =
      const VerificationMeta('gramsPer');
  @override
  late final GeneratedColumn<double> gramsPer = GeneratedColumn<double>(
      'grams_per', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _portionDescriptionMeta =
      const VerificationMeta('portionDescription');
  @override
  late final GeneratedColumn<String> portionDescription =
      GeneratedColumn<String>('portion_description', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [ingredientName, fdcId, gramsPer, portionDescription, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ingredient_usda_mappings';
  @override
  VerificationContext validateIntegrity(
      Insertable<IngredientUsdaMapping> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('ingredient_name')) {
      context.handle(
          _ingredientNameMeta,
          ingredientName.isAcceptableOrUnknown(
              data['ingredient_name']!, _ingredientNameMeta));
    } else if (isInserting) {
      context.missing(_ingredientNameMeta);
    }
    if (data.containsKey('fdc_id')) {
      context.handle(
          _fdcIdMeta, fdcId.isAcceptableOrUnknown(data['fdc_id']!, _fdcIdMeta));
    } else if (isInserting) {
      context.missing(_fdcIdMeta);
    }
    if (data.containsKey('grams_per')) {
      context.handle(_gramsPerMeta,
          gramsPer.isAcceptableOrUnknown(data['grams_per']!, _gramsPerMeta));
    }
    if (data.containsKey('portion_description')) {
      context.handle(
          _portionDescriptionMeta,
          portionDescription.isAcceptableOrUnknown(
              data['portion_description']!, _portionDescriptionMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {ingredientName};
  @override
  IngredientUsdaMapping map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IngredientUsdaMapping(
      ingredientName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}ingredient_name'])!,
      fdcId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}fdc_id'])!,
      gramsPer: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}grams_per']),
      portionDescription: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}portion_description']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $IngredientUsdaMappingsTable createAlias(String alias) {
    return $IngredientUsdaMappingsTable(attachedDatabase, alias);
  }
}

class IngredientUsdaMapping extends DataClass
    implements Insertable<IngredientUsdaMapping> {
  /// Normalized ingredient name (lowercase, trimmed)
  final String ingredientName;

  /// The USDA FDC ID this ingredient maps to
  final int fdcId;

  /// User-specified portion weight in grams for "1 unit" of this ingredient
  /// e.g., "1 egg" = 50g, "1 chicken breast" = 170g
  final double? gramsPer;

  /// What "1 unit" represents (e.g., "large egg", "medium breast")
  final String? portionDescription;

  /// When this mapping was created
  final DateTime createdAt;
  const IngredientUsdaMapping(
      {required this.ingredientName,
      required this.fdcId,
      this.gramsPer,
      this.portionDescription,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['ingredient_name'] = Variable<String>(ingredientName);
    map['fdc_id'] = Variable<int>(fdcId);
    if (!nullToAbsent || gramsPer != null) {
      map['grams_per'] = Variable<double>(gramsPer);
    }
    if (!nullToAbsent || portionDescription != null) {
      map['portion_description'] = Variable<String>(portionDescription);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  IngredientUsdaMappingsCompanion toCompanion(bool nullToAbsent) {
    return IngredientUsdaMappingsCompanion(
      ingredientName: Value(ingredientName),
      fdcId: Value(fdcId),
      gramsPer: gramsPer == null && nullToAbsent
          ? const Value.absent()
          : Value(gramsPer),
      portionDescription: portionDescription == null && nullToAbsent
          ? const Value.absent()
          : Value(portionDescription),
      createdAt: Value(createdAt),
    );
  }

  factory IngredientUsdaMapping.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IngredientUsdaMapping(
      ingredientName: serializer.fromJson<String>(json['ingredientName']),
      fdcId: serializer.fromJson<int>(json['fdcId']),
      gramsPer: serializer.fromJson<double?>(json['gramsPer']),
      portionDescription:
          serializer.fromJson<String?>(json['portionDescription']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ingredientName': serializer.toJson<String>(ingredientName),
      'fdcId': serializer.toJson<int>(fdcId),
      'gramsPer': serializer.toJson<double?>(gramsPer),
      'portionDescription': serializer.toJson<String?>(portionDescription),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  IngredientUsdaMapping copyWith(
          {String? ingredientName,
          int? fdcId,
          Value<double?> gramsPer = const Value.absent(),
          Value<String?> portionDescription = const Value.absent(),
          DateTime? createdAt}) =>
      IngredientUsdaMapping(
        ingredientName: ingredientName ?? this.ingredientName,
        fdcId: fdcId ?? this.fdcId,
        gramsPer: gramsPer.present ? gramsPer.value : this.gramsPer,
        portionDescription: portionDescription.present
            ? portionDescription.value
            : this.portionDescription,
        createdAt: createdAt ?? this.createdAt,
      );
  IngredientUsdaMapping copyWithCompanion(
      IngredientUsdaMappingsCompanion data) {
    return IngredientUsdaMapping(
      ingredientName: data.ingredientName.present
          ? data.ingredientName.value
          : this.ingredientName,
      fdcId: data.fdcId.present ? data.fdcId.value : this.fdcId,
      gramsPer: data.gramsPer.present ? data.gramsPer.value : this.gramsPer,
      portionDescription: data.portionDescription.present
          ? data.portionDescription.value
          : this.portionDescription,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IngredientUsdaMapping(')
          ..write('ingredientName: $ingredientName, ')
          ..write('fdcId: $fdcId, ')
          ..write('gramsPer: $gramsPer, ')
          ..write('portionDescription: $portionDescription, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      ingredientName, fdcId, gramsPer, portionDescription, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IngredientUsdaMapping &&
          other.ingredientName == this.ingredientName &&
          other.fdcId == this.fdcId &&
          other.gramsPer == this.gramsPer &&
          other.portionDescription == this.portionDescription &&
          other.createdAt == this.createdAt);
}

class IngredientUsdaMappingsCompanion
    extends UpdateCompanion<IngredientUsdaMapping> {
  final Value<String> ingredientName;
  final Value<int> fdcId;
  final Value<double?> gramsPer;
  final Value<String?> portionDescription;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const IngredientUsdaMappingsCompanion({
    this.ingredientName = const Value.absent(),
    this.fdcId = const Value.absent(),
    this.gramsPer = const Value.absent(),
    this.portionDescription = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IngredientUsdaMappingsCompanion.insert({
    required String ingredientName,
    required int fdcId,
    this.gramsPer = const Value.absent(),
    this.portionDescription = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : ingredientName = Value(ingredientName),
        fdcId = Value(fdcId);
  static Insertable<IngredientUsdaMapping> custom({
    Expression<String>? ingredientName,
    Expression<int>? fdcId,
    Expression<double>? gramsPer,
    Expression<String>? portionDescription,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ingredientName != null) 'ingredient_name': ingredientName,
      if (fdcId != null) 'fdc_id': fdcId,
      if (gramsPer != null) 'grams_per': gramsPer,
      if (portionDescription != null) 'portion_description': portionDescription,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IngredientUsdaMappingsCompanion copyWith(
      {Value<String>? ingredientName,
      Value<int>? fdcId,
      Value<double?>? gramsPer,
      Value<String?>? portionDescription,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return IngredientUsdaMappingsCompanion(
      ingredientName: ingredientName ?? this.ingredientName,
      fdcId: fdcId ?? this.fdcId,
      gramsPer: gramsPer ?? this.gramsPer,
      portionDescription: portionDescription ?? this.portionDescription,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ingredientName.present) {
      map['ingredient_name'] = Variable<String>(ingredientName.value);
    }
    if (fdcId.present) {
      map['fdc_id'] = Variable<int>(fdcId.value);
    }
    if (gramsPer.present) {
      map['grams_per'] = Variable<double>(gramsPer.value);
    }
    if (portionDescription.present) {
      map['portion_description'] = Variable<String>(portionDescription.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IngredientUsdaMappingsCompanion(')
          ..write('ingredientName: $ingredientName, ')
          ..write('fdcId: $fdcId, ')
          ..write('gramsPer: $gramsPer, ')
          ..write('portionDescription: $portionDescription, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CookbooksTable cookbooks = $CookbooksTable(this);
  late final $RecipesTable recipes = $RecipesTable(this);
  late final $IngredientsTable ingredients = $IngredientsTable(this);
  late final $StepsTable steps = $StepsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $ShoppingCategoriesTable shoppingCategories =
      $ShoppingCategoriesTable(this);
  late final $ShoppingListsTable shoppingLists = $ShoppingListsTable(this);
  late final $CustomCoursesTable customCourses = $CustomCoursesTable(this);
  late final $CustomCategoriesTable customCategories =
      $CustomCategoriesTable(this);
  late final $ShoppingListItemsTable shoppingListItems =
      $ShoppingListItemsTable(this);
  late final $MealPlansTable mealPlans = $MealPlansTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $RecipeTagsTable recipeTags = $RecipeTagsTable(this);
  late final $UserIngredientMappingsTable userIngredientMappings =
      $UserIngredientMappingsTable(this);
  late final $UsdaFoodsTable usdaFoods = $UsdaFoodsTable(this);
  late final $IngredientUsdaMappingsTable ingredientUsdaMappings =
      $IngredientUsdaMappingsTable(this);
  late final CookbookDao cookbookDao = CookbookDao(this as AppDatabase);
  late final RecipeDao recipeDao = RecipeDao(this as AppDatabase);
  late final CategoryDao categoryDao = CategoryDao(this as AppDatabase);
  late final ShoppingDao shoppingDao = ShoppingDao(this as AppDatabase);
  late final MealPlanDao mealPlanDao = MealPlanDao(this as AppDatabase);
  late final CustomTaxonomyDao customTaxonomyDao =
      CustomTaxonomyDao(this as AppDatabase);
  late final TagsDao tagsDao = TagsDao(this as AppDatabase);
  late final UserIngredientMappingsDao userIngredientMappingsDao =
      UserIngredientMappingsDao(this as AppDatabase);
  late final UsdaDao usdaDao = UsdaDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        cookbooks,
        recipes,
        ingredients,
        steps,
        categories,
        shoppingCategories,
        shoppingLists,
        customCourses,
        customCategories,
        shoppingListItems,
        mealPlans,
        tags,
        recipeTags,
        userIngredientMappings,
        usdaFoods,
        ingredientUsdaMappings
      ];
}

typedef $$CookbooksTableCreateCompanionBuilder = CookbooksCompanion Function({
  required String id,
  required String name,
  Value<String?> description,
  Value<String?> imagePath,
  Value<DateTime> createdAt,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});
typedef $$CookbooksTableUpdateCompanionBuilder = CookbooksCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> description,
  Value<String?> imagePath,
  Value<DateTime> createdAt,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});

class $$CookbooksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CookbooksTable,
    Cookbook,
    $$CookbooksTableFilterComposer,
    $$CookbooksTableOrderingComposer,
    $$CookbooksTableCreateCompanionBuilder,
    $$CookbooksTableUpdateCompanionBuilder> {
  $$CookbooksTableTableManager(_$AppDatabase db, $CookbooksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$CookbooksTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$CookbooksTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> imagePath = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CookbooksCompanion(
            id: id,
            name: name,
            description: description,
            imagePath: imagePath,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> description = const Value.absent(),
            Value<String?> imagePath = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CookbooksCompanion.insert(
            id: id,
            name: name,
            description: description,
            imagePath: imagePath,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
        ));
}

class $$CookbooksTableFilterComposer
    extends FilterComposer<_$AppDatabase, $CookbooksTable> {
  $$CookbooksTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get imagePath => $state.composableBuilder(
      column: $state.table.imagePath,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter recipesRefs(
      ComposableFilter Function($$RecipesTableFilterComposer f) f) {
    final $$RecipesTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.recipes,
        getReferencedColumn: (t) => t.cookbookId,
        builder: (joinBuilder, parentComposers) => $$RecipesTableFilterComposer(
            ComposerState(
                $state.db, $state.db.recipes, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$CookbooksTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $CookbooksTable> {
  $$CookbooksTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get imagePath => $state.composableBuilder(
      column: $state.table.imagePath,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$RecipesTableCreateCompanionBuilder = RecipesCompanion Function({
  required String id,
  required String cookbookId,
  required String title,
  Value<String?> description,
  Value<String?> servings,
  Value<int?> prepTimeMinutes,
  Value<int?> cookTimeMinutes,
  Value<String?> sourceUrl,
  Value<String?> imagePath,
  Value<String?> courseId,
  Value<String?> categoryId,
  Value<int?> rating,
  Value<String?> notes,
  Value<String?> nutritionJson,
  Value<bool> isFavorite,
  Value<bool> isPinned,
  Value<DateTime?> deletedAt,
  Value<DateTime?> lastViewedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$RecipesTableUpdateCompanionBuilder = RecipesCompanion Function({
  Value<String> id,
  Value<String> cookbookId,
  Value<String> title,
  Value<String?> description,
  Value<String?> servings,
  Value<int?> prepTimeMinutes,
  Value<int?> cookTimeMinutes,
  Value<String?> sourceUrl,
  Value<String?> imagePath,
  Value<String?> courseId,
  Value<String?> categoryId,
  Value<int?> rating,
  Value<String?> notes,
  Value<String?> nutritionJson,
  Value<bool> isFavorite,
  Value<bool> isPinned,
  Value<DateTime?> deletedAt,
  Value<DateTime?> lastViewedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$RecipesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RecipesTable,
    Recipe,
    $$RecipesTableFilterComposer,
    $$RecipesTableOrderingComposer,
    $$RecipesTableCreateCompanionBuilder,
    $$RecipesTableUpdateCompanionBuilder> {
  $$RecipesTableTableManager(_$AppDatabase db, $RecipesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$RecipesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$RecipesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> cookbookId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> servings = const Value.absent(),
            Value<int?> prepTimeMinutes = const Value.absent(),
            Value<int?> cookTimeMinutes = const Value.absent(),
            Value<String?> sourceUrl = const Value.absent(),
            Value<String?> imagePath = const Value.absent(),
            Value<String?> courseId = const Value.absent(),
            Value<String?> categoryId = const Value.absent(),
            Value<int?> rating = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> nutritionJson = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
            Value<bool> isPinned = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<DateTime?> lastViewedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RecipesCompanion(
            id: id,
            cookbookId: cookbookId,
            title: title,
            description: description,
            servings: servings,
            prepTimeMinutes: prepTimeMinutes,
            cookTimeMinutes: cookTimeMinutes,
            sourceUrl: sourceUrl,
            imagePath: imagePath,
            courseId: courseId,
            categoryId: categoryId,
            rating: rating,
            notes: notes,
            nutritionJson: nutritionJson,
            isFavorite: isFavorite,
            isPinned: isPinned,
            deletedAt: deletedAt,
            lastViewedAt: lastViewedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String cookbookId,
            required String title,
            Value<String?> description = const Value.absent(),
            Value<String?> servings = const Value.absent(),
            Value<int?> prepTimeMinutes = const Value.absent(),
            Value<int?> cookTimeMinutes = const Value.absent(),
            Value<String?> sourceUrl = const Value.absent(),
            Value<String?> imagePath = const Value.absent(),
            Value<String?> courseId = const Value.absent(),
            Value<String?> categoryId = const Value.absent(),
            Value<int?> rating = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> nutritionJson = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
            Value<bool> isPinned = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<DateTime?> lastViewedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RecipesCompanion.insert(
            id: id,
            cookbookId: cookbookId,
            title: title,
            description: description,
            servings: servings,
            prepTimeMinutes: prepTimeMinutes,
            cookTimeMinutes: cookTimeMinutes,
            sourceUrl: sourceUrl,
            imagePath: imagePath,
            courseId: courseId,
            categoryId: categoryId,
            rating: rating,
            notes: notes,
            nutritionJson: nutritionJson,
            isFavorite: isFavorite,
            isPinned: isPinned,
            deletedAt: deletedAt,
            lastViewedAt: lastViewedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
        ));
}

class $$RecipesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $RecipesTable> {
  $$RecipesTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get servings => $state.composableBuilder(
      column: $state.table.servings,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get prepTimeMinutes => $state.composableBuilder(
      column: $state.table.prepTimeMinutes,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get cookTimeMinutes => $state.composableBuilder(
      column: $state.table.cookTimeMinutes,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get sourceUrl => $state.composableBuilder(
      column: $state.table.sourceUrl,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get imagePath => $state.composableBuilder(
      column: $state.table.imagePath,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get courseId => $state.composableBuilder(
      column: $state.table.courseId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get categoryId => $state.composableBuilder(
      column: $state.table.categoryId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get rating => $state.composableBuilder(
      column: $state.table.rating,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get notes => $state.composableBuilder(
      column: $state.table.notes,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get nutritionJson => $state.composableBuilder(
      column: $state.table.nutritionJson,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isFavorite => $state.composableBuilder(
      column: $state.table.isFavorite,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isPinned => $state.composableBuilder(
      column: $state.table.isPinned,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get deletedAt => $state.composableBuilder(
      column: $state.table.deletedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get lastViewedAt => $state.composableBuilder(
      column: $state.table.lastViewedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$CookbooksTableFilterComposer get cookbookId {
    final $$CookbooksTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.cookbookId,
        referencedTable: $state.db.cookbooks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$CookbooksTableFilterComposer(ComposerState(
                $state.db, $state.db.cookbooks, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$RecipesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $RecipesTable> {
  $$RecipesTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get servings => $state.composableBuilder(
      column: $state.table.servings,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get prepTimeMinutes => $state.composableBuilder(
      column: $state.table.prepTimeMinutes,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get cookTimeMinutes => $state.composableBuilder(
      column: $state.table.cookTimeMinutes,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get sourceUrl => $state.composableBuilder(
      column: $state.table.sourceUrl,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get imagePath => $state.composableBuilder(
      column: $state.table.imagePath,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get courseId => $state.composableBuilder(
      column: $state.table.courseId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get categoryId => $state.composableBuilder(
      column: $state.table.categoryId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get rating => $state.composableBuilder(
      column: $state.table.rating,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get notes => $state.composableBuilder(
      column: $state.table.notes,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get nutritionJson => $state.composableBuilder(
      column: $state.table.nutritionJson,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isFavorite => $state.composableBuilder(
      column: $state.table.isFavorite,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isPinned => $state.composableBuilder(
      column: $state.table.isPinned,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get deletedAt => $state.composableBuilder(
      column: $state.table.deletedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get lastViewedAt => $state.composableBuilder(
      column: $state.table.lastViewedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$CookbooksTableOrderingComposer get cookbookId {
    final $$CookbooksTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.cookbookId,
        referencedTable: $state.db.cookbooks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$CookbooksTableOrderingComposer(ComposerState(
                $state.db, $state.db.cookbooks, joinBuilder, parentComposers)));
    return composer;
  }
}

typedef $$IngredientsTableCreateCompanionBuilder = IngredientsCompanion
    Function({
  required String id,
  required String recipeId,
  required int sortOrder,
  Value<String?> amount,
  Value<String?> unit,
  required String name,
  Value<String?> notes,
  Value<int> rowid,
});
typedef $$IngredientsTableUpdateCompanionBuilder = IngredientsCompanion
    Function({
  Value<String> id,
  Value<String> recipeId,
  Value<int> sortOrder,
  Value<String?> amount,
  Value<String?> unit,
  Value<String> name,
  Value<String?> notes,
  Value<int> rowid,
});

class $$IngredientsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $IngredientsTable,
    Ingredient,
    $$IngredientsTableFilterComposer,
    $$IngredientsTableOrderingComposer,
    $$IngredientsTableCreateCompanionBuilder,
    $$IngredientsTableUpdateCompanionBuilder> {
  $$IngredientsTableTableManager(_$AppDatabase db, $IngredientsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$IngredientsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$IngredientsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> recipeId = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<String?> amount = const Value.absent(),
            Value<String?> unit = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              IngredientsCompanion(
            id: id,
            recipeId: recipeId,
            sortOrder: sortOrder,
            amount: amount,
            unit: unit,
            name: name,
            notes: notes,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String recipeId,
            required int sortOrder,
            Value<String?> amount = const Value.absent(),
            Value<String?> unit = const Value.absent(),
            required String name,
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              IngredientsCompanion.insert(
            id: id,
            recipeId: recipeId,
            sortOrder: sortOrder,
            amount: amount,
            unit: unit,
            name: name,
            notes: notes,
            rowid: rowid,
          ),
        ));
}

class $$IngredientsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $IngredientsTable> {
  $$IngredientsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get recipeId => $state.composableBuilder(
      column: $state.table.recipeId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get sortOrder => $state.composableBuilder(
      column: $state.table.sortOrder,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get amount => $state.composableBuilder(
      column: $state.table.amount,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get unit => $state.composableBuilder(
      column: $state.table.unit,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get notes => $state.composableBuilder(
      column: $state.table.notes,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$IngredientsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $IngredientsTable> {
  $$IngredientsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get recipeId => $state.composableBuilder(
      column: $state.table.recipeId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get sortOrder => $state.composableBuilder(
      column: $state.table.sortOrder,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get amount => $state.composableBuilder(
      column: $state.table.amount,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get unit => $state.composableBuilder(
      column: $state.table.unit,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get notes => $state.composableBuilder(
      column: $state.table.notes,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$StepsTableCreateCompanionBuilder = StepsCompanion Function({
  required String id,
  required String recipeId,
  required int sortOrder,
  required String instruction,
  Value<int?> durationMinutes,
  Value<String?> imagePath,
  Value<int> rowid,
});
typedef $$StepsTableUpdateCompanionBuilder = StepsCompanion Function({
  Value<String> id,
  Value<String> recipeId,
  Value<int> sortOrder,
  Value<String> instruction,
  Value<int?> durationMinutes,
  Value<String?> imagePath,
  Value<int> rowid,
});

class $$StepsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StepsTable,
    Step,
    $$StepsTableFilterComposer,
    $$StepsTableOrderingComposer,
    $$StepsTableCreateCompanionBuilder,
    $$StepsTableUpdateCompanionBuilder> {
  $$StepsTableTableManager(_$AppDatabase db, $StepsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$StepsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$StepsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> recipeId = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<String> instruction = const Value.absent(),
            Value<int?> durationMinutes = const Value.absent(),
            Value<String?> imagePath = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StepsCompanion(
            id: id,
            recipeId: recipeId,
            sortOrder: sortOrder,
            instruction: instruction,
            durationMinutes: durationMinutes,
            imagePath: imagePath,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String recipeId,
            required int sortOrder,
            required String instruction,
            Value<int?> durationMinutes = const Value.absent(),
            Value<String?> imagePath = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StepsCompanion.insert(
            id: id,
            recipeId: recipeId,
            sortOrder: sortOrder,
            instruction: instruction,
            durationMinutes: durationMinutes,
            imagePath: imagePath,
            rowid: rowid,
          ),
        ));
}

class $$StepsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $StepsTable> {
  $$StepsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get recipeId => $state.composableBuilder(
      column: $state.table.recipeId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get sortOrder => $state.composableBuilder(
      column: $state.table.sortOrder,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get instruction => $state.composableBuilder(
      column: $state.table.instruction,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get durationMinutes => $state.composableBuilder(
      column: $state.table.durationMinutes,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get imagePath => $state.composableBuilder(
      column: $state.table.imagePath,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$StepsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $StepsTable> {
  $$StepsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get recipeId => $state.composableBuilder(
      column: $state.table.recipeId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get sortOrder => $state.composableBuilder(
      column: $state.table.sortOrder,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get instruction => $state.composableBuilder(
      column: $state.table.instruction,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get durationMinutes => $state.composableBuilder(
      column: $state.table.durationMinutes,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get imagePath => $state.composableBuilder(
      column: $state.table.imagePath,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  required String id,
  required String name,
  Value<int> sortOrder,
  Value<bool> isDefault,
  Value<bool> isHidden,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<int> sortOrder,
  Value<bool> isDefault,
  Value<bool> isHidden,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$CategoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CategoriesTable,
    Category,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder> {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$CategoriesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$CategoriesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<bool> isDefault = const Value.absent(),
            Value<bool> isHidden = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CategoriesCompanion(
            id: id,
            name: name,
            sortOrder: sortOrder,
            isDefault: isDefault,
            isHidden: isHidden,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<int> sortOrder = const Value.absent(),
            Value<bool> isDefault = const Value.absent(),
            Value<bool> isHidden = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CategoriesCompanion.insert(
            id: id,
            name: name,
            sortOrder: sortOrder,
            isDefault: isDefault,
            isHidden: isHidden,
            createdAt: createdAt,
            rowid: rowid,
          ),
        ));
}

class $$CategoriesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get sortOrder => $state.composableBuilder(
      column: $state.table.sortOrder,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isDefault => $state.composableBuilder(
      column: $state.table.isDefault,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isHidden => $state.composableBuilder(
      column: $state.table.isHidden,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$CategoriesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get sortOrder => $state.composableBuilder(
      column: $state.table.sortOrder,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isDefault => $state.composableBuilder(
      column: $state.table.isDefault,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isHidden => $state.composableBuilder(
      column: $state.table.isHidden,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$ShoppingCategoriesTableCreateCompanionBuilder
    = ShoppingCategoriesCompanion Function({
  required String id,
  required String name,
  Value<String?> iconName,
  Value<int> sortOrder,
  Value<bool> isDefault,
  Value<bool> isHidden,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$ShoppingCategoriesTableUpdateCompanionBuilder
    = ShoppingCategoriesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> iconName,
  Value<int> sortOrder,
  Value<bool> isDefault,
  Value<bool> isHidden,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$ShoppingCategoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ShoppingCategoriesTable,
    ShoppingCategory,
    $$ShoppingCategoriesTableFilterComposer,
    $$ShoppingCategoriesTableOrderingComposer,
    $$ShoppingCategoriesTableCreateCompanionBuilder,
    $$ShoppingCategoriesTableUpdateCompanionBuilder> {
  $$ShoppingCategoriesTableTableManager(
      _$AppDatabase db, $ShoppingCategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ShoppingCategoriesTableFilterComposer(ComposerState(db, table)),
          orderingComposer: $$ShoppingCategoriesTableOrderingComposer(
              ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> iconName = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<bool> isDefault = const Value.absent(),
            Value<bool> isHidden = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ShoppingCategoriesCompanion(
            id: id,
            name: name,
            iconName: iconName,
            sortOrder: sortOrder,
            isDefault: isDefault,
            isHidden: isHidden,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> iconName = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<bool> isDefault = const Value.absent(),
            Value<bool> isHidden = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ShoppingCategoriesCompanion.insert(
            id: id,
            name: name,
            iconName: iconName,
            sortOrder: sortOrder,
            isDefault: isDefault,
            isHidden: isHidden,
            createdAt: createdAt,
            rowid: rowid,
          ),
        ));
}

class $$ShoppingCategoriesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $ShoppingCategoriesTable> {
  $$ShoppingCategoriesTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get iconName => $state.composableBuilder(
      column: $state.table.iconName,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get sortOrder => $state.composableBuilder(
      column: $state.table.sortOrder,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isDefault => $state.composableBuilder(
      column: $state.table.isDefault,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isHidden => $state.composableBuilder(
      column: $state.table.isHidden,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$ShoppingCategoriesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $ShoppingCategoriesTable> {
  $$ShoppingCategoriesTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get iconName => $state.composableBuilder(
      column: $state.table.iconName,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get sortOrder => $state.composableBuilder(
      column: $state.table.sortOrder,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isDefault => $state.composableBuilder(
      column: $state.table.isDefault,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isHidden => $state.composableBuilder(
      column: $state.table.isHidden,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$ShoppingListsTableCreateCompanionBuilder = ShoppingListsCompanion
    Function({
  required String id,
  required String name,
  Value<String?> color,
  Value<bool> isDefault,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$ShoppingListsTableUpdateCompanionBuilder = ShoppingListsCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String?> color,
  Value<bool> isDefault,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$ShoppingListsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ShoppingListsTable,
    ShoppingList,
    $$ShoppingListsTableFilterComposer,
    $$ShoppingListsTableOrderingComposer,
    $$ShoppingListsTableCreateCompanionBuilder,
    $$ShoppingListsTableUpdateCompanionBuilder> {
  $$ShoppingListsTableTableManager(_$AppDatabase db, $ShoppingListsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ShoppingListsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$ShoppingListsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> color = const Value.absent(),
            Value<bool> isDefault = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ShoppingListsCompanion(
            id: id,
            name: name,
            color: color,
            isDefault: isDefault,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> color = const Value.absent(),
            Value<bool> isDefault = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ShoppingListsCompanion.insert(
            id: id,
            name: name,
            color: color,
            isDefault: isDefault,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
        ));
}

class $$ShoppingListsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $ShoppingListsTable> {
  $$ShoppingListsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get color => $state.composableBuilder(
      column: $state.table.color,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isDefault => $state.composableBuilder(
      column: $state.table.isDefault,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$ShoppingListsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $ShoppingListsTable> {
  $$ShoppingListsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get color => $state.composableBuilder(
      column: $state.table.color,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isDefault => $state.composableBuilder(
      column: $state.table.isDefault,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$CustomCoursesTableCreateCompanionBuilder = CustomCoursesCompanion
    Function({
  required String id,
  required String cookbookId,
  required String name,
  Value<String> emoji,
  Value<int> sortOrder,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$CustomCoursesTableUpdateCompanionBuilder = CustomCoursesCompanion
    Function({
  Value<String> id,
  Value<String> cookbookId,
  Value<String> name,
  Value<String> emoji,
  Value<int> sortOrder,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$CustomCoursesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CustomCoursesTable,
    CustomCourse,
    $$CustomCoursesTableFilterComposer,
    $$CustomCoursesTableOrderingComposer,
    $$CustomCoursesTableCreateCompanionBuilder,
    $$CustomCoursesTableUpdateCompanionBuilder> {
  $$CustomCoursesTableTableManager(_$AppDatabase db, $CustomCoursesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$CustomCoursesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$CustomCoursesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> cookbookId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> emoji = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CustomCoursesCompanion(
            id: id,
            cookbookId: cookbookId,
            name: name,
            emoji: emoji,
            sortOrder: sortOrder,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String cookbookId,
            required String name,
            Value<String> emoji = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CustomCoursesCompanion.insert(
            id: id,
            cookbookId: cookbookId,
            name: name,
            emoji: emoji,
            sortOrder: sortOrder,
            createdAt: createdAt,
            rowid: rowid,
          ),
        ));
}

class $$CustomCoursesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $CustomCoursesTable> {
  $$CustomCoursesTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get cookbookId => $state.composableBuilder(
      column: $state.table.cookbookId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get emoji => $state.composableBuilder(
      column: $state.table.emoji,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get sortOrder => $state.composableBuilder(
      column: $state.table.sortOrder,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$CustomCoursesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $CustomCoursesTable> {
  $$CustomCoursesTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get cookbookId => $state.composableBuilder(
      column: $state.table.cookbookId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get emoji => $state.composableBuilder(
      column: $state.table.emoji,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get sortOrder => $state.composableBuilder(
      column: $state.table.sortOrder,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$CustomCategoriesTableCreateCompanionBuilder
    = CustomCategoriesCompanion Function({
  required String id,
  required String cookbookId,
  required String name,
  Value<String> emoji,
  Value<int> sortOrder,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$CustomCategoriesTableUpdateCompanionBuilder
    = CustomCategoriesCompanion Function({
  Value<String> id,
  Value<String> cookbookId,
  Value<String> name,
  Value<String> emoji,
  Value<int> sortOrder,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$CustomCategoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CustomCategoriesTable,
    CustomCategory,
    $$CustomCategoriesTableFilterComposer,
    $$CustomCategoriesTableOrderingComposer,
    $$CustomCategoriesTableCreateCompanionBuilder,
    $$CustomCategoriesTableUpdateCompanionBuilder> {
  $$CustomCategoriesTableTableManager(
      _$AppDatabase db, $CustomCategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$CustomCategoriesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$CustomCategoriesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> cookbookId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> emoji = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CustomCategoriesCompanion(
            id: id,
            cookbookId: cookbookId,
            name: name,
            emoji: emoji,
            sortOrder: sortOrder,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String cookbookId,
            required String name,
            Value<String> emoji = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CustomCategoriesCompanion.insert(
            id: id,
            cookbookId: cookbookId,
            name: name,
            emoji: emoji,
            sortOrder: sortOrder,
            createdAt: createdAt,
            rowid: rowid,
          ),
        ));
}

class $$CustomCategoriesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $CustomCategoriesTable> {
  $$CustomCategoriesTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get cookbookId => $state.composableBuilder(
      column: $state.table.cookbookId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get emoji => $state.composableBuilder(
      column: $state.table.emoji,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get sortOrder => $state.composableBuilder(
      column: $state.table.sortOrder,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$CustomCategoriesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $CustomCategoriesTable> {
  $$CustomCategoriesTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get cookbookId => $state.composableBuilder(
      column: $state.table.cookbookId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get emoji => $state.composableBuilder(
      column: $state.table.emoji,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get sortOrder => $state.composableBuilder(
      column: $state.table.sortOrder,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$ShoppingListItemsTableCreateCompanionBuilder
    = ShoppingListItemsCompanion Function({
  required String id,
  required String listId,
  required String name,
  Value<String?> quantity,
  Value<String?> unit,
  Value<String?> shoppingCategoryId,
  Value<bool> isChecked,
  Value<bool> isFavorite,
  Value<int> useCount,
  Value<String?> note,
  Value<int> sortOrder,
  Value<String?> recipeId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$ShoppingListItemsTableUpdateCompanionBuilder
    = ShoppingListItemsCompanion Function({
  Value<String> id,
  Value<String> listId,
  Value<String> name,
  Value<String?> quantity,
  Value<String?> unit,
  Value<String?> shoppingCategoryId,
  Value<bool> isChecked,
  Value<bool> isFavorite,
  Value<int> useCount,
  Value<String?> note,
  Value<int> sortOrder,
  Value<String?> recipeId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$ShoppingListItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ShoppingListItemsTable,
    ShoppingListItem,
    $$ShoppingListItemsTableFilterComposer,
    $$ShoppingListItemsTableOrderingComposer,
    $$ShoppingListItemsTableCreateCompanionBuilder,
    $$ShoppingListItemsTableUpdateCompanionBuilder> {
  $$ShoppingListItemsTableTableManager(
      _$AppDatabase db, $ShoppingListItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ShoppingListItemsTableFilterComposer(ComposerState(db, table)),
          orderingComposer: $$ShoppingListItemsTableOrderingComposer(
              ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> listId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> quantity = const Value.absent(),
            Value<String?> unit = const Value.absent(),
            Value<String?> shoppingCategoryId = const Value.absent(),
            Value<bool> isChecked = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
            Value<int> useCount = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<String?> recipeId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ShoppingListItemsCompanion(
            id: id,
            listId: listId,
            name: name,
            quantity: quantity,
            unit: unit,
            shoppingCategoryId: shoppingCategoryId,
            isChecked: isChecked,
            isFavorite: isFavorite,
            useCount: useCount,
            note: note,
            sortOrder: sortOrder,
            recipeId: recipeId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String listId,
            required String name,
            Value<String?> quantity = const Value.absent(),
            Value<String?> unit = const Value.absent(),
            Value<String?> shoppingCategoryId = const Value.absent(),
            Value<bool> isChecked = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
            Value<int> useCount = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<String?> recipeId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ShoppingListItemsCompanion.insert(
            id: id,
            listId: listId,
            name: name,
            quantity: quantity,
            unit: unit,
            shoppingCategoryId: shoppingCategoryId,
            isChecked: isChecked,
            isFavorite: isFavorite,
            useCount: useCount,
            note: note,
            sortOrder: sortOrder,
            recipeId: recipeId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
        ));
}

class $$ShoppingListItemsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $ShoppingListItemsTable> {
  $$ShoppingListItemsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get listId => $state.composableBuilder(
      column: $state.table.listId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get quantity => $state.composableBuilder(
      column: $state.table.quantity,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get unit => $state.composableBuilder(
      column: $state.table.unit,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get shoppingCategoryId => $state.composableBuilder(
      column: $state.table.shoppingCategoryId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isChecked => $state.composableBuilder(
      column: $state.table.isChecked,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isFavorite => $state.composableBuilder(
      column: $state.table.isFavorite,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get useCount => $state.composableBuilder(
      column: $state.table.useCount,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get note => $state.composableBuilder(
      column: $state.table.note,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get sortOrder => $state.composableBuilder(
      column: $state.table.sortOrder,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get recipeId => $state.composableBuilder(
      column: $state.table.recipeId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$ShoppingListItemsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $ShoppingListItemsTable> {
  $$ShoppingListItemsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get listId => $state.composableBuilder(
      column: $state.table.listId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get quantity => $state.composableBuilder(
      column: $state.table.quantity,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get unit => $state.composableBuilder(
      column: $state.table.unit,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get shoppingCategoryId => $state.composableBuilder(
      column: $state.table.shoppingCategoryId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isChecked => $state.composableBuilder(
      column: $state.table.isChecked,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isFavorite => $state.composableBuilder(
      column: $state.table.isFavorite,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get useCount => $state.composableBuilder(
      column: $state.table.useCount,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get note => $state.composableBuilder(
      column: $state.table.note,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get sortOrder => $state.composableBuilder(
      column: $state.table.sortOrder,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get recipeId => $state.composableBuilder(
      column: $state.table.recipeId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$MealPlansTableCreateCompanionBuilder = MealPlansCompanion Function({
  required String id,
  required DateTime date,
  Value<DateTime?> time,
  Value<String?> name,
  Value<String> mealType,
  Value<String?> customMeal,
  Value<String?> recipeId,
  Value<String?> notes,
  Value<bool> alertEnabled,
  Value<bool> alertSent,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$MealPlansTableUpdateCompanionBuilder = MealPlansCompanion Function({
  Value<String> id,
  Value<DateTime> date,
  Value<DateTime?> time,
  Value<String?> name,
  Value<String> mealType,
  Value<String?> customMeal,
  Value<String?> recipeId,
  Value<String?> notes,
  Value<bool> alertEnabled,
  Value<bool> alertSent,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$MealPlansTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MealPlansTable,
    MealPlan,
    $$MealPlansTableFilterComposer,
    $$MealPlansTableOrderingComposer,
    $$MealPlansTableCreateCompanionBuilder,
    $$MealPlansTableUpdateCompanionBuilder> {
  $$MealPlansTableTableManager(_$AppDatabase db, $MealPlansTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$MealPlansTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$MealPlansTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<DateTime?> time = const Value.absent(),
            Value<String?> name = const Value.absent(),
            Value<String> mealType = const Value.absent(),
            Value<String?> customMeal = const Value.absent(),
            Value<String?> recipeId = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<bool> alertEnabled = const Value.absent(),
            Value<bool> alertSent = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MealPlansCompanion(
            id: id,
            date: date,
            time: time,
            name: name,
            mealType: mealType,
            customMeal: customMeal,
            recipeId: recipeId,
            notes: notes,
            alertEnabled: alertEnabled,
            alertSent: alertSent,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required DateTime date,
            Value<DateTime?> time = const Value.absent(),
            Value<String?> name = const Value.absent(),
            Value<String> mealType = const Value.absent(),
            Value<String?> customMeal = const Value.absent(),
            Value<String?> recipeId = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<bool> alertEnabled = const Value.absent(),
            Value<bool> alertSent = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MealPlansCompanion.insert(
            id: id,
            date: date,
            time: time,
            name: name,
            mealType: mealType,
            customMeal: customMeal,
            recipeId: recipeId,
            notes: notes,
            alertEnabled: alertEnabled,
            alertSent: alertSent,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
        ));
}

class $$MealPlansTableFilterComposer
    extends FilterComposer<_$AppDatabase, $MealPlansTable> {
  $$MealPlansTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get date => $state.composableBuilder(
      column: $state.table.date,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get time => $state.composableBuilder(
      column: $state.table.time,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get mealType => $state.composableBuilder(
      column: $state.table.mealType,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get customMeal => $state.composableBuilder(
      column: $state.table.customMeal,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get recipeId => $state.composableBuilder(
      column: $state.table.recipeId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get notes => $state.composableBuilder(
      column: $state.table.notes,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get alertEnabled => $state.composableBuilder(
      column: $state.table.alertEnabled,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get alertSent => $state.composableBuilder(
      column: $state.table.alertSent,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$MealPlansTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $MealPlansTable> {
  $$MealPlansTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get date => $state.composableBuilder(
      column: $state.table.date,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get time => $state.composableBuilder(
      column: $state.table.time,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get mealType => $state.composableBuilder(
      column: $state.table.mealType,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get customMeal => $state.composableBuilder(
      column: $state.table.customMeal,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get recipeId => $state.composableBuilder(
      column: $state.table.recipeId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get notes => $state.composableBuilder(
      column: $state.table.notes,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get alertEnabled => $state.composableBuilder(
      column: $state.table.alertEnabled,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get alertSent => $state.composableBuilder(
      column: $state.table.alertSent,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$TagsTableCreateCompanionBuilder = TagsCompanion Function({
  required String id,
  required String name,
  Value<String?> color,
  Value<String?> icon,
  Value<int> sortOrder,
  Value<bool> isBuiltIn,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$TagsTableUpdateCompanionBuilder = TagsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> color,
  Value<String?> icon,
  Value<int> sortOrder,
  Value<bool> isBuiltIn,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$TagsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TagsTable,
    Tag,
    $$TagsTableFilterComposer,
    $$TagsTableOrderingComposer,
    $$TagsTableCreateCompanionBuilder,
    $$TagsTableUpdateCompanionBuilder> {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$TagsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$TagsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> color = const Value.absent(),
            Value<String?> icon = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<bool> isBuiltIn = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TagsCompanion(
            id: id,
            name: name,
            color: color,
            icon: icon,
            sortOrder: sortOrder,
            isBuiltIn: isBuiltIn,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> color = const Value.absent(),
            Value<String?> icon = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<bool> isBuiltIn = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TagsCompanion.insert(
            id: id,
            name: name,
            color: color,
            icon: icon,
            sortOrder: sortOrder,
            isBuiltIn: isBuiltIn,
            createdAt: createdAt,
            rowid: rowid,
          ),
        ));
}

class $$TagsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get color => $state.composableBuilder(
      column: $state.table.color,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get icon => $state.composableBuilder(
      column: $state.table.icon,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get sortOrder => $state.composableBuilder(
      column: $state.table.sortOrder,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isBuiltIn => $state.composableBuilder(
      column: $state.table.isBuiltIn,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$TagsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get color => $state.composableBuilder(
      column: $state.table.color,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get icon => $state.composableBuilder(
      column: $state.table.icon,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get sortOrder => $state.composableBuilder(
      column: $state.table.sortOrder,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isBuiltIn => $state.composableBuilder(
      column: $state.table.isBuiltIn,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$RecipeTagsTableCreateCompanionBuilder = RecipeTagsCompanion Function({
  required String recipeId,
  required String tagId,
  Value<int> rowid,
});
typedef $$RecipeTagsTableUpdateCompanionBuilder = RecipeTagsCompanion Function({
  Value<String> recipeId,
  Value<String> tagId,
  Value<int> rowid,
});

class $$RecipeTagsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RecipeTagsTable,
    RecipeTag,
    $$RecipeTagsTableFilterComposer,
    $$RecipeTagsTableOrderingComposer,
    $$RecipeTagsTableCreateCompanionBuilder,
    $$RecipeTagsTableUpdateCompanionBuilder> {
  $$RecipeTagsTableTableManager(_$AppDatabase db, $RecipeTagsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$RecipeTagsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$RecipeTagsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> recipeId = const Value.absent(),
            Value<String> tagId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RecipeTagsCompanion(
            recipeId: recipeId,
            tagId: tagId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String recipeId,
            required String tagId,
            Value<int> rowid = const Value.absent(),
          }) =>
              RecipeTagsCompanion.insert(
            recipeId: recipeId,
            tagId: tagId,
            rowid: rowid,
          ),
        ));
}

class $$RecipeTagsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $RecipeTagsTable> {
  $$RecipeTagsTableFilterComposer(super.$state);
  ColumnFilters<String> get recipeId => $state.composableBuilder(
      column: $state.table.recipeId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get tagId => $state.composableBuilder(
      column: $state.table.tagId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$RecipeTagsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $RecipeTagsTable> {
  $$RecipeTagsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get recipeId => $state.composableBuilder(
      column: $state.table.recipeId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get tagId => $state.composableBuilder(
      column: $state.table.tagId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$UserIngredientMappingsTableCreateCompanionBuilder
    = UserIngredientMappingsCompanion Function({
  required String ingredient,
  required String shoppingCategoryId,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$UserIngredientMappingsTableUpdateCompanionBuilder
    = UserIngredientMappingsCompanion Function({
  Value<String> ingredient,
  Value<String> shoppingCategoryId,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$UserIngredientMappingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserIngredientMappingsTable,
    UserIngredientMapping,
    $$UserIngredientMappingsTableFilterComposer,
    $$UserIngredientMappingsTableOrderingComposer,
    $$UserIngredientMappingsTableCreateCompanionBuilder,
    $$UserIngredientMappingsTableUpdateCompanionBuilder> {
  $$UserIngredientMappingsTableTableManager(
      _$AppDatabase db, $UserIngredientMappingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$UserIngredientMappingsTableFilterComposer(
              ComposerState(db, table)),
          orderingComposer: $$UserIngredientMappingsTableOrderingComposer(
              ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> ingredient = const Value.absent(),
            Value<String> shoppingCategoryId = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserIngredientMappingsCompanion(
            ingredient: ingredient,
            shoppingCategoryId: shoppingCategoryId,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String ingredient,
            required String shoppingCategoryId,
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserIngredientMappingsCompanion.insert(
            ingredient: ingredient,
            shoppingCategoryId: shoppingCategoryId,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
        ));
}

class $$UserIngredientMappingsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $UserIngredientMappingsTable> {
  $$UserIngredientMappingsTableFilterComposer(super.$state);
  ColumnFilters<String> get ingredient => $state.composableBuilder(
      column: $state.table.ingredient,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get shoppingCategoryId => $state.composableBuilder(
      column: $state.table.shoppingCategoryId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$UserIngredientMappingsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $UserIngredientMappingsTable> {
  $$UserIngredientMappingsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get ingredient => $state.composableBuilder(
      column: $state.table.ingredient,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get shoppingCategoryId => $state.composableBuilder(
      column: $state.table.shoppingCategoryId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$UsdaFoodsTableCreateCompanionBuilder = UsdaFoodsCompanion Function({
  Value<int> fdcId,
  required String description,
  Value<String?> dataType,
  Value<String?> brandName,
  Value<String?> brandOwner,
  Value<String?> gtinUpc,
  Value<double?> servingSize,
  Value<String?> servingSizeUnit,
  Value<String?> householdServing,
  required String nutrientsJson,
  Value<String?> foodCategory,
  Value<String?> ingredients,
  Value<bool> isBundled,
  Value<String?> searchKeywords,
  Value<DateTime> cachedAt,
});
typedef $$UsdaFoodsTableUpdateCompanionBuilder = UsdaFoodsCompanion Function({
  Value<int> fdcId,
  Value<String> description,
  Value<String?> dataType,
  Value<String?> brandName,
  Value<String?> brandOwner,
  Value<String?> gtinUpc,
  Value<double?> servingSize,
  Value<String?> servingSizeUnit,
  Value<String?> householdServing,
  Value<String> nutrientsJson,
  Value<String?> foodCategory,
  Value<String?> ingredients,
  Value<bool> isBundled,
  Value<String?> searchKeywords,
  Value<DateTime> cachedAt,
});

class $$UsdaFoodsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UsdaFoodsTable,
    UsdaFood,
    $$UsdaFoodsTableFilterComposer,
    $$UsdaFoodsTableOrderingComposer,
    $$UsdaFoodsTableCreateCompanionBuilder,
    $$UsdaFoodsTableUpdateCompanionBuilder> {
  $$UsdaFoodsTableTableManager(_$AppDatabase db, $UsdaFoodsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$UsdaFoodsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$UsdaFoodsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> fdcId = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String?> dataType = const Value.absent(),
            Value<String?> brandName = const Value.absent(),
            Value<String?> brandOwner = const Value.absent(),
            Value<String?> gtinUpc = const Value.absent(),
            Value<double?> servingSize = const Value.absent(),
            Value<String?> servingSizeUnit = const Value.absent(),
            Value<String?> householdServing = const Value.absent(),
            Value<String> nutrientsJson = const Value.absent(),
            Value<String?> foodCategory = const Value.absent(),
            Value<String?> ingredients = const Value.absent(),
            Value<bool> isBundled = const Value.absent(),
            Value<String?> searchKeywords = const Value.absent(),
            Value<DateTime> cachedAt = const Value.absent(),
          }) =>
              UsdaFoodsCompanion(
            fdcId: fdcId,
            description: description,
            dataType: dataType,
            brandName: brandName,
            brandOwner: brandOwner,
            gtinUpc: gtinUpc,
            servingSize: servingSize,
            servingSizeUnit: servingSizeUnit,
            householdServing: householdServing,
            nutrientsJson: nutrientsJson,
            foodCategory: foodCategory,
            ingredients: ingredients,
            isBundled: isBundled,
            searchKeywords: searchKeywords,
            cachedAt: cachedAt,
          ),
          createCompanionCallback: ({
            Value<int> fdcId = const Value.absent(),
            required String description,
            Value<String?> dataType = const Value.absent(),
            Value<String?> brandName = const Value.absent(),
            Value<String?> brandOwner = const Value.absent(),
            Value<String?> gtinUpc = const Value.absent(),
            Value<double?> servingSize = const Value.absent(),
            Value<String?> servingSizeUnit = const Value.absent(),
            Value<String?> householdServing = const Value.absent(),
            required String nutrientsJson,
            Value<String?> foodCategory = const Value.absent(),
            Value<String?> ingredients = const Value.absent(),
            Value<bool> isBundled = const Value.absent(),
            Value<String?> searchKeywords = const Value.absent(),
            Value<DateTime> cachedAt = const Value.absent(),
          }) =>
              UsdaFoodsCompanion.insert(
            fdcId: fdcId,
            description: description,
            dataType: dataType,
            brandName: brandName,
            brandOwner: brandOwner,
            gtinUpc: gtinUpc,
            servingSize: servingSize,
            servingSizeUnit: servingSizeUnit,
            householdServing: householdServing,
            nutrientsJson: nutrientsJson,
            foodCategory: foodCategory,
            ingredients: ingredients,
            isBundled: isBundled,
            searchKeywords: searchKeywords,
            cachedAt: cachedAt,
          ),
        ));
}

class $$UsdaFoodsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $UsdaFoodsTable> {
  $$UsdaFoodsTableFilterComposer(super.$state);
  ColumnFilters<int> get fdcId => $state.composableBuilder(
      column: $state.table.fdcId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get dataType => $state.composableBuilder(
      column: $state.table.dataType,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get brandName => $state.composableBuilder(
      column: $state.table.brandName,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get brandOwner => $state.composableBuilder(
      column: $state.table.brandOwner,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get gtinUpc => $state.composableBuilder(
      column: $state.table.gtinUpc,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get servingSize => $state.composableBuilder(
      column: $state.table.servingSize,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get servingSizeUnit => $state.composableBuilder(
      column: $state.table.servingSizeUnit,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get householdServing => $state.composableBuilder(
      column: $state.table.householdServing,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get nutrientsJson => $state.composableBuilder(
      column: $state.table.nutrientsJson,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get foodCategory => $state.composableBuilder(
      column: $state.table.foodCategory,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get ingredients => $state.composableBuilder(
      column: $state.table.ingredients,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isBundled => $state.composableBuilder(
      column: $state.table.isBundled,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get searchKeywords => $state.composableBuilder(
      column: $state.table.searchKeywords,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get cachedAt => $state.composableBuilder(
      column: $state.table.cachedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$UsdaFoodsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $UsdaFoodsTable> {
  $$UsdaFoodsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get fdcId => $state.composableBuilder(
      column: $state.table.fdcId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get dataType => $state.composableBuilder(
      column: $state.table.dataType,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get brandName => $state.composableBuilder(
      column: $state.table.brandName,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get brandOwner => $state.composableBuilder(
      column: $state.table.brandOwner,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get gtinUpc => $state.composableBuilder(
      column: $state.table.gtinUpc,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get servingSize => $state.composableBuilder(
      column: $state.table.servingSize,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get servingSizeUnit => $state.composableBuilder(
      column: $state.table.servingSizeUnit,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get householdServing => $state.composableBuilder(
      column: $state.table.householdServing,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get nutrientsJson => $state.composableBuilder(
      column: $state.table.nutrientsJson,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get foodCategory => $state.composableBuilder(
      column: $state.table.foodCategory,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get ingredients => $state.composableBuilder(
      column: $state.table.ingredients,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isBundled => $state.composableBuilder(
      column: $state.table.isBundled,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get searchKeywords => $state.composableBuilder(
      column: $state.table.searchKeywords,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get cachedAt => $state.composableBuilder(
      column: $state.table.cachedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$IngredientUsdaMappingsTableCreateCompanionBuilder
    = IngredientUsdaMappingsCompanion Function({
  required String ingredientName,
  required int fdcId,
  Value<double?> gramsPer,
  Value<String?> portionDescription,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$IngredientUsdaMappingsTableUpdateCompanionBuilder
    = IngredientUsdaMappingsCompanion Function({
  Value<String> ingredientName,
  Value<int> fdcId,
  Value<double?> gramsPer,
  Value<String?> portionDescription,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$IngredientUsdaMappingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $IngredientUsdaMappingsTable,
    IngredientUsdaMapping,
    $$IngredientUsdaMappingsTableFilterComposer,
    $$IngredientUsdaMappingsTableOrderingComposer,
    $$IngredientUsdaMappingsTableCreateCompanionBuilder,
    $$IngredientUsdaMappingsTableUpdateCompanionBuilder> {
  $$IngredientUsdaMappingsTableTableManager(
      _$AppDatabase db, $IngredientUsdaMappingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$IngredientUsdaMappingsTableFilterComposer(
              ComposerState(db, table)),
          orderingComposer: $$IngredientUsdaMappingsTableOrderingComposer(
              ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> ingredientName = const Value.absent(),
            Value<int> fdcId = const Value.absent(),
            Value<double?> gramsPer = const Value.absent(),
            Value<String?> portionDescription = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              IngredientUsdaMappingsCompanion(
            ingredientName: ingredientName,
            fdcId: fdcId,
            gramsPer: gramsPer,
            portionDescription: portionDescription,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String ingredientName,
            required int fdcId,
            Value<double?> gramsPer = const Value.absent(),
            Value<String?> portionDescription = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              IngredientUsdaMappingsCompanion.insert(
            ingredientName: ingredientName,
            fdcId: fdcId,
            gramsPer: gramsPer,
            portionDescription: portionDescription,
            createdAt: createdAt,
            rowid: rowid,
          ),
        ));
}

class $$IngredientUsdaMappingsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $IngredientUsdaMappingsTable> {
  $$IngredientUsdaMappingsTableFilterComposer(super.$state);
  ColumnFilters<String> get ingredientName => $state.composableBuilder(
      column: $state.table.ingredientName,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get fdcId => $state.composableBuilder(
      column: $state.table.fdcId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get gramsPer => $state.composableBuilder(
      column: $state.table.gramsPer,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get portionDescription => $state.composableBuilder(
      column: $state.table.portionDescription,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$IngredientUsdaMappingsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $IngredientUsdaMappingsTable> {
  $$IngredientUsdaMappingsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get ingredientName => $state.composableBuilder(
      column: $state.table.ingredientName,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get fdcId => $state.composableBuilder(
      column: $state.table.fdcId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get gramsPer => $state.composableBuilder(
      column: $state.table.gramsPer,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get portionDescription => $state.composableBuilder(
      column: $state.table.portionDescription,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CookbooksTableTableManager get cookbooks =>
      $$CookbooksTableTableManager(_db, _db.cookbooks);
  $$RecipesTableTableManager get recipes =>
      $$RecipesTableTableManager(_db, _db.recipes);
  $$IngredientsTableTableManager get ingredients =>
      $$IngredientsTableTableManager(_db, _db.ingredients);
  $$StepsTableTableManager get steps =>
      $$StepsTableTableManager(_db, _db.steps);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$ShoppingCategoriesTableTableManager get shoppingCategories =>
      $$ShoppingCategoriesTableTableManager(_db, _db.shoppingCategories);
  $$ShoppingListsTableTableManager get shoppingLists =>
      $$ShoppingListsTableTableManager(_db, _db.shoppingLists);
  $$CustomCoursesTableTableManager get customCourses =>
      $$CustomCoursesTableTableManager(_db, _db.customCourses);
  $$CustomCategoriesTableTableManager get customCategories =>
      $$CustomCategoriesTableTableManager(_db, _db.customCategories);
  $$ShoppingListItemsTableTableManager get shoppingListItems =>
      $$ShoppingListItemsTableTableManager(_db, _db.shoppingListItems);
  $$MealPlansTableTableManager get mealPlans =>
      $$MealPlansTableTableManager(_db, _db.mealPlans);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$RecipeTagsTableTableManager get recipeTags =>
      $$RecipeTagsTableTableManager(_db, _db.recipeTags);
  $$UserIngredientMappingsTableTableManager get userIngredientMappings =>
      $$UserIngredientMappingsTableTableManager(
          _db, _db.userIngredientMappings);
  $$UsdaFoodsTableTableManager get usdaFoods =>
      $$UsdaFoodsTableTableManager(_db, _db.usdaFoods);
  $$IngredientUsdaMappingsTableTableManager get ingredientUsdaMappings =>
      $$IngredientUsdaMappingsTableTableManager(
          _db, _db.ingredientUsdaMappings);
}
