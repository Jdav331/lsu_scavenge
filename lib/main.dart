import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

// Entry point for the app.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PFT Scavenger Hunt',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: Colors.amber[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.purple,
          titleTextStyle: TextStyle(
            color: Colors.amber,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.amber),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.purple,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Set<int> completedTasks = {};

  @override
  void initState() {
    super.initState();
    _loadCompletedTasks();
  }

  // Load saved completed tasks from local storage
  Future<void> _loadCompletedTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedTasks = prefs.getStringList('completedTasks');
    if (savedTasks != null) {
      setState(() {
        completedTasks = savedTasks.map((e) => int.parse(e)).toSet();
      });
    }
  }

  // Save completed tasks in local storage
  Future<void> _saveCompletedTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('completedTasks', completedTasks.map((e) => e.toString()).toList());
  }

  void markTaskCompleted(int taskId) {
    setState(() {
      completedTasks.add(taskId);
    });
    _saveCompletedTasks();
  }

  @override
  Widget build(BuildContext context) {
    int totalTasks = tasks.length;
    int completedCount = completedTasks.length;
    bool allCompleted = completedCount == totalTasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PFT Scavenger Hunt 🐾'),
        actions: [
          IconButton(
            icon: const Icon(Icons.image),
            tooltip: 'LSU Gallery',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LsuGalleryPage()),
              );
            },
          ),
        ],
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
          if (allCompleted)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                '🎉 Congratulations! You have completed all tasks! 🎉',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                textAlign: TextAlign.center,
              ),
            ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                Task task = tasks[index];
                bool isCompleted = completedTasks.contains(task.id);

                return AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  opacity: isCompleted ? 0.5 : 1.0,
                  child: ListTile(
                    title: Text(task.description),
                    trailing: Icon(
                      isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: isCompleted ? Colors.green : Colors.grey,
                    ),
                    onTap: () async {
                      if (isCompleted) return;
                      final result = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(builder: (context) => TaskDetailPage(task: task)),
                      );
                      if (result == true) {
                        markTaskCompleted(task.id);
                      }
                    },
                  ),
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
  const TaskDetailPage({super.key, required this.task});

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  final TextEditingController _answerController = TextEditingController();

  void _submitAnswer() {
    String answer = _answerController.text.trim().toLowerCase();
    if (answer == widget.task.correctAnswer.toLowerCase()) {
      // Add a tiger emoji for the LSU mascot task
      String message = (widget.task.id == 4) ? 'Correct! 🐯' : 'Correct!';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pop(context, true);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incorrect. Try again.'), backgroundColor: Colors.red),
      );
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
            Hero(
              tag: widget.task.id,
              child: Material(
                type: MaterialType.transparency,
                child: Text(widget.task.description, style: const TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _answerController,
              decoration: const InputDecoration(
                labelText: 'Enter your answer 📝',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitAnswer,
              child: const Text('Submit 🐾'),
            ),
          ],
        ),
      ),
    );
  }
}

class LsuGalleryPage extends StatelessWidget {
  const LsuGalleryPage({super.key});

  final List<String> imageUrls = const [
    'https://upload.wikimedia.org/wikipedia/commons/2/26/LSU_Athletic_logo.svg',
    'https://upload.wikimedia.org/wikipedia/commons/4/4f/LSU_Logo.svg',
    'https://www.lsu.edu/communications/news/2020/06/03/lsu-campus.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LSU Gallery 🐯')),
      body: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: imageUrls.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemBuilder: (context, index) {
          return Image.network(
            imageUrls[index],
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
          );
        },
      ),
    );
  }
}

class Task {
  final int id;
  final String description;
  final String correctAnswer;

  Task({required this.id, required this.description, required this.correctAnswer});
}

final List<Task> tasks = [
  Task(id: 1, description: 'Go to room 1200 and count the number of chairs.', correctAnswer: '10'),
  Task(id: 2, description: 'Find the number of computers in the lab near the Cambre Atrium.', correctAnswer: '20'),
  Task(id: 3, description: 'When was LSU established?', correctAnswer: '1853'),
  Task(id: 4, description: 'Locate the LSU mascot on campus.', correctAnswer: 'Tiger'),
];
