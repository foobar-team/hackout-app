
import 'package:intl/intl.dart';
class DateFormatter {
  DateFormatter();
  // AppLocalizations localizations;
  String getVerboseDateTimeRepresentation(DateTime dateTime) {
    DateTime now = DateTime.now();
    DateTime justNow = now.subtract(Duration(minutes: 1));
    DateTime localDateTime = dateTime.toLocal();
    if (!localDateTime.difference(justNow).isNegative) {
      return 'Just now';
    }
    String roughTimeString = DateFormat('jm').format(dateTime);
    if (localDateTime.day == now.day && localDateTime.month == now.month && localDateTime.year == now.year) {
      return roughTimeString;
    }
    DateTime yesterday = now.subtract(Duration(days: 1));
    if (localDateTime.day == yesterday.day && localDateTime.month == now.month && localDateTime.year == now.year) {
      return 'Yesterday, ' + roughTimeString;
    }
    if (now.difference(localDateTime).inDays < 4) {
      String weekday = DateFormat('EEEE').format(localDateTime);
      return '$weekday, $roughTimeString';
    }
    return '${DateFormat('yMd').format(dateTime)}, $roughTimeString';
  }
}