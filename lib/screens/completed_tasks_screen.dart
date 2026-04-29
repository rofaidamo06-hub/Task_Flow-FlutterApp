import 'package:flutter/material.dart';

class CompletedTasksScreen extends StatelessWidget {
  final List<Map<String, dynamic>> completedTasks;

  const CompletedTasksScreen({super.key, required this.completedTasks});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Completed Tasks'),
      ),
      body: completedTasks.isEmpty
          ? const Center(
        child: Text(
          'No completed tasks yet',
          style: TextStyle(fontSize: 20),
        ),
      )
          : ListView.builder(
        itemCount: completedTasks.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.check_circle, color: Colors.green),
            title: Text(
              completedTasks[index]['title'],
              style: const TextStyle(
                decoration: TextDecoration.lineThrough,
              ),
            ),
          );
        },
      ),
    );
  }
}