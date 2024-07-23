import 'dart:convert';

import 'package:aws_client/aws_client.dart';
import 'package:aws_common/aws_common.dart';

/// An extension on [AWSBaseHttpResponse] to convert the response body to JSON.
extension AwsHttpResponseExtension on AWSBaseHttpResponse {
  /// Decodes the response body as JSON. Default encoding is UTF-8.
  Future<Map<String, dynamic>> toJson({Encoding encoding = utf8}) async {
    try {
      final jsonString = await decodeBody(encoding: encoding);
      return Map<String, dynamic>.from(jsonDecode(jsonString) as Map);
    } on Exception catch (e) {
      throw AwsMalformedResponseException(message: e.toString());
    }
  }
}
