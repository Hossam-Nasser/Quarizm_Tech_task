import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../appointments/domain/usecases/book_appointment_usecase.dart';
import '../../../appointments/domain/usecases/is_time_slot_available_usecase.dart';
import '../../domain/entities/specialist_entity.dart';
import '../../domain/usecases/get_available_time_slots_usecase.dart';
import '../../domain/usecases/get_specialist_by_id_usecase.dart';
import 'specialist_details_state.dart';

@injectable
class SpecialistDetailsCubit extends Cubit<SpecialistDetailsState> {
  final GetSpecialistByIdUseCase _getSpecialistByIdUseCase;
  final GetAvailableTimeSlotsUseCase _getAvailableTimeSlotsUseCase;
  final BookAppointmentUseCase _bookAppointmentUseCase;
  
  SpecialistDetailsCubit(
    this._getSpecialistByIdUseCase,
    this._getAvailableTimeSlotsUseCase,
    this._bookAppointmentUseCase,
  ) : super(const SpecialistDetailsInitial());
  
  // Load specialist details
  Future<void> loadSpecialist(String specialistId) async {
    emit(const SpecialistDetailsLoading());
    
    final result = await _getSpecialistByIdUseCase(specialistId);
    
    result.fold(
      (failure) => emit(SpecialistDetailsError(failure.message)),
      (specialist) => emit(SpecialistDetailsLoaded(specialist)),
    );
  }
  
  // Set specialist directly (from navigation arguments)
  void setSpecialist(SpecialistEntity specialist) {
    emit(SpecialistDetailsLoaded(specialist));
  }
  
  // Select a date
  void selectDate(DateTime date) {
    final currentState = state;
    
    if (currentState is SpecialistDetailsLoaded) {
      // Create non-nullable reference
      final specialist = currentState.specialist;
      
      emit(SpecialistDetailsLoadingTimeSlots(
        specialist: specialist,
        selectedDate: date,
      ));
      
      _loadAvailableTimeSlots(specialist, date);
    } else if (currentState is SpecialistDetailsTimeSlotsLoaded) {
      // Create non-nullable reference
      final specialist = currentState.specialist;
      
      emit(SpecialistDetailsLoadingTimeSlots(
        specialist: specialist,
        selectedDate: date,
      ));
      
      _loadAvailableTimeSlots(specialist, date);
    } else if (currentState is SpecialistDetailsTimeSlotsError) {
      // Create non-nullable reference
      final specialist = currentState.specialist;
      
      emit(SpecialistDetailsLoadingTimeSlots(
        specialist: specialist,
        selectedDate: date,
      ));
      
      _loadAvailableTimeSlots(specialist, date);
    } else if (currentState is SpecialistDetailsBooking ||
               currentState is SpecialistDetailsBookingSuccess ||
               currentState is SpecialistDetailsBookingError) {
      // Extract specialist from any of these states
      final specialist = _getSpecialistFromState(currentState);
      if (specialist != null) {
        // Create non-nullable reference
        final nonNullSpecialist = specialist;
        
        emit(SpecialistDetailsLoadingTimeSlots(
          specialist: nonNullSpecialist,
          selectedDate: date,
        ));
        
        _loadAvailableTimeSlots(nonNullSpecialist, date);
      }
    }
  }
  
  // Helper to extract specialist from various states
  SpecialistEntity? _getSpecialistFromState(SpecialistDetailsState state) {
    if (state is SpecialistDetailsLoaded) {
      return state.specialist;
    } else if (state is SpecialistDetailsLoadingTimeSlots) {
      return state.specialist;
    } else if (state is SpecialistDetailsTimeSlotsLoaded) {
      return state.specialist;
    } else if (state is SpecialistDetailsTimeSlotsError) {
      return state.specialist;
    } else if (state is SpecialistDetailsBooking) {
      return state.specialist;
    } else if (state is SpecialistDetailsBookingSuccess) {
      return state.specialist;
    } else if (state is SpecialistDetailsBookingError) {
      return state.specialist;
    }
    return null;
  }
  
  // Load available time slots for a date
  void _loadAvailableTimeSlots(SpecialistEntity specialist, DateTime date) async {
    final result = await _getAvailableTimeSlotsUseCase(
      GetAvailableTimeSlotsParams(
        specialistId: specialist.id,
        date: date,
      ),
    );
    
    result.fold(
      (failure) => emit(SpecialistDetailsTimeSlotsError(
        specialist: specialist,
        selectedDate: date,
        message: failure.message,
      )),
      (timeSlots) => emit(SpecialistDetailsTimeSlotsLoaded(
        specialist: specialist,
        selectedDate: date,
        timeSlots: timeSlots,
      )),
    );
  }
  
  // Select a time slot
  void selectTimeSlot(DateTime timeSlot) {
    final currentState = state;
    
    if (currentState is SpecialistDetailsTimeSlotsLoaded) {
      // Create non-nullable references
      final specialist = currentState.specialist;
      final selectedDate = currentState.selectedDate;
      final timeSlots = currentState.timeSlots;
      
      emit(SpecialistDetailsTimeSlotsLoaded(
        specialist: specialist,
        selectedDate: selectedDate,
        timeSlots: timeSlots,
        selectedTimeSlot: timeSlot,
      ));
    }
  }
  
  // Book appointment
  Future<void> bookAppointment() async {
    final currentState = state;
    DateTime? selectedTimeSlot;
    SpecialistEntity? specialist;
    List<DateTime>? timeSlots;
    DateTime? selectedDate;
    
    if (currentState is SpecialistDetailsTimeSlotsLoaded) {
      selectedTimeSlot = currentState.selectedTimeSlot;
      specialist = currentState.specialist;
      timeSlots = currentState.timeSlots;
      selectedDate = currentState.selectedDate;
    }
    
    if (specialist == null || selectedTimeSlot == null || selectedDate == null || timeSlots == null) {
      emit(const SpecialistDetailsError('Please select a specialist and time slot'));
      return;
    }
    
    // Now we know all required variables are non-null, so we can safely use them
    final nonNullSpecialist = specialist;
    final nonNullSelectedDate = selectedDate;
    final nonNullTimeSlots = timeSlots;
    final nonNullSelectedTimeSlot = selectedTimeSlot;
    
    emit(SpecialistDetailsBooking(
      specialist: nonNullSpecialist,
      selectedDate: nonNullSelectedDate,
      timeSlots: nonNullTimeSlots,
      selectedTimeSlot: nonNullSelectedTimeSlot,
    ));
    
    final result = await _bookAppointmentUseCase(
      BookAppointmentParams(
        specialistId: nonNullSpecialist.id,
        appointmentDateTime: nonNullSelectedTimeSlot,
      ),
    );
    
    result.fold(
      (failure) => emit(SpecialistDetailsBookingError(
        specialist: nonNullSpecialist,
        selectedDate: nonNullSelectedDate,
        timeSlots: nonNullTimeSlots,
        selectedTimeSlot: nonNullSelectedTimeSlot,
        message: failure.message,
      )),
      (appointment) => emit(SpecialistDetailsBookingSuccess(
        specialist: nonNullSpecialist,
        selectedDate: nonNullSelectedDate,
        timeSlots: nonNullTimeSlots,
        selectedTimeSlot: nonNullSelectedTimeSlot,
      )),
    );
  }
  
  // Reset booking state (after success or error)
  void resetBookingState() {
    final currentState = state;
    
    if (currentState is SpecialistDetailsBookingSuccess || 
        currentState is SpecialistDetailsBookingError) {
      final specialist = _getSpecialistFromState(currentState);
      DateTime? selectedDate;
      List<DateTime>? timeSlots;
      DateTime? selectedTimeSlot;
      
      if (currentState is SpecialistDetailsBookingSuccess) {
        selectedDate = (currentState as SpecialistDetailsBookingSuccess).selectedDate;
        timeSlots = (currentState as SpecialistDetailsBookingSuccess).timeSlots;
        selectedTimeSlot = (currentState as SpecialistDetailsBookingSuccess).selectedTimeSlot;
      } else if (currentState is SpecialistDetailsBookingError) {
        selectedDate = (currentState as SpecialistDetailsBookingError).selectedDate;
        timeSlots = (currentState as SpecialistDetailsBookingError).timeSlots;
        selectedTimeSlot = (currentState as SpecialistDetailsBookingError).selectedTimeSlot;
      }
      
      if (specialist != null && selectedDate != null && timeSlots != null) {
        // Create non-nullable references since we've checked they're not null
        final nonNullSpecialist = specialist;
        final nonNullSelectedDate = selectedDate;
        final nonNullTimeSlots = timeSlots;
        
        emit(SpecialistDetailsTimeSlotsLoaded(
          specialist: nonNullSpecialist,
          selectedDate: nonNullSelectedDate,
          timeSlots: nonNullTimeSlots,
          selectedTimeSlot: selectedTimeSlot,
        ));
      } else if (specialist != null) {
        // Create non-nullable reference
        final nonNullSpecialist = specialist;
        emit(SpecialistDetailsLoaded(nonNullSpecialist));
      }
    }
  }
}
