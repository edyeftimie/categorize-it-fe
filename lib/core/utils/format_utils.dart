import 'package:intl/intl.dart';

final _ron     = NumberFormat('#,##0', 'en_US');
final _ronDec  = NumberFormat('#,##0.##', 'en_US');
final _dateShort = DateFormat('MMM d');
final _monthYear = DateFormat('MMMM yyyy');

String formatRon(double amount)       => '${_ron.format(amount)} RON';
String formatRonDec(double amount)    => '${_ronDec.format(amount)} RON';
String formatMonthYear(DateTime date) => _monthYear.format(date);

String formatGroupDate(DateTime date) {
  final now  = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final d     = DateTime(date.year, date.month, date.day);
  final diff  = today.difference(d).inDays;
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Yesterday';
  return _dateShort.format(date);
}

String formatShortDate(DateTime date) => _dateShort.format(date);