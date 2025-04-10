import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TaskScreen(),
    );
  }
}

class TaskScreen extends StatefulWidget {
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priorityController = TextEditingController();
  final CollectionReference _tasks =
      FirebaseFirestore.instance.collection('tasks');

  Future<void> _createOrUpdate([DocumentSnapshot? document]) async {
    String action = document == null ? 'create' : 'update';
    if (document != null) {
      _titleController.text = document['title'];
      _priorityController.text = document['priority'].toString();
    }

    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(action == 'create' ? 'Add Task' : 'Update Task'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(labelText: 'Title'),
                  ),
                  TextField(
                    controller: _priorityController,
                    decoration: InputDecoration(labelText: 'Priority'),
                    keyboardType: TextInputType.number,
                  )
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel')),
                TextButton(
                  onPressed: () async {
                    final String title = _titleController.text;
                    final int? priority =
                        int.tryParse(_priorityController.text);
                    if (title.isNotEmpty && priority != null) {
                      if (action == 'create') {
                        await _tasks
                            .add({'title': title, 'priority': priority});
                      } else {
                        await _tasks
                            .doc(document!.id)
                            .update({'title': title, 'priority': priority});
                      }
                      _titleController.clear();
                      _priorityController.clear();
                      Navigator.pop(context);
                    }
                  },
                  child: Text(action == 'create' ? 'Add' : 'Update'),
                )
              ],
            ));
  }

  Future<void> _deleteTask(String id) async {
    await _tasks.doc(id).delete();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Manager'),
      ),
      body: StreamBuilder(
          stream: _tasks.snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView(
                children: snapshot.data!.docs.map((doc) {
              return ListTile(
                title: Text(doc['title']),
                subtitle: Text('Priority: ${doc['priority']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        onPressed: () => _createOrUpdate(doc),
                        icon: Icon(Icons.edit)),
                    IconButton(
                        onPressed: () => _deleteTask(doc.id),
                        icon: Icon(Icons.delete))
                  ],
                ),
              );
            }).toList());
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createOrUpdate(),
        child: Icon(Icons.add),
      ),
    );
  }
}