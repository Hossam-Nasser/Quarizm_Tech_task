import 'package:equatable/equatable.dart';

class WorkingHour {
  final int dayOfWeek; // 1 = Monday, 2 = Tuesday, etc.
  final DateTime from; // Start time
  final DateTime to; // End time
  final bool isWorkingDay;

  WorkingHour({
    required this.dayOfWeek,
    required this.from,
    required this.to,
    this.isWorkingDay = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'dayOfWeek': dayOfWeek,
      'from': from.toIso8601String(),
      'to': to.toIso8601String(),
      'isWorkingDay': isWorkingDay,
    };
  }

  factory WorkingHour.fromMap(Map<String, dynamic> map) {
    return WorkingHour(
      dayOfWeek: map['dayOfWeek'] as int,
      from: DateTime.parse(map['from'] as String),
      to: DateTime.parse(map['to'] as String),
      isWorkingDay: map['isWorkingDay'] as bool,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkingHour &&
        other.dayOfWeek == dayOfWeek &&
        other.from == from &&
        other.to == to &&
        other.isWorkingDay == isWorkingDay;
  }

  @override
  int get hashCode => dayOfWeek.hashCode ^ from.hashCode ^ to.hashCode ^ isWorkingDay.hashCode;
}

class SpecialistEntity extends Equatable {
  final String id;
  final String name;
  final String specialization;
  final List<WorkingHour> workingHours;
  final String? bio;
  final String? imageUrl;
  final double rating;
  final int appointmentDurationMinutes;
  final double appointmentFee;
  final bool isAvailable;

  const SpecialistEntity({
    required this.id,
    required this.name,
    required this.specialization,
    required this.workingHours,
    this.bio,
    this.imageUrl,
    this.rating = 0.0,
    this.appointmentDurationMinutes = 30,
    this.appointmentFee = 0.0,
    this.isAvailable = true,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        specialization,
        workingHours,
        bio,
        imageUrl,
        rating,
        appointmentDurationMinutes,
        appointmentFee,
        isAvailable,
      ];
}
