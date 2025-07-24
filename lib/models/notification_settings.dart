class NotificationSettings {
  final bool isEnabled;
  final List<int> reminderTimes; // Hours in 24-hour format
  final int frequency; // Times per day
  final bool randomOrder;

  NotificationSettings({
    this.isEnabled = true,
    this.reminderTimes = const [9, 15, 21], // 9 AM, 3 PM, 9 PM
    this.frequency = 3,
    this.randomOrder = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'isEnabled': isEnabled ? 1 : 0,
      'reminderTimes': reminderTimes.join(','),
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
          .map<int>((e) => int.parse(e))
          .toList(),
      frequency: map['frequency'],
      randomOrder: map['randomOrder'] == 1,
    );
  }

  NotificationSettings copyWith({
    bool? isEnabled,
    List<int>? reminderTimes,
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
