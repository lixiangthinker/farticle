import 'package:intl/intl.dart';

String getDateString([DateTime dateTime]) {
  if (dateTime == null) dateTime = DateTime.now();
  var formatter = DateFormat('yyyyMMdd');
  return formatter.format(dateTime);
}