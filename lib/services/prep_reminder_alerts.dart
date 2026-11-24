/// The prep reminder notifications the evening before a planned meal
/// (see PrepReminderService). Phones only: that is where NotificationService
/// sets local notifications up. A no-op on the web.
library;

export 'prep_reminder_alerts_stub.dart'
    if (dart.library.io) 'prep_reminder_alerts_native.dart';
