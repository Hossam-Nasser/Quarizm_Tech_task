import '../models/appointment_model.dart';

abstract class AppointmentServices {
  Future<AppointmentModel> bookAppointment({
    required String specialistId,
    required DateTime appointmentDateTime,
  });
  Future<void> cancelAppointment(String appointmentId);
  Future<AppointmentModel> rescheduleAppointment({
    required String appointmentId,
    required DateTime newDateTime,
  });
  Future<List<AppointmentModel>> getUserAppointments();
  Future<List<AppointmentModel>> getUserUpcomingAppointments();
  Future<List<AppointmentModel>> getUserPastAppointments();
  Future<AppointmentModel> getAppointmentById(String id);
  Future<bool> isTimeSlotAvailable({
    required String specialistId,
    required DateTime dateTime,
  });
}
