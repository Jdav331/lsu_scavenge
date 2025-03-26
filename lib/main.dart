import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('userProfile'); // Clear old format (dev only)
  runApp(const MyApp());
}

// ========== MODELS ==========
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
        name: json['name'],
        email: json['email'],
        isLoggedIn: json['isLoggedIn'],
      );
}

class Task {
  final int id;
  final String description;
  final String correctAnswer;
  final String hint; // New field for the hint

  Task({
    required this.id,
    required this.description,
    required this.correctAnswer,
    required this.hint,
  });
}

// ========== TASKS ==========
final List<Task> tasks = [
  Task(
      id: 1,
      description: 'Go to room 1200 and count the number of chairs.',
      correctAnswer: '120',
      hint: 'Look near the entrance to see a clear view of all chairs.'),
  Task(
      id: 2,
      description:
          'Find the number of computers in the lab near the Cambre Atrium.',
      correctAnswer: '35',
      hint: 'Check the lab’s main area where the computers are set up.'),
  Task(
      id: 3,
      description: 'When was LSU established?',
      correctAnswer: '1853',
      hint: 'Consider the mid-19th century context for LSU’s founding.'),
  Task(
      id: 4,
      description: 'Locate the LSU mascot on campus.',
      correctAnswer: 'Tiger',
      hint: 'Search around the main stadium entrance for the mascot display.'),
  Task(
      id: 5,
      description: 'Placeholder Task 1: Sample description here.',
      correctAnswer: 'Answer1',
      hint: 'Try to think logically about what the task is asking.'),
  Task(
      id: 6,
      description: 'Placeholder Task 2: Sample description here.',
      correctAnswer: 'Answer2',
      hint: 'Re-read the description carefully for any clues.'),
  Task(
      id: 7,
      description: 'Placeholder Task 3: Sample description here.',
      correctAnswer: 'Answer3',
      hint: 'Sometimes the answer is hidden in plain sight.'),
  Task(
      id: 8,
      description: 'Placeholder Task 4: Sample description here.',
      correctAnswer: 'Answer4',
      hint: 'Look for patterns or familiar hints in the wording.'),
  Task(
      id: 9,
      description: 'Placeholder Task 5: Sample description here.',
      correctAnswer: 'Answer5',
      hint: 'Break down the task into smaller parts to see the answer.'),
  Task(
      id: 10,
      description: 'Placeholder Task 6: Sample description here.',
      correctAnswer: 'Answer6',
      hint: 'Take a step back and re-read the question carefully.'),
  Task(
      id: 11,
      description: 'Placeholder Task 7: Sample description here.',
      correctAnswer: 'Answer7',
      hint: 'Maybe the answer is simpler than it appears.'),
  Task(
      id: 12,
      description: 'Placeholder Task 8: Sample description here.',
      correctAnswer: 'Answer8',
      hint: 'Consider any details you might have overlooked.'),
];

// ========== MAP PAGE ==========
class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  int _selectedFloor = 1;

  final Map<int, String> floorImages = {
    1: 'assets/pft-floor-one.png',
    2: 'assets/pft-floor-two.png',
    3: 'assets/pft-floor-three.png',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar removed
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            ToggleButtons(
              isSelected: [
                _selectedFloor == 1,
                _selectedFloor == 2,
                _selectedFloor == 3,
              ],
              onPressed: (index) {
                setState(() {
                  _selectedFloor = index + 1;
                });
              },
              children: const [
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Floor 1')),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Floor 2')),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Floor 3')),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.asset(
                  floorImages[_selectedFloor]!,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========== TASK DETAIL ==========
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

  void _showHint() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hint'),
          content: Text(widget.task.hint),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'))
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar removed
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(widget.task.description,
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              TextField(
                controller: _answerController,
                decoration:
                    const InputDecoration(labelText: 'Enter your answer'),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  ElevatedButton(
                      onPressed: _submitAnswer, child: const Text('Submit')),
                  const SizedBox(width: 16),
                  ElevatedButton(
                      onPressed: _showHint, child: const Text('Show Hint')),
                ],
              ),
              const SizedBox(height: 20),
              if (feedback.isNotEmpty)
                Column(
                  children: [
                    Text(feedback,
                        style:
                            const TextStyle(fontSize: 16, color: Colors.red)),
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
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ========== LSU GALLERY ==========
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
      // AppBar removed
      body: SafeArea(
        child: GridView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: imageUrls.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 8.0, mainAxisSpacing: 8.0),
          itemBuilder: (context, index) {
            return Image.network(imageUrls[index], fit: BoxFit.cover);
          },
        ),
      ),
    );
  }
}

// ========== LOGIN PAGE ==========
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
      await prefs.setString('userProfile', json.encode(userProfile.toJson()));
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MyHomePage(
                title: 'PFT Scavenger Hunt', userProfile: userProfile),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar removed
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // LSULogo.png added at the top
              Image.asset(
                'assets/LSULogo.png',
                height: 150, // adjust the height as needed
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      // Added style for typed text to be purple.
                      style: const TextStyle(color: Color(0xFF461D7C)),
                      decoration: const InputDecoration(
                          labelText: 'Name', border: OutlineInputBorder()),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter your name'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      // Added style for typed text to be purple.
                      style: const TextStyle(color: Color(0xFF461D7C)),
                      decoration: const InputDecoration(
                          labelText: 'Email', border: OutlineInputBorder()),
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
                        child: const Text('Start Scavenger Hunt')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ========== PROFILE PAGE ==========
class ProfilePage extends StatelessWidget {
  final UserProfile userProfile;

  const ProfilePage({super.key, required this.userProfile});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Profile Information',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Name'),
                subtitle: Text(userProfile.name)),
            ListTile(
                leading: const Icon(Icons.email),
                title: const Text('Email'),
                subtitle: Text(userProfile.email)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('userProfile');
                if (context.mounted) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()));
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}

// ========== MY APP ==========
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PFT Scavenger Hunt',
      theme: ThemeData.dark().copyWith(
        // Set a dark theme with a custom scaffold background.
        scaffoldBackgroundColor: const Color(0xFF461D7C),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        // Elevated button theme: white background with purple text.
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF461D7C),
          ),
        ),
        // Input decoration theme for text fields.
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(),
          labelStyle: TextStyle(color: Colors.black),
        ),
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
            final decoded = json.decode(snapshot.data!);
            final userProfile = UserProfile.fromJson(decoded);
            return MyHomePage(
                title: 'PFT Scavenger Hunt', userProfile: userProfile);
          }
          return const LoginPage();
        },
      ),
    );
  }
}

// ========== HOME ==========
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.userProfile});

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
    Widget currentPage;
    if (_selectedIndex == 0) {
      currentPage = Column(
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
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            TaskDetailPage(task: task),
                        transitionsBuilder: (context, animation,
                                secondaryAnimation, child) =>
                            FadeTransition(opacity: animation, child: child),
                        transitionDuration: const Duration(milliseconds: 500),
                      ),
                    );
                    if (result == true) markTaskCompleted(task.id);
                  },
                );
              },
            ),
          ),
        ],
      );
    } else if (_selectedIndex == 1) {
      currentPage = const MapPage();
    } else {
      currentPage = ProfilePage(userProfile: widget.userProfile);
    }

    return Scaffold(
      // AppBar removed
      body: SafeArea(
        child: currentPage,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.question_answer), label: 'Questions'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'LSU Gallery',
        child: const Icon(Icons.photo_library),
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const LsuGalleryPage()));
        },
      ),
    );
  }
}
