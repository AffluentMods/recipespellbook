import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../services/auth_service.dart';
import '../../../services/community_service.dart';
import '../../../utils/responsive_utils.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/community_image.dart';

class CreatorProfileScreen extends StatefulWidget {
  final String userId;
  const CreatorProfileScreen({super.key, required this.userId});

  @override
  State<CreatorProfileScreen> createState() => _CreatorProfileScreenState();
}

class _CreatorProfileScreenState extends State<CreatorProfileScreen> {
  CreatorProfile? _profile;
  bool _loading = true;
  bool _isFollowing = false;
  int _followerCount = 0;
  bool _followLoading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profile = await CommunityService.instance.getCreatorProfile(widget.userId);
    if (mounted) {
      setState(() {
        _profile = profile;
        _loading = false;
        _isFollowing = profile?.isFollowing ?? false;
        _followerCount = profile?.followerCount ?? 0;
      });
    }
  }

  bool get _isOwnProfile =>
      AuthService.instance.currentUser?.id == widget.userId;

  Future<void> _toggleFollow() async {
    if (_followLoading || _isOwnProfile) return;
    final wasFollowing = _isFollowing;
    final oldCount = _followerCount;

    // Optimistic update
    setState(() {
      _followLoading = true;
      _isFollowing = !wasFollowing;
      _followerCount = wasFollowing ? oldCount - 1 : oldCount + 1;
    });

    final result = wasFollowing
        ? await CommunityService.instance.unfollowCreator(widget.userId)
        : await CommunityService.instance.followCreator(widget.userId);

    if (mounted) {
      setState(() {
        _followLoading = false;
        // If API succeeded, use server values; otherwise revert
        if (result.followerCount > 0 || result.following == !wasFollowing) {
          _isFollowing = result.following;
          _followerCount = result.followerCount;
        } else {
          _isFollowing = wasFollowing;
          _followerCount = oldCount;
        }
      });
    }
  }

  static String _resolveAvatarUrl(String avatarUrl) {
    if (avatarUrl.startsWith('http://') || avatarUrl.startsWith('https://')) return avatarUrl;
    final apiUrl = AuthService.instance.apiBaseUrl;
    return '$apiUrl/v1/web/avatar/$avatarUrl';
  }

  void _showReportSheet() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final reasons = [
      ('spam', l10n.reportSpam),
      ('inappropriate', l10n.reportInappropriate),
      ('stolen', l10n.reportStolen),
      ('harassment', l10n.reportHarassment),
      ('other', l10n.reportOther),
    ];

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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(l10n.reportAccountTitle, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            ...reasons.map((r) => ListTile(
              title: Text(r.$2),
              onTap: () async {
                Navigator.pop(ctx);
                final result = await CommunityService.instance.reportAccount(widget.userId, r.$1);
                if (mounted) {
                  if (result.success) {
                    AppSnackbar.success(context, l10n.reportSubmitted);
                  } else if (result.error == 'Already reported recently') {
                    AppSnackbar.info(context, l10n.alreadyReportedRecently);
                  } else if (result.error == 'Cannot report yourself') {
                    AppSnackbar.info(context, l10n.cannotReportSelf);
                  } else {
                    AppSnackbar.error(context, result.error ?? l10n.accountProfileUpdateFailed);
                  }
                }
              },
            )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_profile == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(AppLocalizations.of(context)!.creatorNotFound, style: TextStyle(color: theme.colorScheme.outline))),
      );
    }

    final l10n = AppLocalizations.of(context)!;
    final p = _profile!;
    final hasAvatar = p.avatarUrl != null && p.avatarUrl!.isNotEmpty;

    return Scaffold(
      body: Responsive.constrainWidth(context, child: CustomScrollView(
        slivers: [
          // ── Header ──
          SliverAppBar(
            actions: [
              if (!_isOwnProfile && AuthService.instance.currentUser != null)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'report') _showReportSheet();
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'report',
                      child: Row(
                        children: [
                          Icon(Icons.flag_outlined, size: 18, color: theme.colorScheme.error),
                          const SizedBox(width: 8),
                          Text(l10n.reportAccount),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
            expandedHeight: _isOwnProfile || AuthService.instance.currentUser == null ? 240 : 290,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDark
                        ? [const Color(0xFF6B3A1F), theme.scaffoldBackgroundColor]
                        : [const Color(0xFFD4956B).withValues(alpha: 0.3), theme.scaffoldBackgroundColor],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Avatar
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: const Color(0xFFC75B39).withValues(alpha: 0.18),
                        backgroundImage: hasAvatar ? NetworkImage(_resolveAvatarUrl(p.avatarUrl!)) : null,
                        onBackgroundImageError: hasAvatar ? (_, __) {} : null,
                        child: hasAvatar ? null : Text(
                          p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFC75B39)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Name
                      Text(p.name, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(l10n.creatorMemberSince(_formatDate(p.memberSince)),
                          style: TextStyle(fontSize: 13, color: theme.colorScheme.outline)),
                      // Follow button (only for other users)
                      if (!_isOwnProfile && AuthService.instance.currentUser != null) ...[
                        const SizedBox(height: 10),
                        _isFollowing
                            ? FilledButton.icon(
                                onPressed: _toggleFollow,
                                icon: const Icon(Icons.check, size: 16),
                                label: Text(l10n.following),
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.amber,
                                  foregroundColor: Colors.black87,
                                  minimumSize: const Size(120, 36),
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                ),
                              )
                            : OutlinedButton.icon(
                                onPressed: _toggleFollow,
                                icon: const Icon(Icons.person_add_alt_1, size: 16),
                                label: Text(l10n.follow),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.amber.shade700,
                                  side: BorderSide(color: Colors.amber.shade700),
                                  minimumSize: const Size(120, 36),
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                ),
                              ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Stats strip ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatItem(value: '$_followerCount', label: l10n.followers),
                  _StatItem(value: '${p.followingCount}', label: l10n.followingLabel),
                  _StatItem(value: '${p.totalRecipes}', label: l10n.creatorStatRecipes),
                  _StatItem(value: '${p.totalDownloads}', label: l10n.creatorStatDownloads),
                ],
              ),
            ),
          ),

          // ── Section header ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(l10n.creatorPublishedCookbooks,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            ),
          ),

          // ── Cookbook grid ──
          if (p.publications.isEmpty)
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(l10n.creatorNoCookbooksYet, style: TextStyle(color: theme.colorScheme.outline)),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: Responsive.cookbookColumns(context),
                  childAspectRatio: 0.78,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final pub = p.publications[index];
                    return _CreatorCookbookCard(publication: pub, onTap: () {
                      context.push('/community/${pub.id}');
                    });
                  },
                  childCount: p.publications.length,
                ),
              ),
            ),
        ],
      )),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.year}';
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData? icon;
  const _StatItem({required this.value, required this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            if (icon != null) ...[
              const SizedBox(width: 2),
              Icon(icon, size: 18, color: Colors.amber),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: theme.colorScheme.outline)),
      ],
    );
  }
}

class _CreatorCookbookCard extends StatelessWidget {
  final CommunityListItem publication;
  final VoidCallback onTap;
  const _CreatorCookbookCard({required this.publication, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final hasImage = publication.imagePath != null && publication.imagePath!.isNotEmpty;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasImage)
              CommunityImage(
                publicationId: publication.id,
                imagePath: publication.imagePath,
                fit: BoxFit.cover,
              )
            else
              Container(
                color: theme.colorScheme.primaryContainer,
                child: Icon(Icons.book, size: 40, color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.3)),
              ),
            // Gradient
            Positioned(
              bottom: 0, left: 0, right: 0, height: 80,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                  ),
                ),
              ),
            ),
            // Title + meta
            Positioned(
              bottom: 8, left: 8, right: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(publication.title,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold,
                          shadows: [Shadow(blurRadius: 4, color: Colors.black54)]),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(l10n.creatorRecipesCount(publication.recipeCount),
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
