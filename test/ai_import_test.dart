// Recipes pasted from a chat: how the answer is read and what is saved from
// it. Saving runs against an in-memory database, so the table constraints are
// the real ones.
import 'dart:convert';

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/services/ai_import_service.dart';

const _alpha = '{"title":"Alpha Soup","ingredients":[{"name":"water"}],"steps":[{"instruction":"Boil."}]}';
const _bravo = '{"title":"Bravo Stew","ingredients":[{"name":"beef"}],"steps":[{"instruction":"Stew."}]}';
const _charlie = '{"title":"Charlie Pie","ingredients":[{"name":"apples"}],"steps":[{"instruction":"Bake."}]}';
const _fence = '```';

/// A recipe in the pasted format, small enough to read in a test.
Map<String, dynamic> _recipe(
  String title, {
  List<Object?> ingredients = const [
    {'name': 'water'},
  ],
  List<Object?> steps = const [
    {'instruction': 'Boil.'},
  ],
  Map<String, Object?> extra = const {},
}) =>
    {'title': title, 'ingredients': ingredients, 'steps': steps, ...extra};

List<Object?> _titles(String pasted) => [for (final r in AiImportService.extractRecipes(pasted)) r['title']];

void main() {
  group('reading an answer', () {
    test('one code block per recipe gives every recipe', () {
      final pasted = '${_fence}json\n$_alpha\n$_fence\n\n${_fence}json\n$_bravo\n$_fence';
      expect(AiImportService.validate(pasted), isNull);
      expect(_titles(pasted), ['Alpha Soup', 'Bravo Stew']);
    });

    test('code blocks under headings, with a closing sentence, give every recipe', () {
      final pasted = 'Here are your recipes:\n\n'
          '### Alpha Soup\n${_fence}json\n$_alpha\n$_fence\n\n'
          '### Bravo Stew\n${_fence}json\n$_bravo\n$_fence\n\n'
          '### Charlie Pie\n$_fence\n$_charlie\n$_fence\n\n'
          'Let me know if you need anything else!';
      expect(AiImportService.validate(pasted), isNull);
      expect(_titles(pasted), ['Alpha Soup', 'Bravo Stew', 'Charlie Pie']);
    });

    test('recipes separated by a comma or by labels are all found', () {
      for (final pasted in [
        '$_alpha,\n$_bravo',
        'Recipe 1:\n$_alpha\n\nRecipe 2:\n$_bravo',
        'Recipe 1 [soup]:\n$_alpha\n\nRecipe 2 [stew]:\n$_bravo',
        '1. $_alpha\n2. $_bravo',
      ]) {
        expect(AiImportService.validate(pasted), isNull, reason: pasted);
        expect(_titles(pasted), ['Alpha Soup', 'Bravo Stew'], reason: pasted);
      }
    });

    test('brackets and quote marks in the chat text around a recipe are passed over', () {
      const pie =
          '{"title":"Pie","sourceUrl":"https://example.com/pie","ingredients":[{"name":"apples"}],"steps":[{"instruction":"Bake."}]}';
      final shapes = <String, List<String>>{
        'Here is the JSON [converted from your photo]:\n$_alpha': ['Alpha Soup'],
        '$_alpha\n\nNote: [optional] add salt.': ['Alpha Soup'],
        'Sure!\n$_alpha\n\nNote: [optional] add salt.': ['Alpha Soup'],
        'Sure!\n$_alpha\nEnjoy {the} soup!': ['Alpha Soup'],
        '$_alpha\n\nTip :-[ do not burn it': ['Alpha Soup'],
        'A tip :-[ before the recipe.\n$_alpha': ['Alpha Soup'],
        'Recipe for a 9" pie:\n$pie': ['Pie'],
        'Source: https://example.com/soup $_alpha': ['Alpha Soup'],
        '- [ ] buy apples\n- [x] convert\n$_alpha\nSee [[1]] and {} for more.': ['Alpha Soup'],
        'Use {{name}} and {count} here.\n$_alpha\nDone {ok}.': ['Alpha Soup'],
        '$_alpha\nThanks {note: add salt} and {notes: none} for reading.': ['Alpha Soup'],
        '---\ntitle: x\n---\n$_alpha': ['Alpha Soup'],
        '$_alpha\nTip: put it in [{ a bowl\n$_bravo': ['Alpha Soup', 'Bravo Stew'],
        // A "/*" that never closes is part of a sentence, not a comment over all that follows.
        'Saved under recipes/*.json\n$_alpha\n$_bravo': ['Alpha Soup', 'Bravo Stew'],
        '$_alpha\nMore under recipes/*.json\n$_bravo': ['Alpha Soup', 'Bravo Stew'],
      };
      shapes.forEach((pasted, titles) {
        expect(AiImportService.validate(pasted), isNull, reason: pasted);
        expect(_titles(pasted), titles, reason: pasted);
      });
    });

    test('answers that were read before are read the same', () {
      final shapes = <String, List<String>>{
        _alpha: ['Alpha Soup'],
        '[$_alpha,$_bravo]': ['Alpha Soup', 'Bravo Stew'],
        '$_alpha\n\n$_bravo': ['Alpha Soup', 'Bravo Stew'],
        '$_alpha$_bravo': ['Alpha Soup', 'Bravo Stew'],
        '[$_alpha]\n[$_bravo,$_charlie]': ['Alpha Soup', 'Bravo Stew', 'Charlie Pie'],
        '${_fence}json\n$_alpha\n$_fence': ['Alpha Soup'],
        '$_fence\n$_alpha\n$_fence': ['Alpha Soup'],
        '${_fence}json\n[$_alpha,\n$_bravo]\n$_fence': ['Alpha Soup', 'Bravo Stew'],
        '${_fence}json\n$_alpha\n$_fence\nEnjoy!': ['Alpha Soup'],
        'Here you go:\n\n${_fence}json\n$_alpha\n$_fence\n\nLet me know!': ['Alpha Soup'],
        '${_fence}json $_alpha$_fence': ['Alpha Soup'],
        'Sure! Here you go:\n[$_alpha,$_bravo]\nHope this helps.': ['Alpha Soup', 'Bravo Stew'],
        '"$_alpha"': ['Alpha Soup'],
        "'$_alpha'": ['Alpha Soup'],
        '\uFEFF  $_alpha\r\n': ['Alpha Soup'],
        '// converted from a photo\n$_alpha': ['Alpha Soup'],
        '// e.g. {"title":"x"}\n/* or [{"title":"y"}] */\n$_alpha': ['Alpha Soup'],
        '{\n  // the title\n  "title":"Alpha", /* c */\n  "sourceUrl":"https://example.com/a//b",\n'
            '  "ingredients":[{"name":"water"}],\n  "steps":[{"instruction":"Boil."}]\n}': ['Alpha'],
        '{"recipes":[$_alpha,$_bravo],"links":{"water":["Bravo Stew"]},"version":"3.0"}': ['Alpha Soup', 'Bravo Stew'],
        '[$_charlie,{"recipes":[$_alpha,$_bravo],"links":{}}]': ['Charlie Pie', 'Alpha Soup', 'Bravo Stew'],
      };
      shapes.forEach((pasted, titles) {
        expect(AiImportService.validate(pasted), isNull, reason: pasted);
        expect(_titles(pasted), titles, reason: pasted);
      });
    });

    test('text inside the recipe is left as it was written', () {
      final pasted = jsonEncode(_recipe(
        'The "Best" Soup, [really] {truly}',
        ingredients: [
          {'name': 'salt', 'notes': 'use $_fence sparingly // or not /* at all */'},
        ],
        steps: [
          {'instruction': 'Say "hi", ] then boil, } and serve.'},
          {'instruction': 'Top with any of [nuts, seeds,] then bake'},
        ],
        extra: {'sourceUrl': 'https://example.com/a//b'},
      ));
      final recipe = AiImportService.extractRecipes('Sure:\n$_fence\n$pasted\n$_fence').single;
      expect(recipe['title'], 'The "Best" Soup, [really] {truly}');
      expect(recipe['sourceUrl'], 'https://example.com/a//b');
      expect(recipe['ingredients'][0]['notes'], 'use $_fence sparingly // or not /* at all */');
      expect(recipe['steps'][0]['instruction'], 'Say "hi", ] then boil, } and serve.');
      expect(recipe['steps'][1]['instruction'], 'Top with any of [nuts, seeds,] then bake');
    });

    test('garbled accents from a bad copy are repaired', () {
      const pasted = '{"title":"CrÃ¨me brÃ»lÃ©e","ingredients":[{"amount":"Â½","unit":"cup","name":"sugar"}],'
          '"steps":[{"instruction":"Bake at 300Â°F."}]}';
      final recipe = AiImportService.extractRecipes(pasted).single;
      expect(recipe['title'], 'Crème brûlée');
      expect(recipe['ingredients'][0]['amount'], '½');
      expect(recipe['steps'][0]['instruction'], 'Bake at 300°F.');
    });

    test('no-break spaces used as indentation are read as spaces, and kept inside text', () {
      const pasted = '{\n\u00a0\u00a0"title":"Crêpe\u00a0Suzette",\n'
          '\u00a0\u00a0"ingredients":[\u00a0{"name":"flour"}\u00a0],\n'
          '\u00a0\u00a0"steps":[{"instruction":"Flip."}]\n}';
      expect(AiImportService.validate(pasted), isNull);
      expect(AiImportService.extractRecipes(pasted).single['title'], 'Crêpe\u00a0Suzette');
    });

    test('wide, narrow and invisible blanks between the fields are read as spaces too', () {
      const blanks = {
        'ideographic space': '\u3000',
        'narrow no-break space': '\u202f',
        'thin space': '\u2009',
        'zero-width space': '\u200b',
        'word joiner': '\u2060',
        'right-to-left mark': '\u200f',
        'line separator': '\u2028',
        'byte order mark': '\ufeff',
        'vertical tab': '\u000b',
      };
      blanks.forEach((name, blank) {
        // Inside a text the blank stays what it is. A control character may not stand there at all.
        final inText = blank.codeUnitAt(0) < 0x20 ? ' ' : blank;
        final pasted = '{$blank\n$blank$blank"title":"Crêpe${inText}Suzette",\n'
            '$blank"ingredients":[$blank{"name":"flour"}$blank],$blank\n'
            '$blank"steps":[{"instruction":"Flip."}]\n$blank}';
        expect(AiImportService.validate(pasted), isNull, reason: name);
        expect(AiImportService.extractRecipes(pasted).single['title'], 'Crêpe${inText}Suzette', reason: name);
      });
    });

    test('an answer that was cut off is refused whole, wherever the cut falls', () {
      const cut = '{"title":"Bravo Stew","ingredients":[{"name":"beef"},{"name":"car';
      for (final pasted in [
        '[$_alpha,\n$cut',
        '$_alpha\n$cut',
        '${_fence}json\n[$_alpha,\n$cut',
        '${_fence}json\n$_alpha\n$_fence\n\n${_fence}json\n$cut',
        '$_alpha\n{"ti',
        '$_alpha\n\n${_fence}json\n{',
        '$_alpha\n\n[\n',
        '$_alpha\n{"title":"Bravo Stew","ingredients":[{"name":"beef"}],"steps":[{"instruction":"Stew."}] /* never closed',
      ]) {
        expect(
          AiImportService.validate(pasted),
          'Invalid JSON: A bracket is opened and never closed. The answer may have been cut off.',
          reason: pasted,
        );
        expect(AiImportService.extractRecipes(pasted), isEmpty, reason: pasted);
      }
    });

    test('a sentence that ends on an opening bracket is not an answer that was cut off', () {
      for (final pasted in [
        '$_alpha\n\nEnjoy :-[',
        '$_alpha\n\nEnjoy :-[ \n',
        '$_alpha\n\nTemplate: {',
        '$_alpha\n\nTemplate: { // to fill in',
      ]) {
        expect(AiImportService.validate(pasted), isNull, reason: pasted);
        expect(_titles(pasted), ['Alpha Soup'], reason: pasted);
      }
      // Where a value can begin, it still is one: on a line of its own, or after a comma or a bracket.
      for (final pasted in ['$_alpha\n  {', '$_alpha, {', '$_alpha,[', '[$_alpha, [ {']) {
        expect(AiImportService.validate(pasted), contains('The answer may have been cut off'), reason: pasted);
      }
    });

    test('one unreadable recipe among several refuses them all and says which', () {
      for (final pasted in [
        '$_alpha\n{"title":"Bravo Stew" "ingredients":[{"name":"beef"}],"steps":[{"instruction":"Stew."}]}',
        '$_alpha\n{"title":"Bravo Stew","ingredients":[{"name":"beef"}],"steps":[{"instruction":"Add the "secret" sauce."}]}',
      ]) {
        expect(
          AiImportService.validate(pasted),
          'Invalid JSON: Block 2 of 2 could not be read (Unexpected character)',
          reason: pasted,
        );
        expect(AiImportService.extractRecipes(pasted), isEmpty, reason: pasted);
      }
      // Chat text that only looks a little like JSON is not a recipe that went missing.
      expect(AiImportService.validate('$_alpha\nI left {"servings": as it was} and [{x}] out.'), isNull);
      expect(_titles('$_alpha\nI left {"servings": as it was} and [{x}] out.'), ['Alpha Soup']);
    });

    test('a recipe written in other quotes, or in none, is not passed over as chat text', () {
      const rest = "'ingredients': [{'name': 'beef'}], 'steps': [{'instruction': 'Stew.'}]";
      for (final stew in [
        "{'title': 'Bravo Stew', $rest}",
        '{title: "Bravo Stew", ingredients: [{name: "beef"}], steps: [{instruction: "Stew."}]}',
        '{“title”: “Bravo Stew”, “ingredients”: [{“name”: “beef”}], “steps”: [{“instruction”: “Stew.”}]}',
        '{ ‘title’ : ‘Bravo Stew’, ‘ingredients’ : [{‘name’: ‘beef’}], ‘steps’ : [{‘instruction’: ‘Stew.’}] }',
        // Another field first, the keys with capitals, a list around it, a linked set.
        "{'description': 'Rich.', 'title': 'Bravo Stew', $rest}",
        "{Title: 'Bravo Stew', Ingredients: [{Name: 'beef'}], Steps: [{Instruction: 'Stew.'}]}",
        "[{'title': 'Bravo Stew', $rest}]",
        "{'recipes': [{'title': 'Bravo Stew', $rest}], 'links': {}}",
        "{version: '3.0', recipes: [{title: 'Bravo Stew', $rest}]}",
      ]) {
        expect(
          AiImportService.validate('$_alpha\n$stew'),
          'Invalid JSON: Block 2 of 2 could not be read (Unexpected character)',
          reason: stew,
        );
        expect(
          AiImportService.validate('$stew\n\n$_alpha'),
          'Invalid JSON: Block 1 of 2 could not be read (Unexpected character)',
          reason: stew,
        );
        expect(AiImportService.extractRecipes('$_alpha\n$stew'), isEmpty, reason: stew);
        expect(AiImportService.extractRecipes('$stew\n\n$_alpha'), isEmpty, reason: stew);
        // On its own it is refused in the decoder's words.
        expect(AiImportService.validate(stew), 'Invalid JSON: Unexpected character', reason: stew);
      }

      // A lost quote throws the reading off up to the end of the text.
      const lostQuote = '{title":"Bravo Stew","ingredients":[{"name":"beef"}],"steps":[{"instruction":"Stew."}]}';
      for (final pasted in ['$_alpha\n$lostQuote', '$lostQuote\n$_alpha', '[$_alpha,$lostQuote]']) {
        expect(AiImportService.validate(pasted), startsWith('Invalid JSON'), reason: pasted);
        expect(AiImportService.extractRecipes(pasted), isEmpty, reason: pasted);
      }
    });

    test('text that holds no recipe says so', () {
      expect(AiImportService.validate('hello world'), startsWith('Invalid JSON'));
      expect(AiImportService.validate('{title: "Alpha Soup"}'), startsWith('Invalid JSON'));
      expect(AiImportService.validate('[]'), startsWith('No recipes found'));
      expect(AiImportService.validate('["a","b"]'), startsWith('No recipes found'));
      expect(AiImportService.validate('{}'), 'Recipe #1: Missing required field: "title"');
      expect(AiImportService.validate('{"foo":1}'), 'Recipe #1: Missing required field: "title"');
      expect(AiImportService.validate('{"title":"  ","ingredients":[{"name":"x"}],"steps":[{"instruction":"y"}]}'),
          'Recipe #1: Missing required field: "title"');
      expect(AiImportService.validate('{"title":"T","ingredients":["1 cup flour"],"steps":[{"instruction":"Mix"}]}'),
          'Recipe #1: Ingredient #1 is not a valid object.');
      expect(AiImportService.validate('{"title":"T","ingredients":null,"steps":null}'),
          'Recipe #1: Missing required field: "ingredients" (must be an array)');
      expect(AiImportService.validate('Use {"calories": 200} or {"fat": 3} per serving.'), startsWith('No recipes found'));
    });

    test('a recipe that cannot be read is not answered with "no recipes found"', () {
      // The answer wrapped in quotes with every quote of its own escaped, and
      // one with a stray letter after its first bracket: pieces of both read
      // as JSON, the recipe does not.
      const escaped = r'"{\"title\":\"Alpha Soup\",\"ingredients\":[{\"name\":\"water\"}],\"steps\":[{\"instruction\":\"Boil.\"}]}"';
      const stray = '{x title: "Alpha Soup", ingredients: [{"name":"water"}], steps: [{"instruction":"Boil."}]}';
      for (final pasted in [escaped, '$_fence\n$escaped\n$_fence', stray]) {
        expect(AiImportService.validate(pasted), 'Invalid JSON: Unexpected character', reason: pasted);
        expect(AiImportService.extractRecipes(pasted), isEmpty, reason: pasted);
      }
    });

    test('a recipe that lost a bracket is not left out while the others are imported', () {
      const stew = '"title":"Bravo Stew","ingredients":[{"name":"beef"}],"steps":[{"instruction":"Stew."}]}';
      String outside(String field, {int? afterBlock}) =>
          'Invalid JSON: "$field" stands outside the brackets of a recipe${afterBlock == null ? '' : ', after block $afterBlock'}. '
          'A bracket or a quote may be missing, or it is a remark to take out.';
      final shapes = <String, String>{
        // The opening bracket is gone, or something stands between it and the first field.
        '$_alpha\n$stew': outside('title', afterBlock: 1),
        '$stew\n\n$_alpha': outside('title'),
        '$_alpha\n{x$stew': outside('title', afterBlock: 1),
        '[{/$stew,$_alpha]': outside('title'),
        'Recipe 1:\n$_alpha\n\nRecipe 2:\n{]$stew': outside('title', afterBlock: 1),
        '$_alpha\n$_charlie\n\n{x“title”: “Bravo Stew”, “ingredients”: []}': outside('title', afterBlock: 2),
        // On its own it says the same, which tells more than "unexpected character".
        stew: outside('title'),
        // A bracket too many closes the recipe before its ingredients.
        '$_alpha\n{"title":"Bravo Stew"},"ingredients":[{"name":"beef"}],"steps":[{"instruction":"Stew."}]}':
            outside('ingredients', afterBlock: 2),
        '$_alpha\n{"title":"Bravo Stew","ingredients":[{"name":"beef"}]},"steps":[{"instruction":"Stew."}]}':
            outside('steps', afterBlock: 2),
        // The same for a set of linked recipes, and for other quotes.
        '"recipes":[$_alpha,$_bravo],"links":{}}': outside('recipes'),
        "$_alpha\n'Title': 'Bravo Stew', 'ingredients': [{'name': 'beef'}], 'steps': [{'instruction': 'Stew.'}]}":
            outside('Title', afterBlock: 1),
      };
      shapes.forEach((pasted, verdict) {
        expect(AiImportService.validate(pasted), verdict, reason: pasted);
        expect(AiImportService.extractRecipes(pasted), isEmpty, reason: pasted);
      });
      // Inside a list that reads as one piece, the decoder says what it finds.
      expect(AiImportService.validate('[$_alpha,\n$stew]'), 'Invalid JSON: Unexpected character');

      // A field that is only talked about, or quoted in a comment, is no recipe.
      for (final pasted in [
        '$_alpha\n\nNote: I left "title": as it was, and "steps": too.',
        'Fields: "title", "ingredients" and "steps".\n$_alpha',
        '// "title": "Example"\n$_alpha\n/* "steps": [] */',
      ]) {
        expect(AiImportService.validate(pasted), isNull, reason: pasted);
        expect(_titles(pasted), ['Alpha Soup'], reason: pasted);
      }
    });

    test('a remark in JSON form next to the recipes is not taken for a recipe', () {
      for (final pasted in [
        '$_alpha\n{"note":"converted"}',
        '$_alpha\n\nTo add nutrition later, use {"calories": 200}.',
        '$_alpha\nMore ingredients go in like this: [{"amount":"1","unit":"cup","name":"sugar"}]',
        // Also when the remark has lists or objects of its own.
        '$_alpha\n\nNutrition: {"calories":200,"allergens":["nuts"]}',
        '$_alpha\n{"shoppingList":["flour","eggs"]}',
        '$_alpha\n{"source":{"book":"Joy","page":12}}',
        '$_alpha\n{"name":"Bravo Stew","parts":["beef"],"method":["Stew."]}',
        '$_alpha\n{"links":{"water":["Bravo Stew"]}}',
        // In other quotes too, or with none.
        "$_alpha\n{'note': 'converted'} and {notes: none}",
        '$_alpha\n{}',
      ]) {
        expect(AiImportService.validate(pasted), isNull, reason: pasted);
        expect(_titles(pasted), ['Alpha Soup'], reason: pasted);
      }
      // Inside one list every object is meant as a recipe.
      expect(AiImportService.validate('[{}, $_alpha]'), 'Recipe #1: Missing required field: "title"');
      expect(AiImportService.validate('[$_alpha, {"note":"converted"}]'), 'Recipe #2: Missing required field: "title"');
      // Whatever names one of a recipe's fields is a recipe that went wrong,
      // also inside a wrapper or with capitals: reported, not dropped.
      for (final pasted in [
        '$_alpha\n{"title":"Bravo Stew"}',
        '$_alpha\n{"data":[$_bravo]}',
        '$_alpha\n{"result":{"recipes":[$_bravo]}}',
        '$_alpha\n{"Title":"Bravo Stew","Ingredients":[{"Name":"beef"}],"Steps":[{"Instruction":"Stew."}]}',
      ]) {
        expect(AiImportService.validate(pasted), startsWith('Recipe #2: Missing required field'), reason: pasted);
      }
    });

    test('trailing commas are dropped, also when a comment follows them', () {
      for (final pasted in [
        '{"title":"T","ingredients":[{"name":"salt"},],"steps":[{"instruction":"Mix"},],}',
        '{\n  "title": "T",\n  "ingredients": [\n    {"name": "salt"},\n  ],\n  "steps": [\n    {"instruction": "Mix"},\n  ],\n}',
        '{"title":"T","ingredients":[{"name":"salt"}],"steps":[{"instruction":"Mix"}], // done\n}',
        '{"title":"T","ingredients":[{"name":"salt"} , /* last */ ],"steps":[{"instruction":"Mix"}]}',
        '[{"title":"T","ingredients":[{"name":"salt"}],"steps":[{"instruction":"Mix"}]},\n]',
      ]) {
        expect(AiImportService.validate(pasted), isNull, reason: pasted);
        expect(_titles(pasted), ['T'], reason: pasted);
      }
      // A doubled comma is a mistake of another kind and is not papered over.
      expect(AiImportService.validate('{"title":"T",,"ingredients":[{"name":"salt"}],"steps":[{"instruction":"Mix"}]}'),
          startsWith('Invalid JSON'));
    });

    test('numbers and one-item lists where text is expected are read as text', () {
      final recipe = AiImportService.extractRecipes(jsonEncode({
        'title': 123,
        'servings': 6,
        'prepTimeMinutes': '20',
        'cookTimeMinutes': 15.0,
        'course': ['Main Dish'],
        'category': ['Pasta', 'Casserole'],
        'ingredients': [
          {'amount': 1, 'unit': 'lb', 'name': 'ziti'},
          {'amount': 0.5, 'name': 'onion'},
          {'amount': 2.0, 'name': 7},
        ],
        'steps': [
          {'instruction': 'Bake.', 'durationMinutes': '30', 'notes': ['flip once', 'medium heat']},
          {'instruction': 5},
        ],
      })).single;
      expect(recipe['title'], '123');
      expect(recipe['servings'], '6');
      expect(recipe['prepTimeMinutes'], 20);
      expect(recipe['cookTimeMinutes'], 15);
      expect(recipe['course'], 'Main Dish');
      expect(recipe['category'], 'Pasta, Casserole');
      expect([for (final i in recipe['ingredients']) i['amount']], ['1', '0.5', '2']);
      expect(recipe['ingredients'][2]['name'], '7');
      expect(recipe['steps'][0]['durationMinutes'], 30);
      expect(recipe['steps'][0]['notes'], 'flip once');
      expect(recipe['steps'][1]['instruction'], '5');

      // A number too big for an integer keeps its digits as far as they are
      // known, and is no number of minutes.
      final huge = AiImportService.extractRecipes('{"title":12345678901234567890,"prepTimeMinutes":12345678901234567890,'
              '"cookTimeMinutes":-1e30,"rating":1000000000000000,'
              '"ingredients":[{"amount":12345678901234567890,"unit":1e15,"name":"x"}],'
              '"steps":[{"instruction":"y","durationMinutes":1e300}]}')
          .single;
      expect(huge['title'], '12345678901234567000');
      expect(huge['ingredients'][0]['amount'], '12345678901234567000');
      expect(huge['ingredients'][0]['unit'], '1000000000000000');
      expect(huge['prepTimeMinutes'], isNull);
      expect(huge['cookTimeMinutes'], isNull);
      expect(huge['rating'], isNull);
      expect(huge['steps'][0]['durationMinutes'], isNull);
    });

    test('a field of the wrong kind is named in a sentence, not as a program error', () {
      String? verdict(Map<String, dynamic> recipe) => AiImportService.validate(jsonEncode(recipe));
      expect(verdict(_recipe('x')..['title'] = {'en': 'Soup'}), 'Recipe #1: Missing required field: "title"');
      expect(verdict(_recipe('x')..['title'] = true), 'Recipe #1: Missing required field: "title"');
      expect(
        verdict(_recipe('x', ingredients: [
          {'name': <String>[]},
        ])),
        'Recipe #1: Ingredient #1 is missing a "name" field.',
      );
      expect(
        verdict(_recipe('x', steps: [
          {'instruction': {'text': 'Boil.'}},
        ])),
        'Recipe #1: Step #1 is missing an "instruction" field.',
      );
    });

    test('a linked set with a mistyped links value or a missing title is still read', () {
      final set = {
        'recipes': [
          _recipe('Chocolate Cake', ingredients: [
            {'name': 'flour'},
            {'name': 'Frosting'},
          ]),
          _recipe('Frosting', ingredients: [
            {'name': 'butter'},
          ]),
        ],
        'links': {'Frosting': 'Frosting'},
      };
      expect(AiImportService.validate(jsonEncode(set)), isNull);
      expect(_titles(jsonEncode(set)), ['Chocolate Cake', 'Frosting']);

      for (final links in [null, 'Frosting', 3, <Object>[], {'Frosting': null}, {'Frosting': 7}, {'Frosting': <Object>[1, {}]}]) {
        expect(AiImportService.validate(jsonEncode({...set, 'links': links})), isNull, reason: '$links');
      }

      final untitled = {
        'recipes': [
          {
            'ingredients': [
              {'name': 'flour'},
            ],
            'steps': [
              {'instruction': 'Make.'},
            ],
          },
        ],
        'links': {
          'Frosting': ['Frosting'],
        },
      };
      expect(AiImportService.validate(jsonEncode(untitled)), 'Recipe #1: Missing required field: "title"');
    });

    test('a shopping list answer is cleaned up the same way', () {
      const pasted = 'Here is your list:\n\n$_fence\n[\n'
          '  {"name": "milk", "amount": "1", "unit": "l", "category": "Dairy"}, // for the sauce\n'
          '  {"name": "eggs, [large]", "amount": "6"},\n'
          ']\n$_fence\nAnything else?';
      expect(AiImportService.validateShoppingList(pasted), isNull);
      expect(AiImportService.parseShoppingList(pasted).map((item) => (item['name'], item['amount'], item['category'])), [
        ('milk', '1', 'dairy'),
        ('eggs, [large]', '6', 'other'),
      ]);
      expect(AiImportService.validateShoppingList('{"items":[{"name":"salt"}]}'), isNull);
      expect(AiImportService.validateShoppingList('["milk"]'), 'Item #1 is not a valid object.');
      expect(AiImportService.validateShoppingList('[{"name":"milk"},{"name":"eg'), startsWith('Invalid JSON'));
      expect(AiImportService.validateShoppingList('no list here'), startsWith('Invalid JSON'));
      // A list is not held to what a recipe needs.
      expect(AiImportService.validateShoppingList('I left out the "title": "Groceries".\n[{"name":"milk"}]'), isNull);
    });
  });

  group('saving', () {
    late AppDatabase db;
    late _WriteCounter writes;

    setUp(() {
      writes = _WriteCounter();
      db = AppDatabase.forTesting(NativeDatabase.memory().interceptWith(writes));
    });
    tearDown(() => db.close());

    Future<List<String>> import(Object? pasted) =>
        AiImportService.importAllFromJson(pasted is String ? pasted : jsonEncode(pasted), db, cookbookId: 'starter');

    Future<Recipe> load(String id) => (db.select(db.recipes)..where((t) => t.id.equals(id))).getSingle();

    Future<List<Ingredient>> ingredientsOf(String id) => (db.select(db.ingredients)
          ..where((t) => t.recipeId.equals(id))
          ..orderBy([(t) => drift.OrderingTerm(expression: t.sortOrder)]))
        .get();

    Future<List<Step>> stepsOf(String id) => (db.select(db.steps)
          ..where((t) => t.recipeId.equals(id))
          ..orderBy([(t) => drift.OrderingTerm(expression: t.sortOrder)]))
        .get();

    Future<List<Tag>> tagsOf(String id) => db.tagsDao.getTagsForRecipe(id);

    /// The ingredient names of the recipe each of [id]'s links points to.
    Future<List<List<String>>> linkedIngredients(String id) async {
      final links = await (db.select(db.recipeLinks)..where((t) => t.sourceRecipeId.equals(id))).get();
      return [
        for (final link in links) [for (final i in await ingredientsOf(link.linkedRecipeId)) i.name],
      ];
    }

    /// Makes any step whose text is [instruction] fail to save.
    Future<void> failOnStep(String instruction) => db.customStatement(
          "CREATE TRIGGER fail_step BEFORE INSERT ON steps WHEN NEW.instruction = '$instruction' "
          "BEGIN SELECT RAISE(ABORT, 'boom'); END;",
        );

    test('a documented recipe is saved with every field', () async {
      final id = (await import({
        'title': '  Baked Ziti ',
        'description': 'Weeknight pasta bake',
        'servings': '4',
        'prepTimeMinutes': 15,
        'cookTimeMinutes': 30,
        'course': 'Main Dish',
        'category': 'Pasta',
        'sourceUrl': 'https://example.com/ziti',
        'notes': 'Freezes well.',
        'ingredients': [
          {'amount': null, 'unit': null, 'name': 'For the sauce', 'notes': '__header__'},
          {'amount': '2', 'unit': 'cups', 'name': ' crushed tomatoes ', 'notes': 'drained'},
        ],
        'steps': [
          {'instruction': 'For the sauce', 'notes': '__header__'},
          {'instruction': ' Simmer the 2 cups crushed tomatoes. ', 'durationMinutes': 20},
        ],
      }))
          .single;
      expect(id, startsWith('ai_'));

      final r = await load(id);
      expect(r.cookbookId, 'starter');
      expect(r.title, 'Baked Ziti');
      expect(r.description, 'Weeknight pasta bake');
      expect(r.servings, '4');
      expect(r.prepTimeMinutes, 15);
      expect(r.cookTimeMinutes, 30);
      expect(r.courseId, 'main');
      expect(r.categoryId, 'pasta');
      expect(r.sourceUrl, 'https://example.com/ziti');
      expect(r.notes, 'Freezes well.');

      final ings = await ingredientsOf(id);
      expect(ings.map((i) => (i.sortOrder, i.amount, i.unit, i.name, i.notes)), [
        (0, null, null, 'For the sauce', '__header__'),
        (1, '2', 'cups', 'crushed tomatoes', 'drained'),
      ]);
      final steps = await stepsOf(id);
      expect(steps.map((s) => (s.sortOrder, s.instruction, s.durationMinutes, s.notes)), [
        (0, 'For the sauce', null, '__header__'),
        (1, 'Simmer the 2 cups crushed tomatoes.', 20, null),
      ]);
    });

    test('loosely typed fields are stored as what they mean', () async {
      final id = (await import({
        'title': 'Baked Ziti',
        'servings': 6,
        'prepTimeMinutes': '20',
        'course': ['Main Dish'],
        'category': ['Pasta', 'Casserole'],
        'ingredients': [
          {'amount': 1, 'unit': 'lb', 'name': 'ziti'},
          {'amount': 0.5, 'name': 'onion'},
          {'amount': 2.0, 'name': 'eggs'},
        ],
        'steps': [
          {'instruction': 'Bake.', 'notes': ['flip once', 'medium heat']},
        ],
      }))
          .single;
      final r = await load(id);
      expect(r.servings, '6');
      expect(r.prepTimeMinutes, 20);
      expect(r.courseId, 'main');
      expect(r.categoryId, 'pasta,casserole');
      expect((await ingredientsOf(id)).map((i) => i.amount), ['1', '0.5', '2']);
      expect(await stepsOf(id), hasLength(1));
    });

    test('an ingredient name too long for the table keeps its text', () async {
      const chicken = 'boneless skinless chicken thighs, trimmed of excess fat and cut into 1-inch pieces '
          '(you can substitute chicken breast, but reduce the cooking time by about 5 minutes so it does not dry out; '
          'turkey thigh also works well here and is what my grandmother always used)';
      final exactly200 = 'y' * 200;
      final ids = await import([
        _recipe('One'),
        _recipe('Two'),
        _recipe('Three', ingredients: [
          {'amount': '1', 'unit': 'tbsp', 'name': 'olive oil'},
          {'amount': '2', 'unit': 'lb', 'name': chicken},
          {'name': chicken, 'notes': 'patted dry'},
          {'name': 'x' * 201},
          {'name': exactly200, 'notes': 'kept'},
          {'name': 'z' * 250, 'notes': '__header__'},
          {'name': '${'w' * 198}😀${'v' * 10}'},
        ]),
        _recipe('Four'),
      ]);
      expect(ids, hasLength(4));
      expect((await db.select(db.recipes).get()).map((r) => r.title), ['One', 'Two', 'Three', 'Four']);

      final ings = await ingredientsOf(ids[2]);
      expect(ings, hasLength(7));
      expect(ings.every((i) => i.name.length <= 200), isTrue);

      const rest = 'trimmed of excess fat and cut into 1-inch pieces '
          '(you can substitute chicken breast, but reduce the cooking time by about 5 minutes so it does not dry out; '
          'turkey thigh also works well here and is what my grandmother always used)';
      expect(ings[1].name, 'boneless skinless chicken thighs');
      expect(ings[1].notes, rest);
      expect(ings[1].amount, '2');
      expect(ings[2].notes, '$rest; patted dry');

      // No comma or bracket to cut at: shortened, with the whole text in the notes.
      expect(ings[3].name, hasLength(200));
      expect(ings[3].name, endsWith('…'));
      expect(ings[3].notes, 'x' * 201);

      expect(ings[4].name, exactly200);
      expect(ings[4].notes, 'kept');

      // A section heading stays a heading.
      expect(ings[5].name, hasLength(200));
      expect(ings[5].notes, '__header__');

      // An emoji where the cut falls is left out whole, not cut in half.
      expect(ings[6].name, '${'w' * 198}…');
      expect(ings[6].notes, '${'w' * 198}😀${'v' * 10}');
    });

    test('a failure part way leaves nothing behind, and a retry adds nothing', () async {
      final tagsBefore = (await db.select(db.tags).get()).length;
      await failOnStep('Stew.');
      final pasted = jsonEncode([
        _recipe('One', extra: {
          'cuisine': 'Peruvian',
          'tags': ['date night'],
        }),
        jsonDecode(_bravo),
        _recipe('Three'),
      ]);
      expect(AiImportService.validate(pasted), isNull);

      for (var attempt = 0; attempt < 2; attempt++) {
        await expectLater(import(pasted), throwsA(anything));
        expect(await db.select(db.recipes).get(), isEmpty);
        expect(await db.select(db.ingredients).get(), isEmpty);
        expect(await db.select(db.steps).get(), isEmpty);
        expect(await db.select(db.recipeTags).get(), isEmpty);
        expect(await db.select(db.tags).get(), hasLength(tagsBefore));
      }
    });

    test('an answer that is not a complete recipe is refused before anything is written', () async {
      for (final pasted in [
        '[]',
        'hello world',
        '{"title":"No steps","ingredients":[{"name":"x"}]}',
        '[$_alpha,{"title":"No name","ingredients":[{}],"steps":[{"instruction":"y"}]}]',
        '[$_alpha,\n{"title":"Bravo Stew","ingredients":[{"name":"car',
      ]) {
        await expectLater(import(pasted), throwsFormatException, reason: pasted);
        expect(await db.select(db.recipes).get(), isEmpty, reason: pasted);
      }
    });

    test('asked for a single recipe, only the first of the answer is saved', () async {
      final id = await AiImportService.importFromJson('[$_alpha,$_bravo]', db, cookbookId: 'starter');
      expect((await db.select(db.recipes).get()).map((r) => (r.id, r.title)), [(id, 'Alpha Soup')]);
      await expectLater(AiImportService.importFromJson('[]', db, cookbookId: 'starter'), throwsFormatException);
    });

    test('saving into a cookbook that is not there is refused', () async {
      await expectLater(
        AiImportService.importAllFromJson(_alpha, db, cookbookId: 'cookbook_deleted'),
        throwsArgumentError,
      );
      expect(await db.select(db.recipes).get(), isEmpty);
    });

    test('whatever the types, an answer is refused in a sentence or it imports', () async {
      const odd = <Object?>[null, 1, 2.5, true, 'x', '', <Object?>[], <String, Object?>{}, ['a'], [1], [null], {'a': 1}];
      Map<String, dynamic> full() => {
            'title': 'T',
            'description': 'd',
            'servings': '4',
            'prepTimeMinutes': 5,
            'cookTimeMinutes': 6,
            'course': 'Main Dish',
            'category': 'Pasta',
            'cuisine': 'Italian',
            'tags': ['quick'],
            'rating': 4,
            'sourceUrl': 'https://example.com',
            'notes': 'n',
            'ingredients': <Object?>[
              <String, Object?>{'amount': '1', 'unit': 'cup', 'name': 'flour', 'notes': 'sifted'},
            ],
            'steps': <Object?>[
              <String, Object?>{'instruction': 'Mix.', 'durationMinutes': 5, 'notes': null},
            ],
          };
      final mutations = <String, void Function(Map<String, dynamic>, Object?)>{
        for (final key in full().keys) key: (r, v) => r[key] = v,
        for (final key in ['amount', 'unit', 'name', 'notes']) 'ingredient $key': (r, v) => r['ingredients'][0][key] = v,
        for (final key in ['instruction', 'durationMinutes', 'notes']) 'step $key': (r, v) => r['steps'][0][key] = v,
        'ingredient': (r, v) => r['ingredients'][0] = v,
        'step': (r, v) => r['steps'][0] = v,
      };
      var imported = 0;
      for (final mutation in mutations.entries) {
        for (final value in odd) {
          final recipe = full();
          mutation.value(recipe, value);
          for (final pasted in [
            jsonEncode(recipe),
            jsonEncode({
              'recipes': [recipe, full()],
              'links': {'flour': value},
            }),
            jsonEncode({'recipes': value, 'links': value}),
          ]) {
            final reason = '${mutation.key} = ${jsonEncode(value)} in $pasted';
            final verdict = AiImportService.validate(pasted);
            expect(verdict ?? '', isNot(startsWith('Error parsing recipe')), reason: reason);
            expect(() => AiImportService.extractRecipes(pasted), returnsNormally, reason: reason);
            if (verdict == null) {
              expect(await import(pasted), isNotEmpty, reason: reason);
              imported++;
            } else {
              await expectLater(import(pasted), throwsFormatException, reason: reason);
            }
          }
        }
      }
      expect(imported, greaterThan(100));
    });

    test('tags and the cuisine are kept as tags, reusing the ones that exist', () async {
      final ziti = (await import({
        'title': 'Baked Ziti',
        'servings': '4',
        'course': 'Main Dish',
        'category': 'Pasta',
        'cuisine': 'Italian',
        'tags': ['quick', 'weeknight', 'comfort food'],
        'ingredients': [
          {'amount': '2', 'unit': 'cups', 'name': 'all-purpose flour', 'notes': 'sifted'},
        ],
        'steps': [
          {'instruction': 'Bake at 375F for 30 minutes.', 'durationMinutes': 30},
        ],
      }))
          .single;
      final zitiTags = await tagsOf(ziti);
      expect(zitiTags.map((t) => t.id), containsAll(['tag_quick', 'tag_weeknight', 'tag_comfort']));
      expect(zitiTags.map((t) => t.name), contains('Italian'));
      expect(zitiTags, hasLength(4));

      // A second recipe finds the tag the first one made, however it is written.
      final lasagna = (await import(_recipe('Lasagna', extra: {
        'cuisine': 'italian',
        'tags': ['Gluten Free', 'SPICY', 'date night', 'kid-friendly'],
      })))
          .single;
      final lasagnaTags = await tagsOf(lasagna);
      expect(lasagnaTags.map((t) => t.id), containsAll(['tag_gluten_free', 'tag_spicy', 'tag_kid']));
      expect(lasagnaTags.map((t) => t.name), containsAll(['Italian', 'Date Night']));
      expect(lasagnaTags, hasLength(5));

      final all = await db.select(db.tags).get();
      expect(all.where((t) => t.name.toLowerCase() == 'italian'), hasLength(1));
      expect(all.where((t) => !t.isBuiltIn).map((t) => t.name), unorderedEquals(['Italian', 'Date Night']));
    });

    test('tags that are not a tidy list are taken for what they hold', () async {
      Future<List<String>> names(Object? tags, {Object? cuisine}) async {
        final id = (await import(_recipe('T', extra: {'tags': tags, 'cuisine': cuisine}))).single;
        return [for (final t in await tagsOf(id)) t.name];
      }

      expect(await names('quick'), ['Quick & Easy']);
      expect(await names('spicy, vegan ,  '), unorderedEquals(['Spicy', 'Vegan']));
      // Semicolons and line breaks part tags as commas do, in a list as well.
      expect(await names('quick; spicy; vegan'), unorderedEquals(['Quick & Easy', 'Spicy', 'Vegan']));
      expect(await names('spicy\nvegan\r\nparty'), unorderedEquals(['Spicy', 'Vegan', 'Party']));
      expect(await names(['spicy, vegan', 'date night; party']), unorderedEquals(['Spicy', 'Vegan', 'Date Night', 'Party']));
      expect(await names('辣，素食、快手菜；下饭'), unorderedEquals(['辣', '素食', '快手菜', '下饭']));
      expect(await names(null, cuisine: 'Thai, Vietnamese'), unorderedEquals(['Thai', 'Vietnamese']));
      expect(await names(['spicy', 'Spicy', ' spicy ', 3, null, ['vegan'], '', '   ']), ['Spicy']);
      expect(await names(7), isEmpty);
      expect(await names(null, cuisine: ['Thai']), ['Thai']);
      // Too long to be a tag: left out, and no more than eight are taken.
      expect(await names(['a sentence that is far too long to be a tag']), isEmpty);
      expect(await names(['辣' * 200000, 'spicy']), ['Spicy']);
      expect(await names([for (var i = 0; i < 12; i++) 'made up $i'], cuisine: 'Greek'), hasLength(8));
    });

    test('a tag that was removed is not brought back by its name', () async {
      await (db.update(db.tags)..where((t) => t.id.equals('tag_spicy')))
          .write(TagsCompanion(deletedAt: drift.Value(DateTime(2026))));
      final id = (await import(_recipe('T', extra: {
        'tags': ['spicy'],
      })))
          .single;
      final tag = (await tagsOf(id)).single;
      expect(tag.id, isNot('tag_spicy'));
      expect(tag.name, 'Spicy');
    });

    test('each linked set links to its own sub-recipe when titles repeat', () async {
      final ids = await import([
        {
          'recipes': [
            _recipe('Chocolate Cake', ingredients: [
              {'amount': '1', 'unit': 'cup', 'name': 'flour'},
              {'amount': '1', 'unit': 'cup', 'name': 'cocoa powder'},
              {'amount': '1', 'unit': 'cup', 'name': 'Frosting'},
            ]),
            _recipe('Frosting', ingredients: [
              {'name': 'butter'},
              {'name': 'cocoa powder'},
              {'name': 'powdered sugar'},
            ]),
          ],
          'links': {
            'Frosting': ['Frosting'],
          },
        },
        {
          'recipes': [
            _recipe('Carrot Cake', ingredients: [
              {'name': 'flour'},
              {'name': 'grated carrots'},
              {'name': 'Frosting'},
            ]),
            _recipe('Frosting', ingredients: [
              {'name': 'cream cheese'},
              {'name': 'butter'},
              {'name': 'powdered sugar'},
            ]),
          ],
          'links': {
            'Frosting': ['Frosting'],
          },
        },
      ]);
      expect(ids, hasLength(4));
      expect(await linkedIngredients(ids[0]), [
        ['butter', 'cocoa powder', 'powdered sugar'],
      ]);
      expect(await linkedIngredients(ids[2]), [
        ['cream cheese', 'butter', 'powdered sugar'],
      ]);
      expect(await db.select(db.recipeLinks).get(), hasLength(2));

      // The link hangs on the ingredient it was written for.
      final link = (await (db.select(db.recipeLinks)..where((t) => t.sourceRecipeId.equals(ids[0]))).get()).single;
      expect(link.ingredientId, (await ingredientsOf(ids[0]))[2].id);
    });

    test('a single linked set links each ingredient once', () async {
      final ids = await import({
        'recipes': [
          _recipe('Cream Pie', ingredients: [
            {'amount': '1', 'name': 'Pie Crust'},
            {'amount': '2', 'unit': 'cups', 'name': 'Pastry Cream'},
          ]),
          _recipe('Pastry Cream', ingredients: [
            {'name': 'milk'},
          ]),
          _recipe('Pie Crust', ingredients: [
            {'name': 'flour'},
          ]),
        ],
        'links': {
          'Pastry Cream': ['Pastry Cream'],
          'Pie Crust': ['Pie Crust'],
        },
      });
      expect(await linkedIngredients(ids[0]), unorderedEquals([
        ['milk'],
        ['flour'],
      ]));
      expect(await linkedIngredients(ids[1]), isEmpty);
    });

    test('with only, just those recipes are saved, and a link to one left out is dropped', () async {
      final ids = await AiImportService.importAllFromJson(
        jsonEncode({
          'recipes': [
            _recipe('Cream Pie', ingredients: [
              {'amount': '1', 'name': 'Pie Crust'},
              {'amount': '2', 'unit': 'cups', 'name': 'Pastry Cream'},
            ]),
            _recipe('Pastry Cream', ingredients: [
              {'name': 'milk'},
            ]),
            _recipe('Pie Crust', ingredients: [
              {'name': 'flour'},
            ]),
          ],
          'links': {
            'Pastry Cream': ['Pastry Cream'],
            'Pie Crust': ['Pie Crust'],
          },
        }),
        db,
        cookbookId: 'starter',
        only: {0, 2},
      );
      expect(ids, hasLength(2));
      expect([for (final id in ids) (await load(id)).title], ['Cream Pie', 'Pie Crust']);
      expect(await linkedIngredients(ids[0]), [
        ['flour'],
      ]);
      expect((await db.select(db.recipes).get()).where((r) => r.title == 'Pastry Cream'), isEmpty);
    });

    test('a link still reaches a recipe elsewhere in the paste, whatever the letter case', () async {
      final ids = await import([
        _recipe('Pie Crust', ingredients: [
          {'name': 'flour'},
        ]),
        {
          'recipes': [
            _recipe('Apple Pie', ingredients: [
              {'name': 'apples'},
              {'name': 'pie crust '},
            ]),
          ],
          'links': {'Pie Crust': ' pie crust', 'apples': 'Apple Pie', 'sugar': 'Pie Crust', 'pie crust ': 'Nowhere'},
        },
      ]);
      expect(await linkedIngredients(ids[1]), [
        ['flour'],
      ]);
      // A recipe is never linked to itself.
      expect(await db.select(db.recipeLinks).get(), hasLength(1));
    });

    test('only a recipe imported on its own counts as just opened', () async {
      final single = await import(_alpha);
      expect((await load(single.single)).lastViewedAt, isNotNull);

      final many = await import([for (var i = 0; i < 12; i++) _recipe('Bulk $i')]);
      for (final id in many) {
        expect((await load(id)).lastViewedAt, isNull);
      }
      final recent = await db.recipeDao.watchRecentlyViewedRecipes().first;
      expect(recent.map((r) => r.title), ['Alpha Soup']);
    });

    test('a large answer is saved in one transaction, not row by row', () async {
      // Opening the database seeds it; only the import is counted.
      await db.select(db.cookbooks).get();
      writes.reset();

      final ids = await import([
        for (var i = 0; i < 400; i++)
          _recipe('Recipe $i', ingredients: [
            for (var k = 0; k < 8; k++) {'amount': '$k', 'unit': 'g', 'name': 'ingredient $k'},
          ], steps: [
            for (var k = 0; k < 5; k++) {'instruction': 'Step $k.'},
          ], extra: {
            'tags': ['made up ${i % 7}'],
          }),
      ]);
      expect(ids.toSet(), hasLength(400));
      expect(await db.select(db.ingredients).get(), hasLength(3200));
      expect(await db.select(db.steps).get(), hasLength(2000));
      expect((await db.select(db.tags).get()).where((t) => !t.isBuiltIn), hasLength(7));

      // With a trip of its own for every row, 100 recipes took ten seconds.
      expect(writes.commits, 1);
      expect(writes.batches, 1);
      expect(writes.inserts, 0);
    });
  });
}

/// Counts how the import talks to the database.
class _WriteCounter extends drift.QueryInterceptor {
  int commits = 0;
  int batches = 0;
  int inserts = 0;

  void reset() => commits = batches = inserts = 0;

  @override
  Future<void> commitTransaction(drift.TransactionExecutor inner) {
    commits++;
    return inner.send();
  }

  @override
  Future<void> runBatched(drift.QueryExecutor executor, drift.BatchedStatements statements) {
    batches++;
    return executor.runBatched(statements);
  }

  @override
  Future<int> runInsert(drift.QueryExecutor executor, String statement, List<Object?> args) {
    inserts++;
    return executor.runInsert(statement, args);
  }
}
