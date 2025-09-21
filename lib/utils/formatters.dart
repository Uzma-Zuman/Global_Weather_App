import 'package:intl/intl.dart';

String celsius(double c) => '${c.toStringAsFixed(1)}°C';

String titleCase(String s) {
  if (s.isEmpty) return s;
  return s
      .split(' ')
      .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
      .join(' ');
}

String dayFromEpoch(int epoch) {
  final dt = DateTime.fromMillisecondsSinceEpoch(epoch * 1000);
  return DateFormat('EEE').format(dt); // Mon, Tue, Wed
}

String fullDateFromEpoch(int epoch) {
  final dt = DateTime.fromMillisecondsSinceEpoch(epoch * 1000);
  return DateFormat('EEEE, d MMMM').format(dt); // Monday, 21 September
}

String timeFromEpoch(int epoch) {
  final dt = DateTime.fromMillisecondsSinceEpoch(epoch * 1000);
  return DateFormat.Hm().format(dt); // HH:mm
}
