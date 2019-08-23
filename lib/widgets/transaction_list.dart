import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';

class TransactionList extends StatelessWidget {
  
  final List<Transaction> transactions;
  final Function deleteTx;
  TransactionList(this.transactions,this.deleteTx);
  
  @override
  Widget build(BuildContext context) {
    return transactions.isEmpty
      ?
      LayoutBuilder(builder: (ctx, constraints) {
         
            return Column(
              //mainAxisAlignment: MainAxisAlignment.center,
              //crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  'No transactions added yet!', 
                  style: Theme.of(context).textTheme.title,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20,),
                Container(
                  height: constraints.maxHeight * 0.7,
                  child: Image.asset(
                    'assets/images/waiting.png',
                    fit:BoxFit.cover
                  )),
              ],); 
            })
            : ListView.builder(
            itemBuilder: (ctx,index) {
              return Card(
                elevation: 5,
                margin: EdgeInsets.symmetric(vertical:8, horizontal: 5),
                child: ListTile(
                  leading: CircleAvatar(
                    radius:30,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FittedBox(
                        child: Text('${transactions[index].time} mins'),
                        ),
                    ),
                  ),
                  title: Text(
                    transactions[index].title,
                    style: Theme.of(context).textTheme.title
                    ),
                  subtitle: Text(DateFormat.yMMMd().format(transactions[index].date),
                  ),
                  trailing: MediaQuery.of(context).size.width > 460 
                  ? FlatButton.icon(
                     icon: Icon(Icons.delete),
                     label: Text('Delete'),
                     textColor: Theme.of(context).errorColor, 
                     onPressed: () { 
                        print('------------------------'+transactions[index].id.toString());
                        deleteTx(transactions[index].id); 
                      },
                    ) 
                  : IconButton(
                    icon: Icon(Icons.delete), 
                    color: Theme.of(context).errorColor,
                    onPressed: () { 
                      print('------------------------'+transactions[index].id.toString());
                      deleteTx(transactions[index].id); 
                    },
                  ),
                ),
              );
            },
              itemCount:transactions.length,
        );
      }
}