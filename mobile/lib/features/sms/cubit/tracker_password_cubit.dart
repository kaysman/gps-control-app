import 'package:flutter_bloc/flutter_bloc.dart';

/// The unlock password to send with each tracker's commands, keyed by tracker
/// id.
///
/// Lives above the routes so a password typed in a chat survives leaving that
/// chat. Nothing is persisted to disk — a password is re-entered per session.
class TrackerPasswordCubit extends Cubit<Map<String, String>> {
  /// Creates an empty password book.
  TrackerPasswordCubit() : super(const {});

  /// The factory default every tracker ships with.
  static const fallback = '000000';

  /// The password to send to [trackerId], or [fallback] if none was entered.
  String passwordFor(String trackerId) {
    final pw = state[trackerId]?.trim() ?? '';
    return pw.isEmpty ? fallback : pw;
  }

  /// Records [password] for [trackerId]. An empty value clears it.
  void set(String trackerId, String password) {
    final next = {...state};
    if (password.trim().isEmpty) {
      next.remove(trackerId);
    } else {
      next[trackerId] = password.trim();
    }
    emit(next);
  }
}
