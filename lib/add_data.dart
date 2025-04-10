import 'package:cloud_firestore/cloud_firestore.dart';

void addSampleData() async {
  final CollectionReference tasks = FirebaseFirestore.instance.collection('tasks');

  try {
    await tasks.add({
      'title': 'Sample Task',
      'priority': 1,
    });
    print('Data added successfully!');
  } catch (e) {
    print('Error adding data: $e');
  }
}
