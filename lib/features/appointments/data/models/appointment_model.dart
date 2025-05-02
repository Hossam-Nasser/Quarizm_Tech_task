import '../../domain/entities/appointment_entity.dart';

class AppointmentModel extends AppointmentEntity {
  const AppointmentModel({
    required super.id,
    required super.userId,
    required super.specialistId,
    required super.appointmentDateTime,
    required super.endDateTime,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    required super.specialistName,
    required super.specialization,
    super.specialistImageUrl,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      specialistId: json['specialistId'] as String,
      appointmentDateTime: DateTime.parse(json['appointmentDateTime'] as String),
      endDateTime: DateTime.parse(json['endDateTime'] as String),
      status: _mapStringToAppointmentStatus(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      specialistName: json['specialistName'] as String,
      specialization: json['specialization'] as String,
      specialistImageUrl: json['specialistImageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'specialistId': specialistId,
      'appointmentDateTime': appointmentDateTime.toIso8601String(),
      'endDateTime': endDateTime.toIso8601String(),
      'status': _mapAppointmentStatusToString(status),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'specialistName': specialistName,
      'specialization': specialization,
      'specialistImageUrl': specialistImageUrl,
    };
  }

  factory AppointmentModel.fromEntity(AppointmentEntity entity) {
    return AppointmentModel(
      id: entity.id,
      userId: entity.userId,
      specialistId: entity.specialistId,
      appointmentDateTime: entity.appointmentDateTime,
      endDateTime: entity.endDateTime,
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      specialistName: entity.specialistName,
      specialization: entity.specialization,
      specialistImageUrl: entity.specialistImageUrl,
    );
  }

  static AppointmentStatus _mapStringToAppointmentStatus(String status) {
    switch (status) {
      case 'scheduled':
        return AppointmentStatus.scheduled;
      case 'completed':
        return AppointmentStatus.completed;
      case 'cancelled':
        return AppointmentStatus.cancelled;
      case 'rescheduled':
        return AppointmentStatus.rescheduled;
      default:
        return AppointmentStatus.scheduled;
    }
  }

  static String _mapAppointmentStatusToString(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return 'scheduled';
      case AppointmentStatus.completed:
        return 'completed';
      case AppointmentStatus.cancelled:
        return 'cancelled';
      case AppointmentStatus.rescheduled:
        return 'rescheduled';
    }
  }
}
