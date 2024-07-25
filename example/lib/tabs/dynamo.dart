import 'package:example/extensions/null_or_empty_extension.dart';
import 'package:flutter/material.dart';

class Dynamo extends StatefulWidget {
  const Dynamo({super.key});

  @override
  DynamoState createState() => DynamoState();
}

class DynamoState extends State<Dynamo> {
  String _region = '';
  String _tableName = '';

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
          onPressed: () {
            // TODO: Implement onSubmit function
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
