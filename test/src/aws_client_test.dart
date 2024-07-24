// ignore_for_file: prefer_const_constructors
import 'dart:convert';
import 'dart:io';

import 'package:aws_client/aws_client.dart';
import 'package:aws_common/aws_common.dart';
import 'package:aws_signature_v4/aws_signature_v4.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockAWSHttpClient extends Mock implements AWSHttpClient {}

class _MockAWSSigV4Signer extends Mock implements AWSSigV4Signer {}

class _MockAWSSignedRequest extends Mock implements AWSSignedRequest {}

void main() {
  group('AwsClient', () {
    late AWSHttpClient httpClient;
    late AWSSignedRequest signedRequest;
    late AWSSigV4Signer signer;
    late final AwsClient awsClient;
    late final Uri uri;

    final responseBody = AWSHttpResponse(
      statusCode: HttpStatus.ok,
      body: utf8.encode('{"count": 1, "users": [{"username": "example"}]}'),
    );
    final response = AWSHttpOperation(
      CancelableOperation.fromValue(responseBody),
      requestProgress: Stream.empty(),
      responseProgress: Stream.empty(),
    );
    const region = 'us-east-1';
    const service = AWSService.dynamoDb;

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

    test('can be instantiated', () {
      expect(
        awsClient,
        isNotNull,
      );
    });

    group('sendSignedRequest', () {
      test('returns deserialized response when successful', () async {
        when(() => signedRequest.send(httpClient)).thenAnswer(
          (_) => response,
        );
        final result = await awsClient.sendSignedRequest(
          service: service,
          method: AWSHttpMethod.get,
          uri: uri,
          fromJson: _UsersResponse.fromJson,
        );

        expect(result, isA<_UsersResponse>());
      });

      test('throws exception when request fails', () async {});

      test('throws exception when response in malformed', () async {});

      test('throws exception when another error occurs', () async {});
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
