import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Holds the currently selected app locale. Turkish is the default; English
/// is the only other supported choice for now.
class LocaleCubit extends Cubit<Locale> {
  /// Starts in Turkish — the app's default locale.
  LocaleCubit() : super(const Locale('tr'));

  /// All locales the app knows how to render.
  static const supported = [Locale('tr'), Locale('en')];

  /// Switches the active locale. No-op if [locale] is unsupported or already
  /// active.
  void setLocale(Locale locale) {
    if (!supported.contains(locale) || locale == state) return;
    emit(locale);
  }
}
