import 'package:bariox_control/l10n/generated/app_localizations.dart';
import 'package:flutter/widgets.dart';

export 'package:bariox_control/l10n/generated/app_localizations.dart';
export 'package:bariox_control/l10n/locale_cubit.dart';

/// Convenience accessor for the current [AppLocalizations] from any widget.
extension AppLocalizationsX on BuildContext {
  /// The current locale's translation table.
  AppLocalizations get l10n => AppLocalizations.of(this);
}
