import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'config/database_helper.dart';
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
        theme: ThemeData(
          primarySwatch: Colors.pink,
          accentColor: Colors.amber,
          fontFamily: 'Quicksand',
          textTheme: ThemeData.light().textTheme.copyWith(
            title:TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              ),
            button: TextStyle(
              color:Colors.white,
            ),
          ),
          appBarTheme: AppBarTheme(
            textTheme: ThemeData.light().textTheme.copyWith(
              title: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 20,
                fontWeight: FontWeight.bold, 
              ),
            )
          ),
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

class _MyHomePageState extends State<MyHomePage> {

  final dbHelper = DatabaseHelper.instance;
  
  
  final List<Transaction> _userTransactions =[
    // Transaction(
    //   id:'q1',
    //   title:'Quran New Memerize',
    //   time: 45,
    //   date:DateTime.now(),
    //   ),
    // Transaction(
    //   id:'q2',
    //   title:'Quran Old Memerize',
    //   time: 55,
    //   date:DateTime.now(),
    //   ),
  ];

  _MyHomePageState() {
    _query();
  }

  bool _showChart = false;

  List<Transaction> get _recentTransactions {
    return _userTransactions.where((tx) {
      return tx.date.isAfter(
        DateTime.now().subtract(
          Duration(days:7),
        ),
      );
    }).toList();
  }
  Future _addNewTransaction(String timeSpent,String time,DateTime chosenDate ) async {
    
    Map<String, dynamic> row = {

      DatabaseHelper.columnTitle : timeSpent,
      DatabaseHelper.columnTime  : int.parse(time),
      DatabaseHelper.columnDate : chosenDate.toString()
    };
    final id = await dbHelper.insert(row);
    if(id<=0){
      return;
    }
    final newTx = Transaction(
      title:timeSpent,
      time:double.parse(time),
      date:chosenDate,
      id:double.parse(id.toString()) //DateTime.now().toString()
    );

    setState(() {
      _userTransactions.add(newTx);
    });
  }
 void _startAddNewTransaction(BuildContext ctx) {
   showModalBottomSheet(
     context: ctx, 
     builder:(_){
      return NewTransaction(_addNewTransaction);
    },
  );
 }

  void _deleteTransaction(double id) {
    _delete(int.parse(id.truncate().toString()));
    
    setState(() {
      _userTransactions.removeWhere((tx){
        print(tx.id);
    print(id.truncate());
        return tx.id.truncate() == id.truncate();
      });
    });
  }

   @override
  Widget build(BuildContext context) {
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
            onTap: ()=>_startAddNewTransaction(context),
            )
        ],)
       )
       : AppBar(
        title:Text('Time Spending', style: TextStyle(fontFamily: 'Open Sans')),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.add),
            onPressed: ()=>_startAddNewTransaction(context),
          )
        ],
      );
    final txListWidget = Container(
              height: (mediaQuery.size.height - 
                appBar.preferredSize.height - 
                mediaQuery.padding.top)* 0.7,
              child: TransactionList(_userTransactions,_deleteTransaction));
      final pageBody =  SafeArea(child : SingleChildScrollView(
              child: Column(
          //mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if(isLandscape) Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
              Text('Show Chart', style: Theme.of(context).textTheme.title
                
              ),
              Switch.adaptive(
                activeColor: Theme.of(context).accentColor,
                value:_showChart,
                onChanged: (val) {
                  setState(() {
                    _showChart = val;
                  });
                } ,
                ),
            ],),
            if(!isLandscape) Container(
                height: (
                  mediaQuery.size.height - 
                  appBar.preferredSize.height - 
                  mediaQuery.padding.top)* 0.3,
                child: Chart(_recentTransactions),),
            if(!isLandscape) txListWidget,
            if(isLandscape)
            _showChart ? Container(
                height: (
                  mediaQuery.size.height - 
                  appBar.preferredSize.height - 
                  mediaQuery.padding.top)* 0.7,
                child: Chart(_recentTransactions),) 
            : txListWidget,
          ],
        ),
      ),
      );
    return Platform.isIOS ? CupertinoPageScaffold(child: pageBody, navigationBar: appBar,)     
     : Scaffold(
      appBar: appBar,
      body: pageBody, 
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Platform.isIOS 
      ? Container() : FloatingActionButton(
        child:Icon(Icons.add),
          onPressed: ()=>_startAddNewTransaction(context),
      ),
    );
  }






  
  // Button onPressed methods
  
  void _insert(Map<String,dynamic> row) async {
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
    final allRows = await dbHelper.queryAllRows();
    print('query all rows:');
    allRows.forEach((row) => print(row));

    allRows.forEach((row) {
      final newTx = Transaction(
      id:double.parse(row['_id'].toString()),
      title:row['title'],
      time:double.parse(row['time'].toString()), 
      date:DateTime.parse(row['date']),
      );

      setState(() {
        _userTransactions.add(newTx);
      });
     
    });

  }

  void _update() async {
    // row to update
    Map<String, dynamic> row = {
      DatabaseHelper.columnId   : 1,
      DatabaseHelper.columnTitle : 'Quran old revision',
      DatabaseHelper.columnTime  : 32,
      DatabaseHelper.columnDate : DateTime.now().toString()
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