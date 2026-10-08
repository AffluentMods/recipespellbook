// Importing from pages that publish no recipe data: a hand-written blog post
// is read from its headings and lists, and a recipe kept as a text file or
// answered as JSON is read as what it is.
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:recipespellbook/services/recipe_import_engine.dart';

import 'web_import_helpers.dart';

/// A blog post with everything a real one has around the recipe: a skip
/// link, a menu, a footer and an inline script.
String bananaBreadPost({String contentClass = 'post-content'}) => '''<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>Grandma's Banana Bread - The Cozy Whisk</title>
<meta property="og:title" content="Grandma's Banana Bread">
<meta property="og:image" content="https://cozywhisk.example/uploads/banana-bread.jpg">
<style>.menu li{display:inline-block}</style>
</head>
<body>
<a class="skip-link" href="#content">Skip to content</a>
<header><div class="site-title">The Cozy Whisk</div>
<nav><ul class="menu"><li><a href="/">Home</a></li><li><a href="/recipes/">Recipes</a></li><li><a href="/about/">About</a></li></ul></nav>
</header>
<article>
<h1 class="entry-title">Grandma's Banana Bread</h1>
<div class="$contentClass">
<p>This banana bread has been in our family for three generations. It is moist, sweet and so simple to throw together.</p>
<h2>Ingredients</h2>
<ul>
<li>3 ripe bananas, mashed</li>
<li>1/3 cup melted butter</li>
<li>3/4 cup sugar</li>
<li>1 egg, beaten</li>
<li>1 teaspoon vanilla extract</li>
<li>1 teaspoon baking soda</li>
<li>1 1/2 cups all-purpose flour</li>
</ul>
<h2>Instructions</h2>
<ol>
<li>Preheat the oven to 350°F and butter a 4x8 inch loaf pan.</li>
<li>Stir the melted butter into the mashed bananas.</li>
<li>Mix in the sugar, egg, vanilla and baking soda, then the flour.</li>
<li>Pour the batter into the loaf pan and bake until a skewer comes out clean.</li>
<li>Cool on a rack before slicing.</li>
</ol>
</div>
</article>
<footer><p>© 2025 The Cozy Whisk. All rights reserved.</p></footer>
<script>(function(){var a=document.querySelectorAll('.menu li');for(var i=0;i<a.length;i++){a[i].addEventListener('click',function(){console.log('nav');});}})();</script>
</body>
</html>''';

const bananaIngredients = [
  '3 ripe bananas, mashed',
  '1/3 cup melted butter',
  '3/4 cup sugar',
  '1 egg, beaten',
  '1 teaspoon vanilla extract',
  '1 teaspoon baking soda',
  '1 1/2 cups all-purpose flour',
];

const bananaSteps = [
  'Preheat the oven to 350°F and butter a 4x8 inch loaf pan.',
  'Stir the melted butter into the mashed bananas.',
  'Mix in the sugar, egg, vanilla and baking soda, then the flour.',
  'Pour the batter into the loaf pan and bake until a skewer comes out clean.',
  'Cool on a rack before slicing.',
];

void main() {
  group('a post without recipe markup', () {
    test('is read from its headings and lists, without the page around it', () async {
      final recipe = await importPage('https://cozywhisk.example/banana-bread/', bananaBreadPost());

      expect(recipe.title, "Grandma's Banana Bread");
      expect(recipe.ingredients, bananaIngredients);
      expect(recipe.instructions, bananaSteps);
      expect(recipe.description, startsWith('This banana bread has been in our family'));
      expect(recipe.imageUrl, 'https://cozywhisk.example/uploads/banana-bread.jpg');
    });

    test('reads the same when the page has no whitespace between its tags', () async {
      final recipe = await importPage('https://cozywhisk.example/banana-bread/', minified(bananaBreadPost()));

      expect(recipe.title, "Grandma's Banana Bread");
      expect(recipe.ingredients, bananaIngredients);
      expect(recipe.instructions, bananaSteps);
      expect(recipe.description, startsWith('This banana bread has been in our family'));
    });

    test('steps written as paragraphs are read, a list of related posts is not', () async {
      final recipe = await importPage('https://cozywhisk.example/banana-bread/', '''<!DOCTYPE html>
<html><head><title>Grandma's Banana Bread - The Cozy Whisk</title></head><body>
<article><h1 class="entry-title">Grandma's Banana Bread</h1>
<div class="entry-content">
<p>This banana bread has been in our family for three generations, and it never lasts a day.</p>
<h2>Ingredients</h2>
<ul>${bananaIngredients.map((i) => '<li>$i</li>').join()}</ul>
<h2>Instructions</h2>
${bananaSteps.map((s) => '<p>$s</p>').join('\n')}
<h3>You might also like</h3>
<ul><li><a href="/zucchini-bread/">Zucchini Bread</a></li><li><a href="/pumpkin-muffins/">Pumpkin Muffins</a></li></ul>
</div></article></body></html>''');

      expect(recipe.title, "Grandma's Banana Bread");
      expect(recipe.ingredients, bananaIngredients);
      expect(recipe.instructions, bananaSteps);
    });

    test('a post whose two lists are the recipe is read from the lists', () async {
      // No headings at all: the bullet list is the ingredients, the numbered
      // list the method.
      final recipe = await importPage('https://cozywhisk.example/banana-bread/', '''<!DOCTYPE html>
<html><head><title>Banana Bread</title></head><body><h1>Banana Bread</h1>
<div class="entry-content">
<ul>${bananaIngredients.map((i) => '<li>$i</li>').join()}</ul>
<ol>${bananaSteps.map((s) => '<li>$s</li>').join()}</ol>
<ul><li><a href="/zucchini-bread/">Zucchini Bread</a></li><li><a href="/pumpkin-muffins/">Pumpkin Muffins</a></li></ul>
</div></body></html>''');

      expect(recipe.title, 'Banana Bread');
      expect(recipe.ingredients, bananaIngredients);
      expect(recipe.instructions, bananaSteps);
    });

    test('lists that count their ingredients without units are still the recipe', () async {
      final recipe = await importPage('https://blog.example/tortilla', '''<!DOCTYPE html>
<html><head><title>Spanish Tortilla</title></head><body>
<article><h1 class="entry-title">Spanish Tortilla</h1><div class="entry-content">
<p>The only tortilla you will ever need, straight from my neighbour in Seville who makes it every Sunday.</p>
<ul><li>6 eggs</li><li>4 potatoes, thinly sliced</li><li>1 onion</li><li>Olive oil</li><li>Salt</li></ul>
<ol><li>Fry the potatoes and the onion gently in plenty of olive oil.</li><li>Beat the eggs, stir in the potatoes and season.</li><li>Fry in a small pan, turning once, until just set.</li></ol>
</div></article></body></html>''');

      expect(recipe.title, 'Spanish Tortilla');
      expect(recipe.ingredients, ['6 eggs', '4 potatoes, thinly sliced', '1 onion', 'Olive oil', 'Salt']);
      expect(recipe.instructions, hasLength(3));
    });

    test('headed ingredients without units are a recipe, with or without a method heading', () async {
      for (final methodHeading in ['<h2>Method</h2>', '']) {
        final recipe = await importPage('https://blog.example/omelette', '''<!DOCTYPE html>
<html><head><title>Omelette</title></head><body><article><h1>Omelette</h1>
<h2>Ingredients</h2><ul><li>3 eggs</li><li>1 knob of butter</li><li>Salt and pepper</li></ul>
$methodHeading
<p>Beat the eggs with a fork until the whites and the yolks are just combined.</p>
<p>Melt the butter in a pan, pour in the eggs and stir until they begin to set.</p>
</article></body></html>''');

        expect(recipe.title, 'Omelette', reason: methodHeading);
        expect(recipe.ingredients, ['3 eggs', '1 knob of butter', 'Salt and pepper'], reason: methodHeading);
        expect(
          recipe.instructions,
          [
            'Beat the eggs with a fork until the whites and the yolks are just combined.',
            'Melt the butter in a pan, pour in the eggs and stir until they begin to set.',
          ],
          reason: methodHeading,
        );
      }
    });

    test('a page wrapped in a form is still read', () async {
      // Old ASP.NET sites put the whole page inside one form.
      final recipe = await importPage('https://stmarycookbook.example/recipe.aspx?id=412', '''<!DOCTYPE html>
<html><head><title>Church Cookbook - Chicken Casserole</title></head><body>
<form name="aspnetForm" method="post" action="recipe.aspx?id=412" id="aspnetForm">
<div><input type="hidden" name="__VIEWSTATE" id="__VIEWSTATE" value="/wEPDwUKMTY1NDU2MTA1Mg9kFgJmD2QWAgIDD2QWAgIBD2QW" /></div>
<div id="header"><a href="default.aspx">Home</a> | <a href="browse.aspx">Browse</a> | <a href="search.aspx">Search</a></div>
<div id="content">
<h1><span id="ctl00_Main_lblTitle">Chicken Casserole</span></h1>
<p>Submitted by Mary Ann, a potluck favourite at our parish for many years.</p>
<h3>Ingredients</h3>
<ul><li>4 cups cooked chicken, cubed</li><li>1 can cream of mushroom soup</li><li>1 cup sour cream</li><li>2 cups crushed crackers</li><li>1/2 cup butter, melted</li></ul>
<h3>Directions</h3>
<ol><li>Combine the chicken, soup and sour cream in a baking dish.</li><li>Mix the crackers with the melted butter and sprinkle over the top.</li><li>Bake at 350 degrees until bubbly.</li></ol>
</div>
<div id="footer">Copyright 2009 St. Mary Parish</div>
</form></body></html>''');

      expect(recipe.title, 'Chicken Casserole');
      expect(recipe.ingredients, hasLength(5));
      expect(recipe.instructions, [
        'Combine the chicken, soup and sour cream in a baking dish.',
        'Mix the crackers with the melted butter and sprinkle over the top.',
        'Bake at 350 degrees until bubbly.',
      ]);
    });

    test('lines separated only by line breaks are read one by one', () async {
      // The way older Blogger posts are written: no lists, no paragraphs.
      final recipe = await importPage('https://oldblog.example/2011/05/biscuits.html', '''<html>
<head><title>My Kitchen: Buttermilk Biscuits</title></head><body>
<h1 class="title">My Kitchen</h1>
<div class="post hentry"><h3 class="post-title entry-title">Buttermilk Biscuits</h3>
<div class="post-body entry-content">These biscuits are my grandmother's and they never fail me on a Sunday morning.<br /><br />
<b>What you need:</b><br />2 cups flour<br />1 tbsp baking powder<br />1/2 cup butter<br /><br />
<b>Directions:</b><br />Cut the butter into the flour and baking powder.<br />Stir in the buttermilk until just combined.<br /><br />Enjoy!
</div>
<div class="post-footer">Posted by Ann at 9:41 AM</div></div>
</body></html>''');

      // The post's own title, not the name of the blog above it.
      expect(recipe.title, 'Buttermilk Biscuits');
      expect(recipe.ingredients, ['2 cups flour', '1 tbsp baking powder', '1/2 cup butter']);
      expect(recipe.instructions, [
        'Cut the butter into the flour and baking powder.',
        'Stir in the buttermilk until just combined.',
      ]);
      expect(recipe.description, startsWith('These biscuits are my grandmother'));
    });

    test('a bar of links, a copyright line and the nutrition box are not steps', () async {
      final recipe = await importPage('https://old.example/chili.htm', '''<html>
<head><title>Aunt May's Chili</title></head><body>
<table width="600"><tr><td><b>Aunt May's Chili</b></td></tr>
<tr><td><b>Ingredients</b><br>1 lb ground beef<br>1 can kidney beans<br>2 tbsp chili powder<br></td></tr>
<tr><td><b>Instructions</b><br>Brown the beef in a heavy pot.<br>Add the beans and the chili powder and simmer gently.<br></td></tr>
<tr><td><a href="index.htm">Back to recipes</a> | <a href="mailto:may@example.com">Email me</a></td></tr>
<tr><td>Copyright 2003 May Parker. All rights reserved.</td></tr>
<tr><td><b>Nutrition</b><br>Calories: 320 per serving</td></tr></table>
</body></html>''');

      expect(recipe.ingredients, ['1 lb ground beef', '1 can kidney beans', '2 tbsp chili powder']);
      expect(recipe.instructions, [
        'Brown the beef in a heavy pot.',
        'Add the beans and the chili powder and simmer gently.',
      ]);
    });

    test('ingredients in a table keep a space between the cells', () async {
      final recipe = await importPage('https://oma.example/apfelkuchen', '''<!DOCTYPE html>
<html><head><title>Oma's Apfelkuchen</title></head><body><div id="page"><h1>Oma's Apfelkuchen</h1>
<h2>Ingredients</h2>
<table><tr><td>250 g</td><td>flour</td></tr><tr><td>125 g</td><td>butter</td></tr><tr><td>3</td><td>apples, peeled and sliced</td></tr><tr><td>2 tbsp</td><td>sugar</td></tr></table>
<h2>Method</h2>
<p>Rub the butter into the flour and press the dough into a tin.</p><p>Arrange the apples on top and sprinkle with sugar.</p><p>Bake until golden.</p>
</div></body></html>''');

      expect(recipe.ingredients, ['250 g flour', '125 g butter', '3 apples, peeled and sliced', '2 tbsp sugar']);
      expect(recipe.instructions, hasLength(3));
    });

    test('teasers before the post and comments after it are left out', () async {
      final recipe = await importPage('https://dailytable.example/lentil-soup', '''<!DOCTYPE html>
<html><head><title>Lentil Soup | Daily Table</title><meta property="og:title" content="Lentil Soup"></head><body>
<section class="trending"><article class="teaser"><a href="/best-brownies/">The brownies everyone is baking this week</a></article><article class="teaser"><a href="/sheet-pan/">12 sheet pan dinners</a></article></section>
<main><article class="story"><h1>Lentil Soup</h1>
<p>A pot of this soup has saved more weeknights than we can count.</p>
<h2>Ingredients</h2>
<ul><li>2 cups brown lentils</li><li>1 onion, diced</li><li>2 carrots, diced</li><li>6 cups vegetable stock</li></ul>
<h2>Preparation</h2>
<ol><li>Soften the onion and carrots in a little oil.</li><li>Add the lentils and stock and simmer until tender.</li><li>Season with salt and a squeeze of lemon.</li></ol>
<h2>You might also like</h2>
<ul><li><a href="/minestrone/">A really good minestrone for cold days</a></li></ul>
</article>
<div id="comments"><h3>14 Comments</h3><ol class="comment-list"><li><article class="comment-body"><p>I added 2 cups of spinach at the end and it was great!</p></article></li><li><article class="comment-body"><p>Leave it on the stove longer if you like it thick.</p></article></li></ol></div>
</main></body></html>''');

      expect(recipe.title, 'Lentil Soup');
      expect(recipe.ingredients, ['2 cups brown lentils', '1 onion, diced', '2 carrots, diced', '6 cups vegetable stock']);
      expect(recipe.instructions, [
        'Soften the onion and carrots in a little oil.',
        'Add the lentils and stock and simmer until tender.',
        'Season with salt and a squeeze of lemon.',
      ]);
      expect(recipe.description, 'A pot of this soup has saved more weeknights than we can count.');
    });

    test('a table of contents does not stand in for the recipe headings', () async {
      final recipe = await importPage('https://x.example/flatbread', '''<!DOCTYPE html>
<html><head><title>Flatbread</title></head><body><article><h1>Flatbread</h1>
<ul class="toc"><li><a href="#ingredients">Ingredients</a></li><li><a href="#instructions">Instructions</a></li><li><a href="#notes">Notes</a></li></ul>
<p>Soft flatbread that needs no yeast and no waiting, ready before the curry is.</p>
<h2 id="ingredients">Ingredients</h2>
<ul><li>2 cups flour</li><li>1 cup yogurt</li><li>1 tsp salt</li></ul>
<h2 id="instructions">Instructions</h2>
<ol><li>Knead everything into a soft dough.</li><li>Roll out and fry in a dry pan until blistered.</li></ol>
<h2 id="notes">Notes</h2>
<p>The dough keeps in the fridge until the next day.</p>
</article></body></html>''');

      expect(recipe.ingredients, ['2 cups flour', '1 cup yogurt', '1 tsp salt']);
      expect(recipe.instructions, ['Knead everything into a soft dough.', 'Roll out and fry in a dry pan until blistered.']);
      expect(recipe.notes, 'The dough keeps in the fridge until the next day.');
      expect(recipe.description, startsWith('Soft flatbread that needs no yeast'));
    });

    test('headings worded in other ways still divide the recipe', () async {
      final recipe = await importPage('https://x.example/flatbread', '''<!DOCTYPE html>
<html><head><title>Flatbread</title></head><body><article><h1>Flatbread</h1>
<h2>Ingredients for four flatbreads</h2>
<ul><li>2 cups flour</li><li>1 cup yogurt</li></ul>
<h2>How to make flatbread</h2>
<ol><li>Knead everything into a soft dough.</li><li>Roll out and fry in a dry pan until blistered.</li></ol>
</article></body></html>''');

      expect(recipe.ingredients, ['2 cups flour', '1 cup yogurt']);
      expect(recipe.instructions, ['Knead everything into a soft dough.', 'Roll out and fry in a dry pan until blistered.']);
    });

    test('headings in the other languages recipes are written in divide it too', () async {
      final german = await importPage('https://backen.example/apfelkuchen', '''<!DOCTYPE html>
<html><head><title>Omas Apfelkuchen</title></head><body><article><h1>Omas Apfelkuchen</h1>
<p>Dieser Apfelkuchen kommt bei uns jeden Sonntag auf den Tisch, seit ich denken kann.</p>
<h2>Zutaten</h2><ul><li>250 g Mehl</li><li>125 g Butter</li><li>3 Äpfel</li><li>1 Prise Salz</li></ul>
<h2>Zubereitung</h2><ol><li>Mehl, Butter und Salz zu einem glatten Teig verkneten.</li><li>Die Äpfel schälen, in Spalten schneiden und auf dem Teig verteilen.</li><li>Im heißen Ofen goldbraun backen.</li></ol>
<h2>Tipps</h2><p>Schmeckt lauwarm mit Sahne am besten.</p>
</article></body></html>''');

      expect(german.ingredients, ['250 g Mehl', '125 g Butter', '3 Äpfel', '1 Prise Salz']);
      expect(german.instructions, [
        'Mehl, Butter und Salz zu einem glatten Teig verkneten.',
        'Die Äpfel schälen, in Spalten schneiden und auf dem Teig verteilen.',
        'Im heißen Ofen goldbraun backen.',
      ]);
      expect(german.notes, 'Schmeckt lauwarm mit Sahne am besten.');
      expect(german.description, startsWith('Dieser Apfelkuchen kommt bei uns'));

      final spanish = await importPage('https://cocina.example/tortilla', '''<!DOCTYPE html>
<html><head><title>Tortilla de patatas</title></head><body><article><h1>Tortilla de patatas</h1>
<h2>Ingredientes</h2><ul><li>6 huevos</li><li>4 patatas</li><li>1 cebolla</li><li>Aceite de oliva</li></ul>
<h2>Preparación</h2><ol><li>Freír las patatas y la cebolla a fuego lento.</li><li>Batir los huevos y mezclar con las patatas.</li><li>Cuajar la tortilla por ambos lados.</li></ol>
</article></body></html>''');

      expect(spanish.title, 'Tortilla de patatas');
      expect(spanish.ingredients, ['6 huevos', '4 patatas', '1 cebolla', 'Aceite de oliva']);
      expect(spanish.instructions, hasLength(3));

      final french = await importPage('https://cuisine.example/crepes', '''<!DOCTYPE html>
<html><head><title>Crêpes</title></head><body><article><h1>Crêpes</h1>
<h2>Ingrédients</h2><ul><li>250 g de farine</li><li>4 œufs</li><li>50 cl de lait</li></ul>
<h2>Préparation</h2><ol><li>Mélanger la farine et les œufs dans un saladier.</li><li>Ajouter le lait petit à petit en fouettant.</li></ol>
</article></body></html>''');

      expect(french.ingredients, ['250 g de farine', '4 œufs', '50 cl de lait']);
      expect(french.instructions, hasLength(2));
    });

    test('the sharing and related posts a blog adds under the post are not steps', () async {
      // What WordPress with Jetpack puts inside the post content itself.
      final recipe = await importPage('https://blog.example/carrot-soup', '''<!DOCTYPE html>
<html><head><title>Carrot Soup</title></head><body>
<article><h1 class="entry-title">Carrot Soup</h1><div class="entry-content">
<p><strong>What you need</strong></p><p>500 g carrots<br>1 onion<br>1 l vegetable stock</p>
<p><strong>Method</strong></p><p>Soften the onion in a little butter.</p><p>Add the carrots and the stock and simmer until soft.</p>
<div class="sharedaddy sd-block sd-like"><h3 class="sd-title">Like this:</h3><div class="likes-widget-placeholder"><span class="button"><span>Like</span></span> <span class="loading">Loading...</span></div></div>
<div id="jp-relatedposts" class="jp-relatedposts"><h3 class="jp-relatedposts-headline"><em>Related</em></h3>
<div class="jp-relatedposts-items"><p><a href="/pumpkin">My Favourite Pumpkin Soup Recipe</a></p><p>In "Soups"</p><p><a href="/leek">Leek and Potato Soup for Cold Days</a></p></div></div>
</div></article></body></html>''');

      expect(recipe.ingredients, ['500 g carrots', '1 onion', '1 l vegetable stock']);
      expect(recipe.instructions, [
        'Soften the onion in a little butter.',
        'Add the carrots and the stock and simmer until soft.',
      ]);
    });

    test('the line a blog files the post under is not a step', () async {
      final recipe = await importPage('https://blog.example/carrot-soup', '''<!DOCTYPE html>
<html><head><title>Carrot Soup</title></head><body><div id="post-12" class="post"><h1>Carrot Soup</h1>
<h3>Ingredients</h3><ul><li>500 g carrots</li><li>1 onion</li></ul>
<h3>Method</h3><p>Soften the onion in a little butter.</p><p>Add the carrots and simmer until soft.</p>
<p class="postmetadata">Posted in Soups and tagged carrot, winter warmers by Anna</p>
<p>Anna has cooked for her family of five for twenty years and writes about it here.</p>
</div></body></html>''');

      expect(recipe.instructions, ['Soften the onion in a little butter.', 'Add the carrots and simmer until soft.']);
    });

    test('a line that points to another post does not end the recipe', () async {
      final recipe = await importPage('https://blog.example/sourdough', '''<!DOCTYPE html>
<html><head><title>Sourdough</title></head><body><article><h1>Sourdough</h1>
<h2>Ingredients</h2><ul><li>500 g flour</li><li>350 g water</li><li>100 g starter</li></ul>
<p>Related: how to keep a starter alive through the winter</p>
<h2>Method</h2><ol><li>Mix everything and rest the dough overnight.</li><li>Shape, proof and bake in a hot pot.</li></ol>
</article></body></html>''');

      expect(recipe.instructions, ['Mix everything and rest the dough overnight.', 'Shape, proof and bake in a hot pot.']);
    });

    test('notes under a longer heading are notes, not more steps', () async {
      final recipe = await importPage('https://x.example/flatbread', '''<!DOCTYPE html>
<html><head><title>Flatbread</title></head><body><article><h1>Flatbread</h1>
<h2>Ingredients</h2><ul><li>2 cups flour</li><li>1 cup yogurt</li></ul>
<h2>Directions</h2><ol><li>Knead everything into a soft dough.</li><li>Roll out and fry in a dry pan until blistered.</li></ol>
<h2>Recipe Notes</h2><p>The dough keeps in the fridge until the next day.</p>
</article></body></html>''');

      expect(recipe.instructions, ['Knead everything into a soft dough.', 'Roll out and fry in a dry pan until blistered.']);
      expect(recipe.notes, 'The dough keeps in the fridge until the next day.');
    });

    test('sentences under a notes heading stay notes when the method is missing', () async {
      final recipe = await importPage('https://x.example/flatbread', '''<!DOCTYPE html>
<html><head><title>Flatbread</title></head><body><article><h1>Flatbread</h1>
<h2>Ingredients</h2><ul><li>2 cups flour</li><li>1 cup yogurt</li></ul>
<h2>Notes</h2><p>The dough keeps in the fridge until the next day and freezes well for a month.</p>
</article></body></html>''');

      expect(recipe.ingredients, ['2 cups flour', '1 cup yogurt']);
      expect(recipe.instructions, isEmpty);
      expect(recipe.notes, 'The dough keeps in the fridge until the next day and freezes well for a month.');
    });

    test('a nutrition box between the ingredients and the method does not hide the method', () async {
      final recipe = await importPage('https://blog.example/garlic-rice', '''<!DOCTYPE html>
<html><head><title>Garlic Rice</title></head><body><main><h1>Garlic Rice</h1>
<h2>Ingredients</h2><ul><li>2 cups rice</li><li>4 cloves garlic</li><li>2 tbsp oil</li></ul>
<h2>Nutrition</h2><p>Calories: 320 per serving</p><p>Fat: 7 g</p>
<h2>Directions</h2><ol><li>Fry the garlic in the oil until golden.</li><li>Add the rice and toss until hot.</li></ol>
</main></body></html>''');

      expect(recipe.ingredients, ['2 cups rice', '4 cloves garlic', '2 tbsp oil']);
      expect(recipe.instructions, ['Fry the garlic in the oil until golden.', 'Add the rice and toss until hot.']);
    });

    test('a line of nothing but digits does not stall the import', () async {
      final digits = '7' * 80000;
      final watch = Stopwatch()..start();
      final recipe = await importPage('https://x.example/flatbread', '''<!DOCTYPE html>
<html><head><title>Flatbread</title></head><body><div class="post"><h1>Flatbread</h1>
<p>$digits</p>
<p>2 cups flour</p><p>1 cup yogurt</p>
<p>Knead everything into a soft dough, then roll out and fry in a dry pan.</p>
</div></body></html>''');

      expect(watch.elapsed, lessThan(const Duration(seconds: 10)));
      expect(recipe.ingredients, ['2 cups flour', '1 cup yogurt']);
    });

    test('a method with no heading of its own starts at the first sentence', () async {
      final recipe = await importPage('https://x.example/flatbread', '''<!DOCTYPE html>
<html><head><title>Flatbread</title></head><body><article><h1>Flatbread</h1>
<h2>Ingredients</h2>
<ul><li>2 cups flour</li><li>1 cup yogurt</li><li>Salt</li></ul>
<p>Knead everything into a soft dough and leave it to rest under a damp cloth.</p>
<p>Roll out and fry in a dry pan until blistered on both sides.</p>
</article></body></html>''');

      expect(recipe.ingredients, ['2 cups flour', '1 cup yogurt', 'Salt']);
      expect(recipe.instructions, [
        'Knead everything into a soft dough and leave it to rest under a damp cloth.',
        'Roll out and fry in a dry pan until blistered on both sides.',
      ]);
    });

    test('the yield and times above the ingredients are read', () async {
      final recipe = await importPage('https://x.example/flatbread', '''<!DOCTYPE html>
<html><head><title>Flatbread</title></head><body><article><h1>Flatbread</h1>
<p>Prep Time: 15 minutes</p><p>Cook Time: 10 minutes</p><p>Serves 4</p>
<h2>Ingredients</h2>
<ul><li>2 cups flour</li><li>1 cup yogurt</li></ul>
<h2>Instructions</h2>
<ol><li>Knead everything into a soft dough.</li><li>Roll out and fry in a dry pan until blistered.</li></ol>
</article></body></html>''');

      expect(recipe.prepTimeMinutes, 15);
      expect(recipe.cookTimeMinutes, 10);
      expect(recipe.servings, '4');
      expect(recipe.ingredients, ['2 cups flour', '1 cup yogurt']);
    });

    test('a post with no headings is read when its lines are written like a recipe', () async {
      final recipe = await importPage('https://x.example/dressing', '''<!DOCTYPE html>
<html><head><title>House Dressing</title></head><body><div class="post"><h1>House Dressing</h1>
<p>3 tbsp olive oil</p><p>1 tbsp red wine vinegar</p><p>1 tsp mustard</p>
<p>Whisk everything together in a bowl until it thickens.</p>
</div></body></html>''');

      expect(recipe.title, 'House Dressing');
      expect(recipe.ingredients, ['3 tbsp olive oil', '1 tbsp red wine vinegar', '1 tsp mustard']);
      expect(recipe.instructions, ['Whisk everything together in a bowl until it thickens.']);
    });

    test('a Squarespace post is read once, a line per paragraph', () async {
      const post = '''<!DOCTYPE html><html><head><title>Chocolate Lava Cakes | Butter and Bloom</title>
<meta property="og:title" content="Chocolate Lava Cakes"></head><body>
<article class="entry"><h1 class="entry-title">Chocolate Lava Cakes</h1>
<div class="sqs-layout sqs-grid-12 columns-12"><div class="row sqs-row"><div class="col sqs-col-12">
<div class="sqs-block html-block sqs-block-html"><div class="sqs-block-content"><div class="sqs-html-content"><p style="white-space:pre-wrap;">These little cakes are my favourite dinner party trick.</p><h3 style="white-space:pre-wrap;">Ingredients</h3><p style="white-space:pre-wrap;">4 oz dark chocolate</p><p style="white-space:pre-wrap;">1/2 cup butter</p><p style="white-space:pre-wrap;">2 eggs</p><p style="white-space:pre-wrap;">1/4 cup sugar</p><h3 style="white-space:pre-wrap;">Instructions</h3><p style="white-space:pre-wrap;">Melt the chocolate with the butter until smooth.</p><p style="white-space:pre-wrap;">Whisk in the eggs and sugar, pour into ramekins and bake until just set.</p></div></div></div>
</div></div></div></article></body></html>''';

      for (final url in [
        'https://butterandbloom.squarespace.com/blog/chocolate-lava-cakes',
        'https://www.butterandbloom.example/blog/chocolate-lava-cakes',
      ]) {
        final recipe = await importPage(url, post);

        expect(recipe.title, 'Chocolate Lava Cakes', reason: url);
        expect(recipe.ingredients, ['4 oz dark chocolate', '1/2 cup butter', '2 eggs', '1/4 cup sugar'], reason: url);
        expect(
          recipe.instructions,
          [
            'Melt the chocolate with the butter until smooth.',
            'Whisk in the eggs and sugar, pour into ramekins and bake until just set.',
          ],
          reason: url,
        );
      }
    });

    test('a recipe in a preformatted block keeps its lines', () async {
      final recipe = await importPage('https://archive.example/recipes/0412.html', '''<html><head><title>Lemon Rice</title></head>
<body><h1>Lemon Rice</h1><pre>
Ingredients:
2 cups cooked rice
1 lemon, juiced
1 tsp mustard seeds

Instructions:
Heat the oil and pop the mustard seeds.
Stir in the rice and the lemon juice.
</pre></body></html>''');

      expect(recipe.title, 'Lemon Rice');
      expect(recipe.ingredients, ['2 cups cooked rice', '1 lemon, juiced', '1 tsp mustard seeds']);
      expect(recipe.instructions, ['Heat the oil and pop the mustard seeds.', 'Stir in the rice and the lemon juice.']);
    });

    test('a saved page picked as a file is read the same way', () {
      final recipes = RecipeImportEngine.parseFromHtml(minified(bananaBreadPost()));

      expect(recipes.single.title, "Grandma's Banana Bread");
      expect(recipes.single.ingredients, bananaIngredients);
      expect(recipes.single.instructions, bananaSteps);
    });

    test('a file that holds no recipe gives none', () {
      expect(
        RecipeImportEngine.parseFromHtml('<html><head><title>Links</title></head><body><h1>My recipes</h1>'
            '<ul><li><a href="Pancakes.html">Pancakes</a></li><li><a href="Crepes.html">Crepes</a></li></ul></body></html>'),
        isEmpty,
      );
    });
  });

  group('a page that marks up half its recipe', () {
    test('steps missing from the recipe data are read from the post', () async {
      final recipe = await importPage(
        'https://blog.example/pancakes',
        jsonLdPage(
          recipeJson({'name': 'Pancakes', 'recipeInstructions': <String>[]}),
          body: '<article><h1>Fluffy Pancakes</h1><h2>Ingredients</h2><ul><li>1 cup flour</li><li>2 eggs</li></ul>'
              '<h2>Method</h2><p>Whisk the flour into the eggs.</p><p>Fry in a hot pan until golden.</p></article>',
        ),
      );

      // The data stays the authority for what it does say.
      expect(recipe.title, 'Pancakes');
      expect(recipe.ingredients, ['1 cup flour', '2 eggs']);
      expect(recipe.instructions, ['Whisk the flour into the eggs.', 'Fry in a hot pan until golden.']);
    });

    test('a classed ingredient list is kept and the steps come from the text', () async {
      final recipe = await importPage('https://blog.example/dressing', '''<html><head><title>House Dressing</title></head>
<body><h1>House Dressing</h1>
<ul class="ingredients"><li>3 tbsp olive oil</li><li>1 tbsp red wine vinegar</li><li>A good pinch of salt</li></ul>
<h2>Method</h2>
<p>Whisk the oil into the vinegar until it thickens.</p>
<p>Season with the salt and pour over the leaves.</p>
</body></html>''');

      expect(recipe.title, 'House Dressing');
      expect(recipe.ingredients, ['3 tbsp olive oil', '1 tbsp red wine vinegar', 'A good pinch of salt']);
      expect(recipe.instructions, [
        'Whisk the oil into the vinegar until it thickens.',
        'Season with the salt and pour over the leaves.',
      ]);
    });

    test('a classed list that is not ingredients is not taken for a recipe', () async {
      final failure = await importFailure(
        'https://blog.example/recipes/',
        (_) async => htmlResponse('<html><head><title>Browse by ingredient</title></head><body>'
            '<ul class="ingredient-filter"><li>Chicken (120)</li><li>Beef (80)</li><li>Tofu (14)</li></ul>'
            '</body></html>'),
      );

      expect(failure, noRecipeFound);
    });

    test('lists without amounts are still a recipe when the post has both headings', () async {
      final recipe = await importPage('https://blog.example/toastie', '''<html><head><title>Cheese Toastie</title></head>
<body><div class="entry-content"><h1>Cheese Toastie</h1>
<h2>Ingredients</h2><ul><li>Bread</li><li>Butter</li><li>Cheddar</li></ul>
<h2>Instructions</h2><ol><li>Butter the bread on both sides.</li><li>Fry with the cheese inside until golden.</li></ol>
</div></body></html>''');

      expect(recipe.title, 'Cheese Toastie');
      expect(recipe.ingredients, ['Bread', 'Butter', 'Cheddar']);
      expect(recipe.instructions, ['Butter the bread on both sides.', 'Fry with the cheese inside until golden.']);
    });

    test('recipe data with nothing in it does not stop the post from being read', () async {
      final recipe = await importPage(
        'https://cozywhisk.example/banana-bread/',
        bananaBreadPost().replaceFirst(
          '</head>',
          '<script type="application/ld+json">{"@type":"Recipe","name":"Best Banana Bread",'
              '"description":"Our most baked loaf.","image":"/uploads/loaf.jpg"}</script></head>',
        ),
      );

      // What the data does say is kept, the rest comes from the post.
      expect(recipe.title, 'Best Banana Bread');
      expect(recipe.description, 'Our most baked loaf.');
      expect(recipe.imageUrl, 'https://cozywhisk.example/uploads/loaf.jpg');
      expect(recipe.ingredients, bananaIngredients);
      expect(recipe.instructions, bananaSteps);
    });
  });

  group('a recipe served as plain text', () {
    const lemonRice = '''Lemon Rice

Ingredients:
2 cups cooked rice
1 lemon, juiced
1 tsp mustard seeds

Instructions:
1. Heat the oil and pop the mustard seeds.
2. Stir in the rice and the lemon juice.
''';

    test('is read line by line', () async {
      final recipe = await importUrl(
        'https://raw.example/lemon-rice.txt',
        (_) async => http.Response.bytes(utf8.encode(lemonRice), 200, headers: {'content-type': 'text/plain; charset=utf-8'}),
      );

      expect(recipe.title, 'Lemon Rice');
      expect(recipe.ingredients, ['2 cups cooked rice', '1 lemon, juiced', '1 tsp mustard seeds']);
      expect(recipe.instructions, ['Heat the oil and pop the mustard seeds.', 'Stir in the rice and the lemon juice.']);
      expect(recipe.sourceUrl, 'https://raw.example/lemon-rice.txt');
    });

    test('is not mistaken for a page when the server names no type', () async {
      final recipe = await importUrl(
        'https://raw.example/lemon-rice',
        (_) async => http.Response.bytes(utf8.encode(lemonRice), 200),
      );

      expect(recipe.ingredients, hasLength(3));
      expect(recipe.instructions, hasLength(2));
    });

    test('a web page sent as text/plain is still read as a page', () async {
      final recipe = await importUrl(
        'https://odd.example/pancakes',
        (_) async => htmlResponse(jsonLdPage(recipeJson()), headers: {'content-type': 'text/plain'}),
      );

      expect(recipe.title, 'Pancakes');
      expect(recipe.ingredients, ['1 cup flour', '2 eggs']);
    });

    test('needs no headings or units when its lines open with amounts', () async {
      final recipe = await importUrl(
        'https://raw.example/soup.txt',
        (_) async => http.Response(
            'Soup\n\n1 onion\n2 carrots\n1 litre stock\n\n'
            'Chop the onion and the carrots, then simmer them in the stock until soft.\n',
            200,
            headers: {'content-type': 'text/plain'}),
      );

      expect(recipe.title, 'Soup');
      expect(recipe.ingredients, ['1 onion', '2 carrots', '1 litre stock']);
      expect(recipe.instructions, ['Chop the onion and the carrots, then simmer them in the stock until soft.']);
    });

    test('a recipe answered as JSON is read as JSON, with or without markup in its text', () async {
      final single = await importUrl(
        'https://api.example/recipes/7',
        (_) async => jsonResponse({
          '@type': 'Recipe',
          'name': 'Onion Soup',
          'description': '<p>A good soup.</p>',
          'recipeIngredient': ['1 onion', '2 cups stock'],
          'recipeInstructions': [
            {'@type': 'HowToStep', 'text': 'Soften the onion in butter.'},
            {'@type': 'HowToStep', 'text': 'Add the stock and simmer.'},
          ],
        }),
      );
      expect(single.title, 'Onion Soup');
      expect(single.ingredients, ['1 onion', '2 cups stock']);
      expect(single.instructions, ['Soften the onion in butter.', 'Add the stock and simmer.']);

      final listed = await importUrl(
        'https://api.example/recipes',
        (_) async => jsonResponse([
          {
            'name': 'Pancakes',
            'ingredients': ['1 cup flour', '2 eggs'],
            'instructions': ['Whisk it all together.', 'Fry until golden.'],
          },
        ]),
      );
      expect(listed.title, 'Pancakes');
      expect(listed.ingredients, ['1 cup flour', '2 eggs']);
    });

    test('JSON that holds no recipe is refused, not imported as a line of brackets', () async {
      for (final answer in <Object>[
        {'error': 'Not found', 'message': 'No recipe with that id exists in the database.'},
        [
          {'error': 'Not found', 'message': 'No recipe with that id exists in the database.'},
        ],
        <Object>[],
      ]) {
        expect(await importFailure('https://api.example/recipes/7', (_) async => jsonResponse(answer)), noRecipeFound,
            reason: '$answer');
      }
    });

    test('text that only opens and closes with a bracket is read as text, not as broken JSON', () async {
      final recipe = await importUrl(
        'https://raw.example/recipes/lemon-rice.md',
        (_) async => http.Response.bytes(
            utf8.encode('[All recipes](README.md)\n\n$lemonRice\n[All recipes]\n'), 200,
            headers: {'content-type': 'text/plain; charset=utf-8'}),
      );

      expect(recipe.ingredients, ['2 cups cooked rice', '1 lemon, juiced', '1 tsp mustard seeds']);
      expect(
        recipe.instructions,
        containsAllInOrder(['Heat the oil and pop the mustard seeds.', 'Stir in the rice and the lemon juice.']),
      );
    });

    test('text that is not a recipe is refused', () async {
      final failure = await importFailure(
        'https://x.example/robots.txt',
        (_) async => http.Response('User-agent: *\nDisallow: /admin/\nSitemap: https://x.example/sitemap.xml\n', 200,
            headers: {'content-type': 'text/plain'}),
      );

      expect(failure, noRecipeFound);
    });
  });
}
