import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/error/exceptions.dart';
import '../../../domain/entities/specialist_entity.dart';
import '../../models/specialist_model.dart';
import '../specialist_services.dart';

@LazySingleton(as: SpecialistServices)
class FireStoreSpecialistServices implements SpecialistServices {
  final FirebaseFirestore _firestore;
  
  // Private field to track booked time slots
  final String _bookedTimeSlotsCollection = 'bookedTimeSlots';

  FireStoreSpecialistServices(this._firestore);

  // Collection references
  CollectionReference<Map<String, dynamic>> get _specialistsCollection => 
      _firestore.collection('specialists');

  CollectionReference<Map<String, dynamic>> get _bookedSlotsCollection => 
      _firestore.collection(_bookedTimeSlotsCollection);

  @override
  Future<List<SpecialistModel>> getAllSpecialists() async {
    try {
      final querySnapshot = await _specialistsCollection.get();
      
      return querySnapshot.docs
          .map((doc) => SpecialistModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw FirestoreException(message: 'Failed to get specialists: ${e.toString()}');
    }
  }

  @override
  Future<List<SpecialistModel>> getSpecialistsBySpecialization(String specialization) async {
    try {
      final querySnapshot = await _specialistsCollection
          .where('specialization', isEqualTo: specialization)
          .get();
      
      return querySnapshot.docs
          .map((doc) => SpecialistModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw FirestoreException(
        message: 'Failed to get specialists by specialization: ${e.toString()}',
      );
    }
  }

  @override
  Future<SpecialistModel> getSpecialistById(String id) async {
    try {
      final docSnapshot = await _specialistsCollection.doc(id).get();
      
      if (!docSnapshot.exists) {
        throw DocumentNotFoundException(
          message: 'Specialist with ID $id not found',
        );
      }
      
      return SpecialistModel.fromJson(docSnapshot.data()!);
    } catch (e) {
      if (e is DocumentNotFoundException) {
        rethrow;
      }
      throw FirestoreException(
        message: 'Failed to get specialist by ID: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<String>> getAllSpecializations() async {
    try {
      final querySnapshot = await _specialistsCollection.get();
      
      // Extract unique specializations
      final specializations = querySnapshot.docs
          .map((doc) => doc.data()['specialization'] as String)
          .toSet()
          .toList();
      
      return specializations;
    } catch (e) {
      throw FirestoreException(
        message: 'Failed to get all specializations: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<SpecialistModel>> searchSpecialists(String query) async {
    try {
      // Note: This is a simple implementation that searches on the client side
      // For a production app, consider using Firestore's full-text search capabilities
      // or integrating with Algolia, Elasticsearch, etc.
      final querySnapshot = await _specialistsCollection.get();
      
      final lowercaseQuery = query.toLowerCase();
      
      return querySnapshot.docs
          .map((doc) => SpecialistModel.fromJson(doc.data()))
          .where((specialist) => 
              specialist.name.toLowerCase().contains(lowercaseQuery) ||
              specialist.specialization.toLowerCase().contains(lowercaseQuery))
          .toList();
    } catch (e) {
      throw FirestoreException(
        message: 'Failed to search specialists: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<DateTime>> getAvailableTimeSlots({
    required String specialistId,
    required DateTime date,
  }) async {
    try {
      // Get specialist details
      final specialist = await getSpecialistById(specialistId);
      
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
      
      // Query booked time slots for this specialist on this date
      final dateStart = DateTime(date.year, date.month, date.day);
      final dateEnd = DateTime(date.year, date.month, date.day, 23, 59, 59);
      
      final bookedSlotsQuery = await _bookedSlotsCollection
          .where('specialistId', isEqualTo: specialistId)
          .where('dateTime', isGreaterThanOrEqualTo: dateStart)
          .where('dateTime', isLessThanOrEqualTo: dateEnd)
          .get();
          
      final bookedSlots = bookedSlotsQuery.docs
          .map((doc) => (doc.data()['dateTime'] as Timestamp).toDate())
          .toList();
      
      // Generate available time slots
      while (start.add(Duration(minutes: appointmentDuration)).isBefore(end) ||
             start.add(Duration(minutes: appointmentDuration)).isAtSameMomentAs(end)) {
        // Check if slot is already booked
        bool isBooked = bookedSlots.any((bookedTime) =>
            bookedTime.year == start.year &&
            bookedTime.month == start.month &&
            bookedTime.day == start.day &&
            bookedTime.hour == start.hour &&
            bookedTime.minute == start.minute);
            
        if (!isBooked) {
          availableSlots.add(start);
        }
        
        // Move to next slot
        start = start.add(Duration(minutes: appointmentDuration));
      }
      
      return availableSlots;
    } catch (e) {
      if (e is DocumentNotFoundException) {
        throw SpecialistNotFoundException(
          message: 'Specialist not found',
        );
      }
      throw FirestoreException(
        message: 'Failed to get available time slots: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> bookTimeSlot({
    required String specialistId,
    required DateTime dateTime,
  }) async {
    try {
      // Create a document ID combining specialistId and dateTime
      final String docId = '${specialistId}_${dateTime.millisecondsSinceEpoch}';
      
      // Add to booked slots collection
      await _bookedSlotsCollection.doc(docId).set({
        'specialistId': specialistId,
        'dateTime': Timestamp.fromDate(dateTime),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw FirestoreException(
        message: 'Failed to book time slot: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> cancelTimeSlot({
    required String specialistId,
    required DateTime dateTime,
  }) async {
    try {
      // Query to find the correct document
      final querySnapshot = await _bookedSlotsCollection
          .where('specialistId', isEqualTo: specialistId)
          .get();
          
      // Find the slot that matches the dateTime
      final matchingDocs = querySnapshot.docs.where((doc) {
        final bookedTime = (doc.data()['dateTime'] as Timestamp).toDate();
        return bookedTime.year == dateTime.year &&
               bookedTime.month == dateTime.month &&
               bookedTime.day == dateTime.day &&
               bookedTime.hour == dateTime.hour &&
               bookedTime.minute == dateTime.minute;
      });
      
      if (matchingDocs.isNotEmpty) {
        // Delete the matched document
        await _bookedSlotsCollection.doc(matchingDocs.first.id).delete();
      }
    } catch (e) {
      throw FirestoreException(
        message: 'Failed to cancel time slot: ${e.toString()}',
      );
    }
  }
}
