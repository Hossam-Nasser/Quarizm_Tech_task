// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/appointments/data/repositories/appointment_repository_impl.dart'
    as _i155;
import '../../features/appointments/data/services/appointment_services.dart'
    as _i503;
import '../../features/appointments/data/services/mock/mock_appointment_data_source.dart'
    as _i454;
import '../../features/appointments/domain/repositories/appointment_repository.dart'
    as _i152;
import '../../features/appointments/domain/usecases/book_appointment_usecase.dart'
    as _i84;
import '../../features/appointments/domain/usecases/cancel_appointment_usecase.dart'
    as _i126;
import '../../features/appointments/domain/usecases/get_appointment_by_id_usecase.dart'
    as _i817;
import '../../features/appointments/domain/usecases/get_user_appointments_usecase.dart'
    as _i689;
import '../../features/appointments/domain/usecases/get_user_past_appointments_usecase.dart'
    as _i474;
import '../../features/appointments/domain/usecases/get_user_upcoming_appointments_usecase.dart'
    as _i189;
import '../../features/appointments/domain/usecases/is_time_slot_available_usecase.dart'
    as _i548;
import '../../features/appointments/domain/usecases/reschedule_appointment_usecase.dart'
    as _i811;
import '../../features/appointments/presentation/cubit/appointments_cubit.dart'
    as _i613;
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/data/services/auth_services.dart' as _i845;
import '../../features/auth/data/services/mock/mock_auth_data_source.dart'
    as _i1020;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/domain/usecases/get_current_user_usecase.dart'
    as _i17;
import '../../features/auth/domain/usecases/login_usecase.dart' as _i188;
import '../../features/auth/domain/usecases/logout_usecase.dart' as _i48;
import '../../features/auth/domain/usecases/register_usecase.dart' as _i941;
import '../../features/auth/presentation/cubit/auth_cubit.dart' as _i117;
import '../../features/specialists/data/repositories/specialist_repository_impl.dart'
    as _i1056;
import '../../features/specialists/data/services/mock/mock_specialist_data_source.dart'
    as _i402;
import '../../features/specialists/data/services/specialist_services.dart'
    as _i759;
import '../../features/specialists/domain/repositories/specialist_repository.dart'
    as _i870;
import '../../features/specialists/domain/usecases/get_all_specialists_usecase.dart'
    as _i904;
import '../../features/specialists/domain/usecases/get_all_specializations_usecase.dart'
    as _i276;
import '../../features/specialists/domain/usecases/get_available_time_slots_usecase.dart'
    as _i194;
import '../../features/specialists/domain/usecases/get_specialist_by_id_usecase.dart'
    as _i101;
import '../../features/specialists/domain/usecases/get_specialists_by_specialization_usecase.dart'
    as _i838;
import '../../features/specialists/domain/usecases/search_specialists_usecase.dart'
    as _i201;
import '../../features/specialists/presentation/cubit/specialist_details_cubit.dart'
    as _i254;
import '../../features/specialists/presentation/cubit/specialists_cubit.dart'
    as _i577;

// initializes the registration of main-scope dependencies inside of GetIt
_i174.GetIt init(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i526.GetItHelper(
    getIt,
    environment,
    environmentFilter,
  );
  gh.lazySingleton<_i787.AuthRepository>(
      () => AuthRepositoryImpl(gh<_i845.AuthServices>()));
  gh.factory<_i17.GetCurrentUserUseCase>(
      () => _i17.GetCurrentUserUseCase(gh<_i787.AuthRepository>()));
  gh.factory<_i188.LoginUseCase>(
      () => _i188.LoginUseCase(gh<_i787.AuthRepository>()));
  gh.factory<_i48.LogoutUseCase>(
      () => _i48.LogoutUseCase(gh<_i787.AuthRepository>()));
  gh.factory<_i941.RegisterUseCase>(
      () => _i941.RegisterUseCase(gh<_i787.AuthRepository>()));
  gh.lazySingleton<_i845.AuthServices>(() => _i1020.MockAuthDataSource());
  gh.lazySingleton<_i759.SpecialistServices>(
      () => _i402.MockSpecialistDataSource());
  gh.lazySingleton<_i503.AppointmentServices>(
      () => _i454.MockAppointmentDataSource(
            gh<_i845.AuthServices>(),
            gh<_i759.SpecialistServices>(),
          ));
  gh.factory<_i117.AuthCubit>(() => _i117.AuthCubit(
        gh<_i941.RegisterUseCase>(),
        gh<_i188.LoginUseCase>(),
        gh<_i48.LogoutUseCase>(),
        gh<_i17.GetCurrentUserUseCase>(),
      ));
  gh.lazySingleton<_i870.SpecialistRepository>(
      () => _i1056.SpecialistRepositoryImpl(gh<_i759.SpecialistServices>()));
  gh.lazySingleton<_i904.GetAllSpecialistsUseCase>(
      () => _i904.GetAllSpecialistsUseCase(gh<_i870.SpecialistRepository>()));
  gh.lazySingleton<_i194.GetAvailableTimeSlotsUseCase>(() =>
      _i194.GetAvailableTimeSlotsUseCase(gh<_i870.SpecialistRepository>()));
  gh.factory<_i276.GetAllSpecializationsUseCase>(() =>
      _i276.GetAllSpecializationsUseCase(gh<_i870.SpecialistRepository>()));
  gh.factory<_i838.GetSpecialistsBySpecializationUseCase>(() =>
      _i838.GetSpecialistsBySpecializationUseCase(
          gh<_i870.SpecialistRepository>()));
  gh.factory<_i101.GetSpecialistByIdUseCase>(
      () => _i101.GetSpecialistByIdUseCase(gh<_i870.SpecialistRepository>()));
  gh.factory<_i201.SearchSpecialistsUseCase>(
      () => _i201.SearchSpecialistsUseCase(gh<_i870.SpecialistRepository>()));
  gh.lazySingleton<_i152.AppointmentRepository>(
      () => _i155.AppointmentRepositoryImpl(gh<_i503.AppointmentServices>()));
  gh.factory<_i577.SpecialistsCubit>(() => _i577.SpecialistsCubit(
        gh<_i904.GetAllSpecialistsUseCase>(),
        gh<_i838.GetSpecialistsBySpecializationUseCase>(),
        gh<_i276.GetAllSpecializationsUseCase>(),
        gh<_i201.SearchSpecialistsUseCase>(),
      ));
  gh.lazySingleton<_i84.BookAppointmentUseCase>(
      () => _i84.BookAppointmentUseCase(gh<_i152.AppointmentRepository>()));
  gh.factory<_i126.CancelAppointmentUseCase>(
      () => _i126.CancelAppointmentUseCase(gh<_i152.AppointmentRepository>()));
  gh.factory<_i817.GetAppointmentByIdUseCase>(
      () => _i817.GetAppointmentByIdUseCase(gh<_i152.AppointmentRepository>()));
  gh.factory<_i689.GetUserAppointmentsUseCase>(() =>
      _i689.GetUserAppointmentsUseCase(gh<_i152.AppointmentRepository>()));
  gh.factory<_i474.GetUserPastAppointmentsUseCase>(() =>
      _i474.GetUserPastAppointmentsUseCase(gh<_i152.AppointmentRepository>()));
  gh.factory<_i189.GetUserUpcomingAppointmentsUseCase>(() =>
      _i189.GetUserUpcomingAppointmentsUseCase(
          gh<_i152.AppointmentRepository>()));
  gh.factory<_i548.IsTimeSlotAvailableUseCase>(() =>
      _i548.IsTimeSlotAvailableUseCase(gh<_i152.AppointmentRepository>()));
  gh.factory<_i811.RescheduleAppointmentUseCase>(() =>
      _i811.RescheduleAppointmentUseCase(gh<_i152.AppointmentRepository>()));
  gh.factory<_i613.AppointmentsCubit>(() => _i613.AppointmentsCubit(
        gh<_i689.GetUserAppointmentsUseCase>(),
        gh<_i189.GetUserUpcomingAppointmentsUseCase>(),
        gh<_i474.GetUserPastAppointmentsUseCase>(),
        gh<_i126.CancelAppointmentUseCase>(),
        gh<_i811.RescheduleAppointmentUseCase>(),
      ));
  gh.factory<_i254.SpecialistDetailsCubit>(() => _i254.SpecialistDetailsCubit(
        gh<_i101.GetSpecialistByIdUseCase>(),
        gh<_i194.GetAvailableTimeSlotsUseCase>(),
        gh<_i84.BookAppointmentUseCase>(),
      ));
  return getIt;
}
