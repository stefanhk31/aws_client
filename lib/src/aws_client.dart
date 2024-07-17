import 'dart:convert';

import 'package:aws_client/aws_client.dart';
import 'package:aws_common/aws_common.dart';
import 'package:aws_signature_v4/aws_signature_v4.dart';

/// Generic type representing a JSON factory.
typedef FromJson<T> = T Function(Map<String, dynamic> json);

/// Enum of accepted AWS headers.
enum Header {
  /// The `Accept` header.
  accept,

  /// The `X-Amz-Algorithm` header.
  algorithm,

  /// The `X-Amz-User-Agent` header.
  amzUserAgent,

  /// The `Authorization` header.
  authorization,

  /// The `Content-Encoding` header.
  contentEncoding,

  /// The `Content-Length` header.
  contentLength,

  /// The `Content-Type` header.
  contentType,

  /// The `X-Amz-Content-Sha256` header.
  contentSHA256,

  /// The `X-Amz-Credential` header.
  credential,

  /// The `X-Amz-Date` header.
  date,

  /// The `X-Amz-Decoded-Content-Length` header.
  decodedContentLength,

  /// The `X-Amz-Expires` header.
  expires,

  /// The `Host` header.
  host,

  /// The `Location` header.
  location,

  /// The `X-Amz-Region-Set` header.
  regionSet,

  /// The `X-Amz-Retry-After` header.
  retryAfter,

  /// The `amz-sdk-invocation-id` header.
  sdkInvocationId,

  /// The `amz-sdk-request` header.
  sdkRequest,

  /// The `X-Amz-Security-Token` header.
  securityToken,

  /// The `X-Amz-Signature` header.
  signature,

  /// The `X-Amz-SignedHeaders` header.
  signedHeaders,

  /// The `X-Amz-Target` header.
  target,

  /// The `Transfer-Encoding` header.
  transferEncoding,

  /// The `User-Agent` header.
  userAgent;

  /// The name of the header. Corresponds to a static value
  /// in the [AWSHeaders] abstract class.
  String get name {
    return switch (this) {
      accept => AWSHeaders.accept,
      algorithm => AWSHeaders.algorithm,
      amzUserAgent => AWSHeaders.amzUserAgent,
      authorization => AWSHeaders.authorization,
      contentEncoding => AWSHeaders.contentEncoding,
      contentLength => AWSHeaders.contentLength,
      contentType => AWSHeaders.contentType,
      contentSHA256 => AWSHeaders.contentSHA256,
      credential => AWSHeaders.credential,
      date => AWSHeaders.date,
      decodedContentLength => AWSHeaders.decodedContentLength,
      expires => AWSHeaders.expires,
      host => AWSHeaders.host,
      location => AWSHeaders.location,
      regionSet => AWSHeaders.regionSet,
      retryAfter => AWSHeaders.retryAfter,
      sdkInvocationId => AWSHeaders.sdkInvocationId,
      sdkRequest => AWSHeaders.sdkRequest,
      securityToken => AWSHeaders.securityToken,
      signature => AWSHeaders.signature,
      signedHeaders => AWSHeaders.signedHeaders,
      target => AWSHeaders.target,
      transferEncoding => AWSHeaders.transferEncoding,
      userAgent => AWSHeaders.userAgent,
    };
  }
}

/// {@template aws_client}
/// A client to call AWS services.
/// {@endtemplate}
class AwsClient {
  /// {@macro aws_client}
  AwsClient({
    required String region,
    AWSHttpClient? client,
    AWSSigV4Signer? signer,
  })  : _region = region,
        _client = client ?? AWSHttpClient(),
        _signer = signer ?? const AWSSigV4Signer();

  final AWSHttpClient _client;
  final AWSSigV4Signer _signer;
  final String _region;

  /// Send a signed request to the AWS service.
  /// Parameters:
  ///
  /// - `service`: The AWS service to call.
  /// - `method`: The HTTP method to use.
  /// - `uri`: The URI to call.
  /// - `fromJson`: A function to convert the JSON response to a type `T`.
  /// - `headers`: An optional map of [Header] values to include in the request.
  /// - `body`: An optional object to include in the request body.
  Future<T> sendSignedRequest<T>({
    required AWSService service,
    required AWSHttpMethod method,
    required Uri uri,
    required FromJson<T> fromJson,
    Map<Header, String>? headers,
    Object? body,
  }) async {
    // TODO(stefanhk31): handle exceptions!
    final request = AWSHttpRequest(
      method: AWSHttpMethod.fromString(method.value),
      uri: uri,
      headers: headers?.toStringMap(),
      body: jsonEncode(body).codeUnits,
    );

    final scope = AWSCredentialScope(region: _region, service: service);

    final signedRequest = await _signer.sign(request, credentialScope: scope);

    final response = await signedRequest.send(_client).response;
    return fromJson(
      json.decode(await response.decodeBody()) as Map<String, dynamic>,
    );
  }
}
