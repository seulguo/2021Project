import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/src/widgets/navigator.dart';
import 'main.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({Key? key}) : super(key: key);

  @override
  State<StatisticsPage> createState() => _StatisticsPage();
}

class _StatisticsPage extends State<StatisticsPage> {
  String downloadURL = "";
  int selectedIndex = 0;
  String? id = FirebaseAuth.instance.currentUser!.displayName;
  String email = FirebaseAuth.instance.currentUser!.email.toString();
  String url = FirebaseAuth.instance.currentUser!.photoURL.toString();
  @override
  Widget build(BuildContext context) {
    return Consumer2<ApplicationState, DropDownProvider>(
      builder: (context, appState, dropState, _) => Scaffold(
        appBar: AppBar(
          title: Text("Statistics"),
          actions: <Widget>[
            IconButton(
              icon: const Icon(
                Icons.logout,
              ),
              onPressed: () {
                appState.signOut();
              },
            ),
          ],
        ),
        body: Container(
          child: Consumer2<ApplicationState, DropDownProvider>(
            builder: (context, appState, dropState, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GuestBook3(
                  addMessage: (message) =>
                      dropState.addMessageToGuestBook(message, message, message),
                  messages: dropState.guestBookMessages,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
