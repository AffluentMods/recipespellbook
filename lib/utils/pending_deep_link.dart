/// Deep-link coordination between the app's link handler and the splash screen.
///
/// On cold start the splash screen navigates to '/' when its intro animation
/// finishes (~2.8s), which would clobber a deep-link push that arrived while it
/// was still showing. So while the splash is active ([splashActive] == true) the
/// link handler stashes the target route here instead of pushing, and the splash
/// goes Home and opens it on top when it finishes. Once the app is warm the
/// handler navigates directly.
library;

/// Target route location captured during cold start (e.g. `/community/<id>`,
/// `/s/<code>` or `/family/join/<code>`). Null when there is nothing pending.
String? pendingDeepLink;

/// True while the splash screen is on-screen and owns the next navigation.
bool splashActive = false;
