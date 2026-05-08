import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/course.dart';
import '../state/course_notifier.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final courseState = ref.watch(courseListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Projeto Edu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(courseListProvider.notifier).refresh(),
          ),
        ],
      ),
      body: courseState.when(
        data: (courses) => _buildContent(courses),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Erro: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCourseDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent(List<Course> courses) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        return Card(
          child: ListTile(
            title: Text(course.title),
            subtitle: Text(course.description),
            trailing: course.pendingSync
                ? const Icon(Icons.sync, color: Colors.orange)
                : const Icon(Icons.check_circle, color: Colors.green),
          ),
        );
      },
    );
  }

  void _showAddCourseDialog() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Novo curso'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descrição'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Salvar'),
              onPressed: () async {
                final title = _titleController.text.trim();
                final description = _descriptionController.text.trim();
                if (title.isEmpty || description.isEmpty) {
                  return;
                }
                final dialogContext = context;
                await ref.read(courseListProvider.notifier).addCourse(title, description);
                if (!mounted) {
                  return;
                }
                _titleController.clear();
                _descriptionController.clear();
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
