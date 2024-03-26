import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/src/widgets/navigator.dart';
import 'main.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String downloadURL = "";
  int selectedIndex = 0;
  String? id = FirebaseAuth.instance.currentUser!.displayName;
  String email = FirebaseAuth.instance.currentUser!.email.toString();
  String url = FirebaseAuth.instance.currentUser!.photoURL.toString();
  @override
  Widget build(BuildContext context) {
    final tabs = [
      Container(
        child: Consumer2<ApplicationState, DropDownProvider>(
          builder: (context, appState, dropState, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GuestBook(
                addMessage: (message) =>
                    dropState.addMessageToGuestBook(message, message, message),
                messages: dropState.guestBookMessages,
              ),
            ],
          ),
        ),
      ),
      Container(
        child: Consumer2<ApplicationState, DropDownProvider>(
          builder: (context, appState, dropState, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GuestBook2(
                addMessage: (message) =>
                    dropState.addMessageToGuestBook(message, message, message),
                messages: dropState.guestBookMessages,
              ),
            ],
          ),
        ),
      ),
    ];
    return Consumer2<ApplicationState, DropDownProvider>(
      builder: (context, appState, dropState, _) => Scaffold(
        appBar: AppBar(
          title: Text("TO DO LIST"),
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
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[

              UserAccountsDrawerHeader(
                accountName: Text(
                  id!,
                  style: TextStyle(color: Colors.white),
                ),
                accountEmail: Text(
                  email,
                  style: TextStyle(color: Colors.white),
                ),
              ),
              ListTile(
                leading: Icon(Icons.assessment_outlined),
                title: Text('statistics'),
                onTap: () {
                  Navigator.pushNamed(context, 'statistics');
                },
              ),
              ListTile(
                leading: Icon(Icons.map),
                title: Text('Map'),
                onTap: () {
                  Navigator.pushNamed(context, 'map');
                },
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.white.withOpacity(0.7),
          selectedItemColor: Colors.white,
          currentIndex: selectedIndex,
          onTap: (index) => setState(() {
            selectedIndex = index;
          }),
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.fact_check_outlined),
              label: 'Todos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.done, size: 28),
              label: 'Completed',
            ),
          ],
        ),
        body: tabs[selectedIndex],
        resizeToAvoidBottomInset: false,
      ),
    );
  }
}
