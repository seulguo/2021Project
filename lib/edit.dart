import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/src/widgets/navigator.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'authentification.dart';
import 'main.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:flutter/src/widgets/navigator.dart';

class EditPage extends StatefulWidget {
  const EditPage({Key? key}) : super(key: key);
  static List<GuestBookMessage> list = <GuestBookMessage>[];
  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Consumer<ApplicationState>(
      builder: (context, appState, _) => Scaffold(
        appBar: AppBar(
          title: const Text('Edit'),
        ),
        body: DetailBody(products: EditPage.list),
      ),
    );
  }
}

class DetailBody extends StatefulWidget {
  const DetailBody({
    Key? key,
    required this.products,
  }) : super(key: key);

  final List<GuestBookMessage> products;

  @override
  _DetailBodyState createState() => _DetailBodyState();
}

class _DetailBodyState extends State<DetailBody> {
  bool _isExpanded = false;
  bool _kids = false;
  bool _pet = false;
  bool _breakfast = false;

  DateTime currentDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    //36.Date section: Add a DatePicker to select check-in date.
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: currentDate,
        firstDate: DateTime(2021),
        lastDate: DateTime(2050));
    if (pickedDate != null && pickedDate != currentDate)
      setState(() {
        currentDate = pickedDate;
      });
  }

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>(debugLabel: '_GuestBookState');
    final _name = TextEditingController();
    final _price = TextEditingController();
    final _detail = TextEditingController();


    Object? Id = ModalRoute.of(context)!.settings.arguments;
    int id = 0;
    for (var product in EditPage.list) {
      if (Id == product.id) {
        break;
      }
      id += 1;
    }

    _name.text = widget.products[id].name;
    _price.text = widget.products[id].price.toString();
    _detail.text = widget.products[id].detail;
    Timestamp selectDay = widget.products[id].selectDay;

    return Column(children: [
      Expanded(
        child: Container(
          child: Consumer<ApplicationState>(
            builder: (context, appState, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (appState.loginState == ApplicationLoginState.loggedIn) ...[
                  EditBook(
                    products: widget.products,
                    addMessage: (name, price, detail) =>
                        appState.addMessageToGuestBook(name, price, detail, selectDay),
                    id: id,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ]);
  }
}

