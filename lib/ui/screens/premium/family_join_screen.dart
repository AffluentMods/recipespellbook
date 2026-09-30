import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/auth_service.dart';
import '../../../services/family_service.dart';
import '../../../utils/responsive_utils.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/join_with_link_dialog.dart';
import '../../widgets/sign_in_prompt.dart';

/// Opened by a family invite link (`/family/join/<code>`) or a pasted code.
/// Shows who's inviting and asks "Join the Smiths?" before joining; signs the
/// user in first when needed and then carries on; explains full families,
/// existing memberships and dead codes instead of failing silently.
class FamilyJoinScreen extends ConsumerStatefulWidget {
  final String code;
  const FamilyJoinScreen({super.key, required this.code});

  @override
  ConsumerState<FamilyJoinScreen> createState() => _FamilyJoinScreenState();
}

class _FamilyJoinScreenState extends ConsumerState<FamilyJoinScreen> {
  final _family = FamilyService.instance;

  bool _loading = true;
  bool _joining = false;
  bool _signedOut = false;
  FamilyInvitePreview? _preview;
  bool _previewUnsupported = false;
  InviteErrorKind? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _signedOut = false;
    });
    // A cold-start link can land here before the saved session is restored.
    await waitForAuthReady(ref);
    if (!mounted) return;
    if (!AuthService.instance.isSignedIn) {
      setState(() {
        _loading = false;
        _signedOut = true;
      });
      return;
    }
    final r = await _family.previewFamilyInvite(widget.code);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _preview = r.preview;
      _previewUnsupported = r.unsupported;
      _error = r.error;
      _signedOut = r.error == InviteErrorKind.signedOut;
    });
  }

  Future<void> _signIn({bool sessionExpired = false}) async {
    final l10n = AppLocalizations.of(context)!;
    // An expired session is dead server-side; clear it so sign-in starts clean.
    if (sessionExpired) await ref.read(authProvider.notifier).signOut();
    if (!mounted) return;
    final ok = await promptSignIn(context, ref,
        message: l10n.familyJoinSignIn, icon: Icons.family_restroom);
    if (ok && mounted) await _load();
  }

  Future<void> _join() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _joining = true);
    final r = await _family.joinFamily(widget.code);
    if (!mounted) return;
    setState(() => _joining = false);
    if (r.success) {
      AppSnackbar.success(context, l10n.familyJoined(r.familyName ?? _preview?.familyName ?? ''));
      context.go('/settings/family');
      return;
    }
    switch (r.error) {
      case InviteErrorKind.signedOut:
        setState(() => _signedOut = true);
      case InviteErrorKind.sessionExpired || InviteErrorKind.notFound || InviteErrorKind.network:
        setState(() => _error = r.error);
      case InviteErrorKind.familyFull:
        AppSnackbar.error(context, l10n.familyErrorFull);
        await _load();
      case InviteErrorKind.alreadyInFamily:
        AppSnackbar.error(context, l10n.familyErrorAlreadyInFamily);
        await _load();
      default:
        AppSnackbar.error(context, r.message ?? l10n.familyJoinFailed);
    }
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.familyJoinScreenTitle),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
          onPressed: _close,
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Responsive.constrainWidth(context, maxWidth: 480, child: _buildBody(l10n)),
              ),
            ),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_signedOut) {
      return _StatePanel(
        icon: Icons.family_restroom,
        title: l10n.familyJoinScreenTitle,
        body: l10n.familyJoinSignIn,
        primaryLabel: l10n.signIn,
        onPrimary: _signIn,
        secondaryLabel: l10n.actionCancel,
        onSecondary: _close,
      );
    }

    switch (_error) {
      case null:
        break;
      case InviteErrorKind.notFound:
        return _StatePanel(
          icon: Icons.link_off,
          title: l10n.familyJoinInvalid,
          body: l10n.familyJoinInvalidHint,
          primaryLabel: l10n.inviteTryAnother,
          onPrimary: () => showJoinWithLinkDialog(context, purpose: JoinLinkPurpose.family, replace: true),
          secondaryLabel: l10n.shareViewerGoHome,
          onSecondary: () => context.go('/'),
        );
      case InviteErrorKind.sessionExpired:
        return _StatePanel(
          icon: Icons.lock_clock_outlined,
          title: l10n.familyJoinScreenTitle,
          body: l10n.inviteErrorSessionExpired,
          primaryLabel: l10n.signIn,
          onPrimary: () => _signIn(sessionExpired: true),
          secondaryLabel: l10n.actionCancel,
          onSecondary: _close,
        );
      case InviteErrorKind.network:
        return _StatePanel(
          icon: Icons.wifi_off_rounded,
          title: l10n.familyJoinScreenTitle,
          body: l10n.inviteErrorNetwork,
          primaryLabel: l10n.actionRetry,
          onPrimary: _load,
          secondaryLabel: l10n.actionCancel,
          onSecondary: _close,
        );
      default:
        return _StatePanel(
          icon: Icons.error_outline,
          title: l10n.familyJoinFailed,
          primaryLabel: l10n.actionRetry,
          onPrimary: _load,
          secondaryLabel: l10n.actionCancel,
          onSecondary: _close,
        );
    }

    final p = _preview;
    if (p == null) {
      // Older server without invite previews — still let them join.
      return _StatePanel(
        icon: Icons.family_restroom,
        title: l10n.familyJoinGenericPrompt(widget.code.toUpperCase()),
        body: l10n.familySharingDescription,
        primaryLabel: l10n.familyJoinConfirm,
        onPrimary: _previewUnsupported && !_joining ? _join : null,
        busy: _joining,
        secondaryLabel: l10n.actionCancel,
        onSecondary: _close,
      );
    }

    if (p.alreadyMember) {
      return _StatePanel(
        icon: Icons.check_circle_outline,
        title: l10n.familyJoinAlreadyMember(p.familyName),
        primaryLabel: l10n.familyJoinOpenFamily,
        onPrimary: () => context.go('/settings/family'),
      );
    }
    if (p.currentFamilyName != null) {
      return _StatePanel(
        icon: Icons.family_restroom,
        title: l10n.familyJoinPrompt(p.familyName),
        body: l10n.familyJoinInOtherFamily(p.currentFamilyName!),
        primaryLabel: l10n.familyJoinOpenFamily,
        onPrimary: () => context.go('/settings/family'),
        secondaryLabel: l10n.actionCancel,
        onSecondary: _close,
      );
    }
    if (p.isFull) {
      return _StatePanel(
        icon: Icons.group_off_outlined,
        title: l10n.familyErrorFull,
        body: l10n.familyJoinFullBody(p.familyName, p.maxMembers),
        secondaryLabel: l10n.actionClose,
        onSecondary: _close,
      );
    }

    final theme = Theme.of(context);
    final avatar = p.ownerAvatarUrl;
    return _StatePanel(
      leading: CircleAvatar(
        radius: 36,
        backgroundColor: theme.colorScheme.primaryContainer,
        backgroundImage: (avatar != null && avatar.isNotEmpty) ? NetworkImage(avatar) : null,
        child: (avatar == null || avatar.isEmpty)
            ? Icon(Icons.family_restroom, size: 36, color: theme.colorScheme.onPrimaryContainer)
            : null,
      ),
      title: l10n.familyJoinPrompt(p.familyName),
      body: p.ownerName != null && p.ownerName!.isNotEmpty
          ? l10n.familyJoinInvitedBy(p.ownerName!)
          : l10n.familySharingDescription,
      detail: l10n.familyMembersCount(p.memberCount, p.maxMembers),
      primaryLabel: l10n.familyJoinConfirm,
      onPrimary: _joining ? null : _join,
      busy: _joining,
      secondaryLabel: l10n.actionCancel,
      onSecondary: _joining ? null : _close,
    );
  }
}

/// Centered icon + title + text + actions, used for every state of the screen.
class _StatePanel extends StatelessWidget {
  final IconData? icon;
  final Widget? leading;
  final String title;
  final String? body;
  final String? detail;
  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final bool busy;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  const _StatePanel({
    this.icon,
    this.leading,
    required this.title,
    this.body,
    this.detail,
    this.primaryLabel,
    this.onPrimary,
    this.busy = false,
    this.secondaryLabel,
    this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        leading ?? Icon(icon, size: 64, color: theme.colorScheme.primary.withValues(alpha: 0.6)),
        const SizedBox(height: 20),
        Text(title,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center),
        if (body != null) ...[
          const SizedBox(height: 10),
          Text(body!,
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center),
        ],
        if (detail != null) ...[
          const SizedBox(height: 8),
          Text(detail!,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
              textAlign: TextAlign.center),
        ],
        const SizedBox(height: 28),
        if (primaryLabel != null)
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onPrimary,
              child: busy
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(primaryLabel!),
            ),
          ),
        if (secondaryLabel != null) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(onPressed: onSecondary, child: Text(secondaryLabel!)),
          ),
        ],
      ],
    );
  }
}
