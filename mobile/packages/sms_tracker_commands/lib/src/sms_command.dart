/// A fully-formed SMS command string ready to send to the tracker's SIM.
///
/// The tracker accepts commands in the format: `#password,CMD:params`
/// Example: `#000000,STPH:1,71061248`
class SmsCommand {
  const SmsCommand({required this.password, required this.body});

  final String password;

  /// The command body after the password, e.g. `STPH:1,71061248`.
  final String body;

  /// The full text to send as an SMS to the tracker's SIM card.
  String get text => '#$password,$body';

  @override
  String toString() => text;
}
