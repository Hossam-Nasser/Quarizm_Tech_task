

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quarizmtask/core/util/routing/routes.dart';

import '../../../features/appointments/domain/entities/appointment_entity.dart';
import '../../../features/appointments/presentation/pages/appointment_details_page.dart';
import '../../../features/appointments/presentation/pages/appointments_page.dart';
import '../../../features/auth/presentation/pages/login_page.dart';
import '../../../features/auth/presentation/pages/register_page.dart';
import '../../../features/auth/presentation/pages/splash_page.dart';
import '../../../features/specialists/domain/entities/specialist_entity.dart';
import '../../../features/specialists/presentation/pages/specialist_details_page.dart';
import '../../../features/specialists/presentation/pages/specialists_page.dart';




class AppRouter {
  Route? generateRoute(RouteSettings settings) {
    //this arguments to be passed in any screen like this ( arguments as ClassName )
    final arguments = settings.arguments;

    switch (settings.name) {
      case Routes.splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case Routes.login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case Routes.register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case Routes.specialists:
        return MaterialPageRoute(builder: (_) => const SpecialistsPage());
      case Routes.specialistDetails:
        final specialist = settings.arguments as SpecialistEntity;
        return MaterialPageRoute(
          builder: (_) => SpecialistDetailsPage(specialist: specialist),
        );
      case Routes.appointments:
        return MaterialPageRoute(builder: (_) => const AppointmentsPage());
      case Routes.appointmentDetails:
        final appointment = settings.arguments as AppointmentEntity;
        return MaterialPageRoute(
          builder: (_) => AppointmentDetailsPage(appointment: appointment),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}