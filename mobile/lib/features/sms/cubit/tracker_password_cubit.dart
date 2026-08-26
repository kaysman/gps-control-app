import 'package:flutter_bloc/flutter_bloc.dart';

/// The unlock password to send with each tracker's commands, keyed by tracker
/// id.
///
/// Lives above the routes so a password typed in a chat survives leaving that
/// chat. Nothing is persisted to disk — a password is re-entered per session.
class TrackerPasswordCubit extends Cubit<Map<String, String>> {
  /// Creates an empty password book.
  TrackerPasswordCubit() : super(const {});

  /// What an FMB unit ships with: no SMS password at all. The wire format
  /// keeps the separator either way, so an empty value is valid.
  static const fallback = '';

  /// The password to send to [trackerId], or [fallback] if none was entered.
  String passwordFor(String trackerId) => state[trackerId]?.trim() ?? fallback;

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
