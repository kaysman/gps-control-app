import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gps_control/app/widgets/picker_sheet.dart';
import 'package:gps_control/l10n/l10n.dart';

/// Locale picker. Opens over the tab bar via [openPickerSheet].
class LanguageSheet extends StatelessWidget {
  /// Creates the language picker.
  const LanguageSheet({super.key});

  /// Human name for [locale] in the current translation.
  static String labelFor(AppLocalizations l10n, Locale locale) =>
      switch (locale.languageCode) {
        'tr' => l10n.languageTurkish,
        _ => l10n.languageEnglish,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final current = context.watch<LocaleCubit>().state;

    return PickerSheet(
      title: l10n.languagePickerTitle,
      subtitle: l10n.languagePickerSubtitle,
      children: [
        for (final locale in LocaleCubit.supported)
          PickerRow(
            icon: Icons.translate,
            label: labelFor(l10n, locale),
            subtitle: locale.languageCode.toUpperCase(),
            selected: locale.languageCode == current.languageCode,
            onTap: () {
              context.read<LocaleCubit>().setLocale(locale);
              Navigator.pop(context);
            },
          ),
      ],
    );
  }
}
