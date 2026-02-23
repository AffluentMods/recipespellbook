import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// ═══════════════════════════════════════════════════════════════════
// CONSTANTS
// ═══════════════════════════════════════════════════════════════════

const _kWebGuideBaseUrl = 'https://recipespellbook.app/guides';

// ═══════════════════════════════════════════════════════════════════
// IMPORT GUIDES LANDING PAGE
// ═══════════════════════════════════════════════════════════════════

class ImportGuidesScreen extends StatelessWidget {
  const ImportGuidesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = _buildCategories();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Guides'),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser, size: 22),
            tooltip: 'Open guides in browser',
            onPressed: () => _launchUrl('$_kWebGuideBaseUrl'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // ── Hero ──
          _HeroBanner(theme: theme),
          const SizedBox(height: 24),

          // ── Quick tip ──
          _QuickTipCard(theme: theme),
          const SizedBox(height: 24),

          // ── Guide categories ──
          for (final cat in categories) ...[
            _CategoryHeader(title: cat.title, icon: cat.icon),
            const SizedBox(height: 8),
            for (final guide in cat.guides) ...[
              _GuideCard(guide: guide),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  List<_GuideCategory> _buildCategories() {
    return [
      // ── SOCIAL MEDIA ──
      _GuideCategory(
        title: 'Social Media',
        icon: Icons.share_rounded,
        guides: [
          _ImportGuide(
            id: 'instagram',
            icon: Icons.camera_alt_rounded,
            color: const Color(0xFFE1306C),
            title: 'Instagram',
            subtitle: 'Import from Reels, posts, and stories',
            tag: 'Popular',
            difficulty: 'Easy',
            timeEstimate: '30 sec',
            webSlug: 'instagram',
            steps: [
              _GuideStep(
                title: 'Find a recipe post or Reel',
                description: 'Open Instagram and find a recipe you want to save. This works with feed posts, Reels, and carousels.',
                icon: Icons.search,
                asset: _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Instagram Reel showing a recipe video with the share button visible',
                  filename: 'ig_recipe_reel.png',
                ),
              ),
              _GuideStep(
                title: 'Tap the share button',
                description: 'Tap the paper plane icon (share) below the post.',
                icon: Icons.send,
                asset: _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Instagram share button highlighted/circled on a recipe post',
                  filename: 'ig_share_button.png',
                ),
              ),
              _GuideStep(
                title: 'Share to Recipe Spellbook',
                description: 'Scroll the app row and tap Recipe Spellbook. If you don\'t see it, tap "More" and find it in the list.',
                icon: Icons.apps,
                asset: _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'iOS/Android share sheet with Recipe Spellbook icon visible in the app row',
                  filename: 'ig_share_sheet.png',
                ),
                tip: 'On Android, you can also copy the link and paste it in the app.',
              ),
              _GuideStep(
                title: 'Review the extracted recipe',
                description: 'Our AI reads the caption, hashtags, and any text in the image to build your recipe. Check ingredients and steps, then save.',
                icon: Icons.auto_awesome,
                asset: _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Recipe Spellbook import preview screen showing an extracted recipe from Instagram with ingredients and steps populated',
                  filename: 'ig_import_preview.png',
                ),
              ),
              _GuideStep(
                title: 'Pick a cookbook & save',
                description: 'Choose which cookbook to save to, add any tags, and tap Save. Done!',
                icon: Icons.bookmark_add,
                asset: _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Save recipe dialog showing cookbook picker dropdown and save button',
                  filename: 'ig_save_dialog.png',
                ),
              ),
            ],
          ),
          _ImportGuide(
            id: 'tiktok',
            icon: Icons.music_note_rounded,
            color: const Color(0xFF000000),
            title: 'TikTok',
            subtitle: 'Save recipes from cooking videos',
            tag: 'Popular',
            difficulty: 'Easy',
            timeEstimate: '30 sec',
            webSlug: 'tiktok',
            steps: [
              _GuideStep(
                title: 'Find a recipe TikTok',
                description: 'Open TikTok and find a cooking video you want to save.',
                icon: Icons.search,
                asset: _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'TikTok video of someone cooking with the share arrow visible on the right side',
                  filename: 'tt_recipe_video.png',
                ),
              ),
              _GuideStep(
                title: 'Tap the share arrow',
                description: 'Tap the arrow icon on the right side of the video.',
                icon: Icons.arrow_forward,
                asset: _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'TikTok share arrow button highlighted on the right sidebar',
                  filename: 'tt_share_arrow.png',
                ),
              ),
              _GuideStep(
                title: 'Choose "Copy link" or share directly',
                description: 'Either tap "Copy link" and paste in Recipe Spellbook, or find Recipe Spellbook in the share options.',
                icon: Icons.link,
                asset: _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'TikTok share menu showing Copy Link button and other share options',
                  filename: 'tt_copy_link.png',
                ),
                tip: '"Copy link" is often the most reliable method for TikTok.',
              ),
              _GuideStep(
                title: 'Paste the link in Recipe Spellbook',
                description: 'Open Recipe Spellbook, tap +, choose "From Website/Link", and paste the TikTok URL.',
                icon: Icons.paste,
                asset: _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Recipe Spellbook URL input field with a TikTok link pasted',
                  filename: 'tt_paste_url.png',
                ),
              ),
              _GuideStep(
                title: 'Review & save',
                description: 'The AI extracts the recipe from the video description and comments. Review and save to your cookbook.',
                icon: Icons.check_circle_outline,
                asset: _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Import preview showing extracted TikTok recipe with title, ingredients, and steps',
                  filename: 'tt_import_preview.png',
                ),
              ),
            ],
          ),
          _ImportGuide(
            id: 'youtube',
            icon: Icons.play_circle_filled,
            color: const Color(0xFFFF0000),
            title: 'YouTube',
            subtitle: 'Import from cooking channels & Shorts',
            difficulty: 'Easy',
            timeEstimate: '30 sec',
            webSlug: 'youtube',
            steps: [
              _GuideStep(
                title: 'Find a recipe video',
                description: 'Open YouTube and find a cooking video. Works with regular videos, Shorts, and livestream replays.',
                icon: Icons.ondemand_video,
                asset: _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'YouTube video player showing a recipe/cooking video with the share button visible below',
                  filename: 'yt_recipe_video.png',
                ),
              ),
              _GuideStep(
                title: 'Tap Share',
                description: 'Tap the Share button below the video title.',
                icon: Icons.share,
                asset: _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'YouTube share button highlighted below the video, above comments',
                  filename: 'yt_share_button.png',
                ),
              ),
              _GuideStep(
                title: 'Copy link or share to app',
                description: 'Tap "Copy link" or find Recipe Spellbook in the share sheet.',
                icon: Icons.content_copy,
                asset: _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'YouTube share options showing Copy Link and app sharing options',
                  filename: 'yt_copy_link.png',
                ),
                tip: 'Many YouTube creators put the full recipe in the video description — this makes extraction more accurate.',
              ),
              _GuideStep(
                title: 'Paste & import',
                description: 'In Recipe Spellbook, tap + > "From Website/Link" and paste. The AI reads the video description for ingredients and steps.',
                icon: Icons.auto_awesome,
                asset: _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Recipe Spellbook import preview from a YouTube video with recipe extracted',
                  filename: 'yt_import_preview.png',
                ),
              ),
            ],
          ),
          _ImportGuide(
            id: 'pinterest',
            icon: Icons.push_pin_rounded,
            color: const Color(0xFFE60023),
            title: 'Pinterest',
            subtitle: 'Save pinned recipes to your cookbook',
            difficulty: 'Easy',
            timeEstimate: '30 sec',
            webSlug: 'pinterest',
            steps: [
              _GuideStep(
                title: 'Open a recipe pin',
                description: 'Tap a recipe pin to open it. Most pins link to the original recipe website.',
                icon: Icons.open_in_new,
                asset: _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Pinterest pin showing a recipe with the visit/source button visible',
                  filename: 'pin_recipe_pin.png',
                ),
              ),
              _GuideStep(
                title: 'Tap the source link',
                description: 'Tap the link at the top or bottom of the pin to visit the original recipe page.',
                icon: Icons.link,
                asset: _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Pinterest pin detail showing the source URL/website link highlighted',
                  filename: 'pin_source_link.png',
                ),
                tip: 'If the pin doesn\'t have a source link, try the share method below instead.',
              ),
              _GuideStep(
                title: 'Copy the website URL',
                description: 'Once the recipe website opens in your browser, copy the URL from the address bar.',
                icon: Icons.content_copy,
                asset: _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Browser address bar showing a recipe website URL being copied',
                  filename: 'pin_copy_url.png',
                ),
              ),
              _GuideStep(
                title: 'Import in Recipe Spellbook',
                description: 'Tap + > "From Website/Link", paste the URL, and the recipe is extracted automatically.',
                icon: Icons.download_rounded,
                asset: _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Recipe Spellbook import preview from a Pinterest-sourced recipe',
                  filename: 'pin_import_preview.png',
                ),
              ),
            ],
          ),
          _ImportGuide(
            id: 'facebook',
            icon: Icons.facebook_rounded,
            color: const Color(0xFF1877F2),
            title: 'Facebook',
            subtitle: 'Import from posts, groups & Reels',
            difficulty: 'Medium',
            timeEstimate: '1 min',
            webSlug: 'facebook',
            steps: [
              _GuideStep(
                title: 'Find a recipe post',
                description: 'Open Facebook and find a recipe post, Reel, or video in a cooking group.',
                icon: Icons.search,
                asset: _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Facebook recipe post in a cooking group with the three-dot menu visible',
                  filename: 'fb_recipe_post.png',
                ),
              ),
              _GuideStep(
                title: 'Copy the link',
                description: 'Tap the three dots (•••) on the post and select "Copy link". For Reels, use the share button.',
                icon: Icons.more_horiz,
                asset: _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Facebook post menu showing "Copy link" option highlighted',
                  filename: 'fb_copy_link.png',
                ),
                tip: 'If the post is in a private group, copy the recipe text directly instead.',
              ),
              _GuideStep(
                title: 'Paste in Recipe Spellbook',
                description: 'Open Recipe Spellbook, tap + > "From Website/Link" and paste. If from a private group, use "From Text" instead and paste the recipe text.',
                icon: Icons.paste,
                asset: _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Recipe Spellbook URL input with a Facebook link pasted',
                  filename: 'fb_paste_url.png',
                ),
              ),
              _GuideStep(
                title: 'Review & save',
                description: 'Check the extracted recipe and save to your cookbook.',
                icon: Icons.check_circle_outline,
                asset: _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Import preview showing extracted Facebook recipe',
                  filename: 'fb_import_preview.png',
                ),
              ),
            ],
          ),
        ],
      ),

      // ── WEBSITES ──
      _GuideCategory(
        title: 'Websites',
        icon: Icons.language_rounded,
        guides: [
          _ImportGuide(
            id: 'website',
            icon: Icons.link_rounded,
            color: const Color(0xFF2196F3),
            title: 'Any Recipe Website',
            subtitle: 'AllRecipes, Food Network, BBC, blogs & more',
            tag: 'Easiest',
            difficulty: 'Easy',
            timeEstimate: '15 sec',
            webSlug: 'website',
            steps: [
              _GuideStep(
                title: 'Open the recipe page',
                description: 'Navigate to any recipe on sites like AllRecipes, Food Network, BBC Good Food, Serious Eats, NYT Cooking, or any food blog.',
                icon: Icons.travel_explore,
                asset: _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'A recipe website (e.g. AllRecipes) showing a recipe page with the URL visible in the browser bar',
                  filename: 'web_recipe_page.png',
                ),
              ),
              _GuideStep(
                title: 'Copy the URL',
                description: 'Tap the address bar and copy the full URL to the recipe.',
                icon: Icons.content_copy,
                asset: _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Browser address bar selected with the recipe URL highlighted and copy option showing',
                  filename: 'web_copy_url.png',
                ),
              ),
              _GuideStep(
                title: 'Tap + in Recipe Spellbook',
                description: 'Open the app and tap the + button to start adding a new recipe.',
                icon: Icons.add_circle_outline,
                asset: _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Recipe Spellbook home screen with the + FAB button highlighted',
                  filename: 'web_add_button.png',
                ),
              ),
              _GuideStep(
                title: 'Choose "From Website/Link"',
                description: 'Select the website import option and paste your copied URL.',
                icon: Icons.paste,
                asset: _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Recipe Spellbook add recipe menu showing "From Website/Link" option and URL paste field',
                  filename: 'web_paste_field.png',
                ),
              ),
              _GuideStep(
                title: 'Review & save',
                description: 'The recipe is extracted instantly — title, ingredients, steps, cook times, and even the photo. Review and save.',
                icon: Icons.check_circle_outline,
                asset: _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Import preview showing a fully extracted recipe with image, ingredients list, steps, and prep/cook times',
                  filename: 'web_import_preview.png',
                ),
                tip: 'Works with 10,000+ recipe sites. If extraction fails, try the "From Text" method.',
              ),
            ],
          ),
        ],
      ),

      // ── PHOTOS & FILES ──
      _GuideCategory(
        title: 'Photos & Files',
        icon: Icons.photo_library_rounded,
        guides: [
          _ImportGuide(
            id: 'photo',
            icon: Icons.camera_alt_outlined,
            color: const Color(0xFF9C27B0),
            title: 'Photo / Camera',
            subtitle: 'Scan recipes from books, magazines, or handwritten cards',
            difficulty: 'Easy',
            timeEstimate: '30 sec',
            webSlug: 'photo',
            steps: [
              _GuideStep(
                title: 'Photograph the recipe',
                description: 'Take a clear, well-lit photo of a recipe from a cookbook, magazine page, or handwritten recipe card. Make sure all text is readable.',
                icon: Icons.camera_alt,
                asset: _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Camera viewfinder pointed at an open cookbook page showing a recipe, with good lighting and the text clearly visible',
                  filename: 'photo_capture.png',
                ),
                tip: 'For best results: use good lighting, hold steady, and make sure the entire recipe is in frame. Avoid shadows.',
              ),
              _GuideStep(
                title: 'Tap + then "From Photo"',
                description: 'Open Recipe Spellbook, tap +, and choose "From Photo". Select the photo from your gallery or take a new one.',
                icon: Icons.add_photo_alternate,
                asset: _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Recipe Spellbook add menu showing "From Photo" option, then the photo picker/camera prompt',
                  filename: 'photo_select.png',
                ),
              ),
              _GuideStep(
                title: 'AI scans the text',
                description: 'OCR technology reads the text in your photo and AI intelligently separates the title, ingredients, and instructions.',
                icon: Icons.document_scanner,
                asset: _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Loading/processing screen showing "Scanning recipe..." with a progress indicator',
                  filename: 'photo_scanning.png',
                ),
              ),
              _GuideStep(
                title: 'Review & fix any errors',
                description: 'Check the extracted recipe. OCR occasionally misreads characters — "1/2" might become "1l2". Fix any errors and save.',
                icon: Icons.edit_note,
                asset: _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Import preview from a photo scan with ingredients and steps, showing editable text fields',
                  filename: 'photo_review.png',
                ),
                tip: 'Handwritten recipes work too, but printed text gives the best results.',
              ),
            ],
          ),
          _ImportGuide(
            id: 'pdf',
            icon: Icons.picture_as_pdf_outlined,
            color: const Color(0xFFFF5722),
            title: 'PDF Document',
            subtitle: 'Import from PDF cookbooks or downloads',
            difficulty: 'Easy',
            timeEstimate: '30 sec',
            webSlug: 'pdf',
            steps: [
              _GuideStep(
                title: 'Have a recipe PDF ready',
                description: 'This works with downloaded recipe PDFs, ebook cookbooks, scanned documents, or PDFs shared via email.',
                icon: Icons.description,
                asset: _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Files app or email showing a recipe PDF file ready to be selected',
                  filename: 'pdf_file_ready.png',
                ),
              ),
              _GuideStep(
                title: 'Tap + then "From PDF"',
                description: 'Open Recipe Spellbook, tap +, choose "From PDF", and select your file.',
                icon: Icons.file_open,
                asset: _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'File picker showing PDF files with one selected',
                  filename: 'pdf_file_picker.png',
                ),
              ),
              _GuideStep(
                title: 'Select the recipe page',
                description: 'If the PDF has multiple pages, choose which page contains the recipe you want to import.',
                icon: Icons.checklist,
                asset: _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Page selector showing thumbnail previews of PDF pages with recipe pages highlighted',
                  filename: 'pdf_page_select.png',
                ),
              ),
              _GuideStep(
                title: 'Review & save',
                description: 'The recipe is extracted from the PDF. Review the ingredients and steps, then save to your cookbook.',
                icon: Icons.check_circle_outline,
                asset: _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Import preview showing recipe extracted from PDF with all fields populated',
                  filename: 'pdf_import_preview.png',
                ),
              ),
            ],
          ),
          _ImportGuide(
            id: 'text',
            icon: Icons.text_snippet_outlined,
            color: const Color(0xFF607D8B),
            title: 'Text / Paste',
            subtitle: 'Paste a recipe from messages, email, or notes',
            difficulty: 'Easy',
            timeEstimate: '30 sec',
            webSlug: 'text',
            steps: [
              _GuideStep(
                title: 'Copy recipe text',
                description: 'Copy the recipe text from a text message, email, notes app, WhatsApp, or anywhere else.',
                icon: Icons.content_copy,
                asset: _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Messages/email app with recipe text selected and "Copy" button visible',
                  filename: 'text_copy_source.png',
                ),
              ),
              _GuideStep(
                title: 'Tap + then "From Text"',
                description: 'Open Recipe Spellbook, tap +, and choose "From Text".',
                icon: Icons.add_circle_outline,
                asset: _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Add recipe menu with "From Text" option highlighted',
                  filename: 'text_add_menu.png',
                ),
              ),
              _GuideStep(
                title: 'Paste your recipe',
                description: 'Paste the copied text into the text field. The AI will automatically separate the title, ingredients, and steps.',
                icon: Icons.paste,
                asset: _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Text import screen with recipe text pasted in the input field and an "Import" button below',
                  filename: 'text_paste_field.png',
                ),
                tip: 'This works even with unformatted text — the AI is smart about parsing ingredient amounts and step instructions.',
              ),
              _GuideStep(
                title: 'Review & save',
                description: 'Check the parsed recipe, make any adjustments, and save.',
                icon: Icons.check_circle_outline,
                asset: _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Import preview from pasted text showing properly parsed ingredients and steps',
                  filename: 'text_import_preview.png',
                ),
              ),
            ],
          ),
        ],
      ),

      // ── OTHER APPS ──
      _GuideCategory(
        title: 'Other Recipe Apps',
        icon: Icons.swap_horiz_rounded,
        guides: [
          _ImportGuide(
            id: 'paprika',
            icon: Icons.swap_horiz_rounded,
            color: const Color(0xFFFF9800),
            title: 'Paprika Recipe Manager',
            subtitle: 'Bulk import your entire Paprika library',
            difficulty: 'Medium',
            timeEstimate: '2–5 min',
            webSlug: 'paprika',
            steps: [
              _GuideStep(
                title: 'Export from Paprika',
                description: 'In Paprika, go to Settings (gear icon) > Export. Choose "Export All Recipes" and save as a .paprikarecipes file.',
                icon: Icons.file_download,
                asset: _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Paprika app settings screen showing the Export option, then the export dialog',
                  filename: 'paprika_export.png',
                ),
              ),
              _GuideStep(
                title: 'Send the file to your device',
                description: 'Email the file to yourself, save to iCloud/Google Drive, or use AirDrop to transfer it.',
                icon: Icons.send,
                asset: _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Share/save dialog for the .paprikarecipes export file',
                  filename: 'paprika_transfer.png',
                ),
              ),
              _GuideStep(
                title: 'Import in Recipe Spellbook',
                description: 'Open Recipe Spellbook, go to Settings > Data > Import and select the .paprikarecipes file.',
                icon: Icons.file_open,
                asset: _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Recipe Spellbook Settings > Data > Import screen with file picker open showing the Paprika export file',
                  filename: 'paprika_import.png',
                ),
              ),
              _GuideStep(
                title: 'Wait for import',
                description: 'All your Paprika recipes are imported with ingredients, steps, notes, photos, and categories preserved.',
                icon: Icons.hourglass_bottom,
                asset: _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Import progress indicator followed by success message showing "Imported 47 recipes"',
                  filename: 'paprika_success.png',
                ),
                tip: 'Large libraries (100+ recipes) may take a minute. The app stays responsive while importing.',
              ),
            ],
          ),
          _ImportGuide(
            id: 'other-apps',
            icon: Icons.apps_rounded,
            color: const Color(0xFF4CAF50),
            title: 'Other Recipe Apps',
            subtitle: 'Mealime, CopyMeThat, AnyList, Cookmate, etc.',
            difficulty: 'Medium',
            timeEstimate: '2–5 min',
            webSlug: 'other-apps',
            steps: [
              _GuideStep(
                title: 'Export from your current app',
                description: 'Most recipe apps support exporting to JSON, HTML, or text. Check their Settings > Export or Backup section.',
                icon: Icons.file_download,
                asset: _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Generic settings/export screen from a recipe app (illustration style, not a specific app)',
                  filename: 'other_export.png',
                ),
                tip: 'Common formats: JSON (best), HTML, PDF, or plain text. JSON preserves the most data.',
              ),
              _GuideStep(
                title: 'Get the file on your device',
                description: 'Save or transfer the exported file to your phone using email, cloud storage, or a file transfer method.',
                icon: Icons.cloud_download,
                asset: _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Files app showing a downloaded recipe export file (JSON or HTML)',
                  filename: 'other_file_ready.png',
                ),
              ),
              _GuideStep(
                title: 'Import via Settings',
                description: 'In Recipe Spellbook, go to Settings > Data > Import and select the exported file. The app handles JSON, HTML, and common recipe formats.',
                icon: Icons.settings,
                asset: _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Recipe Spellbook Settings > Data > Import with file picker',
                  filename: 'other_import.png',
                ),
              ),
              _GuideStep(
                title: 'Check your recipes',
                description: 'Imported recipes appear in your default cookbook. You can reorganize them into different cookbooks afterward.',
                icon: Icons.library_books,
                asset: _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Cookbook view showing newly imported recipes from another app',
                  filename: 'other_success.png',
                ),
              ),
            ],
          ),
          _ImportGuide(
            id: 'device-transfer',
            icon: Icons.phone_android,
            color: const Color(0xFF795548),
            title: 'Device Transfer',
            subtitle: 'Move recipes between phones without an account',
            difficulty: 'Easy',
            timeEstimate: '1 min',
            webSlug: 'device-transfer',
            steps: [
              _GuideStep(
                title: 'Open Transfer on the OLD device',
                description: 'On your old phone, open Recipe Spellbook and go to Menu > Device Transfer > Send.',
                icon: Icons.phone_android,
                asset: _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Recipe Spellbook device transfer screen showing "Send" tab with a generated 6-character code',
                  filename: 'transfer_send.png',
                ),
              ),
              _GuideStep(
                title: 'Get the transfer code',
                description: 'A 6-character code is generated. This code is valid for 15 minutes.',
                icon: Icons.pin,
                asset: _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Transfer screen showing a large, clear 6-character code with a 15-minute countdown timer',
                  filename: 'transfer_code.png',
                ),
              ),
              _GuideStep(
                title: 'Enter code on NEW device',
                description: 'On your new phone, install Recipe Spellbook and go to Menu > Device Transfer > Receive. Enter the code.',
                icon: Icons.input,
                asset: _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Transfer receive screen with code input field on the new device',
                  filename: 'transfer_receive.png',
                ),
              ),
              _GuideStep(
                title: 'Recipes transferred!',
                description: 'All your recipes, cookbooks, shopping lists, and meal plans are transferred to the new device.',
                icon: Icons.check_circle,
                asset: _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Success screen showing "Transfer complete — X recipes, X cookbooks imported"',
                  filename: 'transfer_success.png',
                ),
                tip: 'Have a paid account? Just sign in on the new device and everything syncs automatically.',
              ),
            ],
          ),
        ],
      ),
    ];
  }
}

// ═══════════════════════════════════════════════════════════════════
// DATA MODELS
// ═══════════════════════════════════════════════════════════════════

class _GuideCategory {
  final String title;
  final IconData icon;
  final List<_ImportGuide> guides;
  const _GuideCategory({required this.title, required this.icon, required this.guides});
}

class _ImportGuide {
  final String id;
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String? tag;
  final String difficulty;
  final String timeEstimate;
  final String webSlug;
  final List<_GuideStep> steps;

  const _ImportGuide({
    required this.id,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    this.tag,
    required this.difficulty,
    required this.timeEstimate,
    required this.webSlug,
    required this.steps,
  });
}

class _GuideStep {
  final String title;
  final String description;
  final IconData icon;
  final _StepAsset? asset;
  final String? tip;

  const _GuideStep({
    required this.title,
    required this.description,
    required this.icon,
    this.asset,
    this.tip,
  });
}

enum _AssetType { screenshot, gif, video }

class _StepAsset {
  final _AssetType type;
  final String description; // What the image should show
  final String filename;    // Expected asset filename

  const _StepAsset({
    required this.type,
    required this.description,
    required this.filename,
  });
}

// ═══════════════════════════════════════════════════════════════════
// HERO BANNER
// ═══════════════════════════════════════════════════════════════════

class _HeroBanner extends StatelessWidget {
  final ThemeData theme;
  const _HeroBanner({required this.theme});

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: isDark ? 0.3 : 0.1),
            theme.colorScheme.tertiary.withValues(alpha: isDark ? 0.15 : 0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.auto_awesome, size: 36, color: theme.colorScheme.primary),
          const SizedBox(height: 12),
          Text(
            'Bring your recipes from anywhere',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Tap any guide below for step-by-step instructions with screenshots.',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// QUICK TIP CARD
// ═══════════════════════════════════════════════════════════════════

class _QuickTipCard extends StatelessWidget {
  final ThemeData theme;
  const _QuickTipCard({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.lightbulb_outline, size: 20, color: Colors.amber),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Quick tip',
                    style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600, color: Colors.amber.shade800)),
                const SizedBox(height: 2),
                Text(
                  'The fastest way? Copy any recipe link and share it to Recipe Spellbook — works from almost any app.',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// CATEGORY HEADER
// ═══════════════════════════════════════════════════════════════════

class _CategoryHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _CategoryHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.outline),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.outline,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// GUIDE CARD — landing page item
// ═══════════════════════════════════════════════════════════════════

class _GuideCard extends StatelessWidget {
  final _ImportGuide guide;
  const _GuideCard({required this.guide});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: isDark
          ? theme.colorScheme.surfaceContainerHigh
          : theme.colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => _GuideDetailScreen(guide: guide)),
        ),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? theme.colorScheme.outlineVariant.withValues(alpha: 0.25)
                  : theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
              width: 0.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // Icon
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: guide.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(guide.icon, size: 22, color: guide.color),
              ),
              const SizedBox(width: 14),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(guide.title,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                        if (guide.tag != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: guide.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(guide.tag!,
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: guide.color)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(guide.subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Meta + chevron
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(guide.timeEstimate,
                      style: TextStyle(fontSize: 11, color: theme.colorScheme.outline, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Icon(Icons.chevron_right, size: 18, color: theme.colorScheme.outline.withValues(alpha: 0.4)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// GUIDE DETAIL SCREEN
// ═══════════════════════════════════════════════════════════════════

class _GuideDetailScreen extends StatelessWidget {
  final _ImportGuide guide;
  const _GuideDetailScreen({super.key, required this.guide});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(guide.title),
        actions: [
          TextButton.icon(
            onPressed: () => _launchUrl('$_kWebGuideBaseUrl/${guide.webSlug}'),
            icon: const Icon(Icons.open_in_browser, size: 18),
            label: const Text('Web'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          // ── Hero header ──
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  guide.color.withValues(alpha: isDark ? 0.25 : 0.1),
                  guide.color.withValues(alpha: isDark ? 0.08 : 0.03),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: guide.color.withValues(alpha: 0.12)),
            ),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: guide.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(guide.icon, size: 28, color: guide.color),
                ),
                const SizedBox(height: 14),
                Text(guide.title,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center),
                const SizedBox(height: 6),
                Text(guide.subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    textAlign: TextAlign.center),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _MetaPill(icon: Icons.timer_outlined, label: guide.timeEstimate, color: guide.color),
                    const SizedBox(width: 8),
                    _MetaPill(icon: Icons.signal_cellular_alt, label: guide.difficulty, color: guide.color),
                    const SizedBox(width: 8),
                    _MetaPill(icon: Icons.format_list_numbered, label: '${guide.steps.length} steps', color: guide.color),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Steps ──
          for (int i = 0; i < guide.steps.length; i++)
            _StepCard(
              step: guide.steps[i],
              color: guide.color,
              isLast: i == guide.steps.length - 1,
            ),

          // ── Open in browser CTA ──
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _launchUrl('$_kWebGuideBaseUrl/${guide.webSlug}'),
            icon: const Icon(Icons.open_in_browser, size: 18),
            label: const Text('Follow along in browser'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// META PILL (time, difficulty, step count)
// ═══════════════════════════════════════════════════════════════════

class _MetaPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _MetaPill({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// STEP CARD — timeline with screenshot placeholder
// ═══════════════════════════════════════════════════════════════════

class _StepCard extends StatelessWidget {
  final _GuideStep step;
  final Color color;
  final bool isLast;

  const _StepCard({required this.step, required this.color, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stepIndex = step.title; // We use the icon + title approach

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Timeline column ──
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
                  ),
                  child: Center(
                    child: Icon(step.icon, size: 16, color: color),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color.withValues(alpha: 0.25), color.withValues(alpha: 0.05)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // ── Content ──
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Text(step.title,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text(step.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant, height: 1.5)),

                  // ── Screenshot placeholder ──
                  if (step.asset != null) ...[
                    const SizedBox(height: 12),
                    _AssetPlaceholder(asset: step.asset!, color: color),
                  ],

                  // ── Tip box ──
                  if (step.tip != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.amber.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.lightbulb_outline, size: 16, color: Colors.amber),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(step.tip!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant, fontSize: 12, height: 1.4)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// ASSET PLACEHOLDER — shows where screenshots go
// ═══════════════════════════════════════════════════════════════════

class _AssetPlaceholder extends StatelessWidget {
  final _StepAsset asset;
  final Color color;
  const _AssetPlaceholder({required this.asset, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Try to load the real asset first
    final assetPath = 'assets/guides/${asset.filename}';

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 180, maxHeight: 320),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Image.asset(
          assetPath,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _buildPlaceholder(theme),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    final typeIcon = switch (asset.type) {
      _AssetType.screenshot => Icons.phone_android,
      _AssetType.gif => Icons.gif_box_outlined,
      _AssetType.video => Icons.play_circle_outline,
    };
    final typeLabel = switch (asset.type) {
      _AssetType.screenshot => 'Screenshot needed',
      _AssetType.gif => 'GIF needed',
      _AssetType.video => 'Video needed',
    };

    return Container(
      height: 180,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(typeIcon, size: 32, color: color.withValues(alpha: 0.3)),
          const SizedBox(height: 10),
          Text(typeLabel,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                  color: color.withValues(alpha: 0.5))),
          const SizedBox(height: 6),
          Text(asset.description,
              style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline.withValues(alpha: 0.5),
                  fontSize: 11, height: 1.4),
              textAlign: TextAlign.center,
              maxLines: 3, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(asset.filename,
                style: TextStyle(fontSize: 9, fontFamily: 'monospace',
                    color: theme.colorScheme.outline.withValues(alpha: 0.4))),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// URL LAUNCHER
// ═══════════════════════════════════════════════════════════════════

Future<void> _launchUrl(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}