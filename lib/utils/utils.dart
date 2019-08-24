import 'package:intl/intl.dart';

String getDateString([DateTime dateTime]) {
  if (dateTime == null) dateTime = DateTime.now();
  var formatter = DateFormat('yyyyMMdd');
  return formatter.format(dateTime);
}

DateTime getDateTimeFromString(String dateString) {
  try {
    int year = int.parse(dateString?.substring(0, 4));
    int month = int.parse(dateString?.substring(4,6));
    int day = int.parse(dateString?.substring(6,8));
    return DateTime(year, month, day, 12, 30, 30);
  } catch(e) {
    print("error when parsing dateString = $dateString");
    print(e);
    return DateTime.now();
  }
}

main () {
  DateTime dateTime = getDateTimeFromString("20190824");
  print(dateTime);
}