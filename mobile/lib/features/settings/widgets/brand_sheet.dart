import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gps_control/app/widgets/picker_sheet.dart';
import 'package:gps_control/features/settings/cubit/brand_cubit.dart';
import 'package:gps_control/l10n/l10n.dart';

/// Tracker-brand picker: Bariox or Teltonika.
class BrandSheet extends StatelessWidget {
  /// Creates the brand picker.
  const BrandSheet({super.key});

  /// Display name for [brand]. Brand names are not translated; the l10n keys
  /// exist so the sheet reads consistently with the rest of the table.
  static String labelFor(AppLocalizations l10n, TrackerBrand brand) =>
      switch (brand) {
        TrackerBrand.bariox => l10n.brandBariox,
        TrackerBrand.teltonika => l10n.brandTeltonika,
      };

  static String _subtitleFor(AppLocalizations l10n, TrackerBrand brand) =>
      switch (brand) {
        TrackerBrand.bariox => l10n.brandBarioxSub,
        TrackerBrand.teltonika => l10n.brandTeltonikaSub,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final current = context.watch<BrandCubit>().state;

    return PickerSheet(
      title: l10n.brandPickerTitle,
      subtitle: l10n.brandPickerSubtitle,
      children: [
        // TODO(brand): selecting a brand does not switch command sets
        // yet. SMS speaks Teltonika; BLE speaks Bariox — see
        // TrackerBrand.hasBleSupport.
        for (final brand in TrackerBrand.values)
          PickerRow(
            icon: brand == TrackerBrand.bariox
                ? Icons.lock_outline
                : Icons.settings_input_antenna,
            label: labelFor(l10n, brand),
            subtitle: _subtitleFor(l10n, brand),
            selected: brand == current,
            onTap: () {
              context.read<BrandCubit>().setBrand(brand);
              Navigator.pop(context);
            },
          ),
      ],
    );
  }
}
