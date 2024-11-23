import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_crud_firebase/service/firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService firestoreService = FirestoreService();

  final TextEditingController textController = TextEditingController();

  void openNoteBox(String? docID) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: textController,
        ),
        actions: [
          ElevatedButton(
              onPressed: () {
                if (textController.text.isNotEmpty) {
                  if (docID == null) {
                    firestoreService.addNote(textController.text);
                  } else {
                    firestoreService.updateNote(docID, textController.text);
                  }

                  textController.clear();

                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'The note is empty, please add information to continue')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[900],
                foregroundColor: Colors.white,
              ),
              child: Text("Add"))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Crud en Firebase",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green[900],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[900],
        onPressed: () => openNoteBox(null),
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: firestoreService.getNotesStream(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List noteList = snapshot.data!.docs;

              return ListView.builder(
                  itemCount: noteList.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot document = noteList[index];
                    String docID = document.id;

                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                    String noteText = data['note'];

                    return ListTile(
                      title: Text(noteText),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        IconButton(
                          onPressed: () => openNoteBox(docID),
                          icon: Icon(
                            Icons.settings,
                            color: Colors.green[900],
                          ),
                        ),
                        IconButton(
                          onPressed: () => firestoreService.deleteNote(docID),
                          icon: const Icon(Icons.delete),
                          color: Colors.green[900],
                        ),
                      ]),
                    );
                  });
            } else {
              return const Center(child: Text("There are no notes."));
            }
          }),
    );
  }
}
