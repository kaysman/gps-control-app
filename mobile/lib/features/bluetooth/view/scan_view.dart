import 'dart:async';
import 'dart:math' as math;

import 'package:bariox_control/app/tokens.dart';
import 'package:bariox_control/features/bluetooth/bloc/bluetooth_bloc.dart';
import 'package:bariox_control/l10n/l10n.dart';
import 'package:bariox_tracker/bariox_tracker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

/// Radar-style screen while no tracker is connected: animated rings + sweep,
/// scanned devices arranged around the centre hub, tap-to-scan button.
class ScanView extends StatefulWidget {
  const ScanView({super.key});

  @override
  State<ScanView> createState() => _ScanViewState();
}

class _ScanViewState extends State<ScanView> with TickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final AnimationController _sweepCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    unawaited(_pulseCtrl.repeat());
    _sweepCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    unawaited(_sweepCtrl.repeat());
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _sweepCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final l10n = context.l10n;
    return BlocBuilder<BluetoothBloc, BleState>(
      builder: (context, state) {
        final isScanning = state.bleStatus == BleStatus.scanning;
        final isConnecting = state.bleStatus == BleStatus.connecting;
        return LayoutBuilder(
          builder: (_, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;
            final cx = w / 2;
            // Reserve space for title and bottom hint
            final topArea = topPad + 60.0;
            const bottomArea = 150.0; // tab bar + hint
            final radarCy = topArea + (h - topArea - bottomArea) / 2;
            final radarR = math.min(cx - 24, (h - topArea - bottomArea) / 2);

            return Container(
              color: kNavyInk,
              child: Stack(
                children: [
                  // Animated rings + sweep
                  AnimatedBuilder(
                    animation: Listenable.merge([_pulseCtrl, _sweepCtrl]),
                    builder: (_, _) => CustomPaint(
                      size: Size(w, h),
                      painter: _RadarPainter(
                        cx: cx,
                        cy: radarCy,
                        maxRadius: radarR,
                        pulseProgress: _pulseCtrl.value,
                        sweepAngle: _sweepCtrl.value * 2 * math.pi,
                        isScanning: isScanning,
                      ),
                    ),
                  ),
                  // Device nodes
                  ..._deviceNodes(
                    context,
                    state,
                    cx,
                    radarCy,
                    radarR,
                    isConnecting,
                  ),
                  // Centre hub
                  _hub(context, state, cx, radarCy),
                  // Title
                  Positioned(
                    top: topPad + 14,
                    left: 20,
                    child: Text(
                      l10n.bluetoothTitle,
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: kWhite,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  // Bottom status
                  Positioned(
                    bottom: 116,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        if (state.connectionError != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              state.connectionError!,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: kOrange,
                              ),
                            ),
                          )
                        else if (isScanning)
                          Text(
                            l10n.bluetoothScanCountdown(state.scanSecondsLeft),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 11,
                              color: kMute2,
                            ),
                          )
                        else if (!isConnecting)
                          Text(
                            l10n.bluetoothTapToScan,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: kMute2,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<Widget> _deviceNodes(
    BuildContext context,
    BleState state,
    double cx,
    double cy,
    double radarR,
    bool isConnecting,
  ) {
    // Strongest-signal-first, cap at 6 nodes to avoid crowding.
    final devices = [...state.scannedDevices]
      ..sort((a, b) => b.rssi.compareTo(a.rssi));
    final visible = devices.take(6).toList();
    if (visible.isEmpty) return [];

    const nodeW = 76.0;
    const nodeH = 70.0;
    final placementR = radarR * 0.76;

    return visible.asMap().entries.map((entry) {
      final i = entry.key;
      final tracker = entry.value;
      final n = visible.length;
      // Spread evenly from top, with a slight clockwise offset so single
      // devices appear to the upper-right rather than straight up.
      final angle = -math.pi / 2 + math.pi / 10 + i * (2 * math.pi / n);
      final dx = cx + placementR * math.cos(angle) - nodeW / 2;
      final dy = cy + placementR * math.sin(angle) - nodeH / 2;

      return Positioned(
        left: dx,
        top: dy,
        child: _DeviceNode(
          tracker: tracker,
          disabled: isConnecting,
          onTap: () =>
              context.read<BluetoothBloc>().add(BleConnectRequested(tracker)),
        ),
      );
    }).toList();
  }

  Widget _hub(
    BuildContext context,
    BleState state,
    double cx,
    double cy,
  ) {
    const r = 44.0;
    final isScanning = state.bleStatus == BleStatus.scanning;
    final isConnecting = state.bleStatus == BleStatus.connecting;

    void onTap() {
      final bloc = context.read<BluetoothBloc>();
      if (isScanning) {
        bloc.add(const BleScanStopped());
      } else if (!isConnecting) {
        bloc.add(const BleScanStarted());
      }
    }

    return Positioned(
      left: cx - r,
      top: cy - r,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: r * 2,
          height: r * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isScanning ? kOrange : kNavy,
            border: Border.all(
              color: isScanning ? kOrange : kWhite.withValues(alpha: 0.18),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: kOrange.withValues(alpha: isScanning ? 0.45 : 0.18),
                blurRadius: isScanning ? 28 : 14,
                spreadRadius: isScanning ? 4 : 0,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bluetooth,
                color: isScanning ? kNavy : kWhite,
                size: 26,
              ),
              if (isConnecting) ...[
                const SizedBox(height: 4),
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.8,
                    color: kOrange,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  const _RadarPainter({
    required this.cx,
    required this.cy,
    required this.maxRadius,
    required this.pulseProgress,
    required this.sweepAngle,
    required this.isScanning,
  });

  final double cx;
  final double cy;
  final double maxRadius;
  final double pulseProgress;
  final double sweepAngle;
  final bool isScanning;

  @override
  void paint(Canvas canvas, Size size) {
    _drawGhostRings(canvas);
    if (!isScanning) return;
    _drawPulseRings(canvas);
    _drawSweep(canvas);
  }

  void _drawGhostRings(Canvas canvas) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;
    for (var i = 1; i <= 3; i++) {
      paint.color = Color.fromRGBO(255, 255, 255, 0.05 + i * 0.02);
      canvas.drawCircle(Offset(cx, cy), maxRadius * i / 3, paint);
    }
  }

  void _drawPulseRings(Canvas canvas) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    for (var i = 0; i < 3; i++) {
      final phase = (pulseProgress + i / 3) % 1.0;
      final r = maxRadius * Curves.easeOut.transform(phase);
      if (r <= 0) continue;
      final opacity = (1 - phase) * 0.55;
      paint.color = Color.fromRGBO(232, 149, 46, opacity);
      canvas.drawCircle(Offset(cx, cy), r, paint);
    }
  }

  void _drawSweep(Canvas canvas) {
    final center = Offset(cx, cy);
    const sectorAngle = math.pi / 2;
    final rect = Rect.fromCircle(center: center, radius: maxRadius);
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        startAngle: sweepAngle - sectorAngle,
        endAngle: sweepAngle,
        colors: const [Colors.transparent, Color(0x18E8952E)],
      ).createShader(rect);
    canvas.drawCircle(center, maxRadius, sweepPaint);

    final linePaint = Paint()
      ..color = const Color(0x55E8952E)
      ..strokeWidth = 1.2;
    canvas.drawLine(
      center,
      center +
          Offset(
            maxRadius * math.cos(sweepAngle),
            maxRadius * math.sin(sweepAngle),
          ),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(_RadarPainter old) =>
      old.pulseProgress != pulseProgress ||
      old.sweepAngle != sweepAngle ||
      old.isScanning != isScanning;
}

class _DeviceNode extends StatelessWidget {
  const _DeviceNode({
    required this.tracker,
    required this.disabled,
    required this.onTap,
  });

  final DiscoveredTracker tracker;
  final bool disabled;
  final VoidCallback onTap;

  String get _label {
    final name = tracker.advName;
    if (name.startsWith('HB_')) {
      final sn = name.substring(3);
      return sn.length > 6 ? sn.substring(sn.length - 6) : sn;
    }
    return name.isNotEmpty ? name : tracker.deviceId;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: disabled ? 0.5 : 1.0,
        child: Container(
          width: 76,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF162D45),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kOrange.withValues(alpha: 0.35)),
            boxShadow: [
              BoxShadow(
                color: kOrange.withValues(alpha: 0.15),
                blurRadius: 14,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kNavyInk,
                  border: Border.all(
                    color: kOrange.withValues(alpha: 0.5),
                  ),
                ),
                child: const Icon(
                  Icons.lock_outline,
                  size: 15,
                  color: kOrange,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                _label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: kWhite,
                ),
              ),
              Text(
                context.l10n.bluetoothRssiDbm(tracker.rssi),
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 9, color: kMute2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
