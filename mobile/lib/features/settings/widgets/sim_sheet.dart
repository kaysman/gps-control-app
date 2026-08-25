import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gps_control/app/tokens.dart';
import 'package:gps_control/app/widgets/picker_sheet.dart';
import 'package:gps_control/data/sim/sim_repository.dart';
import 'package:gps_control/features/sim/cubit/sim_cubit.dart';
import 'package:gps_control/l10n/l10n.dart';

/// Picker for the SIM outgoing commands leave from. Same shape as the
/// language and brand sheets, plus a refresh action — the SIM list is the one
/// option set that can change while the sheet is open.
class SimSheet extends StatelessWidget {
  /// Creates the SIM picker.
  const SimSheet({super.key});

  /// The settings-row summary of [state]: carrier and slot, or "None".
  static String rowValue(AppLocalizations l10n, SimState state) {
    final sim = state.selected;
    if (sim == null) return l10n.simRowNone;
    return l10n.smsActiveSimChip(sim.label, sim.slotIndex + 1);
  }

  static String _subtitle(AppLocalizations l10n, SimCard sim) {
    final country = sim.countryIso.isNotEmpty
        ? sim.countryIso.toUpperCase()
        : '—';
    return l10n.simSubtitle(sim.slotIndex + 1, country);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<SimCubit>().state;

    return PickerSheet(
      title: l10n.simPickerTitle,
      subtitle: l10n.simPickerSubtitle,
      action: PickerSheetAction(
        label: l10n.simsRefresh,
        onTap: () => context.read<SimCubit>().load(),
      ),
      children: state.sims.isEmpty
          ? [const _NoSimsRow()]
          : [
              for (final sim in state.sims)
                PickerRow(
                  icon: Icons.sim_card_outlined,
                  label: sim.label,
                  subtitle: _subtitle(l10n, sim),
                  mono: sim.number.isNotEmpty ? sim.number : null,
                  selected: sim.subscriptionId == state.selectedSubscriptionId,
                  onTap: () {
                    context.read<SimCubit>().select(sim.subscriptionId);
                    Navigator.pop(context);
                  },
                ),
            ],
    );
  }
}

class _NoSimsRow extends StatelessWidget {
  const _NoSimsRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: Row(
        children: [
          const Icon(Icons.sim_card_alert_outlined, size: 18, color: kMute2),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.l10n.simsNone,
              style: const TextStyle(
                fontFamily: kSans,
                fontSize: 13.5,
                color: kMute,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
