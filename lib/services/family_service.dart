import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'auth_service.dart';

const _apiUrl = String.fromEnvironment('API_URL', defaultValue: 'https://api.recipespellbook.app');

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

/// Why a family / invite request failed, so the UI can offer the right fix
/// (sign in again, upgrade, try another code…) instead of a generic error.
enum InviteErrorKind {
  /// Not signed in on this device.
  signedOut,

  /// Signed in, but the server rejected the session (401) — sign in again.
  sessionExpired,

  /// The signed-in user's plan doesn't include this (403).
  subscriptionRequired,

  /// The owner's plan lapsed, so the shared item can't sync to members.
  ownerSubscriptionRequired,

  /// Unknown / expired code, or the shared item was deleted.
  notFound,

  /// A one-time copy link was used where a live invite was expected.
  notCollab,

  /// The family has no free seats.
  familyFull,

  /// Already in a different family (must leave it first).
  alreadyInFamily,

  /// No connection / server unreachable.
  network,

  /// Anything else — see the accompanying server message.
  other,
}

/// Details of a family invite, shown before joining ("Join the Smiths?").
class FamilyInvitePreview {
  final String familyName;
  final String? ownerName;
  final String? ownerAvatarUrl;
  final int memberCount;
  final int maxMembers;
  final bool isFull;
  final bool alreadyMember;

  /// Name of the family the user is already in, when it's a different one.
  final String? currentFamilyName;

  const FamilyInvitePreview({
    required this.familyName, this.ownerName, this.ownerAvatarUrl,
    required this.memberCount, required this.maxMembers, required this.isFull,
    this.alreadyMember = false, this.currentFamilyName,
  });

  factory FamilyInvitePreview.fromJson(Map<String, dynamic> json) {
    final count = (json['memberCount'] as num?)?.toInt() ?? 0;
    final max = (json['maxMembers'] as num?)?.toInt() ?? 5;
    return FamilyInvitePreview(
      familyName: (json['familyName'] as String?) ?? '',
      ownerName: json['ownerName'] as String?,
      ownerAvatarUrl: json['ownerAvatarUrl'] as String?,
      memberCount: count,
      maxMembers: max,
      isFull: (json['isFull'] as bool?) ?? count >= max,
      alreadyMember: (json['alreadyMember'] as bool?) ?? false,
      currentFamilyName: json['currentFamilyName'] as String?,
    );
  }
}

/// A successful collaboration join.
class ShareJoinInfo {
  final String resourceType;
  final String resourceId;
  final String permission;

  /// The link is the current user's own — nothing was joined.
  final bool isOwner;

  const ShareJoinInfo({
    required this.resourceType, required this.resourceId,
    required this.permission, this.isOwner = false,
  });
}

/// A temporary one-time share link.
class ShareLinkInfo {
  final String code;
  final String url;
  final String resourceType;
  final String resourceId;
  final DateTime expiresAt;

  const ShareLinkInfo({
    required this.code, required this.url, this.resourceType = '',
    this.resourceId = '', required this.expiresAt,
  });

  // The POST /v1/share response only returns { code, url, expiresAt }; the
  // list endpoint adds resourceType/resourceId. Tolerate either — casting a
  // missing field to a non-null String used to throw and silently drop the
  // whole link (falling back to a plain title share).
  factory ShareLinkInfo.fromJson(Map<String, dynamic> json) => ShareLinkInfo(
    code: json['code'] as String,
    url: json['url'] as String,
    resourceType: (json['resourceType'] as String?) ?? '',
    resourceId: (json['resourceId'] as String?) ?? '',
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

  /// Create a family owned by the current user. On failure [error] says why;
  /// [message] carries the server's wording for [InviteErrorKind.other].
  Future<({bool success, InviteErrorKind? error, String? message, FamilyInfo? family})>
      createFamily(String name) async {
    if (!_auth.isSignedIn) {
      return (success: false, error: InviteErrorKind.signedOut, message: null, family: null);
    }
    try {
      final response = await _auth.post('/v1/family', {'name': name});
      if (response.statusCode == 201) {
        _cachedFamily = FamilyInfo.fromJson(jsonDecode(response.body)['family']);
        return (success: true, error: null, message: null, family: _cachedFamily);
      }
      final (kind, message) = _classifyError(response, forbidden: InviteErrorKind.subscriptionRequired);
      return (success: false, error: kind, message: message, family: null);
    } catch (e) {
      return (success: false, error: InviteErrorKind.network, message: null, family: null);
    }
  }

  /// Join the family with [inviteCode]. Joining never needs a paid plan — the
  /// owner's plan covers the family — so a 403 here is NOT "subscription
  /// required" (it's e.g. a disabled account); 401 means the session expired.
  Future<({bool success, InviteErrorKind? error, String? message, String? familyName})>
      joinFamily(String inviteCode) async {
    if (!_auth.isSignedIn) {
      return (success: false, error: InviteErrorKind.signedOut, message: null, familyName: null);
    }
    try {
      final response = await _auth.post('/v1/family/join', {'inviteCode': inviteCode.trim()});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await getFamily();
        return (success: true, error: null, message: null, familyName: data['familyName'] as String?);
      }
      final (kind, message) = _classifyError(response);
      return (success: false, error: kind, message: message, familyName: null);
    } catch (e) {
      return (success: false, error: InviteErrorKind.network, message: null, familyName: null);
    }
  }

  /// Look up a family invite before joining it. [unsupported] is true when the
  /// server predates the preview endpoint — callers can still offer to join.
  Future<({FamilyInvitePreview? preview, InviteErrorKind? error, bool unsupported})>
      previewFamilyInvite(String inviteCode) async {
    if (!_auth.isSignedIn) {
      return (preview: null, error: InviteErrorKind.signedOut, unsupported: false);
    }
    try {
      final r = await _auth.get('/v1/family/invite/${Uri.encodeComponent(inviteCode.trim())}');
      if (r.statusCode == 200) {
        final data = jsonDecode(r.body) as Map<String, dynamic>;
        return (
          preview: FamilyInvitePreview.fromJson(data['invite'] as Map<String, dynamic>),
          error: null,
          unsupported: false,
        );
      }
      // Our 404 is JSON ({error, code}); Express's own "Cannot GET" 404 for an
      // unknown route is HTML — that means an older server without previews.
      if (r.statusCode == 404 && _errorBody(r) == null) {
        return (preview: null, error: null, unsupported: true);
      }
      final (kind, _) = _classifyError(r);
      return (preview: null, error: kind, unsupported: false);
    } catch (e) {
      debugPrint('[Family] previewInvite: $e');
      return (preview: null, error: InviteErrorKind.network, unsupported: false);
    }
  }

  /// Check whether [code] is a live share link (public, no auth). Returns the
  /// HTTP status (200 found, 404 unknown, 410 expired) or null when offline.
  Future<int?> probeShareCode(String code) async {
    try {
      final r = await http
          .get(Uri.parse('$_apiUrl/v1/share/${Uri.encodeComponent(code)}'))
          .timeout(const Duration(seconds: 10));
      return r.statusCode;
    } catch (e) {
      debugPrint('[Share] probe: $e');
      return null;
    }
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

  /// Create (or reuse) a LIVE-COLLABORATION link with a permission. Anyone who
  /// opens it (signed in) joins the resource as a member.
  /// [resourceType]: 'shopping_list' | 'cookbook'.
  /// [permission]: list → 'read' | 'check' | 'full'; cookbook → 'read' | 'edit'.
  /// For shopping lists, pass [snapshot] ({name, color, items:[...]}) so the
  /// list is published server-side (works on any tier).
  Future<ShareLinkInfo?> createCollabLink(
      String resourceType, String resourceId, String permission,
      {Map<String, dynamic>? snapshot}) async {
    try {
      final body = <String, dynamic>{
        'resourceType': resourceType,
        'resourceId': resourceId,
        'kind': 'collab',
        'permission': permission,
        if (snapshot != null) 'snapshot': snapshot,
      };
      final r = await _auth.post('/v1/share', body);
      if (r.statusCode == 201) return ShareLinkInfo.fromJson(jsonDecode(r.body));
      debugPrint('[Share] createCollabLink failed: ${_parseError(r)}');
    } catch (e) { debugPrint('[Share] createCollabLink: $e'); }
    return null;
  }

  /// Join a collaboration invite by code. Returns the resource + granted
  /// permission, or why it failed (expired link, paywalled cookbook, expired
  /// session…) so the caller can offer the right next step.
  Future<({ShareJoinInfo? joined, InviteErrorKind? error, String? message})>
      joinShareLink(String code) async {
    if (!_auth.isSignedIn) {
      return (joined: null, error: InviteErrorKind.signedOut, message: null);
    }
    try {
      final r = await _auth.post('/v1/share/${Uri.encodeComponent(code)}/join', {});
      if (r.statusCode == 200) {
        final d = jsonDecode(r.body) as Map<String, dynamic>;
        return (
          joined: ShareJoinInfo(
            resourceType: d['resourceType'] as String,
            resourceId: d['resourceId'] as String,
            permission: (d['permission'] as String?) ?? 'read',
            isOwner: d['owner'] == true,
          ),
          error: null,
          message: null,
        );
      }
      debugPrint('[Share] join failed (${r.statusCode}): ${_parseError(r)}');
      if (r.statusCode == 400) {
        return (joined: null, error: InviteErrorKind.notCollab, message: null);
      }
      final (kind, message) = _classifyError(r, forbidden: InviteErrorKind.subscriptionRequired);
      return (joined: null, error: kind, message: message);
    } catch (e) {
      debugPrint('[Share] join: $e');
      return (joined: null, error: InviteErrorKind.network, message: null);
    }
  }

  /// Pull collaborative shopping lists shared with me (free channel). Returns
  /// the raw decoded { serverTime, lists, items, members, permissions }.
  Future<Map<String, dynamic>?> collabPull({String? since}) async {
    try {
      final q = since != null ? '?since=${Uri.encodeComponent(since)}' : '';
      final r = await _auth.get('/v1/collab/pull$q');
      if (r.statusCode == 200) return jsonDecode(r.body) as Map<String, dynamic>;
    } catch (e) { debugPrint('[Collab] pull: $e'); }
    return null;
  }

  /// Push my local changes to collaborative shopping lists (permission-enforced
  /// server-side) and get server changes back in the same shape as [collabPull].
  Future<Map<String, dynamic>?> collabPush({
    required List<Map<String, dynamic>> lists,
    required List<Map<String, dynamic>> items,
    String? since,
  }) async {
    try {
      final r = await _auth.post('/v1/collab/push', {
        if (since != null) 'since': since,
        'lists': lists,
        'items': items,
      });
      if (r.statusCode == 200) return jsonDecode(r.body) as Map<String, dynamic>;
    } catch (e) { debugPrint('[Collab] push: $e'); }
    return null;
  }

  /// Push my edits to recipes in shared cookbooks I can edit (server enforces
  /// permission + preserves the owner's userId). [recipes] each carry their
  /// children (ingredients/steps/tags/recipeLinks) inline, same shape as sync.
  Future<Map<String, dynamic>?> collabCookbookPush({
    required List<Map<String, dynamic>> recipes,
    String? since,
  }) async {
    try {
      final r = await _auth.post('/v1/collab/cookbook-push', {
        if (since != null) 'since': since,
        'recipes': recipes,
      });
      if (r.statusCode == 200) return jsonDecode(r.body) as Map<String, dynamic>;
      debugPrint('[Collab] cookbook-push failed: ${_parseError(r)}');
    } catch (e) { debugPrint('[Collab] cookbook-push: $e'); }
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

  /// The decoded JSON error body, or null when the body isn't a JSON object.
  Map<String, dynamic>? _errorBody(http.Response r) {
    try {
      final d = jsonDecode(r.body);
      return d is Map<String, dynamic> ? d : null;
    } catch (_) {
      return null;
    }
  }

  /// Map a failed family / share response to an [InviteErrorKind]. Prefers the
  /// server's machine-readable `code`; falls back to the status for older
  /// servers. [forbidden] is what a code-less 403 means for this endpoint.
  (InviteErrorKind, String?) _classifyError(http.Response r,
      {InviteErrorKind forbidden = InviteErrorKind.other}) {
    final body = _errorBody(r);
    final message = body?['error'] as String?;
    switch (body?['code']) {
      case 'invalid_code' || 'not_found' || 'resource_gone':
        return (InviteErrorKind.notFound, message);
      case 'family_full':
        return (InviteErrorKind.familyFull, message);
      case 'already_in_family':
        return (InviteErrorKind.alreadyInFamily, message);
      case 'subscription_required':
        return (InviteErrorKind.subscriptionRequired, message);
      case 'owner_subscription_required':
        return (InviteErrorKind.ownerSubscriptionRequired, message);
      case 'not_collab':
        return (InviteErrorKind.notCollab, message);
    }
    switch (r.statusCode) {
      case 401:
        return (InviteErrorKind.sessionExpired, message);
      case 403:
        // requireAuth answers 403 for disabled accounts on every route.
        return (message == 'Account disabled' ? InviteErrorKind.other : forbidden, message);
      case 404 || 410:
        return (InviteErrorKind.notFound, message);
      case 409:
        // Older servers send no code: "Family is full" vs "Already in a family".
        final full = (message ?? '').toLowerCase().contains('full');
        return (full ? InviteErrorKind.familyFull : InviteErrorKind.alreadyInFamily, message);
    }
    return (InviteErrorKind.other, message);
  }
}