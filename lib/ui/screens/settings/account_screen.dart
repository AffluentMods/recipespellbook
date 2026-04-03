import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/subscription_provider.dart';
import '../../../services/auth_service.dart';
import '../../../services/community_service.dart';
import '../../../services/grocery_service.dart';
import '../../../services/image_service.dart';
import '../../../services/revenuecat_service.dart';
import '../../../services/sync_service.dart';
import '../../../utils/platform_utils.dart';
import '../../../utils/responsive_utils.dart';
import '../../widgets/app_snackbar.dart';

// ════════════════════════════════════════════════════════════
//  ACCOUNT SCREEN — Dedicated full-screen account management
// ════════════════════════════════════════════════════════════

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.accountTitle)),
      body: authState.isSignedIn
          ? _SignedInBody(user: authState.user!)
          : _SignedOutBody(isLoading: authState.isLoading, error: authState.error),
    );
  }
}

// ════════════════════════════════════════════
//  SIGNED OUT — Sign-in flow
// ════════════════════════════════════════════

class _SignedOutBody extends ConsumerWidget {
  final bool isLoading;
  final String? error;
  const _SignedOutBody({required this.isLoading, this.error});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.account_circle_outlined, size: 48, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.signInToSync,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.signInDescription,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
              textAlign: TextAlign.center,
            ),

            if (error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, size: 18, color: theme.colorScheme.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(error!, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
                    ),
                    GestureDetector(
                      onTap: () => ref.read(authProvider.notifier).clearError(),
                      child: Icon(Icons.close, size: 16, color: theme.colorScheme.error),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 28),

            // Google Sign-In
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: isLoading ? null : () => ref.read(authProvider.notifier).signInWithGoogle(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isLoading)
                      const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    else
                      Text('G', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                    const SizedBox(width: 10),
                    Text(l10n.continueWithGoogle, style: TextStyle(fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
                  ],
                ),
              ),
            ),

            // Apple Sign-In
            if (supportsAppleSignIn) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: isLoading ? null : () => ref.read(authProvider.notifier).signInWithApple(),
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.brightness == Brightness.dark ? Colors.white : Colors.black,
                    foregroundColor: theme.brightness == Brightness.dark ? Colors.black : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.apple, size: 20),
                      const SizedBox(width: 10),
                      Text(l10n.continueWithApple, style: const TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Restore purchases
            TextButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      try {
                        await ref.read(subscriptionProvider.notifier).restorePurchases();
                        if (context.mounted) {
                          final isPro = ref.read(subscriptionProvider).isPro;
                          if (isPro) {
                            AppSnackbar.success(context, l10n.purchasesRestored);
                          } else {
                            AppSnackbar.info(context, l10n.noPurchasesFound);
                          }
                        }
                      } catch (e) {
                        if (context.mounted) AppSnackbar.error(context, l10n.restoreFailed);
                      }
                    },
              child: Text(l10n.restorePurchases),
            ),
          ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════
//  SIGNED IN — Full account management
// ════════════════════════════════════════════

class _SignedInBody extends ConsumerWidget {
  final AuthUser user;
  const _SignedInBody({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(subscriptionProvider);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            // -- Profile Header --
            _ProfileHeader(user: user),

            const SizedBox(height: 8),

            // -- Community Stats --
            _CommunityStatsCard(userId: user.id),

            const SizedBox(height: 4),

            // -- Subscription --
            _SubscriptionCard(status: status),

            // -- Cloud Sync (only if has cloud sync) --
            if (status.hasCloudSync) ...[
              const SizedBox(height: 4),
              const _CloudSyncCard(),
            ],

            // -- Integrations --
            const SizedBox(height: 4),
            const _IntegrationsCard(),

            // -- Danger Zone --
            const SizedBox(height: 4),
            const _DangerZoneCard(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════
//  PROFILE HEADER
// ════════════════════════════════════════════

class _ProfileHeader extends ConsumerStatefulWidget {
  final AuthUser user;
  const _ProfileHeader({required this.user});

  @override
  ConsumerState<_ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends ConsumerState<_ProfileHeader> {
  bool _uploadingAvatar = false;

  /// Resolve an avatar URL — if it's a full URL (Google, etc.) use as-is.
  /// If it's a server storage path, construct the API proxy URL.
  String _resolveAvatarUrl(String avatarUrl) {
    if (avatarUrl.startsWith('http://') || avatarUrl.startsWith('https://')) {
      return avatarUrl;
    }
    const apiUrl = String.fromEnvironment('API_URL', defaultValue: 'https://api.recipespellbook.app');
    return '$apiUrl/v1/web/avatar/$avatarUrl';
  }

  Future<void> _pickAvatarFromLibrary() async {
    final l10n = AppLocalizations.of(context)!;
    if (_uploadingAvatar) return;
    setState(() => _uploadingAvatar = true);

    try {
      final result = await ImageService.instance.pickAndUploadFromGallery();
      if (result == null) {
        if (mounted) setState(() => _uploadingAvatar = false);
        return;
      }

      final avatarPath = result.path;
      final success = await ref.read(authProvider.notifier).updateProfile(avatarUrl: avatarPath);

      if (!mounted) return;
      if (success) {
        AppSnackbar.success(context, l10n.accountProfilePictureUpdated);
      } else {
        AppSnackbar.error(context, l10n.accountProfilePictureUpdateFailed);
      }
    } catch (e) {
      if (mounted) AppSnackbar.error(context, l10n.accountFailedToUploadImage);
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  Future<void> _removeAvatar() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _uploadingAvatar = true);
    try {
      final success = await ref.read(authProvider.notifier).updateProfile(avatarUrl: '');
      if (!mounted) return;
      if (success) {
        AppSnackbar.success(context, l10n.accountProfilePictureUpdated);
      } else {
        AppSnackbar.error(context, l10n.accountProfilePictureUpdateFailed);
      }
    } catch (e) {
      if (mounted) AppSnackbar.error(context, l10n.accountFailedToUploadImage);
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  void _showAvatarSheet() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final hasAvatar = widget.user.avatarUrl != null && widget.user.avatarUrl!.isNotEmpty;

    Responsive.showAdaptiveSheet(
      context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.chooseFromLibrary),
              onTap: () {
                Navigator.pop(ctx);
                _pickAvatarFromLibrary();
              },
            ),
            if (hasAvatar)
              ListTile(
                leading: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                title: Text(l10n.removePhoto, style: TextStyle(color: theme.colorScheme.error)),
                onTap: () {
                  Navigator.pop(ctx);
                  _removeAvatar();
                },
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showEditNameSheet() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final controller = TextEditingController(text: widget.user.name ?? '');
    final validCharsRegex = RegExp(r'^[\p{L}\p{N}\s.,\-_!?]+$', unicode: true);

    Responsive.showAdaptiveSheet(
      context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final text = controller.text.trim();
            final tooShort = text.isNotEmpty && text.length < 2;
            final hasInvalidChars = text.isNotEmpty && !validCharsRegex.hasMatch(text);
            final isValid = text.isNotEmpty && text.length >= 2 && !hasInvalidChars;

            String? errorText;
            if (hasInvalidChars) {
              errorText = l10n.nameContainsUnsupported;
            } else if (tooShort) {
              errorText = l10n.nameTooShort;
            }

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20, right: 20, top: 8, bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        width: 36, height: 4,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(l10n.editDisplayName, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Text(l10n.displayName, style: theme.textTheme.labelLarge),
                    const SizedBox(height: 6),
                    TextField(
                      controller: controller,
                      maxLength: 30,
                      autofocus: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        errorText: errorText,
                        counterText: '${controller.text.length}/30',
                      ),
                      onChanged: (_) => setSheetState(() {}),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.displayNameHelper,
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: isValid
                            ? () async {
                                final name = controller.text.trim();
                                Navigator.pop(ctx);
                                String? cooldownError;
                                final success = await ref.read(authProvider.notifier).updateProfile(
                                  name: name,
                                  errorCallback: (statusCode, body) {
                                    if (statusCode == 429 && body['error'] == 'name_cooldown') {
                                      final nextChangeAt = body['nextChangeAt'] as String?;
                                      if (nextChangeAt != null) {
                                        final date = DateTime.tryParse(nextChangeAt);
                                        if (date != null) {
                                          final formatted = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                                          cooldownError = l10n.nameCooldownMessage(formatted);
                                        }
                                      }
                                      cooldownError ??= l10n.nameCooldownMessage('soon');
                                    } else if (statusCode == 400) {
                                      cooldownError = body['error']?.toString() ?? l10n.accountProfileUpdateFailed;
                                    }
                                  },
                                );
                                if (mounted) {
                                  if (success) {
                                    AppSnackbar.success(context, l10n.accountProfileUpdated);
                                  } else if (cooldownError != null) {
                                    AppSnackbar.warning(context, cooldownError!);
                                  } else {
                                    AppSnackbar.error(context, l10n.accountProfileUpdateFailed);
                                  }
                                }
                              }
                            : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.amber.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(l10n.saveName),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = widget.user;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: [
          // Avatar (tappable → bottom sheet)
          GestureDetector(
            onTap: _uploadingAvatar ? null : _showAvatarSheet,
            child: Stack(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  ),
                  child: _uploadingAvatar
                      ? const Center(child: SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2.5)))
                      : user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                          ? ClipOval(
                              child: Image.network(
                                _resolveAvatarUrl(user.avatarUrl!),
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _avatarFallback(theme, user),
                              ),
                            )
                          : _avatarFallback(theme, user),
                ),
                // Camera badge
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.colorScheme.surface, width: 2),
                    ),
                    child: Icon(Icons.camera_alt, size: 13, color: theme.colorScheme.onPrimary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Display name as text + pencil icon (tap → edit sheet)
          GestureDetector(
            onTap: _showEditNameSheet,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  user.displayName,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 6),
                Icon(Icons.edit, size: 18, color: Colors.amber.shade700),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // Email (muted)
          Text(
            user.email,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),

          // Plan pill (tappable → paywall)
          GestureDetector(
            onTap: () => context.push('/upgrade'),
            child: _TierBadge(tier: user.tier),
          ),
        ],
      ),
    );
  }

  Widget _avatarFallback(ThemeData theme, AuthUser user) {
    final initial = user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?';
    return Center(
      child: Text(
        initial,
        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
      ),
    );
  }
}

// ════════════════════════════════════════════
//  TIER BADGE
// ════════════════════════════════════════════

class _TierBadge extends StatelessWidget {
  final String tier;
  const _TierBadge({required this.tier});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final (label, color, icon) = switch (tier) {
      'creator' || 'admin' => (l10n.tierCreatorName, Colors.amber.shade700, Icons.star),
      'cloudSyncFamily' => (l10n.tierCloudSyncFamilyName, Colors.deepPurple, Icons.family_restroom),
      'cloudSync' => (l10n.tierCloudSyncName, Colors.blue, Icons.cloud_sync),
      'premium' => (l10n.tierPremiumName, Colors.green, Icons.check_circle_outline),
      _ => (l10n.tierFreeName, theme.colorScheme.outline, Icons.person_outline),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            l10n.planLabel(label),
            style: TextStyle(fontWeight: FontWeight.w600, color: color, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════
//  COMMUNITY STATS CARD
// ════════════════════════════════════════════

class _CommunityStatsCard extends ConsumerStatefulWidget {
  final String userId;
  const _CommunityStatsCard({required this.userId});

  @override
  ConsumerState<_CommunityStatsCard> createState() => _CommunityStatsCardState();
}

class _CommunityStatsCardState extends ConsumerState<_CommunityStatsCard> {
  Future<_CommunityStatsData?>? _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _fetchStats();
  }

  Future<_CommunityStatsData?> _fetchStats() async {
    try {
      final service = CommunityService.instance;
      final pubs = await service.getMyPublications();
      if (pubs.isEmpty) return null;

      int totalDownloads = 0;
      for (final pub in pubs) {
        totalDownloads += pub.downloadCount;
      }

      // Fetch follower/following counts via creator profile
      int followerCount = 0;
      int followingCount = 0;
      try {
        final profile = await service.getCreatorProfile(widget.userId);
        if (profile != null) {
          followerCount = profile.followerCount;
          followingCount = profile.followingCount;
        }
      } catch (_) {}

      return _CommunityStatsData(
        downloads: totalDownloads,
        followers: followerCount,
        following: followingCount,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return _CardSection(
      title: l10n.communitySection,
      icon: Icons.people_outline,
      children: [
        FutureBuilder<_CommunityStatsData?>(
          future: _statsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
              );
            }

            final stats = snapshot.data;
            if (stats == null) {
              // State A: no publications — dashed amber border CTA
              return GestureDetector(
                onTap: () => context.push('/community'),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(14),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade600, width: 1.5, strokeAlign: BorderSide.strokeAlignInside),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.menu_book_outlined, size: 28, color: Colors.amber.shade700),
                      const SizedBox(height: 8),
                      Text(
                        l10n.publishCookbookToStart,
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            // State B: has publications — show stats
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatColumn(value: '${stats.downloads}', label: 'downloads'),
                  Container(width: 1, height: 28, color: theme.colorScheme.outlineVariant),
                  _StatColumn(value: '${stats.followers}', label: 'followers'),
                  Container(width: 1, height: 28, color: theme.colorScheme.outlineVariant),
                  _StatColumn(value: '${stats.following}', label: 'following'),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _CommunityStatsData {
  final int downloads;
  final int followers;
  final int following;
  const _CommunityStatsData({required this.downloads, required this.followers, required this.following});
}

class _StatColumn extends StatelessWidget {
  final String value;
  final String label;
  const _StatColumn({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
      ],
    );
  }
}

// ════════════════════════════════════════════
//  SUBSCRIPTION CARD
// ════════════════════════════════════════════

class _SubscriptionCard extends ConsumerWidget {
  final SubscriptionStatus status;
  const _SubscriptionCard({required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return _CardSection(
      title: l10n.subscriptionSection,
      icon: Icons.star_outline,
      children: [
        if (status.isPro) ...[
          // Premium or Family — active
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '\u2726 ',
                      style: TextStyle(fontSize: 18, color: Colors.amber.shade700),
                    ),
                    Expanded(
                      child: Text(
                        status.tier == SubscriptionTier.family
                            ? l10n.familyActive
                            : l10n.premiumActive,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  status.tier == SubscriptionTier.family
                      ? l10n.sharedWithMembers
                      : l10n.cloudSyncEnabled,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                ),

                // Cancellation notice
                if (status.isCancelled && status.expirationDate != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(children: [
                      Icon(Icons.info_outline, size: 16, color: theme.colorScheme.error),
                      const SizedBox(width: 8),
                      Expanded(child: Text(
                        '${l10n.cancelled} \u2014 ${l10n.accessUntil} ${_formatDate(status.expirationDate)}',
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
                      )),
                    ]),
                  ),
                ],

                // Renewal info
                if (status.tier != SubscriptionTier.premium &&
                    status.expirationDate != null &&
                    !status.isCancelled) ...[
                  const SizedBox(height: 6),
                  _DetailRow(label: l10n.renews, value: _formatDate(status.expirationDate)),
                ],

                if (status.tier == SubscriptionTier.premium) ...[
                  const SizedBox(height: 6),
                  _DetailRow(label: l10n.plan, value: l10n.lifetimeNeverExpires),
                ],

                const SizedBox(height: 10),
                Center(
                  child: TextButton(
                    onPressed: () async {
                      try {
                        await ref.read(subscriptionProvider.notifier).restorePurchases();
                        if (context.mounted) {
                          AppSnackbar.success(context, l10n.purchasesRestored);
                        }
                      } catch (e) {
                        if (context.mounted) AppSnackbar.error(context, l10n.restoreFailed);
                      }
                    },
                    child: Text(l10n.restorePurchases),
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          // Free — upgrade prompt
          Container(
            margin: const EdgeInsets.all(14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
            ),
            child: Column(children: [
              Text(
                l10n.unlockPremium,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.oneTimePurchaseDesc,
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => context.push('/upgrade'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.amber.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(l10n.viewPlansPrice),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () async {
                  try {
                    await ref.read(subscriptionProvider.notifier).restorePurchases();
                    if (context.mounted) {
                      final isPro = ref.read(subscriptionProvider).isPro;
                      if (isPro) {
                        AppSnackbar.success(context, l10n.purchasesRestored);
                      } else {
                        AppSnackbar.info(context, l10n.noPurchasesFound);
                      }
                    }
                  } catch (e) {
                    if (context.mounted) AppSnackbar.error(context, l10n.restoreFailed);
                  }
                },
                child: Text(l10n.restorePurchases),
              ),
            ]),
          ),
        ],
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '\u2014';
    return '${date.month}/${date.day}/${date.year}';
  }
}

// ════════════════════════════════════════════
//  CLOUD SYNC CARD
// ════════════════════════════════════════════

class _CloudSyncCard extends StatefulWidget {
  const _CloudSyncCard();

  @override
  State<_CloudSyncCard> createState() => _CloudSyncCardState();
}

class _CloudSyncCardState extends State<_CloudSyncCard> {
  bool _syncing = false;

  Future<void> _doSync() async {
    if (_syncing) return;
    setState(() => _syncing = true);
    final result = await SyncService.instance.sync();
    if (!mounted) return;
    setState(() => _syncing = false);
    final l10n = AppLocalizations.of(context)!;
    if (result.success) {
      AppSnackbar.success(context, l10n.syncSuccess(result.pushedCount, result.pulledCount));
    } else {
      AppSnackbar.error(context, result.error ?? l10n.syncFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return _CardSection(
      title: l10n.accountCloudSync,
      icon: Icons.cloud_outlined,
      children: [
        ListTile(
          leading: Icon(
            _syncing ? Icons.sync : Icons.cloud_sync,
            color: theme.colorScheme.primary,
          ),
          title: Text(l10n.accountSyncNow),
          subtitle: Text(
            _syncing ? l10n.syncing : l10n.syncDescription,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
          ),
          trailing: _syncing
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : FilledButton.tonal(
                  onPressed: _doSync,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    minimumSize: const Size(0, 36),
                  ),
                  child: Text(l10n.sync),
                ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════
//  INTEGRATIONS CARD
// ════════════════════════════════════════════

class _IntegrationsCard extends ConsumerStatefulWidget {
  const _IntegrationsCard();

  @override
  ConsumerState<_IntegrationsCard> createState() => _IntegrationsCardState();
}

class _IntegrationsCardState extends ConsumerState<_IntegrationsCard> {
  bool _krogerConfigured = false;
  bool _discordLinked = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final kr = await GroceryService.isConfigured(GroceryProvider.kroger);
    bool discord = false;
    try {
      if (AuthService.instance.isSignedIn) {
        final status = await AuthService.instance.getDiscordStatus();
        discord = status.linked;
      }
    } catch (_) {}
    if (mounted) {
      setState(() {
        _krogerConfigured = kr;
        _discordLinked = discord;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return _CardSection(
      title: l10n.integrationsSection,
      icon: Icons.extension_outlined,
      children: [
        // Discord
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF5865F2).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(child: Icon(Icons.forum_outlined, size: 20, color: Color(0xFF5865F2))),
          ),
          title: Text(l10n.discord, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          subtitle: Text(
            _loading
                ? l10n.integrationsChecking
                : _discordLinked
                    ? l10n.integrationsLinkedManage
                    : l10n.integrationsTapToLink,
            style: TextStyle(
              fontSize: 13,
              color: _discordLinked ? const Color(0xFF43B02A) : theme.colorScheme.outline,
            ),
          ),
          trailing: _discordLinked
              ? const Icon(Icons.check_circle, color: Color(0xFF43B02A), size: 20)
              : Icon(Icons.chevron_right, size: 20, color: theme.colorScheme.outline.withValues(alpha: 0.5)),
          onTap: () => _showDiscordOptions(context),
        ),

        // Kroger
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF0068B5).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(child: Text('\u{1F3EA}', style: TextStyle(fontSize: 18))),
          ),
          title: Text(l10n.kroger, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          subtitle: Text(
            _loading
                ? l10n.integrationsChecking
                : _krogerConfigured
                    ? l10n.integrationsConnectedManage
                    : l10n.integrationsTapToSignIn,
            style: TextStyle(
              fontSize: 13,
              color: _krogerConfigured ? const Color(0xFF43B02A) : theme.colorScheme.outline,
            ),
          ),
          trailing: _krogerConfigured
              ? const Icon(Icons.check_circle, color: Color(0xFF43B02A), size: 20)
              : Icon(Icons.chevron_right, size: 20, color: theme.colorScheme.outline.withValues(alpha: 0.5)),
          onTap: () => _showKrogerOptions(context),
        ),
      ],
    );
  }

  void _showDiscordOptions(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final auth = AuthService.instance;
    Responsive.showAdaptiveSheet(
      context,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              const Icon(Icons.forum, size: 24, color: Color(0xFF5865F2)),
              const SizedBox(width: 12),
              Text(l10n.discord, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              if (_discordLinked) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF43B02A).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(l10n.integrationsLinked,
                      style: const TextStyle(color: Color(0xFF43B02A), fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ],
            ]),
          ),
          if (!_discordLinked)
            ListTile(
              leading: const Icon(Icons.link),
              title: Text(l10n.discordLinkAccount),
              subtitle: Text(l10n.discordLinkSubtitle),
              onTap: () async {
                Navigator.pop(ctx);
                if (!auth.isSignedIn) {
                  if (context.mounted) AppSnackbar.error(context, l10n.discordSignInFirst);
                  return;
                }
                final url = Uri.parse(auth.discordLinkUrl);
                try {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } catch (e) {
                  if (context.mounted) AppSnackbar.error(context, l10n.couldNotOpenBrowser);
                }
              },
            ),
          if (_discordLinked)
            ListTile(
              leading: Icon(Icons.link_off, color: theme.colorScheme.error),
              title: Text(l10n.discordUnlink, style: TextStyle(color: theme.colorScheme.error)),
              subtitle: Text(l10n.discordUnlinkSubtitle),
              onTap: () async {
                Navigator.pop(ctx);
                final success = await auth.unlinkDiscord();
                if (success) {
                  _checkStatus();
                  if (context.mounted) AppSnackbar.success(context, l10n.discordUnlinked);
                } else {
                  if (context.mounted) AppSnackbar.error(context, l10n.discordUnlinkFailed);
                }
              },
            ),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  void _showKrogerOptions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    Responsive.showAdaptiveSheet(
      context,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              const Text('\u{1F3EA}', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Text(l10n.kroger, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              if (_krogerConfigured) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF43B02A).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(l10n.connected,
                      style: const TextStyle(color: Color(0xFF43B02A), fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ],
            ]),
          ),
          if (!_krogerConfigured)
            ListTile(
              leading: const Icon(Icons.login),
              title: Text(l10n.signInToKroger),
              subtitle: Text(l10n.connectToAddItems),
              onTap: () async {
                Navigator.pop(ctx);
                await GroceryService.krogerStartOAuthLogin();
              },
            ),
          ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: Text(l10n.setPreferredStore),
            subtitle: Text(l10n.searchByZipCode),
            onTap: () {
              Navigator.pop(ctx);
              _showKrogerLocationDialog(context);
            },
          ),
          if (_krogerConfigured)
            ListTile(
              leading: Icon(Icons.link_off, color: theme.colorScheme.error),
              title: Text(l10n.disconnect, style: TextStyle(color: theme.colorScheme.error)),
              onTap: () async {
                Navigator.pop(ctx);
                await GroceryService.disconnect(GroceryProvider.kroger);
                _checkStatus();
              },
            ),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  void _showKrogerLocationDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) {
        List<Map<String, dynamic>> results = [];
        bool searching = false;
        return StatefulBuilder(
          builder: (ctx, ss) => AlertDialog(
            title: Text(l10n.findYourKrogerStore),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: l10n.enterZipCode,
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: searching
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.search),
                    onPressed: () async {
                      final zip = controller.text.trim();
                      if (zip.isEmpty) return;
                      ss(() => searching = true);
                      final locs = await GroceryService.krogerSearchLocations(zip);
                      ss(() {
                        results = locs;
                        searching = false;
                      });
                    },
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              if (results.isNotEmpty) ...[
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: results.length,
                    itemBuilder: (_, i) {
                      final loc = results[i];
                      return ListTile(
                        dense: true,
                        title: Text(loc['name'] ?? l10n.accountStoreFallback),
                        subtitle: Text(
                          '${loc['address'] ?? ''}, ${loc['city'] ?? ''} ${loc['state'] ?? ''}',
                          style: theme.textTheme.bodySmall,
                        ),
                        onTap: () async {
                          final id = loc['id']?.toString();
                          if (id != null) await GroceryService.setKrogerLocation(id);
                          if (ctx.mounted) Navigator.pop(ctx);
                          if (context.mounted) AppSnackbar.success(context, l10n.storeSet(loc['name'] ?? 'Kroger'));
                        },
                      );
                    },
                  ),
                ),
              ],
            ]),
            actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.actionClose))],
          ),
        );
      },
    );
  }
}

// ════════════════════════════════════════════
//  DANGER ZONE CARD
// ════════════════════════════════════════════

class _DangerZoneCard extends ConsumerWidget {
  const _DangerZoneCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return _CardSection(
      title: l10n.dangerZoneSection,
      icon: Icons.warning_amber_rounded,
      children: [
        // Sign out (no confirmation)
        ListTile(
          leading: Icon(Icons.logout, color: theme.colorScheme.outline),
          title: Text(l10n.signOut),
          onTap: () {
            ref.read(authProvider.notifier).signOut();
            if (context.mounted) Navigator.pop(context);
          },
        ),

        // Delete account (type-DELETE confirmation)
        ListTile(
          leading: Icon(Icons.delete_forever_outlined, color: theme.colorScheme.error),
          title: Text(l10n.deleteAccount, style: TextStyle(color: theme.colorScheme.error)),
          onTap: () => _confirmDeleteAccount(context, ref),
        ),
      ],
    );
  }

  void _confirmDeleteAccount(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            final canDelete = controller.text.trim() == 'DELETE';
            return AlertDialog(
              icon: Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error, size: 32),
              title: Text(l10n.deleteAccountTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.deleteAccountWarning, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 16),
                  Text(l10n.typeDeleteToConfirmAccount, style: theme.textTheme.labelLarge),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: 'DELETE',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onChanged: (_) => setDialogState(() {}),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.actionCancel)),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: theme.colorScheme.error),
                  onPressed: canDelete
                      ? () async {
                          Navigator.pop(ctx);
                          final success = await ref.read(authProvider.notifier).deleteAccount();
                          if (context.mounted) {
                            if (success) {
                              Navigator.pop(context);
                            } else {
                              AppSnackbar.info(context, l10n.deleteAccountFailed);
                            }
                          }
                        }
                      : null,
                  child: Text(l10n.deleteForever),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ════════════════════════════════════════════
//  DETAIL ROW
// ════════════════════════════════════════════

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
          Text(value, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════
//  CARD SECTION (reusable wrapper)
// ════════════════════════════════════════════

class _CardSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  const _CardSection({required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
          child: Row(children: [
            Icon(icon, size: 16, color: theme.colorScheme.primary),
            const SizedBox(width: 6),
            Text(
              title,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ]),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: Column(children: children),
        ),
      ],
    );
  }
}
