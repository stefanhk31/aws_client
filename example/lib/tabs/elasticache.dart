import 'package:aws_client/aws_client.dart';
import 'package:example/extensions/null_or_empty_extension.dart';
import 'package:flutter/material.dart';

enum ElastiCacheStatus { initial, loading, loaded, error }

class ElastiCache extends StatefulWidget {
  const ElastiCache({super.key});

  @override
  ElastiCacheState createState() => ElastiCacheState();
}

class ElastiCacheState extends State<ElastiCache> {
  String _region = '';
  String _cacheClusterId = '';
  ElastiCacheStatus _status = ElastiCacheStatus.initial;
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
            labelText: 'Cache Cluster ID',
          ),
          validator: (value) {
            if (value.isNullOrEmpty) {
              return 'Please enter a cache cluster identifier';
            }
            return null;
          },
          onChanged: (value) {
            setState(() {
              _cacheClusterId = value;
            });
          },
        ),
        ElevatedButton(
          onPressed: () async {
            final client = AwsClient(region: _region);
            try {
              setState(() {
                _status = ElastiCacheStatus.loading;
              });
              final result = await client.sendSignedRequest(
                service: AWSService.elastiCache,
                method: AWSHttpMethod.get,
                uri: Uri.parse(
                    'https://elasticache.$_region.amazonaws.com/?Action=DescribeCacheClusters&CacheClusterIdentifier=$_cacheClusterId&SignatureMethod=HmacSHA256&SignatureVersion=4&&Version=2014-12-01'),
                fromJson: (json) => json,
              );
              setState(() {
                _result = result;
                _status = ElastiCacheStatus.loaded;
              });
            } on Exception catch (e) {
              setState(() {
                if (e is AwsClientException) {
                  _awsClientException = e;
                } else if (e is AwsMalformedResponseException) {
                  _awsMalformedResponseException = e;
                }
                _status = ElastiCacheStatus.error;
              });
            }
          },
          child: const Text('Submit'),
        ),
        switch (_status) {
          ElastiCacheStatus.initial =>
            const Text('Enter a region and cache cluster identifier'),
          ElastiCacheStatus.loading => const CircularProgressIndicator(),
          ElastiCacheStatus.loaded => Column(
              children: [
                for (final entry in _result.entries)
                  Text('${entry.key} : ${entry.value.toString()}'),
              ],
            ),
          ElastiCacheStatus.error => Expanded(
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
