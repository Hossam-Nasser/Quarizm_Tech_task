import '../models/specialist_model.dart';

abstract class SpecialistServices {
  Future<List<SpecialistModel>> getAllSpecialists();
  Future<List<SpecialistModel>> getSpecialistsBySpecialization(String specialization);
  Future<SpecialistModel> getSpecialistById(String id);
  Future<List<String>> getAllSpecializations();
  Future<List<SpecialistModel>> searchSpecialists(String query);
  Future<List<DateTime>> getAvailableTimeSlots({
    required String specialistId,
    required DateTime date,
  });
  Future<void> bookTimeSlot({
    required String specialistId,
    required DateTime dateTime,
  });
  Future<void> cancelTimeSlot({
    required String specialistId,
    required DateTime dateTime,
  });
}
