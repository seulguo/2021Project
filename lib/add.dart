
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'main.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:flutter/src/widgets/navigator.dart';


class AddPage extends StatefulWidget {
  const AddPage({Key? key}) : super(key: key);

  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {

  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationState>(
      builder: (context, appState,_) => Scaffold(
        appBar: AppBar(
          title: const Text('Add'),
        ),
        body: DetailBody(),
      ),
    );
  }
}

class DetailBody extends StatefulWidget {
  const DetailBody({
    Key? key,
  }) : super(key: key);

  @override
  _DetailBodyState createState() => _DetailBodyState();
}

class _DetailBodyState extends State<DetailBody> {
  bool _isExpanded = false;
  bool _kids = false;
  bool _pet = false;
  bool _breakfast = false;

  DateTime currentDate = DateTime.now();



  @override
  Widget build(BuildContext context) {
    Object? selectedDay = ModalRoute
        .of(context)!
        .settings
        .arguments;
    DateTime day = DateTime.parse(selectedDay.toString());
    Timestamp selectDay = Timestamp.fromDate(day);

    return Column(children: [
      Expanded(
        child: Container(
          child: Consumer<ApplicationState>(
            builder: (context, appState, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  AddBook(
                    addMessage: (name, price, detail, selectDay) =>
                        appState.addMessageToGuestBook(name, price, detail, selectDay), selectDay: selectDay,
                  ),
              ],
            ),
          ),
        ),
      ),
    ]);
  }
}


