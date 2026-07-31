import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Confirm-before-discard callback published by the currently-mounted recipe
/// editor. Returns true when it's safe to leave (no unsaved changes, or the
/// user chose Discard), false to keep editing.
typedef DiscardGuard = Future<bool> Function();

/// Null unless a recipe editor is mounted in-shell on desktop / large tablet,
/// where a sidebar/rail/shortcut/palette `context.go()` would replace (unmount)
/// the editor WITHOUT triggering its PopScope. Consumers await this before any
/// such navigation. Always null on phones (the editor is full-screen there and
/// PopScope already covers the only exit).
final unsavedEditorGuardProvider = StateProvider<DiscardGuard?>((ref) => null);

/// Consults [unsavedEditorGuardProvider] before a route change that would
/// replace an in-shell editor. Returns true to proceed, false to abort. A no-op
/// (returns true immediately) whenever no editor is guarding.
Future<bool> confirmDiscardBeforeLeaving(WidgetRef ref) async {
  final guard = ref.read(unsavedEditorGuardProvider);
  if (guard == null) return true;
  return guard();
}
