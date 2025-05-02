import 'package:equatable/equatable.dart';

enum AppointmentStatus {
  scheduled,
  completed,
  cancelled,
  rescheduled,
}

class AppointmentEntity extends Equatable {
  final String id;
  final String userId;
  final String specialistId;
  final DateTime appointmentDateTime;
  final DateTime endDateTime;
  final AppointmentStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Specialist info (denormalized for convenience)
  final String specialistName;
  final String specialization;
  final String? specialistImageUrl;

  const AppointmentEntity({
    required this.id,
    required this.userId,
    required this.specialistId,
    required this.appointmentDateTime,
    required this.endDateTime,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.specialistName,
    required this.specialization,
    this.specialistImageUrl,
  });

  bool get isCompleted => status == AppointmentStatus.completed;
  bool get isCancelled => status == AppointmentStatus.cancelled;
  bool get isRescheduled => status == AppointmentStatus.rescheduled;
  bool get isScheduled => status == AppointmentStatus.scheduled;

  bool get isPast => appointmentDateTime.isBefore(DateTime.now());
  bool get isUpcoming => !isPast && isScheduled;

  @override
  List<Object?> get props => [
        id,
        userId,
        specialistId,
        appointmentDateTime,
        endDateTime,
        status,
        createdAt,
        updatedAt,
        specialistName,
        specialization,
        specialistImageUrl,
      ];
      
  AppointmentEntity copyWith({
    String? id,
    String? userId,
    String? specialistId,
    DateTime? appointmentDateTime,
    DateTime? endDateTime,
    AppointmentStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? specialistName,
    String? specialization,
    String? specialistImageUrl,
  }) {
    return AppointmentEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      specialistId: specialistId ?? this.specialistId,
      appointmentDateTime: appointmentDateTime ?? this.appointmentDateTime,
      endDateTime: endDateTime ?? this.endDateTime,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      specialistName: specialistName ?? this.specialistName,
      specialization: specialization ?? this.specialization,
      specialistImageUrl: specialistImageUrl ?? this.specialistImageUrl,
    );
  }
}
