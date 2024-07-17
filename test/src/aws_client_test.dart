// ignore_for_file: prefer_const_constructors
import 'package:aws_client/aws_client.dart';
import 'package:aws_common/aws_common.dart';
import 'package:aws_signature_v4/aws_signature_v4.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockAWSHttpClient extends Mock implements AWSHttpClient {}

class _MockAWSSigV4Signer extends Mock implements AWSSigV4Signer {}

void main() {
  group('AwsClient', () {
    late AWSHttpClient httpClient;
    late AWSSigV4Signer signer;
    late final AwsClient awsClient;
    const region = 'us-east-1';

    setUp(() {
      httpClient = _MockAWSHttpClient();
      signer = _MockAWSSigV4Signer();
      awsClient = AwsClient(
        region: region,
        client: httpClient,
        signer: signer,
      );
    });

    test('can be instantiated', () {
      expect(
        awsClient,
        isNotNull,
      );
    });

    group('sendSignedRequest', () {});
  });
}
