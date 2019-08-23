import 'package:flutter/foundation.dart';

class Transaction {
  final double id;
  final String title;
  final double time;
  final DateTime date;

  Transaction({
    @required this.id, 
    @required this.title,
    @required this.time, 
    @required this.date});
}
