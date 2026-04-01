import 'package:flutter/material.dart';
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
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final pubs = await _admin.getPendingPublications();
    final flags = await _admin.getPendingFlags();
    if (mounted) {
      setState(() {
        _pendingPubs = pubs;
        _pendingFlags = flags;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Moderation Panel'),
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
                      child: Row(
                        children: [
                          _StatChip(label: 'Pending Review', count: _pendingPubs.length, color: Colors.orange),
                          const SizedBox(width: 12),
                          _StatChip(label: 'Pending Flags', count: _pendingFlags.length, color: Colors.red),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Pending publications
                  if (_pendingPubs.isNotEmpty) ...[
                    Text('Pending Review', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ..._pendingPubs.map((pub) => _PendingPubCard(
                      pub: pub,
                      onApprove: () => _approvePub(pub['id'] as String, pub['title'] as String),
                      onRemove: () => _removePub(pub['id'] as String, pub['title'] as String),
                    )),
                    const SizedBox(height: 20),
                  ],

                  // Pending flags
                  if (_pendingFlags.isNotEmpty) ...[
                    Text('Pending Flags', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ..._pendingFlags.map((flag) => _PendingFlagCard(
                      flag: flag,
                      onApprove: () => _approveFlag(flag['id'] as String),
                      onReject: () => _rejectFlag(flag['id'] as String),
                    )),
                  ],

                  if (_pendingPubs.isEmpty && _pendingFlags.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(48),
                        child: Column(
                          children: [
                            Icon(Icons.check_circle, size: 64, color: theme.colorScheme.primary),
                            const SizedBox(height: 16),
                            Text('All clear!', style: theme.textTheme.titleLarge),
                            const SizedBox(height: 8),
                            Text('No pending items to review.', style: TextStyle(color: theme.colorScheme.outline)),
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
    final ok = await _admin.approvePublication(id);
    if (mounted) {
      if (ok) {
        AppSnackbar.success(context, '"$title" approved');
        _load();
      } else {
        AppSnackbar.error(context, 'Failed to approve');
      }
    }
  }

  Future<void> _removePub(String id, String title) async {
    final ok = await _admin.removePublication(id);
    if (mounted) {
      if (ok) {
        AppSnackbar.info(context, '"$title" removed');
        _load();
      } else {
        AppSnackbar.error(context, 'Failed to remove');
      }
    }
  }

  Future<void> _approveFlag(String id) async {
    final ok = await _admin.approveFlag(id);
    if (mounted) {
      if (ok) {
        AppSnackbar.info(context, 'Flag approved (publication removed)');
        _load();
      } else {
        AppSnackbar.error(context, 'Failed to approve flag');
      }
    }
  }

  Future<void> _rejectFlag(String id) async {
    final ok = await _admin.rejectFlag(id);
    if (mounted) {
      if (ok) {
        AppSnackbar.success(context, 'Flag rejected (publication kept)');
        _load();
      } else {
        AppSnackbar.error(context, 'Failed to reject flag');
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
            Text('By $publisherName · $recipeCount recipes', style: TextStyle(color: theme.colorScheme.outline, fontSize: 12)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onApprove,
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Approve'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onRemove,
                    icon: Icon(Icons.delete, size: 18, color: theme.colorScheme.error),
                    label: Text('Remove', style: TextStyle(color: theme.colorScheme.error)),
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
            Text('Reason: $reason', style: TextStyle(color: theme.colorScheme.outline, fontSize: 12)),
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
                    label: const Text('Remove Content'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onReject,
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Dismiss Flag'),
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
