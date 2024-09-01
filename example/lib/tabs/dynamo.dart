import 'package:aws_client/aws_client.dart';
import 'package:example/extensions/null_or_empty_extension.dart';
import 'package:flutter/material.dart';

enum DynamoStatus { initial, loading, loaded, error }

class Dynamo extends StatefulWidget {
  const Dynamo({super.key});

  @override
  DynamoState createState() => DynamoState();
}

class DynamoState extends State<Dynamo> {
  String _region = '';
  String _tableName = '';
  DynamoStatus _status = DynamoStatus.initial;
  Map<String, dynamic> _result = {};
  AwsClientException? _awsClientException;
  AwsMalformedResponseException? _awsMalformedResponseException;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Region',
          ),
          validator: (value) {
            if (value.isNullOrEmpty) {
              return 'Please enter a region';
            }
            return null;
          },
          onChanged: (value) {
            setState(() {
              _region = value;
            });
          },
        ),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Table Name',
          ),
          validator: (value) {
            if (value.isNullOrEmpty) {
              return 'Please enter a table name';
            }
            return null;
          },
          onChanged: (value) {
            setState(() {
              _tableName = value;
            });
          },
        ),
        ElevatedButton(
          onPressed: () async {
            final client = AwsClient(region: _region);
            try {
              setState(() {
                _status = DynamoStatus.loading;
              });
              final result = await client.sendSignedRequest(
                service: AWSService.dynamoDb,
                method: AWSHttpMethod.get,
                uri: Uri.parse(
                    'https://dynamodb.$_region.amazonaws.com/$_tableName'),
                fromJson: (json) => json,
              );
              setState(() {
                _result = result;
                _status = DynamoStatus.loaded;
              });
            } on Exception catch (e) {
              setState(() {
                if (e is AwsClientException) {
                  _awsClientException = e;
                } else if (e is AwsMalformedResponseException) {
                  _awsMalformedResponseException = e;
                }
                _status = DynamoStatus.error;
              });
            }
          },
          child: const Text('Submit'),
        ),
        switch (_status) {
          DynamoStatus.initial => const Text('Enter a region and table name'),
          DynamoStatus.loading => const CircularProgressIndicator(),
          DynamoStatus.loaded => Column(
              children: [
                for (final entry in _result.entries)
                  Text('${entry.key} : ${entry.value.toString()}'),
              ],
            ),
          DynamoStatus.error => Expanded(
              child: _awsClientException != null
                  ? Text('An Error Occurred!\n '
                      'Status Code: ${_awsClientException?.statusCode ?? 0}\n'
                      '${_awsClientException?.body ?? _awsMalformedResponseException?.message}')
                  : Text('An error occurred!\n '
                      '${_awsMalformedResponseException?.message}'),
            )
        },
      ],
    );
  }
}
