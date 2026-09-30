import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../services/family_service.dart';
import '../../utils/invite_link_parser.dart';

/// Where the dialog was opened from — only changes the title, and how a bare
/// code is interpreted (on the Family screen a code is a family code).
enum JoinLinkPurpose { any, shoppingList, cookbook, family }

/// The manual way in for every kind of invite: paste (or type) an invite link
/// or code and we open the matching screen — the share viewer for shared
/// lists / cookbooks / recipes, the family-invite screen, or a community page.
///
/// This is the reliable path whenever a link doesn't open the app on its own
/// (tapped inside an app that strips links, unverified app links, desktop…).
///
/// Returns whatever the opened screen pops with (e.g. `true` once a family
/// join completes), or null when cancelled. With [replace] the opened screen
/// replaces the current one (used by "Try another link" on an error page).
Future<Object?> showJoinWithLinkDialog(
  BuildContext context, {
  JoinLinkPurpose purpose = JoinLinkPurpose.any,
  bool replace = false,
}) async {
  final router = GoRouter.of(context);

  // Pre-fill from the clipboard when it already holds an invite LINK, so most
  // people can just tap Continue. (A lone word on the clipboard could be
  // anything, so bare codes aren't pre-filled.)
  String? prefill;
  try {
    final clip = (await Clipboard.getData(Clipboard.kTextPlain))?.text;
    final parsed = clip == null ? null : InviteLinkParser.parseText(clip);
    if (parsed != null && parsed.kind != InviteTargetKind.bareCode) prefill = clip!.trim();
  } catch (_) {
    // Clipboard access can be denied (web, some desktops) — just start empty.
  }
  if (!context.mounted) return null;

  final target = await showDialog<InviteTarget>(
    context: context,
    builder: (_) => _JoinWithLinkDialog(purpose: purpose, prefill: prefill),
  );
  final route = target?.route;
  if (route == null) return null;
  return replace ? router.pushReplacement<Object?>(route) : router.push<Object?>(route);
}

class _JoinWithLinkDialog extends StatefulWidget {
  final JoinLinkPurpose purpose;
  final String? prefill;

  const _JoinWithLinkDialog({required this.purpose, this.prefill});

  @override
  State<_JoinWithLinkDialog> createState() => _JoinWithLinkDialogState();
}

class _JoinWithLinkDialogState extends State<_JoinWithLinkDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.prefill ?? '');
  late bool _fromClipboard = widget.prefill != null;
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _title(AppLocalizations l10n) => switch (widget.purpose) {
        JoinLinkPurpose.shoppingList => l10n.joinLinkTitleList,
        JoinLinkPurpose.cookbook => l10n.joinLinkTitleCookbook,
        JoinLinkPurpose.family => l10n.joinLinkTitleFamily,
        JoinLinkPurpose.any => l10n.joinLinkTitle,
      };

  Future<void> _paste() async {
    try {
      final clip = (await Clipboard.getData(Clipboard.kTextPlain))?.text;
      if (clip == null || !mounted) return;
      setState(() {
        _controller.text = clip.trim();
        _fromClipboard = false;
        _error = null;
      });
    } catch (_) {}
  }

  Future<void> _submit() async {
    if (_busy) return;
    final l10n = AppLocalizations.of(context)!;
    final parsed = InviteLinkParser.parseText(_controller.text);
    if (parsed == null) {
      setState(() => _error = l10n.joinLinkInvalid);
      return;
    }
    if (parsed.kind != InviteTargetKind.bareCode) {
      Navigator.pop(context, parsed);
      return;
    }

    // A code on its own could be a share code or a family code.
    if (widget.purpose == JoinLinkPurpose.family) {
      Navigator.pop(context, InviteTarget.familyInviteCode(parsed.value));
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final resolved = await _resolveBareCode(parsed.value);
    if (!mounted) return;
    if (resolved == null) {
      setState(() {
        _busy = false;
        _error = l10n.joinLinkOffline;
      });
      return;
    }
    Navigator.pop(context, resolved);
  }

  /// Try the code as a share code first, then fall back to a family code.
  /// Null when the server couldn't be reached.
  Future<InviteTarget?> _resolveBareCode(String code) async {
    final status = await FamilyService.instance.probeShareCode(code);
    if (status == null) return null;
    // Found (200) or expired (410): it's a share code — the viewer explains
    // an expired one.
    if (status == 200 || status == 410) return InviteTarget.shareCode(code);
    if (status == 404) return InviteTarget.familyInviteCode(code);
    // Rate-limited / server error: go by shape and let the screen report.
    return InviteLinkParser.looksLikeFamilyCode(code)
        ? InviteTarget.familyInviteCode(code)
        : InviteTarget.shareCode(code);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return AlertDialog(
      scrollable: true,
      icon: Icon(Icons.group_add_outlined, color: theme.colorScheme.primary),
      title: Text(_title(l10n)),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.joinLinkBody,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              autofocus: true,
              enabled: !_busy,
              autocorrect: false,
              enableSuggestions: false,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.go,
              decoration: InputDecoration(
                hintText: l10n.joinLinkHint,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.link),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.content_paste_rounded),
                  tooltip: l10n.paste,
                  onPressed: _busy ? null : _paste,
                ),
                helperText: _fromClipboard && _error == null ? l10n.joinLinkFromClipboard : null,
                errorText: _error,
                errorMaxLines: 3,
              ),
              onChanged: (_) {
                if (_error != null || _fromClipboard) {
                  setState(() {
                    _error = null;
                    _fromClipboard = false;
                  });
                }
              },
              onSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: _busy ? null : _submit,
          child: _busy
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(l10n.actionContinue),
        ),
      ],
    );
  }
}
