/// Error with a message that is already safe to show to the user.
class FriendlyError implements Exception {
  const FriendlyError(this.message);
  final String message;

  @override
  String toString() => message;
}
