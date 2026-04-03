import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../l10n/app_localizations.dart';
import '../../../services/admin_service.dart';
import '../../../utils/responsive_utils.dart';
import '../../widgets/app_snackbar.dart';

class AdminModerationScreen extends StatefulWidget {
  const AdminModerationScreen({super.key});

  @override
  State<AdminModerationScreen> createState() => _AdminModerationScreenState();
}

class _AdminModerationScreenState extends State<AdminModerationScreen> {
  final _admin = AdminService.instance;
  List<Map<String, dynamic>> _pendingPubs = [];
  List<Map<String, dynamic>> _pendingFlags = [];
  List<Map<String, dynamic>> _pendingReports = [];
  List<Map<String, dynamic>> _pendingAccountReports = [];
  bool _loading = true;
  bool _canGoBack = false;

  @override
  void initState() {
    super.initState();
    _load();
    // Delay back button to prevent accidental closure from tap spam
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _canGoBack = true);
    });
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      _admin.getPendingPublications(),
      _admin.getPendingFlags(),
      _admin.getPendingReports(),
      _admin.getPendingAccountReports(),
    ]);
    if (mounted) {
      setState(() {
        _pendingPubs = results[0];
        _pendingFlags = results[1];
        _pendingReports = results[2];
        _pendingAccountReports = results[3];
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        leading: _canGoBack
            ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context))
            : const SizedBox.shrink(),
        title: Text(l10n.adminModerationPanel),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: Responsive.constrainWidth(context, child: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Stats header
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          _StatChip(label: l10n.adminPendingReview, count: _pendingPubs.length, color: Colors.orange),
                          _StatChip(label: l10n.adminPendingFlags, count: _pendingFlags.length, color: Colors.red),
                          _StatChip(label: l10n.adminPendingReports, count: _pendingReports.length, color: Colors.deepPurple),
                          _StatChip(label: l10n.pendingAccountReports, count: _pendingAccountReports.length, color: Colors.teal),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Pending publications
                  if (_pendingPubs.isNotEmpty) ...[
                    Text(l10n.adminPendingReview, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ..._pendingPubs.map((pub) => _PendingPubCard(
                      pub: pub,
                      onApprove: () => _approvePub(pub['id'] as String, pub['title'] as String),
                      onRemove: () => _removePub(pub['id'] as String, pub['title'] as String),
                    )),
                    const SizedBox(height: 20),
                  ],

                  // User Reports
                  if (_pendingReports.isNotEmpty) ...[
                    Text(l10n.adminUserReports, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ..._pendingReports.map((report) => _PendingReportCard(
                      report: report,
                      onRemove: () => _resolveReport(report['id'] as String, 'remove'),
                      onDismiss: () => _resolveReport(report['id'] as String, 'dismiss'),
                    )),
                    const SizedBox(height: 20),
                  ],

                  // Pending flags
                  if (_pendingFlags.isNotEmpty) ...[
                    Text(l10n.adminPendingFlags, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ..._pendingFlags.map((flag) => _PendingFlagCard(
                      flag: flag,
                      onApprove: () => _approveFlag(flag['id'] as String),
                      onReject: () => _rejectFlag(flag['id'] as String),
                    )),
                  ],

                  // Account reports
                  if (_pendingAccountReports.isNotEmpty) ...[
                    Text(l10n.pendingAccountReports, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ..._pendingAccountReports.map((report) => _PendingAccountReportCard(
                      report: report,
                      onResolve: () => _resolveAccountReport(report['id'] as String, 'resolve'),
                      onDismiss: () => _resolveAccountReport(report['id'] as String, 'dismiss'),
                    )),
                    const SizedBox(height: 20),
                  ],

                  if (_pendingPubs.isEmpty && _pendingFlags.isEmpty && _pendingReports.isEmpty && _pendingAccountReports.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(48),
                        child: Column(
                          children: [
                            Icon(Icons.check_circle, size: 64, color: theme.colorScheme.primary),
                            const SizedBox(height: 16),
                            Text(l10n.adminAllClear, style: theme.textTheme.titleLarge),
                            const SizedBox(height: 8),
                            Text(l10n.adminNoPendingItems, style: TextStyle(color: theme.colorScheme.outline)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
      ),
    );
  }

  Future<void> _approvePub(String id, String title) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await _admin.approvePublication(id);
    if (mounted) {
      if (ok) {
        AppSnackbar.success(context, '"$title" approved');
        _load();
      } else {
        AppSnackbar.error(context, l10n.adminFailedToApprove);
      }
    }
  }

  Future<void> _removePub(String id, String title) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await _admin.removePublication(id);
    if (mounted) {
      if (ok) {
        AppSnackbar.info(context, '"$title" removed');
        _load();
      } else {
        AppSnackbar.error(context, l10n.adminFailedToRemove);
      }
    }
  }

  Future<void> _approveFlag(String id) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await _admin.approveFlag(id);
    if (mounted) {
      if (ok) {
        AppSnackbar.info(context, l10n.adminFlagApproved);
        _load();
      } else {
        AppSnackbar.error(context, l10n.adminFailedToApproveFlag);
      }
    }
  }

  Future<void> _rejectFlag(String id) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await _admin.rejectFlag(id);
    if (mounted) {
      if (ok) {
        AppSnackbar.success(context, l10n.adminFlagRejected);
        _load();
      } else {
        AppSnackbar.error(context, l10n.adminFailedToRejectFlag);
      }
    }
  }

  Future<void> _resolveAccountReport(String id, String action) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await _admin.resolveAccountReport(id, action);
    if (mounted) {
      if (ok) {
        if (action == 'dismiss') {
          AppSnackbar.success(context, l10n.accountReportDismissed);
        } else {
          AppSnackbar.info(context, l10n.accountReportsResolved);
        }
        _load();
      } else {
        AppSnackbar.error(context, l10n.adminFailedToResolveReport);
      }
    }
  }

  Future<void> _resolveReport(String id, String action) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await _admin.resolveReport(id, action);
    if (mounted) {
      if (ok) {
        if (action == 'remove') {
          AppSnackbar.info(context, l10n.adminContentRemovedResolved);
        } else {
          AppSnackbar.success(context, l10n.adminReportDismissed);
        }
        _load();
      } else {
        AppSnackbar.error(context, l10n.adminFailedToResolveReport);
      }
    }
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _StatChip({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text('$count', style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 18)),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: color, fontSize: 12)),
      ]),
    );
  }
}

class _PendingPubCard extends StatelessWidget {
  final Map<String, dynamic> pub;
  final VoidCallback onApprove;
  final VoidCallback onRemove;
  const _PendingPubCard({required this.pub, required this.onApprove, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = pub['title'] as String? ?? 'Untitled';
    final publisher = pub['publisher'] as Map<String, dynamic>?;
    final publisherName = publisher?['name'] as String? ?? 'Unknown';
    final recipeCount = pub['recipeCount'] as int? ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(AppLocalizations.of(context)!.adminByPublisher(publisherName, recipeCount), style: TextStyle(color: theme.colorScheme.outline, fontSize: 12)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onApprove,
                    icon: const Icon(Icons.check, size: 18),
                    label: Text(AppLocalizations.of(context)!.adminApprove),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onRemove,
                    icon: Icon(Icons.delete, size: 18, color: theme.colorScheme.error),
                    label: Text(AppLocalizations.of(context)!.adminRemove, style: TextStyle(color: theme.colorScheme.error)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingReportCard extends StatelessWidget {
  final Map<String, dynamic> report;
  final VoidCallback onRemove;
  final VoidCallback onDismiss;
  const _PendingReportCard({required this.report, required this.onRemove, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pub = report['publication'] as Map<String, dynamic>?;
    final pubTitle = pub?['title'] as String? ?? 'Unknown';
    final pubId = pub?['id'] as String?;
    final reporter = report['reporter'] as Map<String, dynamic>?;
    final reporterName = reporter?['name'] as String? ?? 'Unknown';
    final reason = report['reason'] as String? ?? 'No reason given';
    final details = report['details'] as String? ?? '';
    final createdAt = report['createdAt'] as String?;

    String timeAgo = '';
    if (createdAt != null) {
      try {
        timeAgo = timeago.format(DateTime.parse(createdAt));
      } catch (_) {}
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row — tappable to navigate to publication
            InkWell(
              onTap: pubId != null ? () => context.push('/community/$pubId') : null,
              child: Row(
                children: [
                  Text('\u{1F6A9} ', style: TextStyle(fontSize: 16)),
                  Expanded(
                    child: Text(
                      pubTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  if (pubId != null) Icon(Icons.open_in_new, size: 14, color: theme.colorScheme.outline),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(AppLocalizations.of(context)!.adminReportedBy(reporterName), style: TextStyle(color: theme.colorScheme.outline, fontSize: 12)),
            const SizedBox(height: 2),
            Text(AppLocalizations.of(context)!.adminReason(reason), style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 13)),
            if (details.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(details, style: TextStyle(color: theme.colorScheme.outline, fontSize: 11), maxLines: 3, overflow: TextOverflow.ellipsis),
            ],
            if (timeAgo.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(timeAgo, style: TextStyle(color: theme.colorScheme.outline, fontSize: 11)),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onRemove,
                    style: FilledButton.styleFrom(backgroundColor: theme.colorScheme.error),
                    icon: const Icon(Icons.delete, size: 18),
                    label: Text(AppLocalizations.of(context)!.adminRemoveContent),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDismiss,
                    icon: const Icon(Icons.check, size: 18),
                    label: Text(AppLocalizations.of(context)!.adminDismissReport),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingAccountReportCard extends StatelessWidget {
  final Map<String, dynamic> report;
  final VoidCallback onResolve;
  final VoidCallback onDismiss;
  const _PendingAccountReportCard({required this.report, required this.onResolve, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final reported = report['reported'] as Map<String, dynamic>?;
    final reporter = report['reporter'] as Map<String, dynamic>?;
    final reportedName = reported?['name'] as String? ?? 'Unknown';
    final reportedEmail = reported?['email'] as String? ?? '';
    final reporterName = reporter?['name'] as String? ?? 'Unknown';
    final reason = report['reason'] as String? ?? 'No reason';
    final createdAt = report['createdAt'] as String?;

    String timeAgo = '';
    if (createdAt != null) {
      try {
        timeAgo = timeago.format(DateTime.parse(createdAt));
      } catch (_) {}
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person_off, size: 18, color: Colors.teal),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(reportedName, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            if (reportedEmail.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(reportedEmail, style: TextStyle(color: theme.colorScheme.outline, fontSize: 11)),
            ],
            const SizedBox(height: 4),
            Text(l10n.adminReportedBy(reporterName), style: TextStyle(color: theme.colorScheme.outline, fontSize: 12)),
            const SizedBox(height: 2),
            Text(l10n.adminReason(reason), style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 13)),
            if (timeAgo.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(timeAgo, style: TextStyle(color: theme.colorScheme.outline, fontSize: 11)),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onResolve,
                    style: FilledButton.styleFrom(backgroundColor: theme.colorScheme.error),
                    icon: const Icon(Icons.gavel, size: 18),
                    label: Text(l10n.adminRemoveContent),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDismiss,
                    icon: const Icon(Icons.check, size: 18),
                    label: Text(l10n.adminDismissReport),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingFlagCard extends StatelessWidget {
  final Map<String, dynamic> flag;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  const _PendingFlagCard({required this.flag, required this.onApprove, required this.onReject});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reason = flag['reason'] as String? ?? 'unknown';
    final details = flag['details'] as String? ?? '';
    final pub = flag['publication'] as Map<String, dynamic>?;
    final pubTitle = pub?['title'] as String? ?? 'Unknown';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flag, size: 18, color: theme.colorScheme.error),
                const SizedBox(width: 6),
                Expanded(child: Text(pubTitle, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold))),
              ],
            ),
            const SizedBox(height: 4),
            Text(AppLocalizations.of(context)!.adminReason(reason), style: TextStyle(color: theme.colorScheme.outline, fontSize: 12)),
            if (details.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(details, style: TextStyle(color: theme.colorScheme.outline, fontSize: 11), maxLines: 3, overflow: TextOverflow.ellipsis),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onApprove,
                    style: FilledButton.styleFrom(backgroundColor: theme.colorScheme.error),
                    icon: const Icon(Icons.delete, size: 18),
                    label: Text(AppLocalizations.of(context)!.adminRemoveContent),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onReject,
                    icon: const Icon(Icons.check, size: 18),
                    label: Text(AppLocalizations.of(context)!.adminDismissFlag),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
