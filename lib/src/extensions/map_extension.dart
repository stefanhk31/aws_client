import 'package:aws_client/aws_client.dart';

/// An extension on [Map] to convert [Header] to [String].
extension MapExtension on Map<Header, String> {
  /// Converts the map to a map of [String] keys and values,
  /// based on the name of the header in the [Header] enum.
  Map<String, String> toStringMap() {
    return map((key, value) => MapEntry(key.name, value));
  }
}
