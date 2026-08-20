import 'package:bariox_control/app/tokens.dart';
import 'package:bariox_control/l10n/l10n.dart';
import 'package:bariox_control/mock/mock_data.dart';
import 'package:flutter/material.dart';

class SmsTrackerPickerSheet extends StatefulWidget {
  const SmsTrackerPickerSheet({
    super.key,
    required this.selected,
    required this.passwords,
    required this.onChanged,
  });
  final Set<String> selected;
  final Map<String, String> passwords;
  final void Function(Set<String> sel, Map<String, String> passwords) onChanged;

  @override
  State<SmsTrackerPickerSheet> createState() => _SmsTrackerPickerSheetState();
}

class _SmsTrackerPickerSheetState extends State<SmsTrackerPickerSheet> {
  late final Set<String> _sel;
  late final Map<String, TextEditingController> _pwCtrl;

  @override
  void initState() {
    super.initState();
    _sel = Set.of(widget.selected);
    _pwCtrl = {
      for (final t in smsTrackers)
        t.id: TextEditingController(text: widget.passwords[t.id] ?? ''),
    };
  }

  @override
  void dispose() {
    for (final c in _pwCtrl.values) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: MediaQuery.of(context).viewInsets.top,
      ),
      child: Container(
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
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.trackerPickerTitle,
                        style: TextStyle(
                          fontFamily: kSans,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: kNavy,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: kBone,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 16, color: kNavy),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: kWhite,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: kRule),
                  ),
                  child: Column(
                    children: smsTrackers.asMap().entries.map((e) {
                      final i = e.key;
                      final t = e.value;
                      final checked = _sel.contains(t.id);
                      return Container(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: i == smsTrackers.length - 1
                                ? BorderSide.none
                                : BorderSide(color: kRule),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () => setState(
                                    () => checked
                                        ? _sel.remove(t.id)
                                        : _sel.add(t.id),
                                  ),
                                  child: Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      color: checked ? kNavy : kWhite,
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        color: checked ? kNavy : kRuleS,
                                      ),
                                    ),
                                    child: checked
                                        ? const Icon(
                                            Icons.check,
                                            size: 12,
                                            color: kWhite,
                                          )
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Color(t.tone),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        t.short,
                                        style: TextStyle(
                                          fontFamily: kSans,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: kNavy,
                                        ),
                                      ),
                                      Text(
                                        t.name,
                                        style: TextStyle(
                                          fontFamily: kSans,
                                          fontSize: 11.5,
                                          color: kMute,
                                        ),
                                      ),
                                      Text(
                                        t.phone,
                                        style: TextStyle(
                                          fontFamily: kSans,
                                          fontSize: 11.5,
                                          color: kMute,
                                        ),
                                      ),
                                      _PasswordRow(controller: _pwCtrl[t.id]!),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 4),
              child: GestureDetector(
                onTap: () {
                  final passwords = {
                    for (final t in smsTrackers)
                      if (_pwCtrl[t.id]!.text.trim().isNotEmpty)
                        t.id: _pwCtrl[t.id]!.text.trim(),
                  };
                  widget.onChanged(_sel, passwords);
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: kOrange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      context.l10n.trackerPickerDone(_sel.length),
                      style: TextStyle(
                        fontFamily: kSans,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: kNavy,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SmsAllRecipientsSheet extends StatelessWidget {
  const SmsAllRecipientsSheet({
    super.key,
    required this.recipients,
    required this.onRemove,
  });
  final List<MockTracker> recipients;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
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
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.allRecipientsHeading,
                      style: TextStyle(
                        fontFamily: kMono,
                        fontSize: 10.5,
                        color: kMute,
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      context.l10n.allRecipientsCount(recipients.length),
                      style: TextStyle(
                        fontFamily: kSans,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: kNavy,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: kBone,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 16, color: kNavy),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(18, 4, 18, 14),
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: kRule),
            ),
            child: Column(
              children: recipients.asMap().entries.map((e) {
                final i = e.key;
                final t = e.value;
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: i == recipients.length - 1
                          ? BorderSide.none
                          : BorderSide(color: kRule),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Color(t.tone),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.short,
                              style: TextStyle(
                                fontFamily: kSans,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: kNavy,
                              ),
                            ),
                            Text(
                              t.name,
                              style: TextStyle(
                                fontFamily: kSans,
                                fontSize: 11.5,
                                color: kMute,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          onRemove(t.id);
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: kBone,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 14,
                            color: kMute,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Inline per-tracker password line. Renders as plain text matching the S/N
/// / phone styling; tapping it expands into the full PIN input box,
/// collapsing back to text once focus is lost.
class _PasswordRow extends StatefulWidget {
  const _PasswordRow({required this.controller});

  final TextEditingController controller;

  @override
  State<_PasswordRow> createState() => _PasswordRowState();
}

class _PasswordRowState extends State<_PasswordRow> {
  final _focus = FocusNode();
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    if (!mounted) return;
    if (!_focus.hasFocus && _editing) {
      setState(() => _editing = false);
    }
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocusChanged);
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_editing) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: TextField(
          controller: widget.controller,
          focusNode: _focus,
          autofocus: true,
          keyboardType: TextInputType.number,
          maxLength: 6,
          style: TextStyle(
            fontFamily: kMono,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: kNavy,
            letterSpacing: 4,
          ),
          decoration: InputDecoration(
            isDense: true,
            hintText: '000000',
            hintStyle: TextStyle(
              fontFamily: kMono,
              fontSize: 13,
              color: kMute2,
              letterSpacing: 0,
            ),
            prefixIcon: const Icon(
              Icons.lock_outline,
              size: 14,
              color: kMute,
            ),
            filled: true,
            fillColor: kWhite,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: kRule),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: kRule),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: kNavy),
            ),
            counterText: '',
          ),
          onSubmitted: (_) => _focus.unfocus(),
        ),
      );
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _editing = true),
      child: ListenableBuilder(
        listenable: widget.controller,
        builder: (_, _) {
          final value = widget.controller.text.trim().isNotEmpty
              ? widget.controller.text.trim()
              : '000000';
          return Text(
            value,
            style: TextStyle(fontFamily: kSans, fontSize: 11.5, color: kMute),
          );
        },
      ),
    );
  }
}
