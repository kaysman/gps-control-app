import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Holds the currently selected app locale. English is the default; Turkish
/// is the only other supported choice for now.
class LocaleCubit extends Cubit<Locale> {
  /// Starts in [initial], defaulting to English — the app's default locale.
  LocaleCubit({Locale initial = const Locale('en')}) : super(initial);

  /// All locales the app knows how to render, default first.
  static const supported = [Locale('en'), Locale('tr')];

  /// Switches the active locale. No-op if [locale] is unsupported or already
  /// active.
  void setLocale(Locale locale) {
    if (!supported.contains(locale) || locale == state) return;
    emit(locale);
  }
}
