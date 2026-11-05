# Recipe Spellbook Web Clipper

A browser extension that saves the recipe on the page you are looking at into
the Recipe Spellbook desktop app. One codebase (Manifest V3) for Chrome, Edge,
Brave and Firefox.

There is no server. When you click, the extension reads the page's schema.org
recipe data (the JSON-LD most recipe sites carry), packs it into a
`recipespellbook://clip` link and asks the browser to open that link. The
browser asks you once whether to open Recipe Spellbook; the app then shows
its usual import preview, you pick a cookbook and save.

The extension text is English only for now.

## What is in this folder

```text
web_clipper/
  extension/            everything that ships (load this folder, zip this folder)
    manifest.json
    background.js       right-click menu "Save to Recipe Spellbook"
    popup.html/.css/.js the toolbar popup
    lib/recipe.js       finds the recipe in the JSON-LD, builds the link (no browser APIs)
    lib/tab.js          reads the open tab, opens the link
    icons/              16, 32, 48 and 128 px, made from assets/images/icon.png
  test/
    extract.test.js     Node tests for lib/recipe.js and lib/tab.js (stand-in browser API)
    fixtures/           saved pages the tests read
```

## How it works

1. You click the toolbar button (or right-click the page and choose
   **Save to Recipe Spellbook**).
2. The extension reads the text of the page's
   `<script type="application/ld+json">` blocks and its title. Nothing else of
   the page is read, and only when you click.
3. It finds the Recipe in them: at the top, in a list, in `@graph`, as
   `mainEntity`, with `HowToSection` groups of steps opened up. A page with
   several blocks, broken blocks or a teaser for another recipe is fine.
4. It builds the link and opens it in the tab, so the page stays where it is:

   ```text
   recipespellbook://clip?url=<page>&title=<title>&data=<recipe>&z=1
   ```

   `data` is a compact schema.org Recipe (name, ingredients, steps, yield,
   times, and while there is room image, category, cuisine, description,
   author, keywords, nutrition) as JSON, raw DEFLATE compressed (`z=1`), then
   base64url. Browsers on Windows will not hand a link longer than about 2,000
   characters to an app, so on Windows the link is kept under 2,000
   characters, elsewhere under 8,000. When the recipe does not fit even with
   the extras left out, `data` is not sent and the app fetches the page
   itself, as it does for a pasted link.
5. The app (`lib/utils/clip_request.dart`, `lib/ui/screens/import/clip_import_screen.dart`)
   checks the link again: http and https pages only, no addresses on the
   local network, size limits on everything. It prefers the recipe that came
   with the link, which also works for pages behind a login or built by
   scripts.

Permissions: `activeTab` (read the tab you clicked on, only then),
`scripting` (to read the JSON-LD from that tab) and `contextMenus` (the
right-click item). No host permissions, no remote code, no analytics, no
storage.

## Requirements

The Recipe Spellbook desktop app must be installed, because it is the app
that registers `recipespellbook://` links:

* Windows: the installer or the Microsoft Store package.
* macOS: the Mac app.
* Linux: the builds do not register the link yet, so the clipper does nothing
  there (see Limitations).

If the app is not installed the browser shows nothing useful when you click
Save. The popup links to https://recipespellbook.app/download for that.

## Load it unpacked (to try it)

**Chrome, Edge, Brave**

1. Open `chrome://extensions` (Edge: `edge://extensions`, Brave:
   `brave://extensions`).
2. Turn on **Developer mode**.
3. Click **Load unpacked** and pick the `web_clipper/extension` folder.
4. Pin the Recipe Spellbook button to the toolbar from the puzzle piece menu.

**Firefox** (121 or newer)

1. Open `about:debugging#/runtime/this-firefox`.
2. Click **Load Temporary Add-on** and pick `web_clipper/extension/manifest.json`.
   It stays loaded until Firefox closes.

**Try it**

1. Open any recipe page, for example a recipe on allrecipes.com,
   bbcgoodfood.com or a food blog.
2. Click the Recipe Spellbook button. The popup shows the recipe's name and
   how many ingredients and steps it found. Click **Save**.
3. The browser asks to open Recipe Spellbook. Allow it.
4. The app comes to the front (it starts if it was closed), asks which
   cookbook when you have more than one, and shows the import preview.
5. Also try right-clicking a page and choosing **Save to Recipe Spellbook**,
   and a page without a recipe: the popup then offers **Send this page**,
   and the app tries to read the page itself.

## Tests

Node 20.12 or newer, no packages to install:

```sh
node web_clipper/test/extract.test.js
```

The app side is covered by `test/invite_link_parser_test.dart` and
`test/clip_import_test.dart`.

## Package it for the stores

Bump `version` in `extension/manifest.json` for every upload. Then zip the
**contents** of `extension/` (manifest.json at the top of the zip, not inside a
folder).

Windows (PowerShell, from the repo root):

```powershell
Compress-Archive -Path web_clipper\extension\* -DestinationPath recipe-spellbook-web-clipper-1.0.0.zip -Force
```

macOS or Linux:

```sh
cd web_clipper/extension && zip -r ../../recipe-spellbook-web-clipper-1.0.0.zip . -x '.*'
```

The same zip goes to all stores. Brave installs from the Chrome Web Store.

### Chrome Web Store

1. Register a developer account at https://chrome.google.com/webstore/devconsole
   (one-time registration fee) and verify the contact email.
2. **New item**, upload the zip.
3. Fill in the listing with the text below, the 128 px icon
   (`extension/icons/icon-128.png`), at least one 1280x800 screenshot (the
   popup over a recipe page) and a 440x280 small promo tile.
4. **Privacy practices**: single purpose and the permission reasons below;
   tick that no user data is collected; link the privacy policy page on
   recipespellbook.app.
5. Submit for review.

### Microsoft Edge Add-ons

1. Register at https://partner.microsoft.com/dashboard/microsoftedge (free),
   with the same Microsoft account as the Store app if possible.
2. **Create new extension**, upload the same zip, fill in the same listing
   text, screenshots and privacy policy link, submit.

### Firefox Add-ons (optional)

1. Sign in at https://addons.mozilla.org/developers/ (free).
2. **Submit a New Add-on**, "On this site", upload the same zip. The add-on id
   is `web-clipper@recipespellbook.app` (in manifest.json). Answer the data
   collection question with "none", as the manifest says.

### After publishing

Put the store page address in `webClipperStoreUrl` in
`lib/ui/screens/import/import_guides_screen.dart`. Until then the Web Clipper
guide in the app (Import guides, Websites) shows its steps without the
**Get the extension** button.

## Store listing text

**Name:** Recipe Spellbook Web Clipper

**Short description** (132 characters at most):

> Save the recipe on any web page into Recipe Spellbook with one click. Reads the page only when you click and sends nothing anywhere.

**Long description:**

> Found a recipe you want to keep? Click the Recipe Spellbook button and it
> goes straight into your Recipe Spellbook cookbooks.
>
> How it works
> * Open a recipe page and click the Recipe Spellbook button in the toolbar,
>   or right-click the page and choose "Save to Recipe Spellbook".
> * The popup shows the recipe it found. Click Save.
> * Your browser opens the Recipe Spellbook app with the recipe ready to
>   check: ingredients, steps, times, servings and photo. Pick a cookbook and
>   save it.
>
> Works on most recipe sites and food blogs. The recipe is read from the
> page you already have open, so it often works even for recipes behind a
> login.
>
> Needs the Recipe Spellbook app for Windows or Mac:
> https://recipespellbook.app/download
>
> Private by design
> * The extension reads the page only when you click it, and only the
>   recipe data the page publishes for search engines.
> * It sends nothing to any server. The recipe goes from your browser
>   straight to the app on your computer.
> * No account, no tracking, no analytics.

**Privacy (for the privacy practices or data usage forms):**

> Recipe Spellbook Web Clipper reads the current page only when you click its
> button or its menu item, and only the page's address, title and structured
> recipe data. It passes them to the Recipe Spellbook app on your computer
> through a recipespellbook:// link. It sends nothing to any server, collects
> no personal data and uses no analytics.

**Single purpose:**

> Save the recipe on the current web page into the Recipe Spellbook app.

**Permission reasons:**

* `activeTab`: read the tab the user clicked the button or menu item on, and
  only that tab, only then.
* `scripting`: read the recipe data (JSON-LD) from that tab.
* `contextMenus`: the "Save to Recipe Spellbook" item in the right-click menu.

## Limitations

* Desktop browsers only. Phone browsers do not run these extensions; on
  phones, share the page to Recipe Spellbook instead.
* Linux: the app does not register `recipespellbook://` links on Linux yet
  (that needs a .desktop file with `x-scheme-handler/recipespellbook` and the
  app_links Linux setup), so the link has nowhere to go.
* On Windows, recipes too big for a 2,000 character link are fetched by the
  app from the page instead; that does not work for pages behind a login.
* Pages without schema.org recipe data are sent as a plain address, and the
  app reads them as it reads a pasted link.
