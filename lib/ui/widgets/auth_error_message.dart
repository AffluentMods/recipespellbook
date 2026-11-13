import '../../l10n/app_localizations.dart';
import '../../services/auth_service.dart';

/// What to tell the user when signing in, or deleting the account, did not
/// work, in the app's language.
String authErrorMessage(AppLocalizations l10n, AuthError error) => switch (error) {
      AuthError.network => l10n.errorNetwork,
      AuthError.timeout => l10n.errorTimeout,
      AuthError.server => l10n.errorServerError,
      AuthError.signInFailed => l10n.signInFailed,
      AuthError.transferExpired => l10n.signInTransferExpired,
      AuthError.deleteFailed => l10n.deleteAccountFailed,
    };
