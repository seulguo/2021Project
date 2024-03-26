import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'home.dart';
import 'package:flutter/src/material/colors.dart';

Future<UserCredential> signInWithGoogle() async {
  // Trigger the authentication flow
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  // Obtain the auth details from the request
  final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

  // Create a new credential
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );
  return await FirebaseAuth.instance.signInWithCredential(credential);
}

enum ApplicationLoginState {
  loggedOut,
  loggedIn,
  isGoogle,
}

class Authentication extends StatelessWidget {
  const Authentication({
    required this.loginState,
    required this.signOut,
  });

  final ApplicationLoginState loginState;
  final void Function() signOut;

  @override
  Widget build(BuildContext context) {
    switch (loginState) {
      case ApplicationLoginState.loggedOut:
        return Container(
          color: Color.fromRGBO(148, 123, 192, 10),
          padding: EdgeInsets.all(40),
          child: ListView(
            children: <Widget>[
              const SizedBox(height: 120),
              Center(
                child: SizedBox(
                    height: 150,
                    child: Text(
                      "TO DO LIST",
                      style: TextStyle(
                        fontSize: 50,
                        color: Colors.white,
                      ),
                    ),
                ),
              ),
              const SizedBox(height: 130),
              TextButton(
                child: Text(
                  "Google Login",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                onPressed: (signInWithGoogle),
              ),
              const SizedBox(height: 12.0),
              // TODO: Wrap Password with AccentColorOverride (103)
            ],
          ),
        );
      case ApplicationLoginState.loggedIn:
        return HomePage();
      default:
        return Row(
          children: const [
            Text("Internal error, this shouldn't happen..."),
          ],
        );
    }
  }
}

