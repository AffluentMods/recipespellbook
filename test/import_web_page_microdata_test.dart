// Importing a recipe from a web page that marks it up in the page itself:
// microdata attributes and the class names of recipe plugins.
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/services/recipe_import_engine.dart';

import 'web_import_helpers.dart';

void main() {
  group('microdata', () {
    /// A page whose recipe is marked up with itemprop attributes only.
    String microdataPage(String recipe, {String head = '<title>Recipes | Old Family Blog</title>'}) =>
        '<!DOCTYPE html><html><head><meta charset="utf-8">$head</head><body>$recipe</body></html>';

    const lemonBars = '''
<article itemscope itemtype="https://schema.org/Recipe">
  <p class="byline"><span itemprop="author" itemscope itemtype="https://schema.org/Person">By <span itemprop="name">Priya Patel</span></span></p>
  <h2 itemprop="name">Lemon Bars</h2>
  <p itemprop="description">Tangy lemon bars on a buttery shortbread crust.</p>
  <p>Prep: <meta itemprop="prepTime" content="PT20M">20 minutes, cook: <meta itemprop="cookTime" content="PT40M">40 minutes,
     makes <span itemprop="recipeYield">24 bars</span></p>
  <img itemprop="image" src="/photos/lemon-bars.jpg">
  <ul>
    <li itemprop="recipeIngredient">1 cup butter, softened</li>
    <li itemprop="recipeIngredient">2 cups all-purpose flour</li>
    <li itemprop="recipeIngredient">1/2 cup white sugar</li>
    <li itemprop="recipeIngredient">4 eggs</li>
    <li itemprop="recipeIngredient">2 lemons, juiced</li>
  </ul>
  <div itemprop="recipeInstructions">
    <ol>
      <li>Preheat oven to 350 degrees F.</li>
      <li>Blend butter, flour and 1/2 cup sugar.</li>
      <li>Press into a 9x13 inch pan.</li>
      <li>Bake for 15 to 20 minutes until firm and golden.</li>
      <li>Whisk eggs and lemon juice, pour over the crust and bake again.</li>
    </ol>
  </div>
</article>''';

    test('the recipe name is the title, not the name of its author', () async {
      final recipe = await importPage('https://priyabakes.example/lemon-bars/', microdataPage(lemonBars));

      expect(recipe.title, 'Lemon Bars');
    });

    test('a list inside one instructions property gives one step per item', () async {
      final recipe = await importPage('https://priyabakes.example/lemon-bars/', microdataPage(lemonBars));

      expect(recipe.ingredients, hasLength(5));
      expect(recipe.instructions, [
        'Preheat oven to 350 degrees F.',
        'Blend butter, flour and 1/2 cup sugar.',
        'Press into a 9x13 inch pan.',
        'Bake for 15 to 20 minutes until firm and golden.',
        'Whisk eggs and lemon juice, pour over the crust and bake again.',
      ]);
    });

    test('description, times, yield and photo are read', () async {
      final recipe = await importPage('https://priyabakes.example/lemon-bars/', microdataPage(lemonBars));

      expect(recipe.description, 'Tangy lemon bars on a buttery shortbread crust.');
      expect(recipe.prepTimeMinutes, 20);
      expect(recipe.cookTimeMinutes, 40);
      expect(recipe.servings, '24 bars');
      expect(recipe.imageUrl, 'https://priyabakes.example/photos/lemon-bars.jpg');
    });

    test('list items that wrap their text in a paragraph are not counted twice', () async {
      final recipe = await importPage('https://x.example/garlic-bread/', microdataPage('''
<div itemscope itemtype="https://schema.org/Recipe"><h1 itemprop="name">Garlic Bread</h1>
<ul><li itemprop="recipeIngredient">1 baguette</li><li itemprop="recipeIngredient">4 tbsp butter</li></ul>
<ol itemprop="recipeInstructions"><li><p>Mash the garlic into the softened butter.</p></li><li><p>Slice the baguette and spread with the garlic butter.</p></li><li><p>Bake at 400F for 10 minutes until golden.</p></li></ol>
</div>'''));

      expect(recipe.instructions, [
        'Mash the garlic into the softened butter.',
        'Slice the baguette and spread with the garlic butter.',
        'Bake at 400F for 10 minutes until golden.',
      ]);
    });

    test('steps separated by line breaks are separate steps', () async {
      final recipe = await importPage('https://x.example/toast/', microdataPage('''
<div itemscope itemtype="http://schema.org/Recipe"><h1 itemprop="name">Cheese Toast</h1>
<span itemprop="recipeIngredient">2 slices bread</span>, <span itemprop="recipeIngredient">1 slice cheese</span>
<div itemprop="recipeInstructions">1. Toast the bread lightly.<br>2. Lay the cheese on top.<br/>3. Grill until it bubbles.</div>
</div>'''));

      expect(recipe.ingredients, ['2 slices bread', '1 slice cheese']);
      expect(recipe.instructions, ['Toast the bread lightly.', 'Lay the cheese on top.', 'Grill until it bubbles.']);
    });

    test('steps that are each a block of their own are separate steps', () async {
      final recipe = await importPage('https://x.example/rice/', microdataPage('''
<div itemscope itemtype="https://schema.org/Recipe"><h1 itemprop="name">Plain Rice</h1>
<span itemprop="recipeIngredient">1 cup rice</span> <span itemprop="recipeIngredient">2 cups water</span>
<div itemprop="recipeInstructions"><div class="step">Rinse the rice until the water runs clear.</div><div class="step">Simmer covered until the water is gone.</div><div class="step">Rest off the heat, then fluff with a fork.</div></div>
</div>'''));

      expect(recipe.instructions, [
        'Rinse the rice until the water runs clear.',
        'Simmer covered until the water is gone.',
        'Rest off the heat, then fluff with a fork.',
      ]);
    });

    test('headings that only number the steps are not steps', () async {
      final recipe = await importPage('https://x.example/rice/', microdataPage('''
<div itemscope itemtype="https://schema.org/Recipe"><h1 itemprop="name">Plain Rice</h1>
<span itemprop="recipeIngredient">1 cup rice</span> <span itemprop="recipeIngredient">2 cups water</span>
<div itemprop="recipeInstructions"><h3>Step 1</h3><p>Rinse the rice until the water runs clear.</p><h3>Step 2</h3><p>Simmer covered until the water is gone.</p></div>
</div>'''));

      expect(recipe.instructions, ['Rinse the rice until the water runs clear.', 'Simmer covered until the water is gone.']);
    });

    test('an ingredient laid out in blocks of its own stays one ingredient', () async {
      final recipe = await importPage('https://x.example/rice/', microdataPage('''
<div itemscope itemtype="https://schema.org/Recipe"><h1 itemprop="name">Plain Rice</h1>
<ul><li itemprop="recipeIngredient"><div class="amount">1 cup</div><div class="name">rice</div></li>
<li itemprop="recipeIngredient"><div class="amount">2 cups</div><div class="name">water</div></li></ul>
<p itemprop="recipeInstructions">Simmer the rice in the water until it is gone.</p>
</div>'''));

      expect(recipe.ingredients, ['1 cup rice', '2 cups water']);
    });

    test('a step marked up on its own stays one step when it is laid out in blocks', () async {
      final recipe = await importPage('https://x.example/rice/', microdataPage('''
<div itemscope itemtype="https://schema.org/Recipe"><h1 itemprop="name">Plain Rice</h1>
<span itemprop="recipeIngredient">1 cup rice</span> <span itemprop="recipeIngredient">2 cups water</span>
<ol><li itemprop="recipeInstructions"><div class="number">1</div><div class="text">Rinse the rice until the water runs clear.</div></li>
<li itemprop="recipeInstructions"><span>Simmer covered until the water is gone.</span><div class="tip">Keep the lid on.</div></li></ol>
</div>'''));

      expect(recipe.instructions, [
        'Rinse the rice until the water runs clear.',
        'Simmer covered until the water is gone. Keep the lid on.',
      ]);
    });

    test('a method marked up section by section gives every step of every section', () async {
      final recipe = await importPage('https://x.example/rolls/', microdataPage('''
<div itemscope itemtype="https://schema.org/Recipe"><h1 itemprop="name">Cheese Rolls</h1>
<span itemprop="recipeIngredient">2 cups flour</span> <span itemprop="recipeIngredient">1 cup grated cheese</span>
<div itemprop="recipeInstructions"><ol><li>Knead the flour with warm water.</li><li>Let the dough rest for an hour.</li></ol></div>
<div itemprop="recipeInstructions"><ol><li>Roll the dough around the cheese.</li><li>Bake until golden.</li></ol></div>
</div>'''));

      expect(recipe.instructions, [
        'Knead the flour with warm water.',
        'Let the dough rest for an hour.',
        'Roll the dough around the cheese.',
        'Bake until golden.',
      ]);
    });

    test('steps marked up one by one are read from their own text', () async {
      final recipe = await importPage('https://x.example/rice/', microdataPage('''
<div itemscope itemtype="https://schema.org/Recipe"><h1 itemprop="name">Plain Rice</h1>
<p itemprop="recipeIngredient">1 cup rice</p><p itemprop="recipeIngredient">2 cups water</p>
<div itemprop="recipeInstructions" itemscope itemtype="https://schema.org/HowToStep"><h3 itemprop="name">Rinse</h3><p itemprop="text">Rinse the rice until the water runs clear.</p></div>
<div itemprop="recipeInstructions" itemscope itemtype="https://schema.org/HowToStep"><h3 itemprop="name">Cook</h3><p itemprop="text">Simmer covered for 15 minutes.</p></div>
</div>'''));

      expect(recipe.title, 'Plain Rice');
      expect(recipe.instructions, ['Rinse the rice until the water runs clear.', 'Simmer covered for 15 minutes.']);
    });

    test('the older itemprop="ingredients" is read, with times and yield', () async {
      final recipe = await importPage('https://oldblog.example/zucchini-bread/', microdataPage('''
<div class="easyrecipe" itemscope itemtype="http://schema.org/Recipe">
  <div itemprop="name" class="ERSName">Zucchini Bread</div>
  <div class="ERSTimes">
    <div class="ERSTime">Prep time: <time itemprop="prepTime" datetime="PT15M">15 mins</time></div>
    <div class="ERSTime">Cook time: <time itemprop="cookTime" datetime="PT1H">1 hour</time></div>
  </div>
  <div itemprop="description" class="ERSSummary">Moist zucchini bread with cinnamon and walnuts.</div>
  <div class="ERSServes">Serves: <span itemprop="recipeYield">2 loaves</span></div>
  <div class="ERSIngredients"><ul>
    <li class="ingredient" itemprop="ingredients">3 cups all-purpose flour</li>
    <li class="ingredient" itemprop="ingredients">1 teaspoon salt</li>
    <li class="ingredient" itemprop="ingredients">3 eggs</li>
    <li class="ingredient" itemprop="ingredients">2 cups grated zucchini</li>
    <li class="ingredient" itemprop="ingredients">1 cup chopped walnuts</li>
  </ul></div>
  <div class="ERSInstructions"><ol>
    <li class="instruction" itemprop="recipeInstructions">Preheat oven to 325 degrees F and grease two loaf pans.</li>
    <li class="instruction" itemprop="recipeInstructions">Sift flour and salt together in a bowl.</li>
    <li class="instruction" itemprop="recipeInstructions">Beat eggs, then stir in zucchini and nuts.</li>
    <li class="instruction" itemprop="recipeInstructions">Bake until a tester comes out clean.</li>
  </ol></div>
</div>'''));

      expect(recipe.title, 'Zucchini Bread');
      expect(recipe.ingredients, hasLength(5));
      expect(recipe.ingredients.first, '3 cups all-purpose flour');
      expect(recipe.instructions, hasLength(4));
      expect(recipe.prepTimeMinutes, 15);
      expect(recipe.cookTimeMinutes, 60);
      expect(recipe.servings, '2 loaves');
      expect(recipe.description, 'Moist zucchini bread with cinnamon and walnuts.');
    });

    test('a name given in a meta tag is the title', () async {
      final recipe = await importPage('https://stew.example/beef-stew/', microdataPage('''
<div itemscope itemtype="http://schema.org/Recipe">
  <meta itemprop="name" content="Slow Cooker Beef Stew">
  <ul><li itemprop="ingredients">2 pounds beef stew meat</li><li itemprop="ingredients">4 carrots, sliced</li></ul>
  <ol><li itemprop="recipeInstructions">Place the meat in the slow cooker.</li><li itemprop="recipeInstructions">Cover and leave on low all day.</li></ol>
</div>'''));

      expect(recipe.title, 'Slow Cooker Beef Stew');
      expect(recipe.ingredients, ['2 pounds beef stew meat', '4 carrots, sliced']);
      expect(recipe.instructions, hasLength(2));
    });

    test('a recipe without a name of its own takes the page title, never a nested name', () async {
      final recipe = await importPage(
        'https://x.example/soup/',
        microdataPage('''
<div itemscope itemtype="https://schema.org/Recipe">
  <span itemprop="author" itemscope itemtype="https://schema.org/Person"><span itemprop="name">Dana Reyes</span></span>
  <span itemprop="aggregateRating" itemscope itemtype="https://schema.org/AggregateRating"><meta itemprop="name" content="Reader rating"></span>
  <p itemprop="recipeIngredient">2 cups stock</p><p itemprop="recipeIngredient">1 onion</p>
  <p itemprop="recipeInstructions">Simmer the onion in the stock.</p>
</div>''', head: '<meta property="og:title" content="Onion Soup">'),
      );

      expect(recipe.title, 'Onion Soup');
    });

    test('times written as words are read when there is no machine value', () async {
      final recipe = await importPage('https://x.example/soup/', microdataPage('''
<div itemscope itemtype="https://schema.org/Recipe"><h1 itemprop="name">Onion Soup</h1>
  <span itemprop="prepTime">10 minutes</span> <span itemprop="totalTime">1 hour 10 minutes</span>
  <p itemprop="recipeIngredient">2 cups stock</p><p itemprop="recipeInstructions">Simmer the onion in the stock.</p>
</div>'''));

      expect(recipe.prepTimeMinutes, 10);
      expect(recipe.cookTimeMinutes, 60);
    });

    test('a side the microdata lacks is filled in from the recipe plugin markup', () async {
      // Steps carry itemprop, the ingredients only the plugin's class.
      final recipe = await importPage('https://oldblog.example/pancakes/', microdataPage('''
<div class="easyrecipe" itemscope itemtype="http://schema.org/Recipe">
  <div itemprop="name">Pancakes</div>
  <div class="ERSIngredients"><ul><li>1 cup flour</li><li>1 egg</li></ul></div>
  <ol><li itemprop="recipeInstructions">Whisk the flour and the egg.</li><li itemprop="recipeInstructions">Fry in a hot pan.</li></ol>
</div>'''));

      expect(recipe.title, 'Pancakes');
      expect(recipe.ingredients, ['1 cup flour', '1 egg']);
      expect(recipe.instructions, ['Whisk the flour and the egg.', 'Fry in a hot pan.']);
    });

    test('a file with a microdata recipe imports the same way', () {
      final recipe = RecipeImportEngine.parseFromHtml(microdataPage(lemonBars)).single;

      expect(recipe.title, 'Lemon Bars');
      expect(recipe.ingredients, hasLength(5));
      expect(recipe.instructions, hasLength(5));
      // Nothing to resolve the relative photo against.
      expect(recipe.imageUrl, isNull);
    });
  });

  group('page title', () {
    test('a menu entry marked itemprop="name" is not the title', () async {
      // Genesis themes mark every menu entry and the author this way.
      final recipe = await importPage('https://hearthandhoney.example/skillet-cornbread/', '''
<!DOCTYPE html><html><head><title>Skillet Cornbread - Hearth and Honey</title></head>
<body itemscope itemtype="https://schema.org/WebPage">
<nav itemscope itemtype="https://schema.org/SiteNavigationElement"><ul>
  <li><a href="/" itemprop="url"><span itemprop="name">Home</span></a></li>
  <li><a href="/recipes/" itemprop="url"><span itemprop="name">Recipes</span></a></li>
</ul></nav>
<article itemscope itemtype="https://schema.org/CreativeWork">
  <h1 class="entry-title" itemprop="headline">Skillet Cornbread</h1>
  <p>by <span itemprop="author" itemscope itemtype="https://schema.org/Person"><span itemprop="name">Jo Whitaker</span></span></p>
  <div class="entry-content" itemprop="text">
    <ul><li>1 cup cornmeal</li><li>1 cup buttermilk</li><li>2 eggs</li></ul>
    <ol><li>Heat the oven with a skillet inside.</li><li>Stir everything together and bake.</li></ol>
  </div>
</article></body></html>''');

      expect(recipe.title, 'Skillet Cornbread');
      expect(recipe.ingredients, ['1 cup cornmeal', '1 cup buttermilk', '2 eggs']);
      expect(recipe.instructions, hasLength(2));
    });

    test('a recipe plugin title wins over the page heading', () async {
      final recipe = await importPage('https://spice.example/chicken-curry/', '''
<html><head><title>Easy Chicken Curry - Spice Blog</title></head><body><h1>Easy Chicken Curry for Busy Nights</h1>
<h2 class="wprm-recipe-name">Chicken Curry</h2>
<ul class="wprm-recipe-ingredients">
  <li><span class="wprm-recipe-ingredient-amount">1</span> <span class="wprm-recipe-ingredient-unit">tbsp</span> <span class="wprm-recipe-ingredient-name">oil</span></li>
  <li><span class="wprm-recipe-ingredient-amount">400</span> <span class="wprm-recipe-ingredient-unit">ml</span> <span class="wprm-recipe-ingredient-name">coconut milk</span></li>
</ul>
<ul class="wprm-recipe-instructions">
  <li><div class="wprm-recipe-instruction-text">Heat the oil &amp; brown the chicken.</div></li>
  <li><div class="wprm-recipe-instruction-text">Add the coconut milk and <strong>simmer</strong>.</div></li>
</ul></body></html>''');

      expect(recipe.title, 'Chicken Curry');
      expect(recipe.ingredients, ['1 tbsp oil', '400 ml coconut milk']);
      expect(recipe.instructions, ['Heat the oil & brown the chicken.', 'Add the coconut milk and simmer.']);
    });
  });

  group('fractions in markup', () {
    test('a fraction set in raised and lowered digits keeps its whole number apart', () async {
      final recipe = await importPage('https://old.example/scones', '''
<html><head><title>Scones</title></head><body><h2 class="wprm-recipe-name">Scones</h2>
<ul class="wprm-recipe-ingredients">
  <li>1<sup>1</sup>&frasl;<sub>2</sub> cups flour</li>
  <li><sup>3</sup>/<sub>4</sub> cup milk</li>
  <li>2<sup>nd</sup> helping of butter</li>
</ul>
<ul class="wprm-recipe-instructions"><li>Rub the butter into the flour and stir in the milk.</li></ul>
</body></html>''');

      expect(recipe.ingredients, ['1 1/2 cups flour', '3/4 cup milk', '2nd helping of butter']);
    });
  });
}
