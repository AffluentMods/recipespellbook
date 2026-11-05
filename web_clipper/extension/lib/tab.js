/*
 * Recipe Spellbook Web Clipper: reading the open tab and handing the clip
 * link to the app. Shared by the popup and the context menu (background).
 * Needs lib/recipe.js loaded first.
 *
 * The page is read only when the user clicks (the activeTab permission),
 * and nothing is sent anywhere: the link goes to the browser, which asks
 * the user before it opens the app.
 */
(function (root) {
  'use strict';

  const ext = root.browser || root.chrome;
  const clipper = root.RecipeClipper;

  /**
   * Runs inside the page (injected with scripting.executeScript), so it must
   * stand on its own. Returns the text of the page's JSON-LD blocks and its
   * titles; nothing else of the page is read.
   */
  function collectPageData() {
    const blocks = Array.from(document.querySelectorAll('script[type*="ld+json" i]'))
      .slice(0, 50)
      .map((script) => (script.textContent || '').slice(0, 1000000));
    const og = document.querySelector('meta[property="og:title"]');
    return {
      url: location.href,
      title: document.title || '',
      ogTitle: og ? og.getAttribute('content') || '' : '',
      blocks,
    };
  }

  /** What the tab holds: { url, title, recipe }. recipe is null when none was found. */
  async function readTab(tab) {
    let page = null;
    try {
      const results = await ext.scripting.executeScript({ target: { tabId: tab.id }, func: collectPageData });
      page = results && results[0] ? results[0].result : null;
    } catch (_) {
      // Pages the browser lets no extension read (its own pages, the
      // extension stores). The address can still be sent.
    }
    const url = page && clipper.isWebUrl(page.url) ? page.url : tab.url;
    const recipe = page ? clipper.findRecipe(page.blocks) : null;
    const title = clipper.recipeName(recipe) || (page && (page.ogTitle || page.title)) || tab.title || '';
    return { url, title, recipe };
  }

  /** The longest link this system passes on to an app. */
  async function maxLinkLength() {
    try {
      const info = await ext.runtime.getPlatformInfo();
      return info.os === 'win' ? clipper.MAX_LINK_WINDOWS : clipper.MAX_LINK_OTHER;
    } catch (_) {
      return clipper.MAX_LINK_WINDOWS;
    }
  }

  /**
   * Opens the clip link for [page] (from readTab) from [tab]. The browser asks
   * whether to open Recipe Spellbook; the page itself stays where it is.
   * False when the page is no web page.
   */
  async function sendToApp(tab, page) {
    const link = await clipper.buildClipLink({
      url: page.url,
      title: page.title,
      recipe: page.recipe,
      maxLength: await maxLinkLength(),
    });
    if (!link) return false;
    await ext.tabs.update(tab.id, { url: link });
    return true;
  }

  /** Reads [tab] and sends it to the app in one go (the context menu). */
  async function clipTab(tab) {
    if (!tab || !clipper.isWebUrl(tab.url)) return false;
    return sendToApp(tab, await readTab(tab));
  }

  root.ClipperTab = { readTab, sendToApp, clipTab };
})(globalThis);
