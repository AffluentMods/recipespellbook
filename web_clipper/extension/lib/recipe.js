/*
 * Recipe Spellbook Web Clipper: finding the recipe in a page's JSON-LD and
 * building the recipespellbook://clip link that opens it in the app.
 *
 * Pure functions with no browser APIs, so the same file runs in the popup,
 * in the background script and under Node for the tests
 * (web_clipper/test/extract.test.js).
 *
 * The link:
 *   recipespellbook://clip?url=<page>&title=<title>&data=<recipe>&z=1
 * where data is a compact schema.org Recipe as JSON, raw DEFLATE compressed
 * (z=1) when the browser can, then base64url without padding. data is only
 * added while the whole link stays under the length the system passes on;
 * without it the app fetches the page itself. The app checks it all again
 * (lib/utils/clip_request.dart).
 */
(function (root) {
  'use strict';

  const SCHEME = 'recipespellbook://clip';

  /** Longest link Chrome, Edge and Firefox hand to an app on Windows (2048, less room to spare). */
  const MAX_LINK_WINDOWS = 2000;

  /** Longest link sent on other systems, which have no such limit. */
  const MAX_LINK_OTHER = 8000;

  /** Longest title sent with the link. */
  const MAX_TITLE = 120;

  // ── Reading JSON-LD ───────────────────────────────────────────────────

  /** One JSON-LD block as data, or null when it cannot be read even after light repair. */
  function parseJsonLd(text) {
    if (typeof text !== 'string') return null;
    let source = text.trim();
    if (!source) return null;
    try {
      return JSON.parse(source);
    } catch (_) {
      // Hand-made blocks: an HTML comment or CDATA around the data, raw line
      // breaks inside strings, a comma before a closing bracket.
      source = source.replace(/<!\[CDATA\[|\]\]>|<!--|-->/g, '').trim();
      source = source.replace(/[\u0000-\u001f]+/g, ' ').replace(/,\s*([}\]])/g, '$1');
      try {
        return JSON.parse(source);
      } catch (_) {
        return null;
      }
    }
  }

  function isRecipeType(type) {
    const types = Array.isArray(type) ? type : [type];
    return types.some((t) => typeof t === 'string' && /(^|[/:#])Recipe$/i.test(t.trim()));
  }

  function carriesRecipe(node) {
    return node.recipeIngredient != null || node.ingredients != null || node.recipeInstructions != null;
  }

  /** Recipe entries wherever pages nest them: lists, @graph, mainEntity, ItemList items. */
  function collectRecipes(node, found, depth, inItemList) {
    if (depth > 8 || node == null || typeof node !== 'object') return;
    if (Array.isArray(node)) {
      for (const item of node) collectRecipes(item, found, depth + 1, inItemList);
      return;
    }
    if (isRecipeType(node['@type'])) {
      // An ItemList mostly links to recipes on other pages. Only an entry
      // that carries its recipe belongs to this one.
      if (!inItemList || carriesRecipe(node)) found.push(node);
      return;
    }
    for (const key of ['@graph', 'mainEntity', 'mainEntityOfPage', 'item']) {
      collectRecipes(node[key], found, depth + 1, inItemList);
    }
    collectRecipes(node.itemListElement, found, depth + 1, true);
  }

  /**
   * The recipe in a page's JSON-LD blocks (the text of each
   * script type="application/ld+json"), or null. A page can carry a bare
   * Recipe teaser next to the real one, so the first with ingredients or
   * steps wins.
   */
  function findRecipe(blocks) {
    const found = [];
    for (const block of blocks || []) collectRecipes(parseJsonLd(block), found, 0, false);
    if (!found.length) return null;
    return found.find((r) => ingredientsOf(r).length || stepsOf(r).length) || found[0];
  }

  // ── Cleaning values ───────────────────────────────────────────────────

  // The named entities recipe text uses most. Any other is left as it is:
  // the app decodes the rest.
  const ENTITIES = {
    amp: '&', lt: '<', gt: '>', quot: '"', apos: "'", nbsp: ' ',
    deg: '°', frac12: '½', frac14: '¼', frac34: '¾', times: '×',
    hellip: '…', lsquo: '‘', rsquo: '’', ldquo: '“', rdquo: '”',
    ndash: '–', mdash: '—', eacute: 'é', egrave: 'è', copy: '©', reg: '®',
  };

  function decodeEntities(text) {
    return text.replace(/&(#x[0-9a-f]+|#\d+|[a-z]+\d*);/gi, (whole, name) => {
      if (name[0] === '#') {
        const code = name[1] === 'x' || name[1] === 'X' ? parseInt(name.slice(2), 16) : parseInt(name.slice(1), 10);
        return Number.isFinite(code) && code > 0 && code < 0x110000 ? String.fromCodePoint(code) : whole;
      }
      const known = Object.prototype.hasOwnProperty.call(ENTITIES, name) ? ENTITIES[name] : undefined;
      return known === undefined ? whole : known;
    });
  }

  /** Text with line breaks where the markup had blocks, tags removed, entities decoded. */
  function lines(value) {
    if (typeof value === 'number') value = String(value);
    if (typeof value !== 'string') return [];
    const text = decodeEntities(
      value
        .replace(/<\s*(br|\/p|\/li|\/div|\/h[1-6])\b[^>]*>/gi, '\n')
        .replace(/<[^>]+>/g, ' ')
    );
    return text
      .split(/\r?\n/)
      .map((line) => line.replace(/\s+/g, ' ').trim())
      .filter(Boolean);
  }

  /** One value as a single line of text, or '' when there is none. */
  function text(value) {
    if (Array.isArray(value)) value = value.find((v) => typeof v === 'string' || typeof v === 'number');
    return lines(value).join(' ');
  }

  function shorten(value, max) {
    return value.length <= max ? value : value.slice(0, max - 3).trimEnd() + '...';
  }

  /** The names in a field written as a list or as one comma separated string. */
  function names(value) {
    const out = [];
    for (const item of Array.isArray(value) ? value : [value]) {
      const name = typeof item === 'object' && item ? text(item.name) : text(item);
      for (const part of name.split(',')) {
        const clean = part.trim();
        if (clean && !out.includes(clean)) out.push(clean);
      }
    }
    return out;
  }

  // ── Recipe fields ─────────────────────────────────────────────────────

  function recipeName(recipe) {
    return recipe ? text(recipe.name) || text(recipe.headline) : '';
  }

  function ingredientsOf(recipe) {
    const list = recipe.recipeIngredient != null ? recipe.recipeIngredient : recipe.ingredients;
    const out = [];
    for (const item of Array.isArray(list) ? list : [list]) {
      const value = typeof item === 'object' && item ? item.text || item.name : item;
      out.push(...lines(value));
    }
    return out;
  }

  /**
   * The steps as lines. HowToSection groups are opened up; when there are
   * two or more named groups, each name comes first as "Name:", the line the
   * app turns into a heading.
   */
  function stepsOf(recipe) {
    const entries = [];
    const collect = (node, depth) => {
      if (depth > 8 || node == null) return;
      if (typeof node === 'string' || typeof node === 'number') {
        for (const line of lines(node)) entries.push({ step: line });
      } else if (Array.isArray(node)) {
        for (const item of node) collect(item, depth + 1);
      } else if (typeof node === 'object') {
        const types = [].concat(node['@type'] || []);
        const group = node.itemListElement || node.steps;
        if (group != null || types.some((t) => /Section$/i.test(String(t)))) {
          entries.push({ section: text(node.name) });
          collect(group, depth + 1);
        } else if (types.includes('ListItem') && node.item != null && node.text == null) {
          collect(node.item, depth + 1);
        } else {
          const body = lines(node.text);
          const own = body.length ? body : lines(node.description).length ? lines(node.description) : lines(node.name);
          for (const line of own) entries.push({ step: line });
        }
      }
    };
    collect(recipe.recipeInstructions, 0);
    const named = entries.filter((e) => e.section);
    const out = [];
    for (const entry of entries) {
      if (entry.step) out.push(entry.step);
      else if (named.length >= 2 && entry.section) out.push(entry.section.replace(/[\s:]+$/, '') + ':');
    }
    return out;
  }

  function imageOf(recipe, pageUrl) {
    let image = recipe.image;
    if (Array.isArray(image)) image = image[0];
    if (image && typeof image === 'object') image = image.url || image.contentUrl;
    if (typeof image !== 'string' || !image.trim()) return '';
    try {
      const url = new URL(decodeEntities(image.trim()), pageUrl || undefined);
      return url.protocol === 'http:' || url.protocol === 'https:' ? url.href : '';
    } catch (_) {
      return '';
    }
  }

  function yieldOf(recipe) {
    const values = (Array.isArray(recipe.recipeYield) ? recipe.recipeYield : [recipe.recipeYield])
      .map((v) => text(v))
      .filter(Boolean);
    if (!values.length) return '';
    // ["4", "4 servings"] says the same twice: the longer one says more.
    return values.reduce((a, b) => (b.length > a.length ? b : a));
  }

  function authorOf(recipe) {
    let author = recipe.author;
    if (Array.isArray(author)) author = author[0];
    if (author && typeof author === 'object') author = author.name;
    return text(author);
  }

  function nutritionOf(recipe) {
    const n = recipe.nutrition;
    if (!n || typeof n !== 'object') return null;
    const out = {};
    for (const key of ['calories', 'proteinContent', 'carbohydrateContent', 'fatContent', 'fiberContent']) {
      const value = text(n[key]);
      if (value) out[key] = shorten(value, 40);
    }
    return Object.keys(out).length ? out : null;
  }

  function duration(value) {
    const t = text(value);
    return /^P[0-9TDHMS.]+$/i.test(t) ? t.toUpperCase() : '';
  }

  /**
   * The recipe as small schema.org JSON for the link. [level] 0 keeps
   * everything that is sent; each higher level leaves out more of the
   * extras, for links that would otherwise be too long.
   */
  function compactRecipe(recipe, pageUrl, level) {
    level = level || 0;
    const out = { '@type': 'Recipe' };
    const put = (key, value) => {
      if (value && (!Array.isArray(value) || value.length)) out[key] = value;
    };
    put('name', shorten(recipeName(recipe), 200));
    put('recipeIngredient', ingredientsOf(recipe));
    put('recipeInstructions', stepsOf(recipe));
    put('recipeYield', shorten(yieldOf(recipe), 60));
    put('prepTime', duration(recipe.prepTime));
    put('cookTime', duration(recipe.cookTime || recipe.performTime));
    put('totalTime', duration(recipe.totalTime));
    if (level <= 1) {
      put('recipeCategory', names(recipe.recipeCategory).slice(0, 5));
      put('recipeCuisine', names(recipe.recipeCuisine).slice(0, 5));
      put('image', imageOf(recipe, pageUrl));
    }
    if (level <= 0) {
      put('description', shorten(text(recipe.description), 300));
      put('author', authorOf(recipe));
      put('keywords', names(recipe.keywords).filter((k) => k.length < 40).slice(0, 12));
      put('nutrition', nutritionOf(recipe));
    }
    return out;
  }

  const LEVELS = 3;

  // ── The link ──────────────────────────────────────────────────────────

  function isWebUrl(url) {
    return typeof url === 'string' && /^https?:\/\/[^/\s]/i.test(url.trim());
  }

  function bytesToBase64Url(bytes) {
    let binary = '';
    for (let i = 0; i < bytes.length; i += 0x8000) {
      binary += String.fromCharCode.apply(null, bytes.subarray(i, i + 0x8000));
    }
    return btoa(binary).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
  }

  /** Raw DEFLATE of [bytes], or null where the browser has no CompressionStream for it. */
  async function deflateRaw(bytes) {
    if (typeof CompressionStream !== 'function') return null;
    try {
      const stream = new Blob([bytes]).stream().pipeThrough(new CompressionStream('deflate-raw'));
      return new Uint8Array(await new Response(stream).arrayBuffer());
    } catch (_) {
      return null;
    }
  }

  /**
   * The recipespellbook://clip link for a page. [recipe] is what findRecipe
   * gave (or null), [maxLength] the longest link the system passes on.
   * Returns null when [url] is not a web page.
   */
  async function buildClipLink(options) {
    const url = options.url;
    if (!isWebUrl(url)) return null;
    const maxLength = options.maxLength || MAX_LINK_WINDOWS;
    const base = SCHEME + '?url=' + encodeURIComponent(url.trim());
    const title = shorten(text(options.title || ''), MAX_TITLE);
    let link = title ? base + '&title=' + encodeURIComponent(title) : base;
    if (link.length > maxLength) link = base;

    const recipe = options.recipe;
    if (!recipe) return link;
    for (let level = 0; level < LEVELS; level++) {
      const json = JSON.stringify(compactRecipe(recipe, url, level));
      const plain = new TextEncoder().encode(json);
      const packed = await deflateRaw(plain);
      const tries = packed && packed.length < plain.length ? [[packed, true], [plain, false]] : [[plain, false]];
      for (const [bytes, compressed] of tries) {
        const withData = link + '&data=' + bytesToBase64Url(bytes) + (compressed ? '&z=1' : '');
        if (withData.length <= maxLength) return withData;
      }
    }
    // Too big to send whole: the app reads the page itself.
    return link;
  }

  const api = {
    MAX_LINK_WINDOWS,
    MAX_LINK_OTHER,
    parseJsonLd,
    findRecipe,
    recipeName,
    ingredientsOf,
    stepsOf,
    compactRecipe,
    buildClipLink,
    isWebUrl,
  };

  if (typeof module === 'object' && module.exports) {
    module.exports = api;
  } else {
    root.RecipeClipper = api;
  }
})(typeof globalThis !== 'undefined' ? globalThis : this);
