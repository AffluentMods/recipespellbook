import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';

import '../../database/database.dart';
import '../../providers/cookbook_provider.dart';
import '../../services/collab_service.dart';
import 'app_snackbar.dart';

/// Whether [cookbook] is someone else's, shared with this account. Such a
/// cookbook is left, never deleted: deleting it here trashed the owner's
/// recipes and sent them back to the server as this account's copies.
bool isSharedInCookbook(Cookbook cookbook) =>
    cookbook.sharedOwnerId != null || CollabService.instance.isCollabCookbook(cookbook.id);

/// Asks, then leaves [cookbook] (see CollabService.leaveSharedCookbook) and
/// moves the selection off it. True when it is gone.
Future<bool> confirmLeaveCookbook(BuildContext context, WidgetRef ref, Cookbook cookbook) async {
  final l10n = AppLocalizations.of(context)!;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.cookbookLeave),
      content: Text(l10n.cookbookLeaveConfirm(cookbook.name)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.actionCancel)),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(l10n.familyLeaveAction),
        ),
      ],
    ),
  );
  if (confirmed != true) return false;
  final left = await CollabService.instance.leaveSharedCookbook(cookbook.id);
  if (!context.mounted) return left;
  if (!left) {
    AppSnackbar.error(context, l10n.cookbookLeaveFailed);
    return false;
  }
  await moveOnFromCookbook(ref.read, cookbook.id);
  return true;
}
