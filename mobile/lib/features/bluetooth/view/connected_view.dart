import 'dart:async';

import 'package:gps_control/app/tokens.dart';
import 'package:gps_control/features/bluetooth/bloc/bluetooth_bloc.dart';
import 'package:gps_control/features/bluetooth/view/widgets/ble_command_list.dart';
import 'package:gps_control/features/bluetooth/view/widgets/ble_header.dart';
import 'package:gps_control/features/bluetooth/view/widgets/dial_card.dart';
import 'package:gps_control/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Screen shown once a tracker is connected over BLE: header with tracker
/// name, dial card with lock state, and the command list.
class ConnectedView extends StatefulWidget {
  const ConnectedView({super.key});

  @override
  State<ConnectedView> createState() => _ConnectedViewState();
}

class _ConnectedViewState extends State<ConnectedView>
    with TickerProviderStateMixin {
  late final AnimationController _arcCtrl;
  late final Animation<double> _arcAnim;
  late final AnimationController _spinCtrl;
  String? _toast;
  Timer? _toastTimer;

  @override
  void initState() {
    super.initState();
    // Start at mid-arc (unknown) until first status fetch completes.
    _arcCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      value: 0.75,
    );
    _arcAnim = CurvedAnimation(parent: _arcCtrl, curve: Curves.easeInOut);
    _spinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    unawaited(_spinCtrl.repeat());
  }

  @override
  void dispose() {
    _arcCtrl.dispose();
    _spinCtrl.dispose();
    _toastTimer?.cancel();
    super.dispose();
  }

  void _showToast(String message) {
    setState(() => _toast = message);
    _toastTimer?.cancel();
    _toastTimer = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _toast = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return BlocConsumer<BluetoothBloc, BleState>(
      listenWhen: (prev, next) =>
          prev.lastStatus?.isUnlocked != next.lastStatus?.isUnlocked ||
          (prev.lastCompletedCommand != next.lastCompletedCommand &&
              next.lastCompletedCommand != null),
      listener: (context, state) {
        if (state.lastStatus != null) {
          unawaited(
            _arcCtrl.animateTo(state.lastStatus!.isUnlocked ? 0.5 : 1.0),
          );
        }
        final cmd = state.lastCompletedCommand;
        if (cmd != null) {
          final l10n = context.l10n;
          _showToast(switch (cmd) {
            BleCommand.unlock => l10n.bleToastUnlocked,
            BleCommand.lock => l10n.bleToastLocked,
            BleCommand.refresh => l10n.bleToastStatusRefreshed,
          });
        }
      },
      builder: (context, state) {
        final tracker = state.connectedTracker!;
        final status = state.lastStatus;
        final busy = state.busyCommand != null;
        // null = unknown (still fetching the first status).
        final isLocked = status == null ? null : !status.isUnlocked;

        void onToggle() {
          final bloc = context.read<BluetoothBloc>();
          if (isLocked == null) {
            bloc.add(const BleStatusRefreshRequested());
          } else if (isLocked) {
            bloc.add(const BleUnlockRequested());
          } else {
            bloc.add(const BleLockRequested());
          }
        }

        final title = tracker.label;

        return Padding(
          padding: EdgeInsets.only(top: topPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BleHeader(
                title: title,
                onBack: () => context.read<BluetoothBloc>().add(
                  const BleDisconnectRequested(),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 110),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
                        child: DialCard(
                          tracker: tracker,
                          status: status,
                          isLocked: isLocked,
                          busy: busy,
                          refreshBusy: state.busyCommand == BleCommand.refresh,
                          arcAnim: _arcAnim,
                          spinCtrl: _spinCtrl,
                          toast: _toast,
                          commandError: state.commandError,
                          onToggle: onToggle,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 0, 22, 6),
                        child: Text(
                          context.l10n.bleCommandsHeader,
                          style: TextStyle(
                            fontFamily: kMono,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: kMute,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: BleCommandList(
                          isLocked: isLocked,
                          refreshBusy: state.busyCommand == BleCommand.refresh,
                          onUnlock: () => context.read<BluetoothBloc>().add(
                            const BleUnlockRequested(),
                          ),
                          onLock: () => context.read<BluetoothBloc>().add(
                            const BleLockRequested(),
                          ),
                          onRefresh: () => context.read<BluetoothBloc>().add(
                            const BleStatusRefreshRequested(),
                          ),
                          onDisconnect: () => context.read<BluetoothBloc>().add(
                            const BleDisconnectRequested(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
