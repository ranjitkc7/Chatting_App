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

  static String getLastActiveTime({
    required BuildContext context,
    required DateTime lastActive,
  }) {
    final now = DateTime.now();
    final difference = now.difference(lastActive);

    if (difference.inSeconds < 60) return "Just now";
    if (difference.inMinutes < 60) return "${difference.inMinutes} min ago";
    if (difference.inHours < 24) return "${difference.inHours} hours ago";
    if (difference.inDays < 7) return "${difference.inDays} days ago";

    return "${lastActive.day}/${lastActive.month}/${lastActive.year}";
  }
}
