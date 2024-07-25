import 'package:flutter/material.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AWS Client Examples',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AwsClientExamples(title: 'AWS Client Examples'),
    );
  }
}

class AwsClientExamples extends StatefulWidget {
  const AwsClientExamples({required this.title, super.key});

  final String title;

  @override
  State<AwsClientExamples> createState() => _AwsClientExamplesState();
}

class _AwsClientExamplesState extends State<AwsClientExamples>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          DynamoTab(),
        ],
      ),
      bottomNavigationBar: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Dynamo'),
        ],
      ),
    );
  }
}

class DynamoTab extends StatelessWidget {
  const DynamoTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Dynamo Tab',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
