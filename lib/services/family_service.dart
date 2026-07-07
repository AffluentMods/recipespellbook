import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'auth_service.dart';

// ════════════════════════════════════════════
//  MODELS
// ════════════════════════════════════════════

class FamilyMemberInfo {
  final String userId;
  final String? name;
  final String? email;
  final String? avatarUrl;
  final String? tier;
  final String role;
  final DateTime? joinedAt;

  const FamilyMemberInfo({
    required this.userId, this.name, this.email, this.avatarUrl,
    this.tier, required this.role, this.joinedAt,
  });

  factory FamilyMemberInfo.fromJson(Map<String, dynamic> json) => FamilyMemberInfo(
    userId: json['userId'] as String,
    name: json['name'] as String?,
    email: json['email'] as String?,
    avatarUrl: json['avatarUrl'] as String?,
    tier: json['tier'] as String?,
    role: json['role'] as String? ?? 'member',
    joinedAt: json['joinedAt'] != null ? DateTime.tryParse(json['joinedAt'] as String) : null,
  );

  String get displayName => name ?? email?.split('@').first ?? 'Unknown';
  bool get isOwner => role == 'owner';
  bool get isAdmin => role == 'admin' || role == 'owner';
}

class FamilyInfo {
  final String id;
  final String name;
  final String ownerId;
  final String inviteCode;
  final int maxMembers;
  final String myRole;
  final List<FamilyMemberInfo> members;
  final DateTime? createdAt;

  const FamilyInfo({
    required this.id, required this.name, required this.ownerId,
    required this.inviteCode, required this.maxMembers, required this.myRole,
    required this.members, this.createdAt,
  });

  factory FamilyInfo.fromJson(Map<String, dynamic> json) => FamilyInfo(
    id: json['id'] as String,
    name: json['name'] as String,
    ownerId: json['ownerId'] as String,
    inviteCode: json['inviteCode'] as String,
    maxMembers: json['maxMembers'] as int? ?? 5,
    myRole: json['myRole'] as String? ?? 'member',
    members: (json['members'] as List?)?.map((m) => FamilyMemberInfo.fromJson(m)).toList() ?? [],
    createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
  );

  bool get isOwner => myRole == 'owner';
  bool get isAdmin => myRole == 'admin' || myRole == 'owner';
  bool get isFull => members.length >= maxMembers;
  String get shareLink => 'https://recipespellbook.app/family/join/$inviteCode';

  /// Other members (not me)
  List<FamilyMemberInfo> otherMembers(String myUserId) =>
      members.where((m) => m.userId != myUserId).toList();
}

/// A share grant on a specific resource → specific family member.
class FamilyShareInfo {
  final String id;
  final String resourceType; // 'cookbook' | 'shopping_list'
  final String resourceId;
  final String permission;   // cookbook: read|add|edit  list: read|add|full
  final String? ownerName;
  final String? ownerAvatarUrl;
  final String? sharedWithName;
  final String? sharedWithEmail;
  final String? sharedWithAvatarUrl;

  const FamilyShareInfo({
    required this.id, required this.resourceType, required this.resourceId,
    required this.permission, this.ownerName, this.ownerAvatarUrl,
    this.sharedWithName, this.sharedWithEmail, this.sharedWithAvatarUrl,
  });

  factory FamilyShareInfo.fromJson(Map<String, dynamic> json) {
    final owner = json['owner'] as Map<String, dynamic>?;
    final shared = json['sharedWith'] as Map<String, dynamic>?;
    return FamilyShareInfo(
      id: json['id'] as String,
      resourceType: json['resourceType'] as String,
      resourceId: json['resourceId'] as String,
      permission: json['permission'] as String,
      ownerName: owner?['name'] as String?,
      ownerAvatarUrl: owner?['avatarUrl'] as String?,
      sharedWithName: shared?['name'] as String?,
      sharedWithEmail: shared?['email'] as String?,
      sharedWithAvatarUrl: shared?['avatarUrl'] as String?,
    );
  }

  bool get isCookbook => resourceType == 'cookbook';
  bool get isShoppingList => resourceType == 'shopping_list';
}

/// A temporary one-time share link.
class ShareLinkInfo {
  final String code;
  final String url;
  final String resourceType;
  final String resourceId;
  final DateTime expiresAt;

  const ShareLinkInfo({
    required this.code, required this.url, required this.resourceType,
    required this.resourceId, required this.expiresAt,
  });

  factory ShareLinkInfo.fromJson(Map<String, dynamic> json) => ShareLinkInfo(
    code: json['code'] as String,
    url: json['url'] as String,
    resourceType: json['resourceType'] as String,
    resourceId: json['resourceId'] as String,
    expiresAt: DateTime.parse(json['expiresAt'] as String),
  );
}

// ════════════════════════════════════════════
//  FAMILY SERVICE
// ════════════════════════════════════════════

class FamilyService {
  FamilyService._();
  static final instance = FamilyService._();

  final _auth = AuthService.instance;

  FamilyInfo? _cachedFamily;
  FamilyInfo? get currentFamily => _cachedFamily;
  bool get isInFamily => _cachedFamily != null;

  // ────────────────────────────────────
  //  FAMILY CRUD
  // ────────────────────────────────────

  Future<FamilyInfo?> getFamily() async {
    try {
      final response = await _auth.get('/v1/family');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['family'] != null) {
          _cachedFamily = FamilyInfo.fromJson(data['family']);
          return _cachedFamily;
        }
      }
    } catch (e) { debugPrint('[Family] getFamily: $e'); }
    _cachedFamily = null;
    return null;
  }

  Future<({bool success, String? error, FamilyInfo? family})> createFamily(String name) async {
    if (!_auth.isSignedIn) {
      return (success: false, error: 'Sign in to create a family', family: null);
    }
    try {
      final response = await _auth.post('/v1/family', {'name': name});
      if (response.statusCode == 201) {
        _cachedFamily = FamilyInfo.fromJson(jsonDecode(response.body)['family']);
        return (success: true, error: null, family: _cachedFamily);
      }
      if (response.statusCode == 401 || response.statusCode == 403) {
        return (success: false, error: 'Cloud Sync subscription required to create a family', family: null);
      }
      return (success: false, error: _parseError(response), family: null);
    } catch (e) { return (success: false, error: 'Connection error', family: null); }
  }

  Future<({bool success, String? error, String? familyName})> joinFamily(String inviteCode) async {
    if (!_auth.isSignedIn) {
      return (success: false, error: 'Sign in to join a family', familyName: null);
    }
    try {
      final response = await _auth.post('/v1/family/join', {'inviteCode': inviteCode});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await getFamily();
        return (success: true, error: null, familyName: data['familyName'] as String?);
      }
      if (response.statusCode == 401 || response.statusCode == 403) {
        return (success: false, error: 'Cloud Sync subscription required to join a family', familyName: null);
      }
      return (success: false, error: _parseError(response), familyName: null);
    } catch (e) { return (success: false, error: 'Connection error', familyName: null); }
  }

  Future<bool> leaveFamily() async {
    try {
      final r = await _auth.post('/v1/family/leave', {});
      if (r.statusCode == 200) { _cachedFamily = null; return true; }
    } catch (e) { debugPrint('[Family] leave: $e'); }
    return false;
  }

  Future<bool> removeMember(String targetUserId) async {
    try {
      final r = await _auth.delete('/v1/family/members/$targetUserId');
      if (r.statusCode == 200) { await getFamily(); return true; }
    } catch (e) { debugPrint('[Family] remove: $e'); }
    return false;
  }

  Future<String?> regenerateInviteCode() async {
    try {
      final r = await _auth.post('/v1/family/regenerate-code', {});
      if (r.statusCode == 200) { await getFamily(); return jsonDecode(r.body)['inviteCode']; }
    } catch (_) {}
    return null;
  }

  Future<bool> updateName(String name) async {
    try {
      final r = await _auth.patch('/v1/family', {'name': name});
      if (r.statusCode == 200) { await getFamily(); return true; }
    } catch (_) {}
    return false;
  }

  Future<bool> deleteFamily() async {
    try {
      final r = await _auth.delete('/v1/family');
      if (r.statusCode == 200) { _cachedFamily = null; return true; }
    } catch (_) {}
    return false;
  }

  // ────────────────────────────────────
  //  FAMILY SHARING (per-resource, per-member)
  // ────────────────────────────────────

  /// Get all shares for a specific cookbook or list that I own.
  Future<List<FamilyShareInfo>> getSharesForResource(String resourceType, String resourceId) async {
    try {
      final r = await _auth.get('/v1/family/shares/$resourceType/$resourceId');
      if (r.statusCode == 200) {
        final data = jsonDecode(r.body);
        return (data['shares'] as List).map((s) => FamilyShareInfo.fromJson(s)).toList();
      }
    } catch (e) { debugPrint('[Family] getShares: $e'); }
    return [];
  }

  /// Get all shares I've granted and received.
  Future<({List<FamilyShareInfo> granted, List<FamilyShareInfo> received})> getAllShares() async {
    try {
      final r = await _auth.get('/v1/family/shares');
      if (r.statusCode == 200) {
        final data = jsonDecode(r.body);
        return (
        granted: (data['granted'] as List).map((s) => FamilyShareInfo.fromJson(s as Map<String, dynamic>)).toList(),
        received: (data['received'] as List).map((s) => FamilyShareInfo.fromJson(s as Map<String, dynamic>)).toList(),
        );
      }
    } catch (e) { debugPrint('[Family] getAllShares: $e'); }
    return (granted: <FamilyShareInfo>[], received: <FamilyShareInfo>[]);
  }

  /// Share a resource with a family member.
  /// resourceType: 'cookbook' | 'shopping_list'
  /// permission: cookbook → read|add|edit, list → read|add|full
  Future<FamilyShareInfo?> shareResource({
    required String resourceType,
    required String resourceId,
    required String sharedWithUserId,
    required String permission,
  }) async {
    try {
      final r = await _auth.post('/v1/family/shares', {
        'resourceType': resourceType,
        'resourceId': resourceId,
        'sharedWithUserId': sharedWithUserId,
        'permission': permission,
      });
      if (r.statusCode == 200) {
        return FamilyShareInfo.fromJson(jsonDecode(r.body)['share']);
      }
      debugPrint('[Family] shareResource failed: ${_parseError(r)}');
    } catch (e) { debugPrint('[Family] shareResource: $e'); }
    return null;
  }

  /// Update permission on an existing share.
  Future<bool> updateSharePermission(String shareId, String permission) async {
    try {
      final r = await _auth.patch('/v1/family/shares/$shareId', {'permission': permission});
      return r.statusCode == 200;
    } catch (_) {}
    return false;
  }

  /// Revoke a share.
  Future<bool> revokeShare(String shareId) async {
    try {
      final r = await _auth.delete('/v1/family/shares/$shareId');
      return r.statusCode == 200;
    } catch (_) {}
    return false;
  }

  /// Fetch shared content from family members (for sync).
  Future<Map<String, dynamic>?> getSharedContent({DateTime? since}) async {
    try {
      final sinceParam = since != null ? '?since=${since.toUtc().toIso8601String()}' : '';
      final r = await _auth.get('/v1/family/shared$sinceParam');
      if (r.statusCode == 200) return jsonDecode(r.body);
    } catch (e) { debugPrint('[Family] getSharedContent: $e'); }
    return null;
  }

  // ────────────────────────────────────
  //  ONE-TIME SHARE LINKS
  // ────────────────────────────────────

  /// Create a temporary share link (24h expiry, free).
  /// Create a 24h share link. Pass [snapshot] for a self-contained recipe
  /// share (a frozen copy that works even for unsynced recipes and survives
  /// edits/deletes of the original).
  Future<ShareLinkInfo?> createShareLink(String resourceType, String resourceId,
      {Map<String, dynamic>? snapshot}) async {
    try {
      final body = <String, dynamic>{
        'resourceType': resourceType,
        'resourceId': resourceId,
        if (snapshot != null) 'snapshot': snapshot,
      };
      final r = await _auth.post('/v1/share', body);
      if (r.statusCode == 201) {
        return ShareLinkInfo.fromJson(jsonDecode(r.body));
      }
    } catch (e) { debugPrint('[Share] createLink: $e'); }
    return null;
  }

  /// List my active share links.
  Future<List<ShareLinkInfo>> getMyShareLinks() async {
    try {
      final r = await _auth.get('/v1/share');
      if (r.statusCode == 200) {
        final data = jsonDecode(r.body);
        return (data['links'] as List).map((l) => ShareLinkInfo.fromJson(l)).toList();
      }
    } catch (_) {}
    return [];
  }

  /// Revoke a share link.
  Future<bool> revokeShareLink(String code) async {
    try {
      final r = await _auth.delete('/v1/share/$code');
      return r.statusCode == 200;
    } catch (_) {}
    return false;
  }

  // ────────────────────────────────────

  String _parseError(dynamic response) {
    try {
      return jsonDecode(response.body)['error'] ?? 'Unknown error';
    } catch (_) { return 'Request failed'; }
  }
}