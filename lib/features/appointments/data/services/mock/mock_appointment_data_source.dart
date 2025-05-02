import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';



import '../../../../../core/error/exceptions.dart';
import '../../../../../core/util/constants/app_constants.dart';
import '../../../../auth/data/services/auth_services.dart';
import '../../../../specialists/data/services/specialist_services.dart';
import '../../../domain/entities/appointment_entity.dart';
import '../../models/appointment_model.dart';
import '../appointment_services.dart';

@LazySingleton(as: AppointmentServices)
class MockAppointmentDataSource implements AppointmentServices {
  final AuthServices _authDataSource;
  final SpecialistServices _specialistDataSource;

  // In-memory storage for mock appointments
  final Map<String, AppointmentModel> _appointments = {};
  final Uuid _uuid = const Uuid();

  MockAppointmentDataSource(this._authDataSource, this._specialistDataSource);

  @override
  Future<AppointmentModel> bookAppointment({
    required String specialistId,
    required DateTime appointmentDateTime,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Get current user
    final currentUser = await _authDataSource.getCurrentUser();
    if (currentUser == null) {
      throw AuthException(
        message: 'You must be logged in to book an appointment',
      );
    }

    // Check if time slot is available
    final isAvailable = await isTimeSlotAvailable(
      specialistId: specialistId,
      dateTime: appointmentDateTime,
    );

    if (!isAvailable) {
      throw AppointmentAlreadyBookedException(
        message: 'This time slot is already booked',
      );
    }

    // Get specialist details
    final specialist = await _specialistDataSource.getSpecialistById(specialistId);

    // Create new appointment
    final now = DateTime.now();
    final id = _uuid.v4();

    // Calculate end time based on specialist appointment duration
    final endDateTime = appointmentDateTime.add(
      Duration(minutes: specialist.appointmentDurationMinutes),
    );

    final appointment = AppointmentModel(
      id: id,
      userId: currentUser.id,
      specialistId: specialistId,
      appointmentDateTime: appointmentDateTime,
      endDateTime: endDateTime,
      status: AppointmentStatus.scheduled,
      createdAt: now,
      updatedAt: now,
      specialistName: specialist.name,
      specialization: specialist.specialization,
      specialistImageUrl: specialist.imageUrl,
    );

    // Save appointment to in-memory storage
    _appointments[id] = appointment;

    // Book the time slot in specialist data source
    await _specialistDataSource.bookTimeSlot(
      specialistId: specialistId,
      dateTime: appointmentDateTime,
    );

    return appointment;
  }

  @override
  Future<void> cancelAppointment(String appointmentId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Get current user
    final currentUser = await _authDataSource.getCurrentUser();
    if (currentUser == null) {
      throw AuthException(
        message: 'You must be logged in to cancel an appointment',
      );
    }

    // Find appointment
    final appointment = _appointments[appointmentId];
    if (appointment == null) {
      throw DocumentNotFoundException(
        message: 'Appointment not found',
      );
    }

    // Check if appointment belongs to the current user
    if (appointment.userId != currentUser.id) {
      throw PermissionDeniedException(
        message: 'You do not have permission to cancel this appointment',
      );
    }

    // Check if appointment is in the past
    if (appointment.appointmentDateTime.isBefore(DateTime.now())) {
      throw AppointmentCancellationException(
        message: 'Cannot cancel past appointments',
      );
    }

    // Check if appointment is too close to its scheduled time
    final hoursUntilAppointment = appointment.appointmentDateTime
        .difference(DateTime.now())
        .inHours;

    if (hoursUntilAppointment < AppConstants.cancellationThresholdHours) {
      throw AppointmentCancellationException(
        message: 'Appointments can only be cancelled at least ${AppConstants.cancellationThresholdHours} hours in advance',
      );
    }

    // Update appointment status
    final updatedAppointment = AppointmentModel(
      id: appointment.id,
      userId: appointment.userId,
      specialistId: appointment.specialistId,
      appointmentDateTime: appointment.appointmentDateTime,
      endDateTime: appointment.endDateTime,
      status: AppointmentStatus.cancelled,
      createdAt: appointment.createdAt,
      updatedAt: DateTime.now(),
      specialistName: appointment.specialistName,
      specialization: appointment.specialization,
      specialistImageUrl: appointment.specialistImageUrl,
    );

    // Save updated appointment
    _appointments[appointmentId] = updatedAppointment;

    // Free up the time slot
    await _specialistDataSource.cancelTimeSlot(
      specialistId: appointment.specialistId,
      dateTime: appointment.appointmentDateTime,
    );
  }

  @override
  Future<AppointmentModel> rescheduleAppointment({
    required String appointmentId,
    required DateTime newDateTime,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Get current user
    final currentUser = await _authDataSource.getCurrentUser();
    if (currentUser == null) {
      throw AuthException(
        message: 'You must be logged in to reschedule an appointment',
      );
    }

    // Find appointment
    final appointment = _appointments[appointmentId];
    if (appointment == null) {
      throw DocumentNotFoundException(
        message: 'Appointment not found',
      );
    }

    // Check if appointment belongs to the current user
    if (appointment.userId != currentUser.id) {
      throw PermissionDeniedException(
        message: 'You do not have permission to reschedule this appointment',
      );
    }

    // Check if appointment is in the past
    if (appointment.appointmentDateTime.isBefore(DateTime.now())) {
      throw AppointmentReschedulingException(
        message: 'Cannot reschedule past appointments',
      );
    }

    // Check if appointment is too close to its scheduled time
    final hoursUntilAppointment = appointment.appointmentDateTime
        .difference(DateTime.now())
        .inHours;

    if (hoursUntilAppointment < AppConstants.cancellationThresholdHours) {
      throw AppointmentReschedulingException(
        message: 'Appointments can only be rescheduled at least ${AppConstants.cancellationThresholdHours} hours in advance',
      );
    }

    // Check if new time slot is available
    final isAvailable = await isTimeSlotAvailable(
      specialistId: appointment.specialistId,
      dateTime: newDateTime,
    );

    if (!isAvailable) {
      throw AppointmentAlreadyBookedException(
        message: 'The requested time slot is not available',
      );
    }

    // Get specialist details to calculate new end time
    final specialist = await _specialistDataSource.getSpecialistById(
      appointment.specialistId,
    );

    // Calculate new end time
    final newEndDateTime = newDateTime.add(
      Duration(minutes: specialist.appointmentDurationMinutes),
    );

    // Update appointment
    final updatedAppointment = AppointmentModel(
      id: appointment.id,
      userId: appointment.userId,
      specialistId: appointment.specialistId,
      appointmentDateTime: newDateTime,
      endDateTime: newEndDateTime,
      status: AppointmentStatus.rescheduled,
      createdAt: appointment.createdAt,
      updatedAt: DateTime.now(),
      specialistName: appointment.specialistName,
      specialization: appointment.specialization,
      specialistImageUrl: appointment.specialistImageUrl,
    );

    // Save updated appointment
    _appointments[appointmentId] = updatedAppointment;

    // Free up the old time slot
    await _specialistDataSource.cancelTimeSlot(
      specialistId: appointment.specialistId,
      dateTime: appointment.appointmentDateTime,
    );

    // Book the new time slot
    await _specialistDataSource.bookTimeSlot(
      specialistId: appointment.specialistId,
      dateTime: newDateTime,
    );

    return updatedAppointment;
  }

  @override
  Future<List<AppointmentModel>> getUserAppointments() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Get current user
    final currentUser = await _authDataSource.getCurrentUser();
    if (currentUser == null) {
      throw AuthException(
        message: 'You must be logged in to view your appointments',
      );
    }

    // Filter appointments by user
    return _appointments.values
        .where((appointment) => appointment.userId == currentUser.id)
        .toList();
  }

  @override
  Future<List<AppointmentModel>> getUserUpcomingAppointments() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Get all user appointments
    final allAppointments = await getUserAppointments();

    // Filter to get only upcoming and scheduled appointments
    final now = DateTime.now();
    return allAppointments
        .where((appointment) =>
            appointment.appointmentDateTime.isAfter(now) &&
            appointment.status == AppointmentStatus.scheduled)
        .toList();
  }

  @override
  Future<List<AppointmentModel>> getUserPastAppointments() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Get all user appointments
    final allAppointments = await getUserAppointments();

    // Filter to get only past appointments
    final now = DateTime.now();
    return allAppointments
        .where((appointment) =>
            appointment.appointmentDateTime.isBefore(now) ||
            appointment.status == AppointmentStatus.completed ||
            appointment.status == AppointmentStatus.cancelled)
        .toList();
  }

  @override
  Future<AppointmentModel> getAppointmentById(String id) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Get current user
    final currentUser = await _authDataSource.getCurrentUser();
    if (currentUser == null) {
      throw AuthException(
        message: 'You must be logged in to view appointment details',
      );
    }

    // Find appointment
    final appointment = _appointments[id];
    if (appointment == null) {
      throw DocumentNotFoundException(
        message: 'Appointment not found',
      );
    }

    // Check if appointment belongs to the current user
    if (appointment.userId != currentUser.id) {
      throw PermissionDeniedException(
        message: 'You do not have permission to view this appointment',
      );
    }

    return appointment;
  }

  @override
  Future<bool> isTimeSlotAvailable({
    required String specialistId,
    required DateTime dateTime,
  }) async {
    try {
      // Get available time slots for the day
      final availableSlots = await _specialistDataSource.getAvailableTimeSlots(
        specialistId: specialistId,
        date: DateTime(dateTime.year, dateTime.month, dateTime.day),
      );

      // Check if the requested time is in the available slots
      return availableSlots.any((slot) =>
          slot.year == dateTime.year &&
          slot.month == dateTime.month &&
          slot.day == dateTime.day &&
          slot.hour == dateTime.hour &&
          slot.minute == dateTime.minute);
    } catch (e) {
      return false;
    }
  }
}
