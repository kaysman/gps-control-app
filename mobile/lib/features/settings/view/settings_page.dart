import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gps_control/app/tokens.dart';
import 'package:gps_control/app/widgets/picker_sheet.dart';
import 'package:gps_control/features/settings/cubit/brand_cubit.dart';
import 'package:gps_control/features/settings/widgets/brand_sheet.dart';
import 'package:gps_control/features/settings/widgets/language_sheet.dart';
import 'package:gps_control/features/settings/widgets/settings_section.dart';
import 'package:gps_control/features/settings/widgets/sim_sheet.dart';
import 'package:gps_control/features/sim/cubit/sim_cubit.dart';
import 'package:gps_control/l10n/l10n.dart';

/// Settings tab. Every row here is a one-of-N choice, so every row opens the
/// same kind of bottom sheet rather than inventing a control per setting.
class SettingsPage extends StatelessWidget {
  /// Creates the settings page.
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final l10n = context.l10n;
    final locale = context.watch<LocaleCubit>().state;
    final brand = context.watch<BrandCubit>().state;
    final sims = context.watch<SimCubit>().state;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(0, topPad, 0, 130),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(title: l10n.settingsTitle),
          SettingsSection(
            title: l10n.settingsSectionApp,
            children: [
              SettingsRow(
                icon: Icons.translate,
                label: l10n.settingsRowLanguage,
                value: LanguageSheet.labelFor(l10n, locale),
                onTap: () => openPickerSheet(
                  context: context,
                  builder: (_) => const LanguageSheet(),
                ),
              ),
            ],
          ),
          SettingsSection(
            title: l10n.settingsSectionDevice,
            children: [
              SettingsRow(
                icon: Icons.memory,
                label: l10n.settingsRowBrand,
                value: BrandSheet.labelFor(l10n, brand),
                // TODO(brand): only Bariox is implemented. Surface the gap
                // here again once there is something to say about it.
                onTap: () => openPickerSheet(
                  context: context,
                  builder: (_) => const BrandSheet(),
                ),
              ),
            ],
          ),
          SettingsSection(
            title: l10n.settingsSectionSims,
            children: [
              SettingsRow(
                icon: Icons.sim_card_outlined,
                label: l10n.settingsRowSim,
                value: SimSheet.rowValue(l10n, sims),
                onTap: () => openPickerSheet(
                  context: context,
                  builder: (_) => const SimSheet(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Oversized display header. The title carries the page on its own — no
/// eyebrow, no subtitle explaining what "Settings" means.
class _Header extends StatelessWidget {
  const _Header({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 18),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontFamily: kSans,
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: kInk,
            letterSpacing: -1.4,
            height: 1,
          ),
        ),
      ),
    );
  }
}
