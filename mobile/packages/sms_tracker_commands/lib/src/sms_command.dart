/// A fully-formed SMS command string ready to send to the tracker's SIM.
///
/// The tracker accepts commands in the format: `#password,CMD:params`
/// Example: `#000000,STPH:1,71061248`
class SmsCommand {
  /// Creates an [SmsCommand] from a device [password] and a command [body].
  const SmsCommand({required this.password, required this.body});

  /// Device password the command is authenticated with, e.g. `000000`.
  final String password;

  /// The command body after the password, e.g. `STPH:1,71061248`.
  final String body;

  /// The full text to send as an SMS to the tracker's SIM card.
  String get text => '#$password,$body';

  @override
  String toString() => text;
}
