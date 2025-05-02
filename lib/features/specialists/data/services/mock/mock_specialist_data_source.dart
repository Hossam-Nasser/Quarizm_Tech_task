import 'dart:async';


import 'package:injectable/injectable.dart';


import '../../../../../core/error/exceptions.dart';
import '../../../domain/entities/specialist_entity.dart';
import '../../models/specialist_model.dart';
import '../specialist_services.dart';

@LazySingleton(as: SpecialistServices)
class MockSpecialistDataSource implements SpecialistServices {
  // In-memory storage for mock specialists
  final Map<String, SpecialistModel> _specialists = {};
  
  // Add a private class to track booked time slots
  final List<_BookedTimeSlot> _bookedTimeSlots = [];
  
  MockSpecialistDataSource() {
    _populateWithMockData();
  }
  
  @override
  Future<List<SpecialistModel>> getAllSpecialists() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    return _specialists.values.toList();
  }
  
  @override
  Future<List<SpecialistModel>> getSpecialistsBySpecialization(String specialization) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    return _specialists.values
        .where((specialist) => specialist.specialization == specialization)
        .toList();
  }
  
  @override
  Future<SpecialistModel> getSpecialistById(String id) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    final specialist = _specialists[id];
    if (specialist == null) {
      throw DocumentNotFoundException(
        message: 'Specialist with ID $id not found',
      );
    }
    
    return specialist;
  }
  
  @override
  Future<List<String>> getAllSpecializations() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    return _specialists.values
        .map((specialist) => specialist.specialization)
        .toSet()
        .toList();
  }
  
  @override
  Future<List<SpecialistModel>> searchSpecialists(String query) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    final lowercaseQuery = query.toLowerCase();
    
    return _specialists.values
        .where((specialist) =>
            specialist.name.toLowerCase().contains(lowercaseQuery) ||
            specialist.specialization.toLowerCase().contains(lowercaseQuery))
        .toList();
  }
  
  @override
  Future<List<DateTime>> getAvailableTimeSlots({
    required String specialistId,
    required DateTime date,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Find specialist
    final specialist = _specialists[specialistId];
    if (specialist == null) {
      throw SpecialistNotFoundException(
        message: 'Specialist not found',
      );
    }

    // Get working hours for the day
    final weekday = date.weekday;
    final workingHours = specialist.workingHours.firstWhere(
      (wh) => wh.dayOfWeek == weekday,
      orElse: () => WorkingHour(
        dayOfWeek: weekday,
        from: DateTime(2022, 1, 1, 0, 0),
        to: DateTime(2022, 1, 1, 0, 0),
        isWorkingDay: false,
      ),
    );

    if (!workingHours.isWorkingDay) {
      return [];
    }

    // Generate time slots based on working hours and appointment duration
    final List<DateTime> availableSlots = [];
    final appointmentDuration = specialist.appointmentDurationMinutes;

    DateTime start = DateTime(
      date.year,
      date.month,
      date.day,
      workingHours.from.hour,
      workingHours.from.minute,
    );

    final end = DateTime(
      date.year,
      date.month,
      date.day,
      workingHours.to.hour,
      workingHours.to.minute,
    );

    while (start.add(Duration(minutes: appointmentDuration)).isBefore(end) ||
        start.add(Duration(minutes: appointmentDuration)).isAtSameMomentAs(end)) {
      // Check if the slot is already booked
      if (!_bookedTimeSlots.any((slot) =>
          slot.specialistId == specialistId &&
          slot.dateTime.year == start.year &&
          slot.dateTime.month == start.month &&
          slot.dateTime.day == start.day &&
          slot.dateTime.hour == start.hour &&
          slot.dateTime.minute == start.minute)) {
        availableSlots.add(start);
      }
      // Move to next slot
      start = start.add(Duration(minutes: appointmentDuration));
    }

    return availableSlots;
  }
  
  // Implementation of bookTimeSlot method
  @override
  Future<void> bookTimeSlot({
    required String specialistId,
    required DateTime dateTime,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Add the time slot to booked slots
    _bookedTimeSlots.add(_BookedTimeSlot(
      specialistId: specialistId,
      dateTime: dateTime,
    ));
  }
  
  // Implementation of cancelTimeSlot method
  @override
  Future<void> cancelTimeSlot({
    required String specialistId,
    required DateTime dateTime,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Remove the time slot from booked slots
    _bookedTimeSlots.removeWhere((slot) => 
      slot.specialistId == specialistId &&
      slot.dateTime.year == dateTime.year &&
      slot.dateTime.month == dateTime.month &&
      slot.dateTime.day == dateTime.day &&
      slot.dateTime.hour == dateTime.hour &&
      slot.dateTime.minute == dateTime.minute
    );
  }
  
  void _populateWithMockData() {
    // Create sample specialists
    final specialists = [
      SpecialistModel(
        id: '1',
        name: 'Dr. Jane Smith',
        specialization: 'Cardiologist',
        rating: 4.8,
        appointmentDurationMinutes: 30,
        appointmentFee: 150.0,
        bio: 'Dr. Jane Smith is a cardiologist with over 15 years of experience in treating heart conditions. She specializes in preventive cardiology and heart disease management.',
        imageUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
        workingHours: [
          WorkingHour(
            dayOfWeek: 1, // Monday
            from: DateTime(2022, 1, 1, 9, 0), // 9:00 AM
            to: DateTime(2022, 1, 1, 17, 0), // 5:00 PM
          ),
          WorkingHour(
            dayOfWeek: 2, // Tuesday
            from: DateTime(2022, 1, 1, 9, 0), // 9:00 AM
            to: DateTime(2022, 1, 1, 17, 0), // 5:00 PM
          ),
          WorkingHour(
            dayOfWeek: 3, // Wednesday
            from: DateTime(2022, 1, 1, 9, 0), // 9:00 AM
            to: DateTime(2022, 1, 1, 17, 0), // 5:00 PM
          ),
          WorkingHour(
            dayOfWeek: 4, // Thursday
            from: DateTime(2022, 1, 1, 9, 0), // 9:00 AM
            to: DateTime(2022, 1, 1, 17, 0), // 5:00 PM
          ),
          WorkingHour(
            dayOfWeek: 5, // Friday
            from: DateTime(2022, 1, 1, 9, 0), // 9:00 AM
            to: DateTime(2022, 1, 1, 15, 0), // 3:00 PM
          ),
          WorkingHour(
            dayOfWeek: 6, // Saturday
            from: DateTime(2022, 1, 1, 0, 0), // Not working
            to: DateTime(2022, 1, 1, 0, 0), // Not working
            isWorkingDay: false,
          ),
          WorkingHour(
            dayOfWeek: 7, // Sunday
            from: DateTime(2022, 1, 1, 0, 0), // Not working
            to: DateTime(2022, 1, 1, 0, 0), // Not working
            isWorkingDay: false,
          ),
        ],
      ),
      SpecialistModel(
        id: '2',
        name: 'Dr. Emily Johnson',
        specialization: 'Dermatologist',
        rating: 4.9,
        appointmentDurationMinutes: 45,
        appointmentFee: 120.0,
        bio: 'Dr. Emily Johnson specializes in skin conditions and cosmetic procedures.',
        imageUrl: 'https://randomuser.me/api/portraits/women/2.jpg',
        workingHours: [
          WorkingHour(
            dayOfWeek: 1, // Monday
            from: DateTime(2022, 1, 1, 10, 0), // 10:00 AM
            to: DateTime(2022, 1, 1, 18, 0), // 6:00 PM
          ),
          WorkingHour(
            dayOfWeek: 3, // Wednesday
            from: DateTime(2022, 1, 1, 10, 0), // 10:00 AM
            to: DateTime(2022, 1, 1, 18, 0), // 6:00 PM
          ),
          WorkingHour(
            dayOfWeek: 5, // Friday
            from: DateTime(2022, 1, 1, 10, 0), // 10:00 AM
            to: DateTime(2022, 1, 1, 18, 0), // 6:00 PM
          ),
        ],
      ),
      SpecialistModel(
        id: '3',
        name: 'Dr. Michael Brown',
        specialization: 'Neurologist',
        rating: 4.7,
        appointmentDurationMinutes: 60,
        appointmentFee: 180.0,
        bio: 'Dr. Michael Brown is a specialist in neurological disorders and conditions affecting the nervous system.',
        imageUrl: 'https://randomuser.me/api/portraits/men/3.jpg',
        workingHours: [
          WorkingHour(
            dayOfWeek: 2, // Tuesday
            from: DateTime(2022, 1, 1, 9, 0), // 9:00 AM
            to: DateTime(2022, 1, 1, 17, 0), // 5:00 PM
          ),
          WorkingHour(
            dayOfWeek: 4, // Thursday
            from: DateTime(2022, 1, 1, 9, 0), // 9:00 AM
            to: DateTime(2022, 1, 1, 17, 0), // 5:00 PM
          ),
          WorkingHour(
            dayOfWeek: 6, // Saturday
            from: DateTime(2022, 1, 1, 10, 0), // 10:00 AM
            to: DateTime(2022, 1, 1, 14, 0), // 2:00 PM
          ),
        ],
      ),
      SpecialistModel(
        id: '4',
        name: 'Dr. Sarah Wilson',
        specialization: 'Pediatrician',
        rating: 4.9,
        appointmentDurationMinutes: 30,
        appointmentFee: 100.0,
        bio: 'Dr. Sarah Wilson is a pediatrician who provides care for children from birth to young adulthood.',
        imageUrl: 'https://randomuser.me/api/portraits/women/4.jpg',
        workingHours: [
          WorkingHour(
            dayOfWeek: 1, // Monday
            from: DateTime(2022, 1, 1, 8, 0), // 8:00 AM
            to: DateTime(2022, 1, 1, 16, 0), // 4:00 PM
          ),
          WorkingHour(
            dayOfWeek: 2, // Tuesday
            from: DateTime(2022, 1, 1, 8, 0), // 8:00 AM
            to: DateTime(2022, 1, 1, 16, 0), // 4:00 PM
          ),
          WorkingHour(
            dayOfWeek: 3, // Wednesday
            from: DateTime(2022, 1, 1, 8, 0), // 8:00 AM
            to: DateTime(2022, 1, 1, 16, 0), // 4:00 PM
          ),
          WorkingHour(
            dayOfWeek: 4, // Thursday
            from: DateTime(2022, 1, 1, 8, 0), // 8:00 AM
            to: DateTime(2022, 1, 1, 16, 0), // 4:00 PM
          ),
          WorkingHour(
            dayOfWeek: 5, // Friday
            from: DateTime(2022, 1, 1, 8, 0), // 8:00 AM
            to: DateTime(2022, 1, 1, 16, 0), // 4:00 PM
          ),
        ],
      ),
      SpecialistModel(
        id: '5',
        name: 'Dr. Robert Miller',
        specialization: 'Orthopedist',
        rating: 4.6,
        appointmentDurationMinutes: 45,
        appointmentFee: 150.0,
        bio: 'Dr. Robert Miller specializes in treating conditions affecting the musculoskeletal system.',
        imageUrl: 'https://randomuser.me/api/portraits/men/5.jpg',
        workingHours: [
          WorkingHour(
            dayOfWeek: 1, // Monday
            from: DateTime(2022, 1, 1, 9, 0), // 9:00 AM
            to: DateTime(2022, 1, 1, 18, 0), // 6:00 PM
          ),
          WorkingHour(
            dayOfWeek: 3, // Wednesday
            from: DateTime(2022, 1, 1, 9, 0), // 9:00 AM
            to: DateTime(2022, 1, 1, 18, 0), // 6:00 PM
          ),
          WorkingHour(
            dayOfWeek: 5, // Friday
            from: DateTime(2022, 1, 1, 9, 0), // 9:00 AM
            to: DateTime(2022, 1, 1, 18, 0), // 6:00 PM
          ),
        ],
      ),
      SpecialistModel(
        id: '6',
        name: 'Amanda Davis',
        specialization: 'Business Consultant',
        rating: 4.8,
        appointmentDurationMinutes: 60,
        appointmentFee: 120.0,
        bio: 'Amanda is a business consultant with expertise in strategy and operations for tech startups.',
        imageUrl: 'https://randomuser.me/api/portraits/women/6.jpg',
        workingHours: [
          WorkingHour(
            dayOfWeek: 1, // Monday
            from: DateTime(2022, 1, 1, 10, 0), // 10:00 AM
            to: DateTime(2022, 1, 1, 18, 0), // 6:00 PM
          ),
          WorkingHour(
            dayOfWeek: 2, // Tuesday
            from: DateTime(2022, 1, 1, 10, 0), // 10:00 AM
            to: DateTime(2022, 1, 1, 18, 0), // 6:00 PM
          ),
          WorkingHour(
            dayOfWeek: 3, // Wednesday
            from: DateTime(2022, 1, 1, 10, 0), // 10:00 AM
            to: DateTime(2022, 1, 1, 18, 0), // 6:00 PM
          ),
          WorkingHour(
            dayOfWeek: 4, // Thursday
            from: DateTime(2022, 1, 1, 10, 0), // 10:00 AM
            to: DateTime(2022, 1, 1, 18, 0), // 6:00 PM
          ),
          WorkingHour(
            dayOfWeek: 5, // Friday
            from: DateTime(2022, 1, 1, 10, 0), // 10:00 AM
            to: DateTime(2022, 1, 1, 18, 0), // 6:00 PM
          ),
        ],
      ),
      SpecialistModel(
        id: '7',
        name: 'Daniel Wilson',
        specialization: 'Fitness Trainer',
        rating: 4.9,
        appointmentDurationMinutes: 60,
        appointmentFee: 80.0,
        bio: 'Daniel specializes in personalized fitness training and nutrition planning.',
        imageUrl: 'https://randomuser.me/api/portraits/men/7.jpg',
        workingHours: [
          WorkingHour(
            dayOfWeek: 1, // Monday
            from: DateTime(2022, 1, 1, 7, 0), // 7:00 AM
            to: DateTime(2022, 1, 1, 19, 0), // 7:00 PM
          ),
          WorkingHour(
            dayOfWeek: 2, // Tuesday
            from: DateTime(2022, 1, 1, 7, 0), // 7:00 AM
            to: DateTime(2022, 1, 1, 19, 0), // 7:00 PM
          ),
          WorkingHour(
            dayOfWeek: 3, // Wednesday
            from: DateTime(2022, 1, 1, 7, 0), // 7:00 AM
            to: DateTime(2022, 1, 1, 19, 0), // 7:00 PM
          ),
          WorkingHour(
            dayOfWeek: 4, // Thursday
            from: DateTime(2022, 1, 1, 7, 0), // 7:00 AM
            to: DateTime(2022, 1, 1, 19, 0), // 7:00 PM
          ),
          WorkingHour(
            dayOfWeek: 5, // Friday
            from: DateTime(2022, 1, 1, 7, 0), // 7:00 AM
            to: DateTime(2022, 1, 1, 19, 0), // 7:00 PM
          ),
          WorkingHour(
            dayOfWeek: 6, // Saturday
            from: DateTime(2022, 1, 1, 9, 0), // 9:00 AM
            to: DateTime(2022, 1, 1, 14, 0), // 2:00 PM
          ),
        ],
      ),
      SpecialistModel(
        id: '8',
        name: 'Jennifer Lee',
        specialization: 'Nutritionist',
        rating: 4.7,
        appointmentDurationMinutes: 45,
        appointmentFee: 100.0,
        bio: 'Jennifer helps clients develop healthy eating plans tailored to their specific needs and goals.',
        imageUrl: 'https://randomuser.me/api/portraits/women/8.jpg',
        workingHours: [
          WorkingHour(
            dayOfWeek: 2, // Tuesday
            from: DateTime(2022, 1, 1, 9, 0), // 9:00 AM
            to: DateTime(2022, 1, 1, 17, 0), // 5:00 PM
          ),
          WorkingHour(
            dayOfWeek: 3, // Wednesday
            from: DateTime(2022, 1, 1, 9, 0), // 9:00 AM
            to: DateTime(2022, 1, 1, 17, 0), // 5:00 PM
          ),
          WorkingHour(
            dayOfWeek: 4, // Thursday
            from: DateTime(2022, 1, 1, 9, 0), // 9:00 AM
            to: DateTime(2022, 1, 1, 17, 0), // 5:00 PM
          ),
          WorkingHour(
            dayOfWeek: 5, // Friday
            from: DateTime(2022, 1, 1, 9, 0), // 9:00 AM
            to: DateTime(2022, 1, 1, 15, 0), // 3:00 PM
          ),
        ],
      ),
    ];
    
    // Add to in-memory storage
    for (final specialist in specialists) {
      _specialists[specialist.id] = specialist;
    }
  }
}

// Helper class to track booked time slots
class _BookedTimeSlot {
  final String specialistId;
  final DateTime dateTime;
  
  _BookedTimeSlot({
    required this.specialistId,
    required this.dateTime,
  });
}
