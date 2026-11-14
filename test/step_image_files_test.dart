// Step photos are kept under names of their own. Named by step position, a
// new photo overwrote another step's photo once a step was deleted or moved,
// and the cloud copy known for that path was reused, so the new photo never
// reached other devices. On Windows the "already kept" check compared text
// with forward slashes and never matched, so every save copied every photo.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:recipespellbook/utils/step_image_files.dart';

void main() {
  late Directory docs;
  late Directory temp;

  setUp(() {
    docs = Directory.systemTemp.createTempSync('rsb_docs');
    temp = Directory.systemTemp.createTempSync('rsb_picked');
  });

  tearDown(() {
    docs.deleteSync(recursive: true);
    temp.deleteSync(recursive: true);
  });

  File picked(String name, String content) =>
      File(p.join(temp.path, name))..writeAsStringSync(content);

  test('a picked photo is copied into the step folder', () async {
    final kept = await keepStepImage(picked('a.jpg', 'A').path, documentsDir: docs.path, recipeId: 'r1');
    expect(isKeptStepImage(kept, docs.path), isTrue);
    expect(p.extension(kept), '.jpg');
    expect(File(kept).readAsStringSync(), 'A');
  });

  test('two photos for the same recipe never share a file', () async {
    // Step 2 is deleted, so the old step 3 is now the second step, and a
    // new photo is picked for the step now in third place.
    final first = await keepStepImage(picked('a.jpg', 'A').path, documentsDir: docs.path, recipeId: 'r1');
    final second = await keepStepImage(picked('b.jpg', 'B').path, documentsDir: docs.path, recipeId: 'r1');
    expect(second, isNot(first));
    expect(File(first).readAsStringSync(), 'A', reason: 'the first photo was overwritten');
    expect(File(second).readAsStringSync(), 'B');
  });

  test('a kept photo stays where it is, written with this system\'s separators', () async {
    final kept = await keepStepImage(picked('a.jpg', 'A').path, documentsDir: docs.path, recipeId: 'r1');
    final files = docs.listSync(recursive: true).whereType<File>().length;
    expect(await keepStepImage(kept, documentsDir: docs.path, recipeId: 'r1'), kept);
    expect(docs.listSync(recursive: true).whereType<File>().length, files, reason: 'copied again');
  });

  test('a new recipe gets copies of its own', () async {
    final kept = await keepStepImage(picked('a.jpg', 'A').path, documentsDir: docs.path, recipeId: 'r1');
    final copy = await keepStepImage(kept, documentsDir: docs.path, recipeId: 'r2', copyKept: true);
    expect(copy, isNot(kept));
    expect(File(copy).readAsStringSync(), 'A');
  });

  test('a photo that cannot be copied keeps its path', () async {
    final missing = p.join(temp.path, 'gone.jpg');
    expect(await keepStepImage(missing, documentsDir: docs.path, recipeId: 'r1'), missing);
  });

  test('only paths inside the step folder count as kept', () {
    expect(isKeptStepImage(p.join(docs.path, 'images', 'steps', 'x.jpg'), docs.path), isTrue);
    expect(isKeptStepImage(p.join(docs.path, 'images', 'x.jpg'), docs.path), isFalse);
    expect(isKeptStepImage(p.join(temp.path, 'images', 'steps', 'x.jpg'), docs.path), isFalse);
  });
}
