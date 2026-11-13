/// A notification when a cooking mode timer ends while the app is not on
/// screen (the phone locked, another app open), when the timer itself cannot
/// run. Phones only: that is where NotificationService sets local
/// notifications up. A no-op on the web.
library;

export 'cooking_timer_alerts_stub.dart'
    if (dart.library.io) 'cooking_timer_alerts_native.dart';
