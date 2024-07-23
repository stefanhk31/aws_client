/// {@template aws_client_exception}
/// Exception thrown when an error occurs while making a request
/// to the AWS Client.
/// {@endtemplate}
class AwsClientException implements Exception {
  /// {@macro aws_client_exception}
  const AwsClientException({required this.statusCode, required this.body});

  /// The HTTP status code of the response.
  final int statusCode;

  /// The body of the response that generated the error..
  final Map<String, dynamic> body;
}
