/*
 * Recipe Spellbook Web Clipper: the right-click menu.
 *
 * Chrome, Edge and Brave run this as a service worker and load the shared
 * files here; Firefox runs it as a background script with those files listed
 * before it in manifest.json.
 */
if (typeof importScripts === 'function') {
  importScripts('lib/recipe.js', 'lib/tab.js');
}

const MENU_ID = 'save-to-recipe-spellbook';
const extApi = globalThis.browser || globalThis.chrome;

async function createMenu() {
  try {
    await extApi.contextMenus.removeAll();
  } catch (_) {
    // Nothing to remove.
  }
  extApi.contextMenus.create({
    id: MENU_ID,
    title: 'Save to Recipe Spellbook',
    contexts: ['page'],
  });
}

extApi.runtime.onInstalled.addListener(createMenu);
extApi.runtime.onStartup.addListener(createMenu);

extApi.contextMenus.onClicked.addListener((info, tab) => {
  if (info.menuItemId !== MENU_ID) return;
  globalThis.ClipperTab.clipTab(tab).catch(() => {
    // Nothing to tell from a menu: the page could not be read or sent.
  });
});
