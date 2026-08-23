import 'package:gps_control/app/tokens.dart';
import 'package:gps_control/features/sim/cubit/sim_cubit.dart';
import 'package:gps_control/l10n/l10n.dart';
import 'package:gps_control/data/sim/sim_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final l10n = context.l10n;
    final locale = context.watch<LocaleCubit>().state;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(0, topPad, 0, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
            child: Text(
              l10n.settingsTitle,
              style: TextStyle(
                fontFamily: kSans,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: kNavy,
                letterSpacing: -0.5,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 6, 22, 6),
            child: Text(
              l10n.settingsSectionApp,
              style: TextStyle(
                fontFamily: kSans,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: kMute,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(18, 0, 18, 14),
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: kRule),
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _openLanguagePicker(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.settingsRowLanguage,
                        style: TextStyle(
                          fontFamily: kSans,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: kNavy,
                        ),
                      ),
                    ),
                    Text(
                      _languageLabel(l10n, locale),
                      style: TextStyle(
                        fontFamily: kSans,
                        fontSize: 12.5,
                        color: kMute,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.chevron_right, size: 18, color: kMute2),
                  ],
                ),
              ),
            ),
          ),
          const _SimsSection(),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Text(
                l10n.settingsFooter,
                style: TextStyle(fontFamily: kMono, fontSize: 11, color: kMute),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openLanguagePicker(BuildContext context) {
    final cubit = context.read<LocaleCubit>();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _LanguagePickerSheet(
        current: cubit.state,
        onPick: (locale) {
          cubit.setLocale(locale);
          Navigator.pop(context);
        },
      ),
    );
  }
}

String _languageLabel(AppLocalizations l10n, Locale locale) =>
    switch (locale.languageCode) {
      'tr' => l10n.languageTurkish,
      _ => l10n.languageEnglish,
    };

class _LanguagePickerSheet extends StatelessWidget {
  const _LanguagePickerSheet({required this.current, required this.onPick});

  final Locale current;
  final ValueChanged<Locale> onPick;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: kPaper,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(0, 0, 0, bottomPad),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: kRuleS,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.languagePickerTitle,
                style: TextStyle(
                  fontFamily: kSans,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: kNavy,
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(18, 0, 18, 14),
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: kRule),
            ),
            child: Column(
              children: [
                _LanguageRow(
                  label: l10n.languageTurkish,
                  selected: current.languageCode == 'tr',
                  onTap: () => onPick(const Locale('tr')),
                ),
                Divider(height: 1, color: kRule),
                _LanguageRow(
                  label: l10n.languageEnglish,
                  selected: current.languageCode == 'en',
                  onTap: () => onPick(const Locale('en')),
                  last: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({
    required this.label,
    required this.selected,
    required this.onTap,
    this.last = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: kSans,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: kNavy,
                ),
              ),
            ),
            if (selected) Icon(Icons.check, size: 18, color: kOrange),
          ],
        ),
      ),
    );
  }
}

class _SimsSection extends StatelessWidget {
  const _SimsSection();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<SimCubit>().state;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 6, 22, 6),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.settingsSectionSims,
                  style: TextStyle(
                    fontFamily: kSans,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: kMute,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => context.read<SimCubit>().load(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  child: Text(
                    l10n.simsRefresh,
                    style: TextStyle(
                      fontFamily: kSans,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: kOrangeD,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(18, 0, 18, 14),
          decoration: BoxDecoration(
            color: kWhite,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kRule),
          ),
          child: state.sims.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.sim_card_alert_outlined,
                        size: 18,
                        color: kMute2,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l10n.simsNone,
                          style: TextStyle(
                            fontFamily: kSans,
                            fontSize: 13.5,
                            color: kMute,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    for (var i = 0; i < state.sims.length; i++)
                      _SimRow(
                        sim: state.sims[i],
                        selected:
                            state.sims[i].subscriptionId ==
                            state.selectedSubscriptionId,
                        last: i == state.sims.length - 1,
                        onTap: () => context.read<SimCubit>().select(
                          state.sims[i].subscriptionId,
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _SimRow extends StatelessWidget {
  const _SimRow({
    required this.sim,
    required this.selected,
    required this.last,
    required this.onTap,
  });

  final SimCard sim;
  final bool selected;
  final bool last;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final country = sim.countryIso.isNotEmpty
        ? sim.countryIso.toUpperCase()
        : '—';
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: last ? BorderSide.none : BorderSide(color: kRule),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Icon(Icons.sim_card_outlined, size: 18, color: kNavy),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sim.label,
                    style: TextStyle(
                      fontFamily: kSans,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: kNavy,
                    ),
                  ),
                  Text(
                    l10n.simSubtitle(sim.slotIndex + 1, country),
                    style: TextStyle(
                      fontFamily: kSans,
                      fontSize: 11.5,
                      color: kMute,
                    ),
                  ),
                  if (sim.number.isNotEmpty)
                    Text(
                      sim.number,
                      style: TextStyle(
                        fontFamily: kMono,
                        fontSize: 11,
                        color: kMute2,
                      ),
                    ),
                ],
              ),
            ),
            if (selected) Icon(Icons.check, size: 18, color: kOrange),
          ],
        ),
      ),
    );
  }
}
