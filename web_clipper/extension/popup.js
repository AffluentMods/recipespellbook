/*
 * Recipe Spellbook Web Clipper: the toolbar popup. Shows the recipe found on
 * the page and sends it to the app when the user clicks Save. Without a
 * recipe on the page it still offers to send the page address, which the
 * app then reads itself.
 */
(function () {
  'use strict';

  const ext = globalThis.browser || globalThis.chrome;
  const clipper = globalThis.RecipeClipper;
  const tabs = globalThis.ClipperTab;

  const $ = (id) => document.getElementById(id);

  function show(id, text) {
    const el = $(id);
    if (text !== undefined) el.textContent = text;
    el.hidden = false;
  }

  function plural(count, one, many) {
    return count + ' ' + (count === 1 ? one : many);
  }

  async function start() {
    let tab;
    try {
      [tab] = await ext.tabs.query({ active: true, currentWindow: true });
    } catch (_) {
      tab = null;
    }
    if (!tab || !clipper.isWebUrl(tab.url)) {
      $('status').textContent = 'Open a recipe page in this tab to save it.';
      return;
    }

    const page = await tabs.readTab(tab);
    if (page.recipe) {
      const ingredients = clipper.ingredientsOf(page.recipe).length;
      const steps = clipper.stepsOf(page.recipe).length;
      $('status').hidden = true;
      show('title', page.title || 'Recipe');
      if (ingredients || steps) {
        show('details', plural(ingredients, 'ingredient', 'ingredients') + ', ' + plural(steps, 'step', 'steps'));
      }
      $('save').textContent = 'Save';
    } else {
      $('status').textContent =
        'No recipe found on this page. You can still send the page, and Recipe Spellbook will try to read it.';
      if (page.title) show('title', page.title);
      $('save').textContent = 'Send this page';
    }

    const button = $('save');
    button.hidden = false;
    button.focus();
    button.addEventListener('click', async () => {
      button.disabled = true;
      try {
        const sent = await tabs.sendToApp(tab, page);
        if (sent) {
          button.hidden = true;
          show('sent');
        } else {
          button.disabled = false;
        }
      } catch (_) {
        button.disabled = false;
        $('status').textContent = 'The page could not be sent. Try again.';
        $('status').hidden = false;
      }
    });
  }

  start();
})();
