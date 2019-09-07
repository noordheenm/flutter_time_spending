import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NewContact extends StatefulWidget {
  final Function addTx;

  NewContact(this.addTx) {
    print('Constructor NewContact');
  }

  @override
  _NewContactState createState() {
    print('Create NewContact');
    return _NewContactState();
  }
}

class _NewContactState extends State<NewContact> {
  final _studentCtrl = TextEditingController();
 

_NewContactState() {
  print("Constructor NewContact State");
}
  @override
  void initState() {
     print("initState NewContact State");
    super.initState();
  }

  @override
  void didUpdateWidget(NewContact oldWidget) {
     print("didUpdateWidget NewContact State");
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    print("dispose NewContact State");
    super.dispose();
  }
  void _submitData() {

  
    final enteredName = _studentCtrl.text;
  

    if(enteredName.isEmpty ) {
      return;
    }
    widget.addTx(
      enteredName
    );     
    Navigator.of(context).pop();       
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
                        labelText: 'New Student/Children'
                      ),
                      controller: _studentCtrl,
                      onSubmitted: (_)=>_submitData,
                      //onChanged: (val) {
                       // timeSpent=val;
                      //}
                    ),
                    RaisedButton(
                      child:Text('Add Student/Child'),
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