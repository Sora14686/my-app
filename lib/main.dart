import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => CounterProvider(),
      child: const BeginnerFlutterApp(),
    ),
  );
}

class BeginnerFlutterApp extends StatelessWidget {
  const BeginnerFlutterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Beginner Lab',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const LearningHomePage(),
    );
  }
}

class CounterProvider extends ChangeNotifier {
  int _count = 0;

  int get count => _count;

  void increment() {
    _count++;
    notifyListeners();
  }

  void reset() {
    _count = 0;
    notifyListeners();
  }
}

class LearningHomePage extends StatefulWidget {
  const LearningHomePage({super.key});

  @override
  State<LearningHomePage> createState() => _LearningHomePageState();
}

class _LearningHomePageState extends State<LearningHomePage> {
  int _setStateCounter = 0;
  String _name = '';
  final TextEditingController _nameController = TextEditingController();

  final Dio _dio = Dio();
  bool _isLoadingPost = false;
  String _postTitle = 'No API data yet';
  String _postBody = 'Press the button to call API with Dio.';

  final TextEditingController _noteController = TextEditingController();
  String _savedNote = 'No local note saved yet.';

  final TextEditingController _imageUrlController = TextEditingController(
    text: 'https://picsum.photos/500/300',
  );
  String _networkImageUrl = 'https://picsum.photos/500/300';
  String? _localImagePath;

  @override
  void initState() {
    super.initState();
    _loadLocalData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _fetchPost() async {
    setState(() => _isLoadingPost = true);
    try {
      final response = await _dio.get('https://jsonplaceholder.typicode.com/posts/1');
      final data = response.data as Map<String, dynamic>;
      setState(() {
        _postTitle = data['title']?.toString() ?? 'Missing title';
        _postBody = data['body']?.toString() ?? 'Missing body';
      });
    } catch (_) {
      setState(() {
        _postTitle = 'API request failed';
        _postBody = 'Please check your internet connection and try again.';
      });
    } finally {
      setState(() => _isLoadingPost = false);
    }
  }

  Future<void> _saveNote() async {
    final prefs = await SharedPreferences.getInstance();
    final text = _noteController.text.trim();
    await prefs.setString('beginner_note', text);
    setState(() {
      _savedNote = text.isEmpty ? 'Note cleared.' : text;
    });
  }

  Future<void> _loadLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    final note = prefs.getString('beginner_note');
    final imagePath = prefs.getString('picked_image_path');
    setState(() {
      _savedNote = (note == null || note.isEmpty) ? 'No local note saved yet.' : note;
      _localImagePath = imagePath;
      if (note != null) {
        _noteController.text = note;
      }
    });
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('picked_image_path', file.path);

    setState(() {
      _localImagePath = file.path;
    });
  }

  void _updateName() {
    setState(() {
      _name = _nameController.text.trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    final providerCounter = context.watch<CounterProvider>().count;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Beginner Lab'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionTitle('1) Variables, Functions, and setState'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('setState counter: $_setStateCounter'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilledButton.icon(
                        onPressed: () => setState(() => _setStateCounter++),
                        icon: const Icon(Icons.add),
                        label: const Text('Increment'),
                      ),
                      OutlinedButton(
                        onPressed: () => setState(() => _setStateCounter = 0),
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Type your name',
                    ),
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: _updateName,
                    child: const Text('Save name'),
                  ),
                  const SizedBox(height: 8),
                  Text(_name.isEmpty ? 'Hello Flutter Dev' : 'Hello $_name'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const SectionTitle('2) State Management with Provider'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('provider counter: $providerCounter'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilledButton(
                        onPressed: context.read<CounterProvider>().increment,
                        child: const Text('Increment Provider'),
                      ),
                      OutlinedButton(
                        onPressed: context.read<CounterProvider>().reset,
                        child: const Text('Reset Provider'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const SectionTitle('3) Call API with Dio'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FilledButton.icon(
                    onPressed: _isLoadingPost ? null : _fetchPost,
                    icon: const Icon(Icons.cloud_download),
                    label: Text(_isLoadingPost ? 'Loading...' : 'Fetch sample post'),
                  ),
                  const SizedBox(height: 8),
                  Text('Title: $_postTitle', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(_postBody),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const SectionTitle('4) Local Storage (SharedPreferences)'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Write a short note',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilledButton(onPressed: _saveNote, child: const Text('Save to local')),
                      OutlinedButton(onPressed: _loadLocalData, child: const Text('Reload local')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Saved note: $_savedNote'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const SectionTitle('5) Images from URL + File + Cache'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _imageUrlController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Image URL',
                    ),
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: () {
                      setState(() => _networkImageUrl = _imageUrlController.text.trim());
                    },
                    child: const Text('Load URL image'),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: _networkImageUrl,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const SizedBox(
                        height: 180,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (_, __, ___) => const SizedBox(
                        height: 180,
                        child: Center(child: Text('Invalid image URL')),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _pickImageFromGallery,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Pick image from gallery'),
                  ),
                  const SizedBox(height: 8),
                  if (_localImagePath == null)
                    const Text('No local image selected yet')
                  else if (!File(_localImagePath!).existsSync())
                    const Text('Selected file was not found on disk')
                  else
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(_localImagePath!),
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const SectionTitle('6) Common Widgets in this demo'),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Scaffold, AppBar, ListView, Card, Padding, Column, Wrap, '
                'TextField, Button, Icon, Image, CircularProgressIndicator, SizedBox',
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
