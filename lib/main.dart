import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'screens/splash_screen.dart';
import 'screens/task_details_screen.dart';
import 'screens/add_edit_task_screen.dart';
import 'screens/completed_tasks_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskFlow',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.teal[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black12,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController controller = TextEditingController();

  CollectionReference<Map<String, dynamic>> get tasksRef {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('tasks');
  }

  Future<void> addTaskFromTextField() async {
    if (controller.text.trim().isEmpty) return;

    await tasksRef.add({
      'title': controller.text.trim(),
      'description': '',
      'isDone': false,
      'createdAt': Timestamp.now(),
    });

    controller.clear();
  }

  Future<void> deleteTask(String docId) async {
    await tasksRef.doc(docId).delete();
  }

  Future<void> updateTaskStatus(String docId, bool isDone) async {
    await tasksRef.doc(docId).update({
      'isDone': isDone,
    });
  }

  Future<void> openCompletedTasks() async {
    final snapshot = await tasksRef.where('isDone', isEqualTo: true).get();

    final completedTasks = snapshot.docs
        .map((doc) => {
      'id': doc.id,
      ...doc.data(),
    })
        .toList();

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CompletedTasksScreen(completedTasks: completedTasks),
      ),
    );
  }

  Future<void> addTaskFromAddScreen() async {
    final newTask = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditTaskScreen(),
      ),
    );

    if (newTask != null) {
      await tasksRef.add({
        'title': newTask['title'] ?? '',
        'description': newTask['description'] ?? '',
        'isDone': newTask['isDone'] ?? false,
        'createdAt': Timestamp.now(),
      });
    }
  }

  Future<void> editTask(String docId, Map<String, dynamic> oldTask) async {
    final updatedTask = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditTaskScreen(task: oldTask),
      ),
    );

    if (updatedTask != null) {
      await tasksRef.doc(docId).update({
        'title': updatedTask['title'] ?? '',
        'description': updatedTask['description'] ?? '',
        'isDone': updatedTask['isDone'] ?? false,
      });
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: openCompletedTasks,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: addTaskFromAddScreen,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: "Enter task",
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: addTaskFromTextField,
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: tasksRef.orderBy('createdAt', descending: false).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return const Center(
                    child: Text('No tasks yet'),
                  );
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final docId = doc.id;
                    final task = doc.data();

                    return ListTile(
                      leading: Icon(
                        task['isDone'] == true
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: task['isDone'] == true
                            ? Colors.green
                            : Colors.grey,
                      ),
                      title: Text(
                        task['title'] ?? '',
                        style: TextStyle(
                          decoration: task['isDone'] == true
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          color: task['isDone'] == true
                              ? Colors.green
                              : Colors.black,
                          decorationColor: Colors.black,
                          decorationThickness: 3,
                        ),
                      ),
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TaskDetailsScreen(
                              taskTitle: task['title'] ?? '',
                              description: task['description'] ?? '',
                              isDone: task['isDone'] ?? false,
                            ),
                          ),
                        );

                        if (result == true) {
                          await updateTaskStatus(docId, true);
                        }
                      },
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => editTask(docId, task),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => deleteTask(docId),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}