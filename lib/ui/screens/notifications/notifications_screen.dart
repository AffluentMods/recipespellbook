import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../providers/notification_provider.dart';
import '../../../utils/responsive_utils.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('notification_inbox') ?? [];
    final items = raw.map((s) {
      try { return jsonDecode(s) as Map<String, dynamic>; }
      catch (_) { return null; }
    }).whereType<Map<String, dynamic>>().toList();
    // newest first
    items.sort((a, b) => (b['timestamp'] as int? ?? 0).compareTo(a['timestamp'] as int? ?? 0));
    if (mounted) setState(() { _notifications = items; _loading = false; });
  }

  Future<void> _markAllRead() async {
    final prefs = await SharedPreferences.getInstance();
    for (var n in _notifications) {
      n['isRead'] = true;
    }
    await prefs.setStringList(
      'notification_inbox',
      _notifications.map((n) => jsonEncode(n)).toList(),
    );
    ref.read(unreadNotificationCountProvider.notifier).state = 0;
    setState(() {});
  }

  Future<void> _markRead(int index) async {
    if (_notifications[index]['isRead'] == true) return;
    _notifications[index]['isRead'] = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'notification_inbox',
      _notifications.map((n) => jsonEncode(n)).toList(),
    );
    final unread = _notifications.where((n) => n['isRead'] != true).length;
    ref.read(unreadNotificationCountProvider.notifier).state = unread;
    setState(() {});
  }

  IconData _iconForCategory(String? category) {
    switch (category) {
      case 'cooking': return Icons.schedule;
      case 'community': return Icons.people;
      case 'achievement': return Icons.emoji_events;
      case 'quest': return Icons.assignment;
      default: return Icons.notifications;
    }
  }

  Color _colorForCategory(String? category, ThemeData theme) {
    switch (category) {
      case 'cooking': return Colors.orange;
      case 'community': return Colors.blue;
      case 'achievement': return Colors.amber;
      case 'quest': return Colors.purple;
      default: return theme.colorScheme.primary;
    }
  }

  String _timeAgo(int? ts) {
    if (ts == null) return '';
    final diff = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(ts));
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${diff.inDays ~/ 7}w ago';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unreadCount = _notifications.where((n) => n['isRead'] != true).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: Responsive.constrainWidth(context, child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.notifications_none, size: 64, color: theme.colorScheme.outline.withValues(alpha: 0.4)),
                      const SizedBox(height: 16),
                      Text('No notifications yet', style: TextStyle(color: theme.colorScheme.outline, fontSize: 16)),
                    ],
                  ),
                )
              : ListView.separated(
                  itemCount: _notifications.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final n = _notifications[index];
                    final isRead = n['isRead'] == true;
                    final category = n['category'] as String?;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _colorForCategory(category, theme).withValues(alpha: 0.15),
                        child: Icon(_iconForCategory(category), color: _colorForCategory(category, theme), size: 20),
                      ),
                      title: Text(
                        n['title'] as String? ?? 'Notification',
                        style: isRead ? null : const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(n['body'] as String? ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
                      trailing: Text(
                        _timeAgo(n['timestamp'] as int?),
                        style: TextStyle(fontSize: 12, color: theme.colorScheme.outline),
                      ),
                      tileColor: isRead ? null : theme.colorScheme.primaryContainer.withValues(alpha: 0.08),
                      onTap: () {
                        _markRead(index);
                        // Navigate based on category/data
                        final data = n['data'] as Map<String, dynamic>?;
                        if (data != null) {
                          final route = data['route'] as String?;
                          if (route != null) context.push(route);
                        }
                      },
                    );
                  },
                )),
    );
  }
}
