import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'auth_service.dart';

/// Lightweight admin service for in-app moderation panel.
/// Only works for users with role == 'admin'.
class AdminService {
  AdminService._();
  static final instance = AdminService._();
  final _auth = AuthService.instance;

  /// Check if current user is admin
  bool get isAdmin => _auth.currentUser?.role == 'admin';

  /// Get pending review count
  Future<int> getPendingCount() async {
    try {
      final r = await _auth.get('/v1/admin/stats');
      if (r.statusCode == 200) {
        final data = jsonDecode(r.body);
        return (data['pendingReviewCount'] as int?) ?? 0;
      }
    } catch (e) {
      debugPrint('[Admin] getPendingCount: $e');
    }
    return 0;
  }

  /// Get pending publications
  Future<List<Map<String, dynamic>>> getPendingPublications() async {
    try {
      final r = await _auth.get('/v1/admin/publications?status=pending_review&limit=50');
      if (r.statusCode == 200) {
        final data = jsonDecode(r.body);
        return (data['publications'] as List).cast<Map<String, dynamic>>();
      }
    } catch (e) {
      debugPrint('[Admin] getPendingPublications: $e');
    }
    return [];
  }

  /// Get pending flags
  Future<List<Map<String, dynamic>>> getPendingFlags() async {
    try {
      final r = await _auth.get('/v1/admin/flags?status=pending&limit=50');
      if (r.statusCode == 200) {
        final data = jsonDecode(r.body);
        return (data['flags'] as List).cast<Map<String, dynamic>>();
      }
    } catch (e) {
      debugPrint('[Admin] getPendingFlags: $e');
    }
    return [];
  }

  /// Approve a flag (removes the publication)
  Future<bool> approveFlag(String flagId) async {
    try {
      final r = await _auth.post('/v1/admin/flags/$flagId/approve', {});
      return r.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Reject a flag (keeps the publication published)
  Future<bool> rejectFlag(String flagId) async {
    try {
      final r = await _auth.post('/v1/admin/flags/$flagId/reject', {});
      return r.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Directly approve a pending_review publication (set to published)
  Future<bool> approvePublication(String pubId) async {
    try {
      final r = await _auth.post('/v1/admin/publications/$pubId/approve', {});
      return r.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Directly remove a publication
  Future<bool> removePublication(String pubId) async {
    try {
      final r = await _auth.post('/v1/admin/publications/$pubId/remove', {});
      return r.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
