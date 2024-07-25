// ignore_for_file: prefer_const_constructors
import 'dart:convert';
import 'dart:io';

import 'package:aws_client/aws_client.dart';
import 'package:aws_client/src/extensions/aws_http_response_extension.dart';
import 'package:aws_common/aws_common.dart';
import 'package:aws_signature_v4/aws_signature_v4.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockAWSHttpClient extends Mock implements AWSHttpClient {}

class _MockAWSSigV4Signer extends Mock implements AWSSigV4Signer {}

class _MockAWSSignedRequest extends Mock implements AWSSignedRequest {}

void main() {
  group('$AwsClient', () {
    late AwsClient awsClient;
    late AWSHttpClient httpClient;
    late AWSSignedRequest signedRequest;
    late AWSSigV4Signer signer;
    late Uri uri;

    const region = 'us-east-1';
    const service = AWSService.dynamoDb;

    AWSHttpOperation<AWSHttpResponse> awsResponse(AWSHttpResponse body) =>
        AWSHttpOperation(
          CancelableOperation.fromValue(body),
          requestProgress: Stream.empty(),
          responseProgress: Stream.empty(),
        );

    setUpAll(() {
      registerFallbackValue(
        AWSHttpRequest(
          method: AWSHttpMethod.post,
          uri: Uri.parse('https://example.com'),
          body: utf8.encode(''),
        ),
      );
      registerFallbackValue(
        AWSCredentialScope(
          region: region,
          service: service,
        ),
      );
    });

    setUp(() {
      httpClient = _MockAWSHttpClient();
      signedRequest = _MockAWSSignedRequest();
      signer = _MockAWSSigV4Signer();
      uri = Uri.parse('https://dynamodb.$region.amazonaws.com');
      awsClient = AwsClient(
        region: region,
        client: httpClient,
        signer: signer,
      );
      when(
        () => signer.sign(
          any(that: isA<AWSHttpRequest>()),
          credentialScope: any(
            named: 'credentialScope',
            that: isA<AWSCredentialScope>(),
          ),
        ),
      ).thenAnswer((_) async => signedRequest);
    });

    group('can be instantiated', () {
      test('with custom client and signer', () {
        expect(
          awsClient,
          isNotNull,
        );
      });

      test('with default client and signer', () {
        expect(
          AwsClient(region: region),
          isNotNull,
        );
      });
    });

    group('$Header has correct $AWSHeaders name', () {
      test('for $Header.accept', () {
        expect(
          Header.accept.name,
          equals(AWSHeaders.accept),
        );
      });

      test('for $Header.algorithm', () {
        expect(
          Header.algorithm.name,
          equals(AWSHeaders.algorithm),
        );
      });

      test('for $Header.amzUserAgent', () {
        expect(
          Header.amzUserAgent.name,
          equals(AWSHeaders.amzUserAgent),
        );
      });

      test('for $Header.authorization', () {
        expect(
          Header.authorization.name,
          equals(AWSHeaders.authorization),
        );
      });

      test('for $Header.contentEncoding', () {
        expect(
          Header.contentEncoding.name,
          equals(AWSHeaders.contentEncoding),
        );
      });

      test('for $Header.contentLength', () {
        expect(
          Header.contentLength.name,
          equals(AWSHeaders.contentLength),
        );
      });

      test('for $Header.contentType', () {
        expect(
          Header.contentType.name,
          equals(AWSHeaders.contentType),
        );
      });

      test('for $Header.contentSHA256', () {
        expect(
          Header.contentSHA256.name,
          equals(AWSHeaders.contentSHA256),
        );
      });

      test('for $Header.credential', () {
        expect(
          Header.credential.name,
          equals(AWSHeaders.credential),
        );
      });

      test('for $Header.date', () {
        expect(
          Header.date.name,
          equals(AWSHeaders.date),
        );
      });

      test('for $Header.decodedContentLength', () {
        expect(
          Header.decodedContentLength.name,
          equals(AWSHeaders.decodedContentLength),
        );
      });

      test('for $Header.expires', () {
        expect(
          Header.expires.name,
          equals(AWSHeaders.expires),
        );
      });

      test('for $Header.host', () {
        expect(
          Header.host.name,
          equals(AWSHeaders.host),
        );
      });

      test('for $Header.location', () {
        expect(
          Header.location.name,
          equals(AWSHeaders.location),
        );
      });

      test('for $Header.regionSet', () {
        expect(
          Header.regionSet.name,
          equals(AWSHeaders.regionSet),
        );
      });

      test('for $Header.retryAfter', () {
        expect(
          Header.retryAfter.name,
          equals(AWSHeaders.retryAfter),
        );
      });

      test('for $Header.sdkInvocationId', () {
        expect(
          Header.sdkInvocationId.name,
          equals(AWSHeaders.sdkInvocationId),
        );
      });

      test('for $Header.sdkRequest', () {
        expect(
          Header.sdkRequest.name,
          equals(AWSHeaders.sdkRequest),
        );
      });

      test('for $Header.securityToken', () {
        expect(
          Header.securityToken.name,
          equals(AWSHeaders.securityToken),
        );
      });

      test('for $Header.signature', () {
        expect(
          Header.signature.name,
          equals(AWSHeaders.signature),
        );
      });

      test('for $Header.signedHeaders', () {
        expect(
          Header.signedHeaders.name,
          equals(AWSHeaders.signedHeaders),
        );
      });

      test('for $Header.target', () {
        expect(
          Header.target.name,
          equals(AWSHeaders.target),
        );
      });

      test('for $Header.transferEncoding', () {
        expect(
          Header.transferEncoding.name,
          equals(AWSHeaders.transferEncoding),
        );
      });

      test('for $Header.userAgent', () {
        expect(
          Header.userAgent.name,
          equals(AWSHeaders.userAgent),
        );
      });
    });

    group('sendSignedRequest', () {
      final headers = {
        Header.accept: 'application/json',
        Header.contentType: 'application/json',
      };
      test('returns deserialized response when successful', () async {
        final successBody = AWSHttpResponse(
          statusCode: HttpStatus.ok,
          body: utf8.encode('{"count": 1, "users": [{"username": "example"}]}'),
        );
        when(() => signedRequest.send(client: httpClient)).thenAnswer(
          (_) => awsResponse(successBody),
        );
        final result = await awsClient.sendSignedRequest(
          service: service,
          method: AWSHttpMethod.get,
          uri: uri,
          headers: headers,
          fromJson: _UsersResponse.fromJson,
        );

        expect(result, isA<_UsersResponse>());
      });

      test('throws exception when request fails', () async {
        final failedBody = AWSHttpResponse(
          statusCode: HttpStatus.badRequest,
          body: utf8.encode('{"message": "Bad request"}'),
        );
        when(() => signedRequest.send(client: httpClient)).thenAnswer(
          (_) => awsResponse(failedBody),
        );

        expect(
          () => awsClient.sendSignedRequest(
            service: service,
            method: AWSHttpMethod.get,
            uri: uri,
            headers: headers,
            fromJson: _UsersResponse.fromJson,
          ),
          throwsA(
            isA<AwsClientException>()
                .having(
                  (e) => e.statusCode,
                  'statusCode',
                  equals(failedBody.statusCode),
                )
                .having(
                  (e) => e.body,
                  'body',
                  equals(await failedBody.toJson()),
                ),
          ),
        );
      });

      test('throws exception when response in malformed', () async {
        final malformedBody = AWSHttpResponse(
          statusCode: HttpStatus.ok,
          body: utf8.encode('not valid json'),
        );
        when(() => signedRequest.send(client: httpClient)).thenAnswer(
          (_) => awsResponse(malformedBody),
        );

        expect(
          () => awsClient.sendSignedRequest(
            service: service,
            method: AWSHttpMethod.get,
            uri: uri,
            headers: headers,
            fromJson: _UsersResponse.fromJson,
          ),
          throwsA(
            isA<AwsMalformedResponseException>().having(
              (e) => e.message,
              'message',
              contains('FormatException'),
            ),
          ),
        );
      });

      test('throws exception when another error occurs', () async {
        when(
          () => signer.sign(
            any(that: isA<AWSHttpRequest>()),
            credentialScope: any(
              named: 'credentialScope',
              that: isA<AWSCredentialScope>(),
            ),
          ),
        ).thenThrow(Exception('error'));

        expect(
          () => awsClient.sendSignedRequest(
            service: service,
            method: AWSHttpMethod.get,
            uri: uri,
            headers: headers,
            fromJson: _UsersResponse.fromJson,
          ),
          throwsA(
            isA<AwsClientException>()
                .having(
                  (e) => e.statusCode,
                  'statusCode',
                  equals(HttpStatus.internalServerError),
                )
                .having(
                  (e) => e.body,
                  'body',
                  contains(internalServerErrorMessage),
                ),
          ),
        );
      });
    });
  });
}

class _UsersResponse {
  _UsersResponse({
    required this.count,
    required this.users,
  });

  factory _UsersResponse.fromJson(Map<String, dynamic> json) {
    return _UsersResponse(
      count: json['count'] as int,
      users: (json['users'] as List)
          .map((e) => _User.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final int count;
  final List<_User> users;
}

class _User {
  _User({
    required this.username,
  });

  factory _User.fromJson(Map<String, dynamic> json) {
    return _User(
      username: json['username'] as String,
    );
  }
  final String username;
}
