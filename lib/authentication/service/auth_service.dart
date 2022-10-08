import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:todo_fb/constants/app_constants.dart';
import '../../notes/database/repository/user_database.dart';


class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  UserDatabase userDatabase=UserDatabase();



  Future<User?> createUserWithEmailandPassword(String name,String email,String password)async{
    final user=await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password);
    await FirebaseFirestore.instance
        .collection(AppConstants.referencePath)
        .doc(user.user!.email)
        .set({
      'email':user.user!.email,
    'userUid':user.user!.uid,
    'userName':user.user!.displayName});
    User? userr=user.user;
    userr!.updateDisplayName(user.user!.displayName);
    return user.user;
  }

  Future<User?> signInWithEmailandPassword(String email,String password)async{
    final userCredential=await firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    print('SIGN IN WİTH EMAIL AND PASSWORD ${userCredential.user}');
    return userCredential.user;
  }


  Future<void> signInwithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
      await _googleSignIn.signIn();
      if(googleSignInAccount !=null){
        final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );
        userDatabase.addGoogleUsertoFirestore(googleSignInAccount);
        await firebaseAuth.signInWithCredential(credential);
      }
    } on FirebaseAuthException catch (e) {
      print(e.message);
      rethrow;
    }
  }

  Stream<User?> authStatus(){
    return firebaseAuth.authStateChanges();
  }

  Future<void> update(Map<String,Object?>data)async{
    return await FirebaseFirestore.instance
        .collection(AppConstants.referencePath)
        .doc(FirebaseAuth.instance.currentUser!.email).update(data);

  }


  Future updateName(){
    Map<String,dynamic> data=<String,dynamic>{
      'userName':userNameController.text
    };
    return FirebaseFirestore.instance
        .collection(AppConstants.referencePath)
        .doc(FirebaseAuth.instance.currentUser!.email).update(data);

  }

  Future<void> signOut() async {
    if (_googleSignIn.currentUser != null) {
      await _googleSignIn.disconnect();
      await _googleSignIn.signOut();
      FirebaseAuth.instance.signOut();
    }
    else {
      await FirebaseAuth.instance.signOut();

    }
  }


}