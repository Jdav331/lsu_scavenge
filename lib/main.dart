import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// Entry point for the app.
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PFT Scavenger Hunt',
      theme: ThemeData(
        // Purple and gold theme.
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: Colors.amber[50], // light gold background
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.purple,
          titleTextStyle: const TextStyle(
            color: Colors.amber,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: const IconThemeData(color: Colors.amber),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.purple,
        ),
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: Colors.purple,
          displayColor: Colors.purple,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

// Data class for a scavenger hunt task.
class Task {
  final int id;
  final String description;
  final String correctAnswer;

  Task({
    required this.id,
    required this.description,
    required this.correctAnswer,
  });
}

// List of tasks.
final List<Task> tasks = [
  Task(
    id: 1,
    description: 'Go to room 1200 and count the number of chairs.',
    correctAnswer: 'correct answer here', // Update when ready.
  ),
  Task(
    id: 2,
    description: 'Find the number of computers in the lab near the Cambre Atrium.',
    correctAnswer: 'correct answer here', // Update when ready.
  ),
  // Additional tasks can be added here.
];

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Set to store IDs of completed tasks.
  final Set<int> completedTasks = {};

  void markTaskCompleted(int taskId) {
    setState(() {
      completedTasks.add(taskId);
    });
  }

  @override
  Widget build(BuildContext context) {
    int totalTasks = tasks.length;
    int completedCount = completedTasks.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PFT Scavenger Hunt'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Progress: $completedCount / $totalTasks tasks completed',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                Task task = tasks[index];
                bool isCompleted = completedTasks.contains(task.id);
                return ListTile(
                  title: Text(task.description),
                  trailing: isCompleted
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () async {
                    if (isCompleted) return;
                    // Use a fade transition animation when navigating to the TaskDetailPage.
                    final result = await Navigator.push<bool>(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            TaskDetailPage(task: task),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                        transitionDuration: const Duration(milliseconds: 500),
                      ),
                    );
                    if (result == true) {
                      markTaskCompleted(task.id);
                    }
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

class TaskDetailPage extends StatefulWidget {
  final Task task;
  const TaskDetailPage({Key? key, required this.task}) : super(key: key);

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  final TextEditingController _answerController = TextEditingController();
  String feedback = '';

  void _submitAnswer() {
    String answer = _answerController.text.trim();
    if (answer == widget.task.correctAnswer) {
      setState(() {
        feedback = 'Correct!';
      });
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pop(context, true);
      });
    } else {
      setState(() {
        feedback = 'Incorrect. Try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(widget.task.description, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            TextField(
              controller: _answerController,
              decoration: const InputDecoration(
                labelText: 'Enter your answer',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitAnswer,
              child: const Text('Submit'),
            ),
            const SizedBox(height: 20),
            Text(feedback,
                style: const TextStyle(fontSize: 16, color: Colors.red)),
            const SizedBox(height: 20),
            // Extra back button for improved navigation.
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
