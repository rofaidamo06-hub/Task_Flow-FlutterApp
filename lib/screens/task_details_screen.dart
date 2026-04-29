import 'package:flutter/material.dart';

class TaskDetailsScreen extends StatefulWidget {
  final String taskTitle;
  final String description;
  final bool isDone;

  const TaskDetailsScreen({
    super.key,
    required this.taskTitle,
    required this.description,
    required this.isDone,
  });

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  late bool currentStatus;

  @override
  void initState() {
    super.initState();
    currentStatus = widget.isDone;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Task Title:',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.taskTitle,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 30),
            const Text(
              'Status:',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              currentStatus ? 'Completed' : 'Pending',
              style: TextStyle(
                fontSize: 20,
                color: currentStatus ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Description:',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.description.isEmpty
                  ? 'No description'
                  : widget.description,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    currentStatus = true;
                  });

                  Navigator.pop(context, true);
                },
                child: const Text('Mark as Completed'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}