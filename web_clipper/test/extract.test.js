// Tests for the web clipper's recipe reading and link building, on saved
// pages in fixtures/. No browser and no network: the JSON-LD blocks are
// taken from the HTML the way the extension takes them from the page.
//
// Run with Node 20.12 or newer:  node web_clipper/test/extract.test.js
'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const zlib = require('node:zlib');

const clipper = require('../extension/lib/recipe.js');

/** The text of every script type="application/ld+json" in [html], in page order. */
function jsonLdBlocks(html) {
  const blocks = [];
  const pattern = /<script\b[^>]*type\s*=\s*["']?application\/ld\+json["']?[^>]*>([\s\S]*?)<\/script>/gi;
  for (const match of html.matchAll(pattern)) blocks.push(match[1]);
  return blocks;
}

function fixture(name) {
  return fs.readFileSync(path.join(__dirname, 'fixtures', name), 'utf8');
}

function recipeIn(name) {
  return clipper.findRecipe(jsonLdBlocks(fixture(name)));
}

/** The query parameters of a clip link, with data unpacked back to JSON. */
function readLink(link) {
  assert.ok(link.startsWith('recipespellbook://clip?url='), link);
  const params = new URL(link.replace('recipespellbook://clip', 'https://clip.invalid/')).searchParams;
  const out = Object.fromEntries(params);
  if (out.data) {
    assert.match(out.data, /^[A-Za-z0-9_-]+$/);
    const bytes = Buffer.from(out.data, 'base64url');
    out.json = JSON.parse((out.z === '1' ? zlib.inflateRawSync(bytes) : bytes).toString('utf8'));
  }
  return out;
}

const LASAGNA_PAGE = 'https://example-kitchen.com/weeknight-lasagna/';

test('@graph page with HowToSection steps', async () => {
  const recipe = recipeIn('graph-sections.html');
  assert.ok(recipe);
  assert.equal(clipper.recipeName(recipe), 'Weeknight Lasagna');
  assert.equal(clipper.ingredientsOf(recipe).length, 6);
  assert.deepEqual(clipper.stepsOf(recipe), [
    'For the sauce:',
    'Brown the beef in a large pan.',
    'Stir in the marinara and simmer for 10 minutes.',
    'To assemble:',
    'Layer noodles, ricotta, sauce and mozzarella, three times.',
    'Top with parmesan and bake at 375\u00b0F for 45 minutes.',
  ]);

  const compact = clipper.compactRecipe(recipe, LASAGNA_PAGE);
  assert.equal(compact['@type'], 'Recipe');
  assert.equal(compact.image, 'https://example-kitchen.com/img/lasagna-1x1.jpg');
  assert.equal(compact.recipeYield, '6 servings');
  assert.equal(compact.totalTime, 'PT1H5M');
  assert.equal(compact.author, 'Sam Baker');
  assert.deepEqual(compact.recipeCategory, ['Main Course']);
  assert.deepEqual(compact.keywords, ['lasagna', 'pasta', 'weeknight dinner']);
  assert.deepEqual(compact.nutrition, { calories: '520 kcal', proteinContent: '28 g' });
  assert.equal(compact.aggregateRating, undefined, 'ratings are not sent');
  assert.equal(compact.video, undefined, 'videos are not sent');

  const link = await clipper.buildClipLink({ url: LASAGNA_PAGE, title: 'Weeknight Lasagna', recipe, maxLength: 2000 });
  assert.ok(link.length <= 2000, `link is ${link.length} characters`);
  const params = readLink(link);
  assert.equal(params.url, LASAGNA_PAGE);
  assert.equal(params.title, 'Weeknight Lasagna');
  assert.equal(params.z, '1');
  assert.deepEqual(params.json, compact);
});

test('several scripts: the recipe of the page wins over a teaser and a broken block', async () => {
  const recipe = recipeIn('multiple-scripts.html');
  assert.ok(recipe);
  assert.equal(clipper.recipeName(recipe), 'Lemon Herb Chicken');
  assert.deepEqual(clipper.ingredientsOf(recipe), [
    '4 chicken thighs',
    '2 lemons, zested & juiced',
    '3 cloves garlic',
    'Salt & pepper',
    '1 tsp dried oregano',
  ]);
  assert.deepEqual(clipper.stepsOf(recipe), [
    'Heat the oven to 425\u00b0F.',
    'Toss the chicken with lemon, garlic, oregano, salt and pepper.',
    'Roast for 35 minutes, until golden.',
  ]);

  const page = 'https://foodmag.example/lemon-herb-chicken?utm_source=feed';
  const compact = clipper.compactRecipe(recipe, page);
  assert.equal(compact.image, 'https://foodmag.example/photos/lemon-chicken.jpg');
  assert.equal(compact.author, 'Ana Ruiz');
  assert.equal(compact.recipeYield, '4');

  const params = readLink(await clipper.buildClipLink({ url: page, title: 'Lemon Herb Chicken - Food Mag', recipe }));
  assert.equal(params.url, page);
  assert.equal(params.json.name, 'Lemon Herb Chicken');
});

test('mainEntity in a hand-written block, steps in one HTML string', async () => {
  const recipe = recipeIn('main-entity.html');
  assert.ok(recipe, 'the comment wrapper and trailing commas are repaired');
  assert.equal(clipper.recipeName(recipe), 'Overnight Oats');
  assert.deepEqual(clipper.ingredientsOf(recipe), ['1/2 cup rolled oats', '1/2 cup milk', '1 tbsp chia seeds', 'Honey, to taste']);
  assert.deepEqual(clipper.stepsOf(recipe), [
    'Stir everything together in a jar.',
    'Cover and chill overnight.',
    'Top with fruit in the morning.',
  ]);
  const params = readLink(await clipper.buildClipLink({ url: 'https://oats.example/overnight', title: 'Overnight Oats', recipe }));
  assert.deepEqual(params.json.recipeIngredient, clipper.ingredientsOf(recipe));
});

test('a list of recipes on other pages is no recipe: only the page is sent', async () => {
  const recipe = recipeIn('no-recipe.html');
  assert.equal(recipe, null);
  const link = await clipper.buildClipLink({ url: 'https://foodmag.example/winter-soups', title: '10 Soups for Winter | Food Mag', recipe });
  assert.deepEqual(readLink(link), { url: 'https://foodmag.example/winter-soups', title: '10 Soups for Winter | Food Mag' });
});

test('a recipe too big for the link is cut down, then left to the app', async () => {
  const recipe = {
    '@type': 'Recipe',
    name: 'Feast',
    description: 'x'.repeat(280),
    keywords: Array.from({ length: 12 }, (_, i) => `keyword number ${i}`).join(', '),
    recipeIngredient: Array.from({ length: 25 }, (_, i) => `${i + 1} cups of ingredient number ${i + 1}, finely chopped`),
    recipeInstructions: Array.from({ length: 12 }, (_, i) => `Step ${i + 1}: stir the pot slowly for a while and taste it again ${i}.`),
  };
  const page = 'https://feast.example/recipe';

  // Windows: only what fits. The app reads the rest from the page.
  const small = await clipper.buildClipLink({ url: page, title: 'Feast', recipe, maxLength: clipper.MAX_LINK_WINDOWS });
  assert.ok(small.length <= clipper.MAX_LINK_WINDOWS);

  // Elsewhere: the whole recipe.
  const big = await clipper.buildClipLink({ url: page, title: 'Feast', recipe, maxLength: clipper.MAX_LINK_OTHER });
  assert.ok(big.length <= clipper.MAX_LINK_OTHER);
  const params = readLink(big);
  assert.equal(params.json.recipeIngredient.length, 25);
  assert.equal(params.json.description, recipe.description);

  // Hopelessly big: no data at all, never a link that would not open.
  const huge = { ...recipe, recipeIngredient: Array.from({ length: 400 }, (_, i) => `ingredient ${i} ${'y'.repeat(i % 37)}`) };
  const none = await clipper.buildClipLink({ url: page, title: 'Feast', recipe: huge, maxLength: clipper.MAX_LINK_WINDOWS });
  assert.deepEqual(readLink(none), { url: page, title: 'Feast' });
});

test('only web pages get a link', async () => {
  for (const url of ['chrome://extensions', 'about:blank', 'file:///C:/recipe.html', 'javascript:alert(1)', '', undefined]) {
    assert.equal(await clipper.buildClipLink({ url, title: 'x', recipe: null }), null, String(url));
  }
  assert.ok(clipper.isWebUrl('http://example.com/a'));
});

test('the toolbar and menu glue: reads the tab, opens the link in that same tab', async () => {
  const opened = [];
  let blocks = jsonLdBlocks(fixture('multiple-scripts.html'));
  let readable = true;
  globalThis.chrome = {
    scripting: {
      executeScript: async ({ target }) => {
        assert.equal(target.tabId, 7);
        if (!readable) throw new Error('Cannot access contents of the page');
        return [{ result: { url: 'https://foodmag.example/lemon-herb-chicken', title: 'Lemon Herb Chicken - Food Mag', ogTitle: '', blocks } }];
      },
    },
    runtime: { getPlatformInfo: async () => ({ os: 'win' }) },
    tabs: { update: async (tabId, props) => opened.push([tabId, props.url]) },
  };
  globalThis.RecipeClipper = clipper;
  require('../extension/lib/tab.js');
  const tabs = globalThis.ClipperTab;
  const tab = { id: 7, url: 'https://foodmag.example/lemon-herb-chicken', title: 'Tab title' };

  const page = await tabs.readTab(tab);
  assert.equal(page.title, 'Lemon Herb Chicken');
  assert.equal(clipper.recipeName(page.recipe), 'Lemon Herb Chicken');
  assert.equal(await tabs.sendToApp(tab, page), true);
  assert.equal(opened.length, 1);
  assert.equal(opened[0][0], 7);
  assert.ok(opened[0][1].length <= clipper.MAX_LINK_WINDOWS);
  assert.equal(readLink(opened[0][1]).json.name, 'Lemon Herb Chicken');

  // A page with no recipe: the address and title still go.
  blocks = jsonLdBlocks(fixture('no-recipe.html'));
  assert.equal(await tabs.clipTab(tab), true);
  assert.deepEqual(readLink(opened[1][1]), { url: tab.url, title: 'Lemon Herb Chicken - Food Mag' });

  // A page the browser does not let extensions read: the address still goes.
  readable = false;
  assert.equal(await tabs.clipTab(tab), true);
  assert.deepEqual(readLink(opened[2][1]), { url: tab.url, title: 'Tab title' });

  // Not a web page: nothing is opened.
  assert.equal(await tabs.clipTab({ id: 7, url: 'chrome://newtab/' }), false);
  assert.equal(opened.length, 3);
});

test('a long title is shortened, and a page address with its own query survives', async () => {
  const url = 'https://example.com/r?id=7&lang=en#print';
  const params = readLink(await clipper.buildClipLink({ url, title: 'T'.repeat(500), recipe: null }));
  assert.equal(params.url, url);
  assert.ok(params.title.length <= 120);
});
