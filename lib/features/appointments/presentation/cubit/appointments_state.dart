import 'package:equatable/equatable.dart';

import '../../domain/entities/appointment_entity.dart';

abstract class AppointmentsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AppointmentsInitial extends AppointmentsState {}

class AppointmentsLoading extends AppointmentsState {}

class AppointmentsLoaded extends AppointmentsState {
  final List<AppointmentEntity> appointments;
  
  AppointmentsLoaded(this.appointments);
  
  // Get upcoming appointments
  List<AppointmentEntity> get upcomingAppointments => appointments
      .where((appointment) => appointment.isUpcoming)
      .toList();

  // Get past appointments
  List<AppointmentEntity> get pastAppointments => appointments
      .where((appointment) => 
          appointment.isPast || 
          appointment.isCancelled || 
          appointment.isCompleted)
      .toList();
  
  @override
  List<Object?> get props => [appointments];
}

class AppointmentsEmpty extends AppointmentsState {}

class AppointmentsError extends AppointmentsState {
  final String message;
  
  AppointmentsError(this.message);
  
  @override
  List<Object?> get props => [message];
}

class AppointmentsCancelling extends AppointmentsState {
  final List<AppointmentEntity> appointments;
  final String appointmentIdInProgress;
  
  AppointmentsCancelling(this.appointments, this.appointmentIdInProgress);
  
  @override
  List<Object?> get props => [appointments, appointmentIdInProgress];
}

class AppointmentsCancelled extends AppointmentsState {
  final List<AppointmentEntity> appointments;
  
  AppointmentsCancelled(this.appointments);
  
  @override
  List<Object?> get props => [appointments];
}

class AppointmentsCancelError extends AppointmentsState {
  final List<AppointmentEntity> appointments;
  final String message;
  
  AppointmentsCancelError(this.appointments, this.message);
  
  @override
  List<Object?> get props => [appointments, message];
}

class AppointmentsRescheduling extends AppointmentsState {
  final List<AppointmentEntity> appointments;
  final String appointmentIdInProgress;
  
  AppointmentsRescheduling(this.appointments, this.appointmentIdInProgress);
  
  @override
  List<Object?> get props => [appointments, appointmentIdInProgress];
}

class AppointmentsRescheduled extends AppointmentsState {
  final List<AppointmentEntity> appointments;
  
  AppointmentsRescheduled(this.appointments);
  
  @override
  List<Object?> get props => [appointments];
}

class AppointmentsRescheduleError extends AppointmentsState {
  final List<AppointmentEntity> appointments;
  final String message;
  
  AppointmentsRescheduleError(this.appointments, this.message);
  
  @override
  List<Object?> get props => [appointments, message];
}
