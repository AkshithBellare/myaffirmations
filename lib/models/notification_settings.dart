import 'package:flutter/material.dart';

class NotificationSettings {
  final bool isEnabled;
  final List<TimeOfDay> reminderTimes;
  final int frequency; // Times per day
  final bool randomOrder;

  NotificationSettings({
    this.isEnabled = true,
    this.reminderTimes = const [
      TimeOfDay(hour: 9, minute: 0),
      TimeOfDay(hour: 15, minute: 0),
      TimeOfDay(hour: 21, minute: 0)
    ], // 9 AM, 3 PM, 9 PM
    this.frequency = 3,
    this.randomOrder = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'isEnabled': isEnabled ? 1 : 0,
      'reminderTimes':
          reminderTimes.map((t) => '${t.hour}:${t.minute}').join(','),
      'frequency': frequency,
      'randomOrder': randomOrder ? 1 : 0,
    };
  }

  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    return NotificationSettings(
      isEnabled: map['isEnabled'] == 1,
      reminderTimes: map['reminderTimes']
          .toString()
          .split(',')
          .where((e) => e.isNotEmpty)
          .map<TimeOfDay>((e) {
        final parts = e.split(':');
        return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }).toList(),
      frequency: map['frequency'],
      randomOrder: map['randomOrder'] == 1,
    );
  }

  NotificationSettings copyWith({
    bool? isEnabled,
    List<TimeOfDay>? reminderTimes,
    int? frequency,
    bool? randomOrder,
  }) {
    return NotificationSettings(
      isEnabled: isEnabled ?? this.isEnabled,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      frequency: frequency ?? this.frequency,
      randomOrder: randomOrder ?? this.randomOrder,
    );
  }
}