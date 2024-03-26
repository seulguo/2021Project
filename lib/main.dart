import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/src/material/page.dart';
import 'package:flutter/src/widgets/navigator.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart';
import 'package:projectaza/home.dart';
import 'package:projectaza/statistics.dart';
import 'package:projectaza/widgets.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'add.dart';
import 'authentification.dart';
import 'package:projectaza/edit.dart';
import 'package:fl_chart/fl_chart.dart';

import 'map.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ApplicationState(),
        ),
        ChangeNotifierProvider(
          create: (context) => DropDownProvider(),
        ),
      ],
      builder: (context, _) => App(),
    ),
  );
} //provider 설정해주는 부분

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Final Project',
      theme: ThemeData(
        buttonTheme: Theme.of(context).buttonTheme.copyWith(
              highlightColor: Colors.deepPurple,
            ),
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LoginPage(),
      routes: {
        'login': (context) => LoginPage(),
        'add': (context) => AddPage(),
        'home': (context) => HomePage(),
        'edit': (context) => EditPage(),
        'statistics': (context) => StatisticsPage(),
        'map' : (context) => MapPage(),
      },
      initialRoute: '/login',
      onGenerateRoute: _getRoute,
    );
  } //LoginPage로 이동

  Route<dynamic>? _getRoute(RouteSettings settings) {
    if (settings.name != '/login') {
      return null;
    }

    return MaterialPageRoute<void>(
      settings: settings,
      builder: (BuildContext context) => const LoginPage(),
      fullscreenDialog: true,
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationState>(
      builder: (context, appState, _) => Authentication(
        loginState: appState.loginState,
        signOut: appState.signOut,
      ),
    );
  }
}

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  } //appState

  Future<void> init() async {
    await Firebase.initializeApp();
    // Firebase내용을 가져오는 곳
    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        //로그인 됐을때
        print("********");
        print("로그인 됨 ");
        print(user);
        print("********");
        _loginState = ApplicationLoginState.loggedIn;
        _guestBookSubscription = FirebaseFirestore.instance
            .collection('product')
            .orderBy('selectDay', descending: false)
            .snapshots()
            .listen((snapshot) {
          _guestBookMessages = [];
          for (final document in snapshot.docs) {
            _guestBookMessages.add(
              GuestBookMessage(
                id: document.id,
                name: document.data()['name'] as String,
                price: document.data()['price2'] as int,
                detail: document.data()['detail'] as String,
                createTime: document.data()['createTime'] as int,
                editTime: document.data()['currentTime'] as int,
                userID: document.data()['userId'] as String,
                list: document.data()['like'] as List,
                isDone: document.data()['isDone'] as bool,
                selectDay: document.data()['selectDay'] as Timestamp,
              ),
            );
          }
          notifyListeners();
        });
      } else {
        _loginState = ApplicationLoginState.loggedOut;
        _guestBookMessages = [];
        _guestBookSubscription?.cancel();
      }
      notifyListeners();
    });
  }

  ApplicationLoginState _loginState = ApplicationLoginState.loggedOut;

  ApplicationLoginState get loginState => _loginState;

  StreamSubscription<QuerySnapshot>? _guestBookSubscription;
  List<GuestBookMessage> _guestBookMessages = [];

  List<GuestBookMessage> get guestBookMessages => _guestBookMessages;

  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  Future<DocumentReference> addMessageToGuestBook(
      String name, String price, String detail, Timestamp selectDay) {
    if (_loginState != ApplicationLoginState.loggedIn) {
      throw Exception('Must be logged in');
    }

    return FirebaseFirestore.instance
        .collection('product')
        .add(<String, dynamic>{
      'name': name,
      'price2': int.parse(price),
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'detail': detail,
      'createTime': DateTime.now().millisecondsSinceEpoch,
      'currentTime': DateTime.now().millisecondsSinceEpoch,
      'like': List<dynamic>.empty(),
      'isDone': false,
      'selectDay': selectDay,
    });
  }

  Future<void> editSave() async {
    await _EditBookState().save();
  }

  Future<void> addSave() async {
    await _AddBookState().save();
  }
}

class DropDownProvider extends ChangeNotifier {
  DropDownProvider() {
    init();
  }

  Future<void> init() async {
    await Firebase.initializeApp();
    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        //로그인 됐을때
        _loginState = ApplicationLoginState.loggedIn;
        _guestBookSubscription = FirebaseFirestore.instance
            .collection('product')
            .orderBy('selectDay', descending: false)
            .snapshots()
            .listen((snapshot) {
          _guestBookMessages = [];
          for (final document in snapshot.docs) {
            _guestBookMessages.add(
              GuestBookMessage(
                id: document.id,
                name: document.data()['name'] as String,
                price: document.data()['price2'] as int,
                detail: document.data()['detail'] as String,
                createTime: document.data()['createTime'] as int,
                editTime: document.data()['currentTime'] as int,
                userID: document.data()['userId'] as String,
                list: document.data()['like'] as List,
                isDone: document.data()['isDone'] as bool,
                selectDay: document.data()['selectDay'] as Timestamp,
              ),
            );
          }
          notifyListeners();
        });
      } else {
        _loginState = ApplicationLoginState.loggedOut;
        _guestBookMessages = [];
        _guestBookSubscription?.cancel();
      }
      notifyListeners();
    });
  }

  ApplicationLoginState _loginState = ApplicationLoginState.loggedOut;

  ApplicationLoginState get loginState => _loginState;

  StreamSubscription<QuerySnapshot>? _guestBookSubscription;
  List<GuestBookMessage> _guestBookMessages = [];

  List<GuestBookMessage> get guestBookMessages => _guestBookMessages;

  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  Future<DocumentReference> addMessageToGuestBook(
      String name, String price, String detail) {
    if (_loginState != ApplicationLoginState.loggedIn) {
      throw Exception('Must be logged in');
    }

    return FirebaseFirestore.instance
        .collection('product')
        .add(<String, dynamic>{
      'name': name,
      'price2': int.parse(price),
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'detail': detail,
      'createTime': DateTime.now().millisecondsSinceEpoch,
      'currentTime': DateTime.now().millisecondsSinceEpoch,
      'like': List<dynamic>.empty(),
      'isDone': false,
    });
  }

  Future<void> editSave() async {
    await _EditBookState().save();
  }

  Future<void> addSave() async {
    await _AddBookState().save();
  }
}

class GuestBookMessage {
  GuestBookMessage({
    required this.name,
    required this.price,
    required this.id,
    required this.detail,
    required this.userID,
    required this.createTime,
    required this.editTime,
    required this.list,
    required this.isDone,
    required this.selectDay,
  });

  final String name;
  final int price;
  final String id;
  final String detail;
  final int createTime;
  final int editTime;
  final String userID;
  final List list;
  late final bool isDone;
  final Timestamp selectDay;
}

class AddBook extends StatefulWidget {
  const AddBook({required this.addMessage, required this.selectDay});

  final Timestamp selectDay;
  final FutureOr<void> Function(
          String name, String price, String description, Timestamp selectDay)
      addMessage;

  @override
  _AddBookState createState() => _AddBookState();
}

class _AddBookState extends State<AddBook> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_GuestBookState');
  final _name = TextEditingController();
  final _price = TextEditingController();
  final _detail = TextEditingController();

  Future<void> save() async {
    await widget.addMessage(
        _name.text, _price.text, _detail.text, widget.selectDay);
    _name.clear();
    _price.clear();
    _detail.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SingleChildScrollView(),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _name,
                            decoration: const InputDecoration(
                              hintText: 'Title',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter your message to continue';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _detail,
                            decoration: const InputDecoration(
                              hintText: 'Description',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter your message to continue';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        SizedBox(width: 320),
                        Expanded(
                          child: StyledButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                await widget.addMessage(_name.text, "1",
                                    _detail.text, widget.selectDay);
                                _name.clear();
                                _price.clear();
                                _detail.clear();
                                Navigator.pushNamed(context, 'home');
                              }
                            },
                            child: Row(
                              children: const [
                                SizedBox(width: 4),
                                Text('SAVE'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class EditBook extends StatefulWidget {
  const EditBook(
      {required this.addMessage, required this.products, required this.id});

  final FutureOr<void> Function(String name, String price, String description)
      addMessage;
  final List<GuestBookMessage> products;
  final int id;

  @override
  _EditBookState createState() => _EditBookState();
}

class _EditBookState extends State<EditBook> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_GuestBookState');
  final _name = TextEditingController();
  final _price = TextEditingController();
  final _detail = TextEditingController();

  Future<void> save() async {
    print("---------");

    await FirebaseFirestore.instance
        .collection('product')
        .doc(widget.products[widget.id].id)
        .update(<String, dynamic>{
      'name': _name.text,
      'price2': int.parse(_price.text),
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'detail': _detail.text,
      'currentTime': DateTime.now().millisecondsSinceEpoch,
      'isDone': widget.products[widget.id].isDone,
    });
    _name.clear();
    _price.clear();
    _detail.clear();
  }

  @override
  Widget build(BuildContext context) {
    _name.text = widget.products[widget.id].name;
    _price.text = widget.products[widget.id].price.toString();
    _detail.text = widget.products[widget.id].detail;

    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _name,
                            decoration: const InputDecoration(
                              hintText: 'Title',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter your message to continue';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _detail,
                            decoration: const InputDecoration(
                              hintText: 'Description',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter your message to continue';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        SizedBox(width: 320),
                        Expanded(
                          child: StyledButton(
                            onPressed: () async {
                              print("---------");
                              await FirebaseFirestore.instance
                                  .collection('product')
                                  .doc(widget.products[widget.id].id)
                                  .update(<String, dynamic>{
                                'name': _name.text,
                                'price2': int.parse(_price.text),
                                'userId':
                                    FirebaseAuth.instance.currentUser!.uid,
                                'detail': _detail.text,
                                'currentTime':
                                    DateTime.now().millisecondsSinceEpoch,
                                'isDone': widget.products[widget.id].isDone,
                              });
                              _name.clear();
                              _price.clear();
                              _detail.clear();
                              Navigator.pushNamed(context, 'home');
                            },
                            child: Row(
                              children: const [
                                SizedBox(width: 4),
                                Text('SAVE'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class GuestBook3 extends StatefulWidget {
  const GuestBook3({required this.addMessage, required this.messages});

  final FutureOr<void> Function(String message) addMessage;
  final List<GuestBookMessage> messages;

  @override
  _GuestBookState3 createState() => _GuestBookState3();
}

class _GuestBookState3 extends State<GuestBook3> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_GuestBookState');
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    List stack = [];
    List real = [];
    int? num = 0;

    var map = Map<String, int>();
    for(int i = 0; i<widget.messages.length; i++) {
      map[DateFormat('yyyy-MM-dd').format(widget.messages[i].selectDay.toDate()).toString()] = 0;
    }

    for(int i = 0; i<widget.messages.length; i++) {
      map.update(DateFormat('yyyy-MM-dd').format(widget.messages[i].selectDay.toDate()).toString(), (value) => value +
          widget.messages[i].price);
    }

    print("####");
    print(map);
    print("####");

    stack = map.values.toList();

    print(stack);

    for(int i = 0; i<stack.length; i++){
      num = (num! + stack[i]) as int?;
      real.add(num);
    }

    print(real);





    return Consumer<DropDownProvider>(
      builder: (context, dropState, _) => Expanded(
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 40, 20, 40),
          width: double.infinity,
          child: Column(
            children: [
              Expanded(
                child: LineChart(
                  LineChartData(
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(spots: [
                          for(double i = 0; i<real.length; i++)
                            FlSpot(i+1, real[i.toInt()].toDouble())
                        ])
                      ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GuestBook2 extends StatefulWidget {
  const GuestBook2({required this.addMessage, required this.messages});

  final FutureOr<void> Function(String message) addMessage;
  final List<GuestBookMessage> messages;

  @override
  _GuestBookState2 createState() => _GuestBookState2();
}

class _GuestBookState2 extends State<GuestBook2> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_GuestBookState');
  final _controller = TextEditingController();
  bool isDone = false;

  String dropdownValue = 'ASC';
  bool order = false;
  CalendarFormat format = CalendarFormat.month;
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();
  String strToday = DateFormat('yyyy-MM-dd').format(DateTime.now()).toString();

  List<Card> _buildGridCards(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final NumberFormat formatter = NumberFormat.simpleCurrency(
        locale: Localizations.localeOf(context).toString());
    return widget.messages.map((product) {
      return Card(
        clipBehavior: Clip.antiAlias,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: product.isDone
                  ? Container(
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                      child: Row(children: [
                        Checkbox(
                          activeColor: Colors.deepPurple,
                          checkColor: Colors.white,
                          value: product.isDone,
                          onChanged: (value) async {
                            await FirebaseFirestore.instance
                                .collection('product')
                                .doc(product.id)
                                .update(<String, dynamic>{
                              'isDone': !product.isDone,
                              'price2' : product.price - 1,
                            });
                          },
                        ),
                        SizedBox(width: 20),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              SizedBox(height: 10),
                              Text(product.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                    fontSize: 20,
                                  )),
                              Text(
                                product.detail,
                                style: TextStyle(fontSize: 15),
                              ),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(DateFormat('yyyy-MM-dd')
                                        .format(product.selectDay.toDate())
                                        .toString()),
                                    // IconButton(
                                    //   onPressed: () async {
                                    //     await FirebaseFirestore.instance
                                    //         .collection("product")
                                    //         .doc(product.id)
                                    //         .delete();
                                    //     Navigator.pushNamed(context, 'home');
                                    //   },
                                    //   icon: Icon(Icons.delete),
                                    // ),
                                  ]),
                            ]))
                      ]),
                    )
                  : Container(),
            ),
          ],
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {

    return Consumer<DropDownProvider>(
      builder: (context, dropState, _) => Expanded(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(16.0),
                children: _buildGridCards(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GuestBook extends StatefulWidget {
  const GuestBook({required this.addMessage, required this.messages});

  final FutureOr<void> Function(String message) addMessage;
  final List<GuestBookMessage> messages;

  @override
  _GuestBookState createState() => _GuestBookState();
}

class _GuestBookState extends State<GuestBook> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_GuestBookState');
  final _controller = TextEditingController();
  bool isDone = false;

  String dropdownValue = 'ASC';
  bool order = false;
  CalendarFormat format = CalendarFormat.month;
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();
  String strToday = DateFormat('yyyy-MM-dd').format(DateTime.now()).toString();

  List<Card> _buildGridCards(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final NumberFormat formatter = NumberFormat.simpleCurrency(
        locale: Localizations.localeOf(context).toString());
    return widget.messages.map((product) {
      return Card(
        clipBehavior: Clip.antiAlias,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: !product.isDone &&
                      DateFormat('yyyy-MM-dd')
                              .format(product.selectDay.toDate()) ==
                          DateFormat('yyyy-MM-dd').format(selectedDay)
                  ? Container(
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Row(children: [
                        Checkbox(
                          activeColor: Colors.deepPurple,
                          checkColor: Colors.white,
                          value: product.isDone,
                          onChanged: (value) async {
                            await FirebaseFirestore.instance
                                .collection('product')
                                .doc(product.id)
                                .update(<String, dynamic>{
                              'isDone': !product.isDone,
                              'price2' : product.price + 1,
                            });
                          },
                        ),
                        SizedBox(width: 20),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              SizedBox(height: 10),
                              Text(product.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                    fontSize: 20,
                                  )),
                              Stack(
                                children: [
                                  Text(
                                    product.detail,
                                    style: TextStyle(fontSize: 15),
                                  ),
                                  Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            Navigator.pushNamed(context, 'edit',
                                                arguments: product.id);
                                            EditPage.list =
                                                List.from(widget.messages);
                                          },
                                          icon: Icon(Icons.edit),
                                        ),
                                        IconButton(
                                          onPressed: () async {
                                            await FirebaseFirestore.instance
                                                .collection("product")
                                                .doc(product.id)
                                                .delete();
                                            Navigator.pushNamed(
                                                context, 'home');
                                          },
                                          icon: Icon(Icons.delete),
                                        ),
                                      ]),
                                ],
                              ),
                            ]))
                      ]),
                    )
                  : Container(),
            ),
          ],
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DropDownProvider>(
      builder: (context, dropState, _) => Expanded(
        child: Column(
          children: [
            // SizedBox(height : 30.0),
            // Center(
            //     child: Text(strToday),
            // ),
            TableCalendar(
              focusedDay: DateTime.now(),
              firstDay: DateTime(2021),
              lastDay: DateTime(2050),
              calendarFormat: format,
              onFormatChanged: (CalendarFormat _format) {
                setState(() {
                  format = _format;
                });
              },
              selectedDayPredicate: (DateTime date) {
                return isSameDay(selectedDay, date);
              },
              calendarStyle: CalendarStyle(
                  isTodayHighlighted: true,
                  selectedDecoration: BoxDecoration(
                    color: Color.fromRGBO(148, 123, 192, 10),
                    shape: BoxShape.circle,
                  )),
              onDaySelected: (DateTime selectDay, DateTime focusDay) {
                setState(() {
                  selectedDay = selectDay;
                  focusedDay = focusDay;
                  print("focusDay");
                  print(focusDay);
                  print("selectDay");
                  print(selectDay);
                });
              },
            ),
            Expanded(
              child: Stack(
                children: [
                  ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(16.0),
                    children: _buildGridCards(context),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 130, 0, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FloatingActionButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          backgroundColor: Colors.deepPurple,
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              'add',
                              arguments: selectedDay,
                            );
                          },
                          child: const Icon(Icons.add),
                        ),
                        const SizedBox(width: 15),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
