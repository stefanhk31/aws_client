import 'package:aws_client/aws_client.dart';
import 'package:aws_common/aws_common.dart';
import 'package:test/test.dart';

void main() {
  group('MapExtension', () {
    group('toStringMap', () {
      test('converts the map to AWS String keys and values', () {
        final map = {
          Header.target: 'AWSCognitoIdentityProviderService.DescribeUserPool',
          Header.contentType: 'application/x-amz-json-1.1',
        };

        expect(
          map.toStringMap(),
          equals({
            AWSHeaders.target:
                'AWSCognitoIdentityProviderService.DescribeUserPool',
            AWSHeaders.contentType: 'application/x-amz-json-1.1',
          }),
        );
      });
    });
  });
}
