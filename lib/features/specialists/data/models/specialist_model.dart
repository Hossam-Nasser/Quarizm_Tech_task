import '../../domain/entities/specialist_entity.dart';

class SpecialistModel extends SpecialistEntity {
  const SpecialistModel({
    required super.id,
    required super.name,
    required super.specialization,
    required super.workingHours,
    super.bio,
    super.imageUrl,
    super.rating,
    super.appointmentDurationMinutes,
    super.appointmentFee,
    super.isAvailable,
  });

  factory SpecialistModel.fromJson(Map<String, dynamic> json) {
    return SpecialistModel(
      id: json['id'] as String,
      name: json['name'] as String,
      specialization: json['specialization'] as String,
      workingHours: (json['workingHours'] as List)
          .map((hour) => WorkingHour.fromMap(hour as Map<String, dynamic>))
          .toList(),
      bio: json['bio'] as String?,
      imageUrl: json['imageUrl'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      appointmentDurationMinutes: json['appointmentDurationMinutes'] as int? ?? 30,
      appointmentFee: (json['appointmentFee'] as num?)?.toDouble() ?? 0.0,
      isAvailable: json['isAvailable'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialization': specialization,
      'workingHours': workingHours.map((hour) => hour.toMap()).toList(),
      'bio': bio,
      'imageUrl': imageUrl,
      'rating': rating,
      'appointmentDurationMinutes': appointmentDurationMinutes,
      'appointmentFee': appointmentFee,
      'isAvailable': isAvailable,
    };
  }

  factory SpecialistModel.fromEntity(SpecialistEntity entity) {
    return SpecialistModel(
      id: entity.id,
      name: entity.name,
      specialization: entity.specialization,
      workingHours: entity.workingHours,
      bio: entity.bio,
      imageUrl: entity.imageUrl,
      rating: entity.rating,
      appointmentDurationMinutes: entity.appointmentDurationMinutes,
      appointmentFee: entity.appointmentFee,
      isAvailable: entity.isAvailable,
    );
  }
}
