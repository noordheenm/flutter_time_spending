import 'package:flutter/material.dart';

import '../models/transaction.dart';
import 'transaction_item.dart';

class TransactionList extends StatelessWidget {
  
  final List<Transaction> transactions;
  final Function deleteTx;
  TransactionList(this.transactions,this.deleteTx);
  
  @override
  Widget build(BuildContext context) {
    print('build() TransactionList');
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
                const SizedBox(height: 20,),
                Container(
                  height: constraints.maxHeight * 0.7,
                  child: Image.asset(
                    'assets/images/waiting.png',
                    fit:BoxFit.cover
                  )),
              ],); 
            })
            : ListView(
              children: transactions.map((tx) => TransactionItem(
                key: ValueKey(tx.id),
                transactions: tx, 
                deleteTx: deleteTx)).toList()
             );
            
      }
}

