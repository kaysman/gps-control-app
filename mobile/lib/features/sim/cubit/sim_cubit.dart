import 'package:gps_control/data/sim/sim_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Loading state for the active-SIMs query.
enum SimLoadStatus { initial, loading, ready, error }

/// Snapshot of the device's SIM state: the list of active SIMs and which one
/// the user has chosen for outgoing SMS.
@immutable
class SimState {
  const SimState({
    this.status = SimLoadStatus.initial,
    this.sims = const [],
    this.selectedSubscriptionId,
    this.error,
  });

  final SimLoadStatus status;
  final List<SimCard> sims;
  final int? selectedSubscriptionId;
  final String? error;

  /// The currently selected SIM, or null if none chosen / none available.
  SimCard? get selected {
    if (selectedSubscriptionId == null) return null;
    for (final sim in sims) {
      if (sim.subscriptionId == selectedSubscriptionId) return sim;
    }
    return null;
  }

  SimState copyWith({
    SimLoadStatus? status,
    List<SimCard>? sims,
    int? selectedSubscriptionId,
    String? error,
    bool clearError = false,
  }) {
    return SimState(
      status: status ?? this.status,
      sims: sims ?? this.sims,
      selectedSubscriptionId:
          selectedSubscriptionId ?? this.selectedSubscriptionId,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Manages the active-SIMs list and the per-app default for outgoing SMS.
class SimCubit extends Cubit<SimState> {
  SimCubit(this._sims) : super(const SimState());

  final SimRepository _sims;

  /// Reloads the SIM list. Auto-selects the first SIM if nothing is selected
  /// yet, or if the previously selected SIM is no longer present.
  Future<void> load() async {
    emit(state.copyWith(status: SimLoadStatus.loading, clearError: true));
    try {
      final sims = await _sims.getActiveSims();
      final stillThere = sims.any(
        (s) => s.subscriptionId == state.selectedSubscriptionId,
      );
      final nextSelected = stillThere
          ? state.selectedSubscriptionId
          : (sims.isNotEmpty ? sims.first.subscriptionId : null);
      emit(
        SimState(
          status: SimLoadStatus.ready,
          sims: sims,
          selectedSubscriptionId: nextSelected,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: SimLoadStatus.error, error: e.toString()));
    }
  }

  /// Picks which SIM outgoing SMS should leave from. No-op if the
  /// subscription isn't in the current list.
  void select(int subscriptionId) {
    if (!state.sims.any((s) => s.subscriptionId == subscriptionId)) return;
    if (state.selectedSubscriptionId == subscriptionId) return;
    emit(state.copyWith(selectedSubscriptionId: subscriptionId));
  }
}
