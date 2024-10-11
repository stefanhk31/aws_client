import 'dart:html';
import 'dart:typed_data';

import 'package:aws_client/aws_client.dart';
import 'package:example/extensions/null_or_empty_extension.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

enum S3Status { initial, loading, loaded, error }

class S3 extends StatefulWidget {
  const S3({super.key});

  @override
  S3State createState() => S3State();
}

class S3State extends State<S3> {
  String _region = '';
  String _bucketName = '';
  File? _file;
  String _filename = '';
  S3Status _status = S3Status.initial;
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
            labelText: 'Bucket Name',
          ),
          validator: (value) {
            if (value.isNullOrEmpty) {
              return 'Please enter a bucket name';
            }
            return null;
          },
          onChanged: (value) {
            setState(() {
              _bucketName = value;
            });
          },
        ),
        ElevatedButton(
          onPressed: () async {
            FilePickerResult? result = await FilePicker.platform.pickFiles();
            if (result != null) {
              final file = result.files.single;
              _filename = file.name;
              _file = File(file.bytes!, _filename);
            }
          },
          child: const Text('Attach file'),
        ),
        ElevatedButton(
          onPressed: () async {
            final client = AwsClient(region: _region);
            try {
              if (_file == null) {
                throw Exception('Please attach a file');
              }

              setState(() {
                _status = S3Status.loading;
              });
              // Read the file's bytes
              final fileBlob = _file!.slice();
              final reader = FileReader()..readAsArrayBuffer(fileBlob);
              await reader.onLoadEnd.first;
              final fileBytes = reader.result as Uint8List?;
              if (fileBytes == null) {
                throw Exception('Cannot read bytes from Blob.');
              }

              final result = await client.sendSignedRequest(
                  service: AWSService.s3,
                  method: AWSHttpMethod.put,
                  uri: Uri.parse(
                      'https://$_bucketName.s3.$_region.amazonaws.com/$_filename'),
                  fromJson: (json) => json,
                  body: fileBytes);
              setState(() {
                _result = result;
                _status = S3Status.loaded;
              });
            } on Exception catch (e) {
              setState(() {
                if (e is AwsClientException) {
                  _awsClientException = e;
                } else if (e is AwsMalformedResponseException) {
                  _awsMalformedResponseException = e;
                }
                _status = S3Status.error;
              });
            }
          },
          child: const Text('Submit'),
        ),
        switch (_status) {
          S3Status.initial => const Text('Enter a region and table name'),
          S3Status.loading => const CircularProgressIndicator(),
          S3Status.loaded => Column(
              children: [
                for (final entry in _result.entries)
                  Text('${entry.key} : ${entry.value.toString()}'),
              ],
            ),
          S3Status.error => Expanded(
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
