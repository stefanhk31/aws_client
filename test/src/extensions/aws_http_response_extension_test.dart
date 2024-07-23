import 'dart:convert';
import 'dart:io';

import 'package:aws_client/aws_client.dart';
import 'package:aws_client/src/extensions/aws_http_response_extension.dart';
import 'package:aws_common/aws_common.dart';
import 'package:test/test.dart';

void main() {
  group('AwsHttpResponseException', () {
    group('toJson', () {
      test('converts body to map', () async {
        const body = '{"key": "value"}';
        final encodedBody = utf8.encode(body);
        final response =
            AWSHttpResponse(statusCode: HttpStatus.ok, body: encodedBody);
        final json = await response.toJson();

        expect(json, equals({'key': 'value'}));
      });

      test('throws AwsMalformedResponseException on error', () async {
        const body = 'invalid json';
        final encodedBody = utf8.encode(body);
        final response =
            AWSHttpResponse(statusCode: HttpStatus.ok, body: encodedBody);

        expect(response.toJson, throwsA(isA<AwsMalformedResponseException>()));
      });
    });
  });
}
