import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todo_fb/constants/app_constants.dart';

final FirebaseFirestore _firebaseFirestore=FirebaseFirestore.instance;

class NoteDatabase{

  static String? id;

  Stream<QuerySnapshot> readNotes(){
    CollectionReference notesCollection =_firebaseFirestore
        .collection(AppConstants.referencePath)
        .doc(FirebaseAuth.instance.currentUser!.email)
        .collection(AppConstants.collectionPath);

    return notesCollection.snapshots();
  }


  Future<void> addNote(String title, String description)async{
    DocumentReference documentReference=_firebaseFirestore
        .collection(AppConstants.referencePath)
        .doc(FirebaseAuth.instance.currentUser!.email)
        .collection(AppConstants.collectionPath).doc(id);

    Map<String,dynamic> data=<String,dynamic>{
      'title':title,
      'description':description,
    };

    await documentReference.set(data).whenComplete(() =>
        print('Note inserted to the database')).catchError((e)=>print(e));

  }
  
   Future<void> deleteNote({required String id})async{
    DocumentReference documentReference=_firebaseFirestore
        .collection(AppConstants.referencePath)
        .doc(FirebaseAuth.instance.currentUser!.email)
        .collection(AppConstants.collectionPath)
        .doc(id);

    await documentReference.delete().whenComplete(() =>
        print('Note deleted from the database')).catchError((e)=>print(e));
  }



}