import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gps_control/app/tokens.dart';
import 'package:gps_control/app/widgets/picker_sheet.dart';
import 'package:gps_control/features/sms/cubit/tracker_password_cubit.dart';
import 'package:gps_control/l10n/l10n.dart';
import 'package:gps_control/mock/mock_data.dart';

/// Opens the password editor for [tracker].
void openPasswordSheet({
  required BuildContext context,
  required MockTracker tracker,
}) {
  openPickerSheet(
    context: context,
    builder: (_) => _PasswordSheet(tracker: tracker),
  );
}

/// Wears the same chrome as every other picker, holding a single field
/// instead of a list of options.
class _PasswordSheet extends StatefulWidget {
  const _PasswordSheet({required this.tracker});

  final MockTracker tracker;

  @override
  State<_PasswordSheet> createState() => _PasswordSheetState();
}

class _PasswordSheetState extends State<_PasswordSheet> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
      text: context.read<TrackerPasswordCubit>().state[widget.tracker.id] ?? '',
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PickerSheet(
      title: l10n.smsPasswordTitle,
      subtitle: l10n.smsPasswordSubtitle,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
          child: TextField(
            controller: _ctrl,
            keyboardType: TextInputType.number,
            maxLength: 6,
            // Saved as it is typed: the sheet has no submit button, so there
            // is no way to lose what was entered by dismissing it.
            onChanged: (v) =>
                context.read<TrackerPasswordCubit>().set(widget.tracker.id, v),
            style: const TextStyle(
              fontFamily: kMono,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: kInk,
              letterSpacing: 3,
            ),
            decoration: InputDecoration(
              counterText: '',
              hintText: TrackerPasswordCubit.fallback,
              hintStyle: const TextStyle(
                fontFamily: kMono,
                fontSize: 17,
                color: kMute2,
                letterSpacing: 3,
              ),
              filled: true,
              fillColor: kCanvas,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(kR14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(kR14),
                borderSide: const BorderSide(color: kGreen, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
