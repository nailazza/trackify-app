// lib/utils/format.dart
import 'package:intl/intl.dart';

class F {
  static String time(DateTime t) => DateFormat.Hm().format(t);
  static String date(DateTime t) => DateFormat('dd MMM yyyy').format(t);
  static String datetime(DateTime t) => DateFormat('dd MMM yyyy HH:mm').format(t);

  static String duration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    if (h == 0) return "$m min";
    if (m == 0) return "${h}h";
    return "${h}h ${m}m";
  }
}
