import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'config/database_helper.dart';
import 'models/contact.dart';
import 'widgets/new_contacts.dart';
import 'widgets/new_transaction.dart';
import 'widgets/transaction_list.dart';
import 'models/transaction.dart';
import 'widgets/chart.dart';

void main() {
  /* SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitUp
  ]); */
  runApp(MyMainPage());
}

class MyMainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Time Spending',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
        accentColor: Colors.amber,
        fontFamily: 'Quicksand',
        textTheme: ThemeData.light().textTheme.copyWith(
              title: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              button: TextStyle(
                color: Colors.white,
              ),
            ),
        appBarTheme: AppBarTheme(
            textTheme: ThemeData.light().textTheme.copyWith(
                  title: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                )),
        // appBarTheme: Colors.amberAccent,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  final dbHelper = DatabaseHelper.instance;
  final List<Transaction> _userTransactions = [];
  final List<Contact> _userContacts = [];
  //static List<String> nameMap = ['Nafisa','Amathullaah','Shakura','Noor'];
  //String currentName = nameMap.elementAt(0);
  String studentName;
  List<Contact> _contacts = []; //Contact.getContacts();
  List<DropdownMenuItem<Contact>> _dropdownMenuItems;
  Contact _selectedContact;
  

  _MyHomePageState() {}

  bool _showChart = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    //print(state);
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    //dbHelper.deleteContact(3);
    _queryContact();
   
    print("initialize............");

   /*_userContacts.forEach((row) {
      nameMap.add(row.name);
    });*/

   
    super.initState();
  }

  List<DropdownMenuItem<Contact>> buildDropdownMenuItems(List contacts) {
  List<DropdownMenuItem<Contact>> items = List();
  for (Contact contact in contacts) {
    items.add(
      DropdownMenuItem(
        value: contact,
        child: Text(contact.name),
      ),
    );
  }
  return items;
}

onChangeDropdownItem(Contact selectedContact) {
  setState(() {
    _selectedContact = selectedContact;
    print("selected contact:"+_selectedContact.name);
    _query();
  });
}

  @override
  dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  List<Transaction> get _recentTransactions {
    return _userTransactions.where((tx) {
      return tx.date.isAfter(
        DateTime.now().subtract(
          Duration(days: 7),
        ),
      );
    }).toList();
  }

  Future _addNewTransaction(
    String timeSpent,
    String time,
    DateTime chosenDate,
    String studentName,
  ) async {

    if(time!=null && int.parse(time)>100) {
       print("Time:"+time);
       showDialog(
                context: context,
                builder: (ctxt) => new AlertDialog(
                  title: Text("Time should not be more than 100 minutes"),
                )
            );
            return;
    }
    Map<String, dynamic> row = {
      DatabaseHelper.columnTitle: timeSpent,
      DatabaseHelper.columnTime: int.parse(time),
      DatabaseHelper.columnDate: chosenDate.toString(),
      DatabaseHelper.studentName: studentName
    };
    final id = await dbHelper.insert(row);
    if (id <= 0) {
      return;
    }
    final newTx = Transaction(
        title: timeSpent,
        time: double.parse(time),
        date: chosenDate,
        id: double.parse(id.toString()),
        name: studentName //DateTime.now().toString()
        );

    setState(() {
      _userTransactions.add(newTx);
    });
  }

  Future _addNewContact(String contactName) async {
    print("contact Name:"+contactName);
    Map<String, dynamic> row = {DatabaseHelper.studentName: contactName};
    final id = await dbHelper.insertContact(row);
    if (id <= 0) {
      return;
    }
    final newTx = Contact(name: contactName); //DateTime.now().toString()

    setState(() {
      _userContacts.add(newTx);
    });
    updateNameList();
  }

  void _startAddNewTransaction(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) {
        return NewTransaction(_addNewTransaction,_selectedContact.name);
      },
    );
  }

  void _startAddNewContacts(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) {
        return NewContact(_addNewContact);
      },
    );
  }

  void _deleteTransaction(double id) {
    _delete(int.parse(id.truncate().toString()));

    setState(() {
      _userTransactions.removeWhere((tx) {
       // print(tx.id);
        //print(id.truncate());
        return tx.id.truncate() == id.truncate();
      });
    });
  }

  List<Widget> _buildLandscapeContent(
      MediaQueryData mediaQuery, AppBar appBar, txListWidget) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Show Chart', style: Theme.of(context).textTheme.title),
          Switch.adaptive(
            activeColor: Theme.of(context).accentColor,
            value: _showChart,
            onChanged: (val) {
              setState(() {
                _showChart = val;
              });
            },
          ),
        ],
      ),
      _showChart
          ? Container(
              height: (mediaQuery.size.height -
                      appBar.preferredSize.height -
                      mediaQuery.padding.top) *
                  0.7,
              child: Chart(_recentTransactions),
            )
          : txListWidget
    ];
  }

  List<Widget> _buildPortraitContent(
      MediaQueryData mediaQuery, AppBar appBar, txListWidget) {
    return [
      Container(
        height: (mediaQuery.size.height -
                appBar.preferredSize.height -
                mediaQuery.padding.top) *
            0.1,
        child: DropdownButton(
                value: _selectedContact,
                items: _dropdownMenuItems,
                onChanged: onChangeDropdownItem,
              )
        
        /*DropdownButton<String>(
          value: currentName,
          isExpanded: true,
          hint: Text("Student Name"),
          items: nameMap.map((String name) {
            return DropdownMenuItem<String>( 
              value: name,
              child: Text(name),
            );
          }).toList(),
          onChanged: (String newName) {
            setState(() {
              this.currentName = newName;
            });
          },
        ),*/
      ),
      Container(
        height: (mediaQuery.size.height -
                appBar.preferredSize.height -
                mediaQuery.padding.top) *
            0.3,
        child: Chart(_recentTransactions),
      ),
      txListWidget
    ];
  }

  @override
  Widget build(BuildContext context) {
    print('build() HomePage');
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final PreferredSizeWidget appBar = Platform.isIOS
        ? CupertinoNavigationBar(
            middle: Text(
              'Time Spending',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                GestureDetector(
                  child: Icon(CupertinoIcons.add),
                  onTap: () => _startAddNewTransaction(context),
                )
              ],
            ))
        : AppBar(
            title: Text('Time Spending',
                style: TextStyle(fontFamily: 'Open Sans')),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.contacts),
                onPressed: () => _startAddNewContacts(context),
              ),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () => _startAddNewTransaction(context),
              )
            ],
          );
    final txListWidget = Container(
      height: (mediaQuery.size.height -
              appBar.preferredSize.height -
              mediaQuery.padding.top) *
          0.6,
      child: TransactionList(_userTransactions, _deleteTransaction),
    );
    final pageBody = SafeArea(
      child: SingleChildScrollView(
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (isLandscape)
              ..._buildLandscapeContent(mediaQuery, appBar, txListWidget),
            if (!isLandscape)
              ..._buildPortraitContent(mediaQuery, appBar, txListWidget)
          ],
        ),
      ),
    );
    return Platform.isIOS
        ? CupertinoPageScaffold(
            child: pageBody,
            navigationBar: appBar,
          )
        : Scaffold(
            appBar: appBar,
            body: pageBody,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: Platform.isIOS
                ? Container()
                : FloatingActionButton(
                    child: Icon(Icons.add),
                    onPressed: () => _startAddNewTransaction(context),
                  ),
          );
  }

  // Button onPressed methods

  void _insert(Map<String, dynamic> row) async {
    // row to insert
    /* Map<String, dynamic> row = {

      DatabaseHelper.columnTitle : 'Quran Memorize',
      DatabaseHelper.columnTime  : 45,
      DatabaseHelper.columnDate : DateTime.now().toString()
    }; */
    final id = await dbHelper.insert(row);
    print('inserted row id: $id');
  }

  void _query() async {

    final allRows1 = await dbHelper.queryAllRowsAllUsers();
    print('query all rows all users:'+allRows1.toList().toString());
 
    if(_selectedContact.name==null) {
      return;
    }
    final allRows = await dbHelper.queryAllRows(_selectedContact.name);
    print('query all rows trans:'+allRows.toList().toString());
    //allRows.forEach((row) => print(row));
    setState(() {
        _userTransactions.removeRange(0, _userTransactions.length);
    });
    allRows.forEach((row) {
      final newTx = Transaction(
        id: double.parse(row['_id'].toString()),
        title: row['title'],
        time: double.parse(row['time'].toString()),
        date: DateTime.parse(row['date']),
      );

      setState(() {
        _userTransactions.add(newTx);
      });
    });
  }

  void _queryContact() async {
    final allRows = await dbHelper.queryAllRowsContacts();
    print('query all rows contact:'+allRows.toList().toString());
    allRows.forEach((row) => print(row));

    allRows.forEach((row) {
      final newTx = Contact(
        id: int.parse(row['_id'].toString()),
        name: row['name'],
      );

      setState(() {
        print("student names :"+newTx.name);
        _userContacts.add(newTx);
        print("user contacts:"+_userContacts.toList().toString());
        
        //nameMap.add(newTx.name);
        //print("name Map:"+nameMap.toString());
      });
    updateNameList();
      
    });

     _query();
  }

  void updateNameList(){
    _contacts = _userContacts;
    print("contacts : "+_contacts.toList().toString());
    _dropdownMenuItems = buildDropdownMenuItems(_contacts);
    _selectedContact = _dropdownMenuItems[0].value;
  }

  void _update() async {
    // row to update
    Map<String, dynamic> row = {
      DatabaseHelper.columnId: 1,
      DatabaseHelper.columnTitle: 'Quran old revision',
      DatabaseHelper.columnTime: 32,
      DatabaseHelper.columnDate: DateTime.now().toString()
    };
    final rowsAffected = await dbHelper.update(row);
    print('updated $rowsAffected row(s)');
  }

  void _delete(int id) async {
    // Assuming that the number of rows is the id for the last row.
    //final id = await dbHelper.queryRowCount();
    final rowsDeleted = await dbHelper.delete(id);
    print('deleted $rowsDeleted row(s): row $id');
  }
}
