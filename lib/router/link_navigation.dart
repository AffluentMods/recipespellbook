import '../utils/pending_deep_link.dart';
import '../utils/widget_links.dart';
import 'router.dart';

/// Opens [target], an in-app route from a link, a home screen widget or a
/// notification tap.
///
/// On a cold start the splash still owns navigation and goes Home when its
/// intro ends, which would cover anything pushed now. While it is up the
/// target is handed to it ([pendingDeepLink]) and it opens it on top of
/// Home. Once the app is up, a main tab is switched to and anything else is
/// pushed.
void openLinkTarget(String target) {
  if (splashActive) {
    pendingDeepLink = target;
  } else if (WidgetLinks.isTabRoute(target)) {
    router.go(target);
  } else {
    router.push(target);
  }
}
