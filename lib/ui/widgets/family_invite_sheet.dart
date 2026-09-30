import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../l10n/app_localizations.dart';
import '../../services/family_service.dart';
import '../../utils/responsive_utils.dart';
import 'app_snackbar.dart';
import 'sheet_chrome.dart';

/// Everything needed to bring someone into the family in one place: a QR code
/// they can scan with their phone camera, the invite link and code (each with
/// copy), and the system share sheet.
Future<void> showFamilyInviteSheet(BuildContext context, FamilyInfo info) {
  return Responsive.showAdaptiveSheet(
    context,
    useRootNavigator: true,
    desktopMaxHeight: 720,
    builder: (ctx) => _FamilyInviteSheet(info: info),
  );
}

class _FamilyInviteSheet extends StatelessWidget {
  final FamilyInfo info;
  const _FamilyInviteSheet({required this.info});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final seatsLeft = info.maxMembers - info.members.length;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SheetHandle(top: 0),
            const SizedBox(height: 16),
            Text(l10n.familyInviteSheetTitle(info.name),
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(
              '${l10n.familyMembersCount(info.members.length, info.maxMembers)} · ${l10n.familySeatsLeft(seatsLeft)}',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // White card so the code scans in dark mode too.
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: QrImageView(
                data: info.shareLink,
                version: QrVersions.auto,
                size: 180,
                backgroundColor: Colors.white,
                semanticsLabel: l10n.familyInviteLink,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.familyInviteSheetBody,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _CopyRow(
              label: l10n.familyInviteLink,
              value: info.shareLink,
              copiedMessage: l10n.familyLinkCopied,
            ),
            const SizedBox(height: 8),
            _CopyRow(
              label: l10n.familyInviteCode,
              value: info.inviteCode,
              copiedMessage: l10n.familyCodeCopied,
              large: true,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  final box = context.findRenderObject() as RenderBox?;
                  SharePlus.instance.share(ShareParams(
                    text: l10n.familyShareMessage(info.inviteCode, info.shareLink),
                    subject: l10n.familyShareSubject,
                    // iPad needs an anchor for the share popover.
                    sharePositionOrigin: box == null ? null : box.localToGlobal(Offset.zero) & box.size,
                  ));
                },
                icon: const Icon(Icons.share, size: 18),
                label: Text(l10n.actionShare),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CopyRow extends StatelessWidget {
  final String label;
  final String value;
  final String copiedMessage;
  final bool large;

  const _CopyRow({
    required this.label,
    required this.value,
    required this.copiedMessage,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 4, 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline)),
              const SizedBox(height: 2),
              SelectableText(
                value,
                maxLines: 1,
                style: large
                    ? const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 3, fontFamily: 'monospace')
                    : const TextStyle(fontSize: 13, fontFamily: 'monospace'),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.copy, size: 20),
          tooltip: MaterialLocalizations.of(context).copyButtonLabel,
          onPressed: () {
            Clipboard.setData(ClipboardData(text: value));
            AppSnackbar.success(context, copiedMessage);
          },
        ),
      ]),
    );
  }
}
