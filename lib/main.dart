import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

// User profile model
class UserProfile {
  final String name;
  final String email;
  final bool isLoggedIn;

  UserProfile({
    required this.name,
    required this.email,
    this.isLoggedIn = false,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'isLoggedIn': isLoggedIn,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        name: json['name'] as String,
        email: json['email'] as String,
        isLoggedIn: json['isLoggedIn'] as bool,
      );
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
    correctAnswer: '120', // Update when ready.
  ),
  Task(
    id: 2,
    description:
        'Find the number of computers in the lab near the Cambre Atrium.',
    correctAnswer: '35', // Update when ready.
  ),
  Task(
    id: 3,
    description: 'When was LSU established?',
    correctAnswer: '1853',
  ),
  Task(
    id: 4,
    description: 'Locate the LSU mascot on campus.',
    correctAnswer: 'Tiger',
  ),
];

class TaskDetailPage extends StatefulWidget {
  final Task task;
  const TaskDetailPage({super.key, required this.task});

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  final TextEditingController _answerController = TextEditingController();
  String feedback = '';
  bool showThumbsUp = false;

  void _submitAnswer() {
    String answer = _answerController.text.trim();
    if (answer == widget.task.correctAnswer) {
      setState(() {
        feedback = 'Correct!';
        showThumbsUp = true;
      });
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pop(context, true);
      });
    } else {
      setState(() {
        feedback = 'Incorrect. Try again.';
        showThumbsUp = false;
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
            if (feedback.isNotEmpty)
              Column(
                children: [
                  Text(feedback,
                      style: const TextStyle(fontSize: 16, color: Colors.red)),
                  if (showThumbsUp)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Image.network(
                        'https://media.giphy.com/media/OkJat1YNdoD3W/giphy.gif',
                        height: 100,
                      ),
                    ),
                ],
              ),
            const SizedBox(height: 20),
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

class LsuGalleryPage extends StatelessWidget {
  const LsuGalleryPage({super.key});

  final List<String> imageUrls = const [
    'https://upload.wikimedia.org/wikipedia/commons/thumb/2/26/LSU_Athletic_logo.svg/1024px-LSU_Athletic_logo.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4f/LSU_Logo.svg/1200px-LSU_Logo.svg.png',
    'https://www.lsu.edu/communications/news/2020/06/03/lsu-campus.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LSU Gallery'),
      ),
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
          );
        },
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  Future<void> _saveUserProfile() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      final userProfile = UserProfile(
        name: _nameController.text,
        email: _emailController.text,
        isLoggedIn: true,
      );
      await prefs.setString('userProfile', userProfile.toJson().toString());
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MyHomePage(
              title: 'PFT Scavenger Hunt',
              userProfile: userProfile,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to PFT Scavenger Hunt'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveUserProfile,
                child: const Text('Start Scavenger Hunt'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  final UserProfile userProfile;

  const ProfilePage({super.key, required this.userProfile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profile Information',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Name'),
            subtitle: Text(userProfile.name),
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Email'),
            subtitle: Text(userProfile.email),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('userProfile');
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              }
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PFT Scavenger Hunt',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: FutureBuilder<String?>(
        future: SharedPreferences.getInstance()
            .then((prefs) => prefs.getString('userProfile')),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData && snapshot.data != null) {
            final userProfile = UserProfile.fromJson(
              Map<String, dynamic>.from(snapshot.data as Map),
            );
            return MyHomePage(
              title: 'PFT Scavenger Hunt',
              userProfile: userProfile,
            );
          }
          return const LoginPage();
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
    required this.userProfile,
  });

  final String title;
  final UserProfile userProfile;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  final Set<int> completedTasks = {};

  void markTaskCompleted(int taskId) {
    setState(() {
      completedTasks.add(taskId);
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
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
      body: _selectedIndex == 0
          ? Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Progress: ${completedTasks.length} / ${tasks.length} tasks completed',
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
                          final result = await Navigator.push<bool>(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      TaskDetailPage(task: task),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                              transitionDuration:
                                  const Duration(milliseconds: 500),
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
            )
          : _selectedIndex == 1
              ? const Center(
                  child: Text('Map View Coming Soon!'),
                )
              : ProfilePage(userProfile: widget.userProfile),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.question_answer),
            label: 'Questions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'LSU Gallery',
        child: const Icon(Icons.photo_library),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LsuGalleryPage()),
          );
        },
      ),
    );
  }
}
