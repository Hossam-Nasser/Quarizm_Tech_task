import 'package:equatable/equatable.dart';

import '../../domain/entities/specialist_entity.dart';

abstract class SpecialistDetailsState extends Equatable {
  const SpecialistDetailsState();
  
  @override
  List<Object?> get props => [];
}

class SpecialistDetailsInitial extends SpecialistDetailsState {
  const SpecialistDetailsInitial();
}

class SpecialistDetailsLoading extends SpecialistDetailsState {
  const SpecialistDetailsLoading();
}

class SpecialistDetailsLoaded extends SpecialistDetailsState {
  final SpecialistEntity specialist;

  const SpecialistDetailsLoaded(this.specialist);

  @override
  List<Object?> get props => [specialist];
}

class SpecialistDetailsError extends SpecialistDetailsState {
  final String message;

  const SpecialistDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}

class SpecialistDetailsLoadingTimeSlots extends SpecialistDetailsState {
  final SpecialistEntity specialist;
  final DateTime selectedDate;

  const SpecialistDetailsLoadingTimeSlots({
    required this.specialist,
    required this.selectedDate,
  });

  @override
  List<Object?> get props => [specialist, selectedDate];
}

class SpecialistDetailsTimeSlotsLoaded extends SpecialistDetailsState {
  final SpecialistEntity specialist;
  final DateTime selectedDate;
  final List<DateTime> timeSlots;
  final DateTime? selectedTimeSlot;

  const SpecialistDetailsTimeSlotsLoaded({
    required this.specialist,
    required this.selectedDate,
    required this.timeSlots,
    this.selectedTimeSlot,
  });

  @override
  List<Object?> get props => [specialist, selectedDate, timeSlots, selectedTimeSlot];
}

class SpecialistDetailsTimeSlotsError extends SpecialistDetailsState {
  final SpecialistEntity specialist;
  final DateTime selectedDate;
  final String message;

  const SpecialistDetailsTimeSlotsError({
    required this.specialist,
    required this.selectedDate,
    required this.message,
  });

  @override
  List<Object?> get props => [specialist, selectedDate, message];
}

class SpecialistDetailsBooking extends SpecialistDetailsState {
  final SpecialistEntity specialist;
  final DateTime selectedDate;
  final List<DateTime> timeSlots;
  final DateTime selectedTimeSlot;

  const SpecialistDetailsBooking({
    required this.specialist,
    required this.selectedDate,
    required this.timeSlots,
    required this.selectedTimeSlot,
  });

  @override
  List<Object?> get props => [specialist, selectedDate, timeSlots, selectedTimeSlot];
}

class SpecialistDetailsBookingSuccess extends SpecialistDetailsState {
  final SpecialistEntity specialist;
  final DateTime selectedDate;
  final List<DateTime> timeSlots;
  final DateTime selectedTimeSlot;

  const SpecialistDetailsBookingSuccess({
    required this.specialist,
    required this.selectedDate,
    required this.timeSlots,
    required this.selectedTimeSlot,
  });

  @override
  List<Object?> get props => [specialist, selectedDate, timeSlots, selectedTimeSlot];
}

class SpecialistDetailsBookingError extends SpecialistDetailsState {
  final SpecialistEntity specialist;
  final DateTime selectedDate;
  final List<DateTime> timeSlots;
  final DateTime selectedTimeSlot;
  final String message;

  const SpecialistDetailsBookingError({
    required this.specialist,
    required this.selectedDate,
    required this.timeSlots,
    required this.selectedTimeSlot,
    required this.message,
  });

  @override
  List<Object?> get props => [specialist, selectedDate, timeSlots, selectedTimeSlot, message];
}
