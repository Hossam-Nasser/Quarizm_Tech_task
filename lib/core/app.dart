import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quarizmtask/core/util/routing/app_router.dart';
import 'package:quarizmtask/core/util/routing/routes.dart';
import 'package:quarizmtask/core/util/theme/app_theme.dart';

import '../features/appointments/presentation/cubit/appointments_cubit.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/specialists/presentation/cubit/specialist_details_cubit.dart';
import '../features/specialists/presentation/cubit/specialists_cubit.dart';
import 'di/injection.dart';

class ServiceReservationApp extends StatelessWidget {
  final AppRouter appRouter;
  const ServiceReservationApp({super.key,required this.appRouter});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // Standard design size based on iPhone X
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>(
              create: (context) => getIt<AuthCubit>(),
            ),
            BlocProvider<SpecialistsCubit>(
              create: (context) => getIt<SpecialistsCubit>(),
            ),
            BlocProvider<SpecialistDetailsCubit>(
              create: (context) => getIt<SpecialistDetailsCubit>(),
            ),
            BlocProvider<AppointmentsCubit>(
              create: (context) => getIt<AppointmentsCubit>(),
            ),
          ],
          child: MaterialApp(
            title: 'Service Reservation',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            initialRoute: Routes.splash,
            onGenerateRoute: appRouter.generateRoute,
          ),
        );
      },
    );
  }
}