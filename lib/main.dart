import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:quarizmtask/core/util/routing/routes.dart';

import 'core/app.dart';
import 'core/di/injection.dart';
import 'core/util/theme/app_theme.dart';
import 'core/util/routing/app_router.dart';
import 'features/appointments/presentation/cubit/appointments_cubit.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/specialists/presentation/cubit/specialist_details_cubit.dart';
import 'features/specialists/presentation/cubit/specialists_cubit.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependency injection
  configureDependencies();
  
  // Initialize Firebase - commenting this out as we're using mock implementations
  // await Firebase.initializeApp();
  
  runApp(ServiceReservationApp(
    appRouter: AppRouter(),
  ));
}


