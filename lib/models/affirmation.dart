import 'package:uuid/uuid.dart';

class Affirmation {
  final String id;
  final String text;
  final DateTime createdAt;
  final bool isActive;

  Affirmation({
    String? id,
    required this.text,
    DateTime? createdAt,
    this.isActive = true,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isActive': isActive ? 1 : 0,
    };
  }

  factory Affirmation.fromMap(Map<String, dynamic> map) {
    return Affirmation(
      id: map['id'],
      text: map['text'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      isActive: map['isActive'] == 1,
    );
  }

  Affirmation copyWith({
    String? id,
    String? text,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return Affirmation(
      id: id ?? this.id,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
