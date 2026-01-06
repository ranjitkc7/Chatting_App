import 'package:flutter/material.dart';

class DateUtil {
  /// Converts a timestamp string (milliseconds since epoch) to a formatted local time like "10:45 AM"
  static String getFormattedTime({
    required BuildContext context,
    required String time,
  }) {
    // 1️⃣ Convert the timestamp string to int (milliseconds)
    int timestamp = int.tryParse(time) ?? 0;

    // 2️⃣ Convert milliseconds to DateTime
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);

    // 3️⃣ Convert DateTime to TimeOfDay
    final timeOfDay = TimeOfDay.fromDateTime(date);

    // 4️⃣ Format the time according to device locale with AM/PM
    return MaterialLocalizations.of(context).formatTimeOfDay(
      timeOfDay,
      alwaysUse24HourFormat: false, // false = use AM/PM
    );
  }
}
