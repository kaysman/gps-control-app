import 'package:gps_control/mock/mock_data.dart';

/// The trackers in [trackers] matching [query].
///
/// A tracker is identified by four strings the user might half-remember — the
/// short name, the serial, the id and the phone number — so all four are
/// searched at once.
///
/// Both sides are stripped to letters and digits before comparing, which is
/// what makes `bx-001`, `bx001`, `2500000001` and `+993 71 06-12-87` all find
/// something: dashes, spaces and a leading `+` are noise when you are typing
/// an identifier from memory. Stripping the query alone would not do it — the
/// punctuation is in the stored values too.
List<MockTracker> searchTrackers(List<MockTracker> trackers, String query) {
  final q = _norm(query);
  if (q.isEmpty) return trackers;
  return [
    for (final t in trackers)
      if (_norm('${t.short} ${t.name} ${t.id} ${t.phone}').contains(q)) t,
  ];
}

String _norm(String s) => s.toLowerCase().replaceAll(RegExp('[^a-z0-9]'), '');
