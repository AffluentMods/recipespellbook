import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final categories = _buildCategories(l10n);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.importGuidesTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser, size: 22),
            tooltip: l10n.importGuidesOpenInBrowser,
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

  List<_GuideCategory> _buildCategories(AppLocalizations l10n) {
    return [
      // ── SOCIAL MEDIA ──
      _GuideCategory(
        title: l10n.importGuideCategorySocial,
        icon: Icons.share_rounded,
        guides: [
          _ImportGuide(
            id: 'instagram',
            icon: Icons.camera_alt_rounded,
            color: const Color(0xFFE1306C),
            title: l10n.importGuideInstagramTitle,
            subtitle: l10n.importGuideInstagramSubtitle,
            tag: l10n.importGuideTagPopular,
            difficulty: l10n.importGuideDifficultyEasy,
            timeEstimate: l10n.importGuideTime30Sec,
            webSlug: 'instagram',
            steps: [
              _GuideStep(
                title: l10n.importGuideInstagramStep1Title,
                description: l10n.importGuideInstagramStep1Desc,
                icon: Icons.search,
                asset: const _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Instagram Reel showing a recipe video with the share button visible',
                  filename: 'ig_recipe_reel.png',
                ),
              ),
              _GuideStep(
                title: l10n.importGuideInstagramStep2Title,
                description: l10n.importGuideInstagramStep2Desc,
                icon: Icons.send,
                asset: const _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Instagram share button highlighted/circled on a recipe post',
                  filename: 'ig_share_button.png',
                ),
              ),
              _GuideStep(
                title: l10n.importGuideInstagramStep3Title,
                description: l10n.importGuideInstagramStep3Desc,
                icon: Icons.apps,
                asset: const _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'iOS/Android share sheet with Recipe Spellbook icon visible in the app row',
                  filename: 'ig_share_sheet.png',
                ),
                tip: l10n.importGuideInstagramStep3Tip,
              ),
              _GuideStep(
                title: l10n.importGuideInstagramStep4Title,
                description: l10n.importGuideInstagramStep4Desc,
                icon: Icons.auto_awesome,
                asset: const _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Recipe Spellbook import preview screen showing an extracted recipe from Instagram with ingredients and steps populated',
                  filename: 'ig_import_preview.png',
                ),
              ),
              _GuideStep(
                title: l10n.importGuideInstagramStep5Title,
                description: l10n.importGuideInstagramStep5Desc,
                icon: Icons.bookmark_add,
                asset: const _StepAsset(
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
            title: l10n.importGuideTiktokTitle,
            subtitle: l10n.importGuideTiktokSubtitle,
            tag: l10n.importGuideTagPopular,
            difficulty: l10n.importGuideDifficultyEasy,
            timeEstimate: l10n.importGuideTime30Sec,
            webSlug: 'tiktok',
            steps: [
              _GuideStep(
                title: l10n.importGuideTiktokStep1Title,
                description: l10n.importGuideTiktokStep1Desc,
                icon: Icons.search,
                asset: const _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'TikTok video of someone cooking with the share arrow visible on the right side',
                  filename: 'tt_recipe_video.png',
                ),
              ),
              _GuideStep(
                title: l10n.importGuideTiktokStep2Title,
                description: l10n.importGuideTiktokStep2Desc,
                icon: Icons.arrow_forward,
                asset: const _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'TikTok share arrow button highlighted on the right sidebar',
                  filename: 'tt_share_arrow.png',
                ),
              ),
              _GuideStep(
                title: l10n.importGuideTiktokStep3Title,
                description: l10n.importGuideTiktokStep3Desc,
                icon: Icons.link,
                asset: const _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'TikTok share menu showing Copy Link button and other share options',
                  filename: 'tt_copy_link.png',
                ),
                tip: l10n.importGuideTiktokStep3Tip,
              ),
              _GuideStep(
                title: l10n.importGuideTiktokStep4Title,
                description: l10n.importGuideTiktokStep4Desc,
                icon: Icons.paste,
                asset: const _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Recipe Spellbook URL input field with a TikTok link pasted',
                  filename: 'tt_paste_url.png',
                ),
              ),
              _GuideStep(
                title: l10n.importGuideTiktokStep5Title,
                description: l10n.importGuideTiktokStep5Desc,
                icon: Icons.check_circle_outline,
                asset: const _StepAsset(
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
            title: l10n.importGuideYoutubeTitle,
            subtitle: l10n.importGuideYoutubeSubtitle,
            difficulty: l10n.importGuideDifficultyEasy,
            timeEstimate: l10n.importGuideTime30Sec,
            webSlug: 'youtube',
            steps: [
              _GuideStep(
                title: l10n.importGuideYoutubeStep1Title,
                description: l10n.importGuideYoutubeStep1Desc,
                icon: Icons.ondemand_video,
                asset: const _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'YouTube video player showing a recipe/cooking video with the share button visible below',
                  filename: 'yt_recipe_video.png',
                ),
              ),
              _GuideStep(
                title: l10n.importGuideYoutubeStep2Title,
                description: l10n.importGuideYoutubeStep2Desc,
                icon: Icons.share,
                asset: const _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'YouTube share button highlighted below the video, above comments',
                  filename: 'yt_share_button.png',
                ),
              ),
              _GuideStep(
                title: l10n.importGuideYoutubeStep3Title,
                description: l10n.importGuideYoutubeStep3Desc,
                icon: Icons.content_copy,
                asset: const _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'YouTube share options showing Copy Link and app sharing options',
                  filename: 'yt_copy_link.png',
                ),
                tip: l10n.importGuideYoutubeStep3Tip,
              ),
              _GuideStep(
                title: l10n.importGuideYoutubeStep4Title,
                description: l10n.importGuideYoutubeStep4Desc,
                icon: Icons.auto_awesome,
                asset: const _StepAsset(
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
            title: l10n.importGuidePinterestTitle,
            subtitle: l10n.importGuidePinterestSubtitle,
            difficulty: l10n.importGuideDifficultyEasy,
            timeEstimate: l10n.importGuideTime30Sec,
            webSlug: 'pinterest',
            steps: [
              _GuideStep(
                title: l10n.importGuidePinterestStep1Title,
                description: l10n.importGuidePinterestStep1Desc,
                icon: Icons.open_in_new,
                asset: const _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Pinterest pin showing a recipe with the visit/source button visible',
                  filename: 'pin_recipe_pin.png',
                ),
              ),
              _GuideStep(
                title: l10n.importGuidePinterestStep2Title,
                description: l10n.importGuidePinterestStep2Desc,
                icon: Icons.link,
                asset: const _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Pinterest pin detail showing the source URL/website link highlighted',
                  filename: 'pin_source_link.png',
                ),
                tip: l10n.importGuidePinterestStep2Tip,
              ),
              _GuideStep(
                title: l10n.importGuidePinterestStep3Title,
                description: l10n.importGuidePinterestStep3Desc,
                icon: Icons.content_copy,
                asset: const _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Browser address bar showing a recipe website URL being copied',
                  filename: 'pin_copy_url.png',
                ),
              ),
              _GuideStep(
                title: l10n.importGuidePinterestStep4Title,
                description: l10n.importGuidePinterestStep4Desc,
                icon: Icons.download_rounded,
                asset: const _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Recipe Spellbook import preview from a Pinterest-sourced recipe',
                  filename: 'pin_import_preview.png',
                ),
              ),
            ],
          ),
        ],
      ),

      // ── WEBSITES ──
      _GuideCategory(
        title: l10n.importGuideCategoryWebsites,
        icon: Icons.language_rounded,
        guides: [
          _ImportGuide(
            id: 'website',
            icon: Icons.link_rounded,
            color: const Color(0xFF2196F3),
            title: l10n.importGuideWebsiteTitle,
            subtitle: l10n.importGuideWebsiteSubtitle,
            tag: l10n.importGuideTagEasiest,
            difficulty: l10n.importGuideDifficultyEasy,
            timeEstimate: l10n.importGuideTime15Sec,
            webSlug: 'website',
            steps: [
              _GuideStep(
                title: l10n.importGuideWebsiteStep1Title,
                description: l10n.importGuideWebsiteStep1Desc,
                icon: Icons.travel_explore,
                asset: const _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'A recipe website (e.g. AllRecipes) showing a recipe page with the URL visible in the browser bar',
                  filename: 'web_recipe_page.png',
                ),
              ),
              _GuideStep(
                title: l10n.importGuideWebsiteStep2Title,
                description: l10n.importGuideWebsiteStep2Desc,
                icon: Icons.content_copy,
                asset: const _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Browser address bar selected with the recipe URL highlighted and copy option showing',
                  filename: 'web_copy_url.png',
                ),
              ),
              _GuideStep(
                title: l10n.importGuideWebsiteStep3Title,
                description: l10n.importGuideWebsiteStep3Desc,
                icon: Icons.add_circle_outline,
                asset: const _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Recipe Spellbook home screen with the + FAB button highlighted',
                  filename: 'web_add_button.png',
                ),
              ),
              _GuideStep(
                title: l10n.importGuideWebsiteStep4Title,
                description: l10n.importGuideWebsiteStep4Desc,
                icon: Icons.paste,
                asset: const _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Recipe Spellbook add recipe menu showing "From Website/Link" option and URL paste field',
                  filename: 'web_paste_field.png',
                ),
              ),
              _GuideStep(
                title: l10n.importGuideWebsiteStep5Title,
                description: l10n.importGuideWebsiteStep5Desc,
                icon: Icons.check_circle_outline,
                asset: const _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Import preview showing a fully extracted recipe with image, ingredients list, steps, and prep/cook times',
                  filename: 'web_import_preview.png',
                ),
                tip: l10n.importGuideWebsiteStep5Tip,
              ),
            ],
          ),
        ],
      ),

      // ── PHOTOS & FILES ──
      _GuideCategory(
        title: l10n.importGuideCategoryPhotos,
        icon: Icons.photo_library_rounded,
        guides: [
          _ImportGuide(
            id: 'photo',
            icon: Icons.camera_alt_outlined,
            color: const Color(0xFF9C27B0),
            title: l10n.importGuidePhotoTitle,
            subtitle: l10n.importGuidePhotoSubtitle,
            difficulty: l10n.importGuideDifficultyEasy,
            timeEstimate: l10n.importGuideTime30Sec,
            webSlug: 'photo',
            steps: [
              _GuideStep(
                title: l10n.importGuidePhotoStep1Title,
                description: l10n.importGuidePhotoStep1Desc,
                icon: Icons.camera_alt,
                asset: const _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Camera viewfinder pointed at an open cookbook page showing a recipe, with good lighting and the text clearly visible',
                  filename: 'photo_capture.png',
                ),
                tip: l10n.importGuidePhotoStep1Tip,
              ),
              _GuideStep(
                title: l10n.importGuidePhotoStep2Title,
                description: l10n.importGuidePhotoStep2Desc,
                icon: Icons.add_photo_alternate,
                asset: const _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Recipe Spellbook add menu showing "From Photo" option, then the photo picker/camera prompt',
                  filename: 'photo_select.png',
                ),
              ),
              _GuideStep(
                title: l10n.importGuidePhotoStep3Title,
                description: l10n.importGuidePhotoStep3Desc,
                icon: Icons.document_scanner,
                asset: const _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Loading/processing screen showing "Scanning recipe..." with a progress indicator',
                  filename: 'photo_scanning.png',
                ),
              ),
              _GuideStep(
                title: l10n.importGuidePhotoStep4Title,
                description: l10n.importGuidePhotoStep4Desc,
                icon: Icons.edit_note,
                asset: const _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Import preview from a photo scan with ingredients and steps, showing editable text fields',
                  filename: 'photo_review.png',
                ),
                tip: l10n.importGuidePhotoStep4Tip,
              ),
            ],
          ),
          _ImportGuide(
            id: 'pdf',
            icon: Icons.picture_as_pdf_outlined,
            color: const Color(0xFFFF5722),
            title: l10n.importGuidePdfTitle,
            subtitle: l10n.importGuidePdfSubtitle,
            difficulty: l10n.importGuideDifficultyEasy,
            timeEstimate: l10n.importGuideTime30Sec,
            webSlug: 'pdf',
            steps: [
              _GuideStep(
                title: l10n.importGuidePdfStep1Title,
                description: l10n.importGuidePdfStep1Desc,
                icon: Icons.description,
                asset: const _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Files app or email showing a recipe PDF file ready to be selected',
                  filename: 'pdf_file_ready.png',
                ),
              ),
              _GuideStep(
                title: l10n.importGuidePdfStep2Title,
                description: l10n.importGuidePdfStep2Desc,
                icon: Icons.file_open,
                asset: const _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'File picker showing PDF files with one selected',
                  filename: 'pdf_file_picker.png',
                ),
              ),
              _GuideStep(
                title: l10n.importGuidePdfStep3Title,
                description: l10n.importGuidePdfStep3Desc,
                icon: Icons.checklist,
                asset: const _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Page selector showing thumbnail previews of PDF pages with recipe pages highlighted',
                  filename: 'pdf_page_select.png',
                ),
              ),
              _GuideStep(
                title: l10n.importGuidePdfStep4Title,
                description: l10n.importGuidePdfStep4Desc,
                icon: Icons.check_circle_outline,
                asset: const _StepAsset(
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
            title: l10n.importGuideTextTitle,
            subtitle: l10n.importGuideTextSubtitle,
            difficulty: l10n.importGuideDifficultyEasy,
            timeEstimate: l10n.importGuideTime30Sec,
            webSlug: 'text',
            steps: [
              _GuideStep(
                title: l10n.importGuideTextStep1Title,
                description: l10n.importGuideTextStep1Desc,
                icon: Icons.content_copy,
                asset: const _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Messages/email app with recipe text selected and "Copy" button visible',
                  filename: 'text_copy_source.png',
                ),
              ),
              _GuideStep(
                title: l10n.importGuideTextStep2Title,
                description: l10n.importGuideTextStep2Desc,
                icon: Icons.add_circle_outline,
                asset: const _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Add recipe menu with "From Text" option highlighted',
                  filename: 'text_add_menu.png',
                ),
              ),
              _GuideStep(
                title: l10n.importGuideTextStep3Title,
                description: l10n.importGuideTextStep3Desc,
                icon: Icons.paste,
                asset: const _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Text import screen with recipe text pasted in the input field and an "Import" button below',
                  filename: 'text_paste_field.png',
                ),
                tip: l10n.importGuideTextStep3Tip,
              ),
              _GuideStep(
                title: l10n.importGuideTextStep4Title,
                description: l10n.importGuideTextStep4Desc,
                icon: Icons.check_circle_outline,
                asset: const _StepAsset(
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
        title: l10n.importGuideCategoryOtherApps,
        icon: Icons.swap_horiz_rounded,
        guides: [
          _ImportGuide(
            id: 'paprika',
            icon: Icons.swap_horiz_rounded,
            color: const Color(0xFFFF9800),
            title: l10n.importGuidePaprikaTitle,
            subtitle: l10n.importGuidePaprikaSubtitle,
            difficulty: l10n.importGuideDifficultyMedium,
            timeEstimate: l10n.importGuideTime2To5Min,
            webSlug: 'paprika',
            steps: [
              _GuideStep(
                title: l10n.importGuidePaprikaStep1Title,
                description: l10n.importGuidePaprikaStep1Desc,
                icon: Icons.file_download,
                asset: const _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Paprika app settings screen showing the Export option, then the export dialog',
                  filename: 'paprika_export.png',
                ),
              ),
              _GuideStep(
                title: l10n.importGuidePaprikaStep2Title,
                description: l10n.importGuidePaprikaStep2Desc,
                icon: Icons.send,
                asset: const _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Share/save dialog for the .paprikarecipes export file',
                  filename: 'paprika_transfer.png',
                ),
              ),
              _GuideStep(
                title: l10n.importGuidePaprikaStep3Title,
                description: l10n.importGuidePaprikaStep3Desc,
                icon: Icons.file_open,
                asset: const _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Recipe Spellbook Settings > Data > Import screen with file picker open showing the Paprika export file',
                  filename: 'paprika_import.png',
                ),
              ),
              _GuideStep(
                title: l10n.importGuidePaprikaStep4Title,
                description: l10n.importGuidePaprikaStep4Desc,
                icon: Icons.hourglass_bottom,
                asset: const _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Import progress indicator followed by success message showing "Imported 47 recipes"',
                  filename: 'paprika_success.png',
                ),
                tip: l10n.importGuidePaprikaStep4Tip,
              ),
            ],
          ),
          _ImportGuide(
            id: 'other-apps',
            icon: Icons.apps_rounded,
            color: const Color(0xFF4CAF50),
            title: l10n.importGuideOtherAppsTitle,
            subtitle: l10n.importGuideOtherAppsSubtitle,
            difficulty: l10n.importGuideDifficultyMedium,
            timeEstimate: l10n.importGuideTime2To5Min,
            webSlug: 'other-apps',
            steps: [
              _GuideStep(
                title: l10n.importGuideOtherAppsStep1Title,
                description: l10n.importGuideOtherAppsStep1Desc,
                icon: Icons.file_download,
                asset: const _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Generic settings/export screen from a recipe app (illustration style, not a specific app)',
                  filename: 'other_export.png',
                ),
                tip: l10n.importGuideOtherAppsStep1Tip,
              ),
              _GuideStep(
                title: l10n.importGuideOtherAppsStep2Title,
                description: l10n.importGuideOtherAppsStep2Desc,
                icon: Icons.cloud_download,
                asset: const _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Files app showing a downloaded recipe export file (JSON or HTML)',
                  filename: 'other_file_ready.png',
                ),
              ),
              _GuideStep(
                title: l10n.importGuideOtherAppsStep3Title,
                description: l10n.importGuideOtherAppsStep3Desc,
                icon: Icons.settings,
                asset: const _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Recipe Spellbook Settings > Data > Import with file picker',
                  filename: 'other_import.png',
                ),
              ),
              _GuideStep(
                title: l10n.importGuideOtherAppsStep4Title,
                description: l10n.importGuideOtherAppsStep4Desc,
                icon: Icons.library_books,
                asset: const _StepAsset(
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
            title: l10n.importGuideDeviceTransferTitle,
            subtitle: l10n.importGuideDeviceTransferSubtitle,
            difficulty: l10n.importGuideDifficultyEasy,
            timeEstimate: l10n.importGuideTime1Min,
            webSlug: 'device-transfer',
            steps: [
              _GuideStep(
                title: l10n.importGuideDeviceTransferStep1Title,
                description: l10n.importGuideDeviceTransferStep1Desc,
                icon: Icons.phone_android,
                asset: const _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Recipe Spellbook device transfer screen showing "Send" tab with a generated 6-character code',
                  filename: 'transfer_send.png',
                ),
              ),
              _GuideStep(
                title: l10n.importGuideDeviceTransferStep2Title,
                description: l10n.importGuideDeviceTransferStep2Desc,
                icon: Icons.pin,
                asset: const _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Transfer screen showing a large, clear 6-character code with a 15-minute countdown timer',
                  filename: 'transfer_code.png',
                ),
              ),
              _GuideStep(
                title: l10n.importGuideDeviceTransferStep3Title,
                description: l10n.importGuideDeviceTransferStep3Desc,
                icon: Icons.input,
                asset: const _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Transfer receive screen with code input field on the new device',
                  filename: 'transfer_receive.png',
                ),
              ),
              _GuideStep(
                title: l10n.importGuideDeviceTransferStep4Title,
                description: l10n.importGuideDeviceTransferStep4Desc,
                icon: Icons.check_circle,
                asset: const _StepAsset(
                  type: _AssetType.screenshot,
                  description: 'Success screen showing "Transfer complete — X recipes, X cookbooks imported"',
                  filename: 'transfer_success.png',
                ),
                tip: l10n.importGuideDeviceTransferStep4Tip,
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
    final l10n = AppLocalizations.of(context)!;
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
            l10n.importGuideHeroTitle,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            l10n.importGuideHeroSubtitle,
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
    final l10n = AppLocalizations.of(context)!;
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
                Text(l10n.importGuideQuickTipLabel,
                    style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600, color: Colors.amber.shade800)),
                const SizedBox(height: 2),
                Text(
                  l10n.importGuideQuickTipText,
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(guide.title),
        actions: [
          TextButton.icon(
            onPressed: () => _launchUrl('$_kWebGuideBaseUrl/${guide.webSlug}'),
            icon: const Icon(Icons.open_in_browser, size: 18),
            label: Text(l10n.importGuideWebButton),
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
                    _MetaPill(icon: Icons.format_list_numbered, label: l10n.importGuideStepsCount(guide.steps.length), color: guide.color),
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
            label: Text(l10n.importGuideFollowInBrowser),
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
          errorBuilder: (_, __, ___) => _buildPlaceholder(context, theme),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context, ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    final typeIcon = switch (asset.type) {
      _AssetType.screenshot => Icons.phone_android,
      _AssetType.gif => Icons.gif_box_outlined,
      _AssetType.video => Icons.play_circle_outline,
    };
    final typeLabel = switch (asset.type) {
      _AssetType.screenshot => l10n.importGuideScreenshotNeeded,
      _AssetType.gif => l10n.importGuideGifNeeded,
      _AssetType.video => l10n.importGuideVideoNeeded,
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
