import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInProvider extends ChangeNotifier {
  final googleSignIn = GoogleSignIn();

  GoogleSignInAccount? _user;

  GoogleSignInAccount get user => _user!;

  Future chooseAccount() async {
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) return;
    _user = googleUser;
    notifyListeners();
    return [await checkIfEmailInUse(googleUser.email), googleUser];
  }

  Future googleLogin() async {
    var googleUser = _user;

    final googleAuth = await googleUser!.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);
    notifyListeners();
  }

  Future googleLogout() async {
    await googleSignIn.disconnect();
    FirebaseAuth.instance.signOut();
  }

  Future<bool> checkIfEmailInUse(String emailAddress) async {
    try {
      // Recebe lista de emails
      final list =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(emailAddress);

      if (list.isNotEmpty) {
        // Retorna verdadeiro caso
        // o email estiver na lista
        return true;
      } else {
        // Retorna falso caso não exista
        return false;
      }
    } catch (error) {
      //Em caso de erro retorna para a função
      return true;
    }
  }
}
