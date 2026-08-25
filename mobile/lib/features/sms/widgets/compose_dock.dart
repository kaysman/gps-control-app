import 'package:flutter/material.dart';
import 'package:gps_control/app/tokens.dart';
import 'package:gps_control/features/sms/sms_command_labels.dart';
import 'package:gps_control/l10n/l10n.dart';
import 'package:gps_control/mock/mock_data.dart';

class SmsComposeDock extends StatefulWidget {
  const SmsComposeDock({
    required this.cmd,
    required this.onCancel,
    required this.onSend,
    super.key,
  });
  final SmsCommand cmd;
  final VoidCallback onCancel;
  final ValueChanged<Object?> onSend;

  @override
  State<SmsComposeDock> createState() => _SmsComposeDockState();
}

class _SmsComposeDockState extends State<SmsComposeDock> {
  late Object? _value;

  @override
  void initState() {
    super.initState();
    final input = widget.cmd.input;
    _value = input == null
        ? null
        : input.kind == 'toggle'
        ? (input.defaultBool ?? true)
        : (input.defaultStr ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final cmd = widget.cmd;
    final l10n = context.l10n;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final tagLabel = cmd.input != null
        ? l10n.composeTagSet
        : cmd.danger
        ? l10n.composeTagAction
        : l10n.composeTagCommand;

    final sub = smsCommandSub(l10n, cmd.id);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(kR30)),
        ),
        padding: EdgeInsets.fromLTRB(14, 16, 14, 16 + bottomPad),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: kMist,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    tagLabel,
                    style: const TextStyle(
                      fontFamily: kSans,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: kInk,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  smsCommandName(l10n, cmd.id),
                  style: const TextStyle(
                    fontFamily: kSans,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: kInk,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: widget.onCancel,
                  child: const Icon(Icons.close, color: kMute),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (cmd.input != null)
              _SmsInputWidget(
                cmdId: cmd.id,
                input: cmd.input!,
                value: _value,
                onChange: (v) => setState(() => _value = v),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cmd.danger ? kBad.withValues(alpha: 0.06) : kCanvas,
                  borderRadius: BorderRadius.circular(kR14),
                ),
                child: Text(
                  cmd.danger
                      ? l10n.composeDangerWarning
                      : (sub.isEmpty ? l10n.composeNoParams : sub),
                  style: TextStyle(
                    fontFamily: kSans,
                    fontSize: 12.5,
                    color: cmd.danger ? kBad : kInkSoft,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => widget.onSend(_value),
              child: Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: cmd.danger ? kBad : kGreen,
                  borderRadius: BorderRadius.circular(kR14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.send, size: 14, color: kInk),
                    const SizedBox(width: 8),
                    Text(
                      l10n.composeSend,
                      style: TextStyle(
                        fontFamily: kSans,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: cmd.danger ? kWhite : kInk,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmsInputWidget extends StatelessWidget {
  const _SmsInputWidget({
    required this.cmdId,
    required this.input,
    required this.value,
    required this.onChange,
  });
  final String cmdId;
  final CmdInput input;
  final Object? value;
  final ValueChanged<Object?> onChange;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final label = smsInputLabel(l10n, cmdId);
    final unit = smsInputUnit(l10n, cmdId);

    if (input.kind == 'toggle') {
      final on = value as bool? ?? true;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: kCanvas,
          borderRadius: BorderRadius.circular(kR14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: kSans,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: kInk,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: kRule),
                borderRadius: BorderRadius.circular(kR14),
              ),
              child: Row(
                children: [
                  _SmsToggleBtn(
                    label: l10n.composeToggleOn,
                    active: on,
                    onTap: () => onChange(true),
                  ),
                  _SmsToggleBtn(
                    label: l10n.composeToggleOff,
                    active: !on,
                    onTap: () => onChange(false),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    if (input.kind == 'segmented') {
      final options = input.optionIds ?? const <String>[];
      final sel = value as String? ?? (options.isNotEmpty ? options.first : '');
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: kCanvas,
          borderRadius: BorderRadius.circular(kR14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: kSans,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: kInk,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: kRule),
                borderRadius: BorderRadius.circular(kR14),
              ),
              child: Row(
                children: options
                    .map(
                      (id) => _SmsToggleBtn(
                        label: smsOptionLabel(l10n, id),
                        active: sel == id,
                        onTap: () => onChange(id),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      );
    }
    final isPin = input.kind == 'pin';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kCanvas,
        borderRadius: BorderRadius.circular(kR14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: kSans,
              fontSize: 12,
              color: kMute,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextField(
                  obscureText: isPin,
                  keyboardType: input.kind == 'duration' || input.kind == 'pin'
                      ? TextInputType.number
                      : input.kind == 'phone'
                      ? TextInputType.phone
                      : TextInputType.text,
                  controller: TextEditingController(text: input.defaultStr),
                  textAlign: isPin ? TextAlign.center : TextAlign.start,
                  style: TextStyle(
                    fontFamily: kMono,
                    fontSize: isPin ? 18 : 14,
                    fontWeight: FontWeight.w700,
                    color: kInk,
                    letterSpacing: isPin ? 6 : 0,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: input.placeholder,
                    filled: true,
                    fillColor: kWhite,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: kRule),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: kRule),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                  ),
                  onChanged: onChange,
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 8),
                Text(
                  unit,
                  style: const TextStyle(
                    fontFamily: kSans,
                    fontSize: 12.5,
                    color: kMute,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _SmsToggleBtn extends StatelessWidget {
  const _SmsToggleBtn({
    required this.label,
    required this.active,
    required this.onTap,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: active ? kInk : kWhite,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: kSans,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: active ? kWhite : kInk,
          ),
        ),
      ),
    );
  }
}
