import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/appointment_entity.dart';
import '../../domain/usecases/cancel_appointment_usecase.dart';
import '../../domain/usecases/get_user_appointments_usecase.dart';
import '../../domain/usecases/get_user_past_appointments_usecase.dart';
import '../../domain/usecases/get_user_upcoming_appointments_usecase.dart';
import '../../domain/usecases/reschedule_appointment_usecase.dart';
import 'appointments_state.dart';

@injectable
class AppointmentsCubit extends Cubit<AppointmentsState> {
  final GetUserAppointmentsUseCase _getUserAppointmentsUseCase;
  final GetUserUpcomingAppointmentsUseCase _getUserUpcomingAppointmentsUseCase;
  final GetUserPastAppointmentsUseCase _getUserPastAppointmentsUseCase;
  final CancelAppointmentUseCase _cancelAppointmentUseCase;
  final RescheduleAppointmentUseCase _rescheduleAppointmentUseCase;
  
  AppointmentsCubit(
    this._getUserAppointmentsUseCase,
    this._getUserUpcomingAppointmentsUseCase,
    this._getUserPastAppointmentsUseCase,
    this._cancelAppointmentUseCase,
    this._rescheduleAppointmentUseCase,
  ) : super(AppointmentsInitial());
  
  // Load all user appointments
  Future<void> loadAppointments() async {
    emit(AppointmentsLoading());
    
    final result = await _getUserAppointmentsUseCase();
    
    result.fold(
      (failure) => emit(AppointmentsError(failure.message)),
      (appointments) => appointments.isEmpty
          ? emit(AppointmentsEmpty())
          : emit(AppointmentsLoaded(appointments)),
    );
  }
  
  // Load only upcoming appointments
  Future<void> loadUpcomingAppointments() async {
    emit(AppointmentsLoading());
    
    final result = await _getUserUpcomingAppointmentsUseCase();
    
    result.fold(
      (failure) => emit(AppointmentsError(failure.message)),
      (appointments) => appointments.isEmpty
          ? emit(AppointmentsEmpty())
          : emit(AppointmentsLoaded(appointments)),
    );
  }
  
  // Load only past appointments
  Future<void> loadPastAppointments() async {
    emit(AppointmentsLoading());
    
    final result = await _getUserPastAppointmentsUseCase();
    
    result.fold(
      (failure) => emit(AppointmentsError(failure.message)),
      (appointments) => appointments.isEmpty
          ? emit(AppointmentsEmpty())
          : emit(AppointmentsLoaded(appointments)),
    );
  }
  
  // Cancel an appointment
  Future<void> cancelAppointment(String appointmentId) async {
    final currentState = state;
    if (currentState is AppointmentsLoaded) {
      emit(AppointmentsCancelling(currentState.appointments, appointmentId));
      
      final result = await _cancelAppointmentUseCase(appointmentId);
      
      result.fold(
        (failure) => emit(AppointmentsCancelError(
          currentState.appointments,
          failure.message,
        )),
        (_) {
          // Remove the cancelled appointment from the list
          final updatedAppointments = currentState.appointments
              .map((appointment) => appointment.id == appointmentId
                  ? appointment.copyWith(status: AppointmentStatus.cancelled)
                  : appointment)
              .toList();
          
          emit(updatedAppointments.isEmpty
              ? AppointmentsEmpty()
              : AppointmentsCancelled(updatedAppointments));
        },
      );
    }
  }
  
  // Reschedule an appointment
  Future<void> rescheduleAppointment({
    required String appointmentId,
    required DateTime newDateTime,
  }) async {
    final currentState = state;
    if (currentState is AppointmentsLoaded) {
      emit(AppointmentsRescheduling(currentState.appointments, appointmentId));
      
      final result = await _rescheduleAppointmentUseCase(
        appointmentId: appointmentId,
        newDateTime: newDateTime,
      );
      
      result.fold(
        (failure) => emit(AppointmentsRescheduleError(
          currentState.appointments,
          failure.message,
        )),
        (rescheduledAppointment) {
          // Update the rescheduled appointment in the list
          final updatedAppointments = currentState.appointments
              .map((appointment) => appointment.id == appointmentId
                  ? rescheduledAppointment
                  : appointment)
              .toList();
          
          emit(AppointmentsRescheduled(updatedAppointments));
        },
      );
    }
  }
  
  // Reset action state (after cancel/reschedule success or error)
  void resetActionState() {
    final currentState = state;
    if (currentState is AppointmentsCancelled ||
        currentState is AppointmentsCancelError ||
        currentState is AppointmentsRescheduled ||
        currentState is AppointmentsRescheduleError) {
      if (currentState is AppointmentsCancelled) {
        emit(AppointmentsLoaded(currentState.appointments));
      } else if (currentState is AppointmentsCancelError) {
        emit(AppointmentsLoaded(currentState.appointments));
      } else if (currentState is AppointmentsRescheduled) {
        emit(AppointmentsLoaded(currentState.appointments));
      } else if (currentState is AppointmentsRescheduleError) {
        emit(AppointmentsLoaded(currentState.appointments));
      }
    }
  }
}
