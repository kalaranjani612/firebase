import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_crud_app/task_screen.dart';
//import 'package:firebase_crud_app/main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
  return MaterialApp(
    home: TaskScreen(),
  );
  }
}

class TaskScreen extends StatefulWidget{
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {

 final TextEditingController _titleController = TextEditingController();
 final TextEditingController _priorityController = TextEditingController();
 final CollectionReference_tasks = 
      FirebaseFirestore.instance.collection('tasks');


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
 StatelessWidget
}


