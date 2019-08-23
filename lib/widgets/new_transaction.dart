import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/widgets/adaptive_flat_buttom.dart';
import 'package:intl/intl.dart';

class NewTransaction extends StatefulWidget {
  final Function addTx;

  NewTransaction(this.addTx);

  @override
  _NewTransactionState createState() => _NewTransactionState();
}

class _NewTransactionState extends State<NewTransaction> {
  final _timeSpentCtrl = TextEditingController();

  final _timeInMinuteCtrl = TextEditingController();
  DateTime _selectedDate;

  void _submitData() {

    if(_timeInMinuteCtrl.text.isEmpty){
      return;
    }
    final enteredTitle = _timeSpentCtrl.text;
    final enteredTime = _timeInMinuteCtrl.text;

    if(enteredTitle.isEmpty || enteredTime.isEmpty || _selectedDate == null ) {
      return;
    }
    widget.addTx(
      enteredTitle,
      enteredTime,
      _selectedDate
    );     
    Navigator.of(context).pop();       
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2019),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if(pickedDate == null) {
        return;
      }
      setState(() {
         _selectedDate = pickedDate;
      });
     
    });
  }
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
              elevation: 10,
              child: Container(
                padding: EdgeInsets.only(
                  top:10,
                  left:10,
                  right:10,
                  bottom: MediaQuery.of(context).viewInsets.bottom +10
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Time Spent for?'
                      ),
                      controller: _timeSpentCtrl,
                      onSubmitted: (_)=>_submitData,
                      //onChanged: (val) {
                       // timeSpent=val;
                      //}
                    ),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'How many minutes?'
                      ),
                      controller: _timeInMinuteCtrl,
                      keyboardType: TextInputType.number,
                      onSubmitted: (_)=>_submitData,
                      //onChanged: (val) => timeInMinutes = val,
                    ),
                    Container(
                      height: 70,
                      child: Row(children: <Widget>[
                        Expanded (
                          child: Text(
                            _selectedDate== null 
                            ? 'No Date Chosen!'
                            :'Picked Date: ${DateFormat.yMd().format( _selectedDate)}',
                          ),
                        ),
                        AdaptiveFlatButton('Choose Date',_presentDatePicker),
                       ],),
                    ),
                    RaisedButton(
                      child:Text('Add spending time'),
                      textColor: Theme.of(context).textTheme.button.color,
                      color:Theme.of(context).primaryColor,
                      onPressed:_submitData,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}