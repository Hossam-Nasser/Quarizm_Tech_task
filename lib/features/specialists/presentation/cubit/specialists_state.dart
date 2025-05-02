import 'package:equatable/equatable.dart';

import '../../domain/entities/specialist_entity.dart';

abstract class SpecialistsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SpecialistsInitial extends SpecialistsState {}

class SpecialistsLoading extends SpecialistsState {}

class SpecialistsLoaded extends SpecialistsState {
  final List<SpecialistEntity> specialists;
  final List<String> specializations;
  final String? selectedSpecialization;
  final String? searchQuery;

  SpecialistsLoaded({
    required this.specialists,
    required this.specializations,
    this.selectedSpecialization,
    this.searchQuery,
  });

  // Get specialists filtered by specialization if one is selected
  List<SpecialistEntity> get filteredSpecialists {
    if (selectedSpecialization == null) {
      return specialists;
    }
    return specialists
        .where((specialist) => specialist.specialization == selectedSpecialization)
        .toList();
  }

  // Get specialists filtered by search query
  List<SpecialistEntity> get searchResults {
    if (searchQuery == null || searchQuery!.isEmpty) {
      return filteredSpecialists;
    }
    
    final query = searchQuery!.toLowerCase();
    return filteredSpecialists
        .where((specialist) =>
            specialist.name.toLowerCase().contains(query) ||
            specialist.specialization.toLowerCase().contains(query))
        .toList();
  }

  // Get specializations grouped by their specialist count
  Map<String, int> get specializationsWithCount {
    final Map<String, int> result = {};
    
    for (final specialization in specializations) {
      result[specialization] = specialists
          .where((specialist) => specialist.specialization == specialization)
          .length;
    }
    
    return result;
  }

  SpecialistsLoaded copyWith({
    List<SpecialistEntity>? specialists,
    List<String>? specializations,
    String? selectedSpecialization,
    String? searchQuery,
  }) {
    return SpecialistsLoaded(
      specialists: specialists ?? this.specialists,
      specializations: specializations ?? this.specializations,
      selectedSpecialization: selectedSpecialization ?? this.selectedSpecialization,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
        specialists,
        specializations,
        selectedSpecialization,
        searchQuery,
      ];
}

class SpecialistsEmpty extends SpecialistsState {}

class SpecialistsError extends SpecialistsState {
  final String message;
  
  SpecialistsError(this.message);
  
  @override
  List<Object?> get props => [message];
}
