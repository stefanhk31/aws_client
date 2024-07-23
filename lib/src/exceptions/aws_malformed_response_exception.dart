/// {@template aws_malformed_response_exception}
/// Exception thrown when decoding the body of an AWS response fails.
/// {@endtemplate}
class AwsMalformedResponseException implements Exception {
  /// {@macro aws_malformed_response_exception}
  const AwsMalformedResponseException({required this.message});

  /// The error message.
  final String message;
}
