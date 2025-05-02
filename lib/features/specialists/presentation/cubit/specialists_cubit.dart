import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/get_all_specialists_usecase.dart';
import '../../domain/usecases/get_all_specializations_usecase.dart';
import '../../domain/usecases/get_specialists_by_specialization_usecase.dart';
import '../../domain/usecases/search_specialists_usecase.dart';
import 'specialists_state.dart';

@injectable
class SpecialistsCubit extends Cubit<SpecialistsState> {
  final GetAllSpecialistsUseCase _getAllSpecialistsUseCase;
  final GetSpecialistsBySpecializationUseCase _getSpecialistsBySpecializationUseCase;
  final GetAllSpecializationsUseCase _getAllSpecializationsUseCase;
  final SearchSpecialistsUseCase _searchSpecialistsUseCase;
  
  SpecialistsCubit(
    this._getAllSpecialistsUseCase,
    this._getSpecialistsBySpecializationUseCase,
    this._getAllSpecializationsUseCase,
    this._searchSpecialistsUseCase,
  ) : super(SpecialistsInitial());
  
  // Load all specialists and specializations
  Future<void> loadSpecialists() async {
    emit(SpecialistsLoading());
    
    // Get all specializations
    final specializationsResult = await _getAllSpecializationsUseCase();
    
    await specializationsResult.fold(
      (failure) {
        emit(SpecialistsError(failure.message));
      },
      (specializations) async {
        // Get all specialists
        final specialistsResult = await _getAllSpecialistsUseCase();
        
        specialistsResult.fold(
          (failure) {
            emit(SpecialistsError(failure.message));
          },
          (specialists) {
            if (specialists.isEmpty) {
              emit(SpecialistsEmpty());
            } else {
              emit(SpecialistsLoaded(
                specialists: specialists,
                specializations: specializations,
              ));
            }
          },
        );
      },
    );
  }
  
  // Filter specialists by specialization
  Future<void> filterBySpecialization(String? specialization) async {
    // Get current state properties if it's loaded state
    if (state is SpecialistsLoaded) {
      final currentState = state as SpecialistsLoaded;
      
      // If null, show all specialists
      if (specialization == null) {
        emit(currentState.copyWith(
          selectedSpecialization: null,
        ));
        return;
      }
    }
    
    emit(SpecialistsLoading());
    
    // Fix: Only call the use case with non-null specialization
    if (specialization == null) {
      // If specialization is null, load all specialists instead
      loadSpecialists();
      return;
    }
    
    final result = await _getSpecialistsBySpecializationUseCase(specialization);
    
    result.fold(
      (failure) {
        emit(SpecialistsError(failure.message));
      },
      (specialists) {
        if (specialists.isEmpty) {
          emit(SpecialistsEmpty());
        } else {
          // Get specializations and searchQuery from current state if available
          final currentSpecializations = state is SpecialistsLoaded 
              ? (state as SpecialistsLoaded).specializations 
              : <String>[];
          final currentSearchQuery = state is SpecialistsLoaded 
              ? (state as SpecialistsLoaded).searchQuery 
              : null;
          
          emit(SpecialistsLoaded(
            specialists: specialists,
            specializations: currentSpecializations,
            selectedSpecialization: specialization,
            searchQuery: currentSearchQuery,
          ));
        }
      },
    );
  }
  
  // Search specialists by name or specialization
  Future<void> searchSpecialists(String query) async {
    // If empty query, load all specialists
    if (query.isEmpty && state is SpecialistsLoaded) {
      final currentState = state as SpecialistsLoaded;
      emit(currentState.copyWith(
        searchQuery: null,
      ));
      loadSpecialists();
      return;
    }
    
    emit(SpecialistsLoading());
    
    final result = await _searchSpecialistsUseCase(query);
    
    result.fold(
      (failure) {
        emit(SpecialistsError(failure.message));
      },
      (specialists) {
        if (specialists.isEmpty) {
          emit(SpecialistsEmpty());
        } else {
          // Get specializations and selectedSpecialization from current state if available
          final currentSpecializations = state is SpecialistsLoaded 
              ? (state as SpecialistsLoaded).specializations 
              : <String>[];
          final currentSelectedSpecialization = state is SpecialistsLoaded 
              ? (state as SpecialistsLoaded).selectedSpecialization 
              : null;
          
          emit(SpecialistsLoaded(
            specialists: specialists,
            specializations: currentSpecializations,
            selectedSpecialization: currentSelectedSpecialization,
            searchQuery: query,
          ));
        }
      },
    );
  }
  
  // Clear all filters and search
  void clearFilters() {
    if (state is SpecialistsLoaded) {
      final currentState = state as SpecialistsLoaded;
      if (currentState.selectedSpecialization != null || currentState.searchQuery != null) {
        emit(currentState.copyWith(
          selectedSpecialization: null,
          searchQuery: null,
        ));
        loadSpecialists();
      }
    } else {
      loadSpecialists();
    }
  }
}
