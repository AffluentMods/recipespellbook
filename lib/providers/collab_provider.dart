import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/collab_service.dart';

/// Rebuilds dependents whenever collab membership / permissions change.
///
/// Bridges [CollabService.revision] (a shared singleton [ValueNotifier]) into
/// Riverpod without letting Riverpod dispose the notifier — it only adds/removes
/// its own listener. Watch it from any widget that shows permission-gated
/// controls (add / edit / delete on shared cookbooks or lists).
final collabRevisionProvider = Provider<int>((ref) {
  final notifier = CollabService.instance.revision;
  void listener() => ref.invalidateSelf();
  notifier.addListener(listener);
  ref.onDispose(() => notifier.removeListener(listener));
  return notifier.value;
});
