import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final CollectionReference tasks = FirebaseFirestore.instance.collection('tasks');
  final TextEditingController titleController = TextEditingController();
  final TextEditingController priorityController = TextEditingController();

  Future<void> createOrUpdateTask([DocumentSnapshot? document]) async {
    String action = document == null ? 'Create' : 'Update';
    if (document != null) {
      titleController.text = document['title'];
      priorityController.text = document['priority'].toString();
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$action Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: priorityController,
              decoration: const InputDecoration(labelText: 'Priority'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final String title = titleController.text;
              final int? priority = int.tryParse(priorityController.text);
              if (title.isNotEmpty && priority != null) {
                if (document == null) {
                  await tasks.add({'title': title, 'priority': priority});
                } else {
                  await tasks.doc(document.id).update({'title': title, 'priority': priority});
                }
                titleController.clear();
                priorityController.clear();
                Navigator.pop(context);
              }
            },
            child: Text(action),
          ),
        ],
      ),
    );
  }

  Future<void> deleteTask(String taskId) async {
    await tasks.doc(taskId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task Manager')),
      body: StreamBuilder(
        stream: tasks.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          return ListView(
            children: snapshot.data!.docs.map((doc) {
              return ListTile(
                title: Text(doc['title']),
                subtitle: Text('Priority: ${doc['priority']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => createOrUpdateTask(doc),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => deleteTask(doc.id),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => createOrUpdateTask(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
