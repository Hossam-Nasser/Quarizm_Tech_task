import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quarizmtask/core/util/responsive/app_responsive.dart';
import 'package:quarizmtask/core/util/routing/extensions.dart';
import 'package:quarizmtask/core/util/routing/routes.dart';


import '../../../../core/util/constants/app_constants.dart';
import '../../../../core/util/theme/app_theme.dart';
import '../../../../core/util/widget/common_widgets.dart';
import '../../domain/entities/appointment_entity.dart';
import '../cubit/appointments_cubit.dart';
import '../cubit/appointments_state.dart';
import '../widgets/appointment_card.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({Key? key}) : super(key: key);

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Load all appointments when page is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppointmentsCubit>().loadAppointments();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _navigateToAppointmentDetails(AppointmentEntity appointment) {
    context.pushNamed(
      Routes.appointmentDetails,
      arguments: appointment,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Appointments',
          style: TextStyle(
            fontSize: AppResponsive.sp(AppTheme.heading3),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: AppTheme.subtitleColor,
          indicatorColor: Theme.of(context).primaryColor,
          labelStyle: TextStyle(fontSize: AppResponsive.sp(14)),
          unselectedLabelStyle: TextStyle(fontSize: AppResponsive.sp(14)),
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: BlocConsumer<AppointmentsCubit, AppointmentsState>(
        listener: (context, state) {
          if (state is AppointmentsCancelled) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppConstants.appointmentCancelledSuccessMessage),
                backgroundColor: AppTheme.successColor,
              ),
            );
            context.read<AppointmentsCubit>().resetActionState();
          } else if (state is AppointmentsCancelError) {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
              ),
            );
            context.read<AppointmentsCubit>().resetActionState();
          } else if (state is AppointmentsRescheduled) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(AppConstants.appointmentRescheduledSuccessMessage),
                backgroundColor: AppTheme.successColor,
              ),
            );
            context.read<AppointmentsCubit>().resetActionState();
          } else if (state is AppointmentsRescheduleError) {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
              ),
            );
            context.read<AppointmentsCubit>().resetActionState();
          }
        },
        builder: (context, state) {
          if (state is AppointmentsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AppointmentsError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () {
                context.read<AppointmentsCubit>().loadAppointments();
              },
            );
          }

          // Handle empty state
          if (state is AppointmentsEmpty) {
            return AppEmptyWidget(
              message: 'No appointments found',
              actionLabel: 'Book New Appointment',
              onAction: () {
                context.pushNamedAndRemoveUntil(
                  Routes.specialists,
                  predicate: (route) => false,
                );
              },
            );
          }

          // Get appointments for loaded state
          List<AppointmentEntity> appointments = [];
          String appointmentIdInProgress = '';
          
          if (state is AppointmentsLoaded) {
            appointments = state.appointments;
          } else if (state is AppointmentsCancelling) {
            appointments = state.appointments;
            appointmentIdInProgress = state.appointmentIdInProgress;
          } else if (state is AppointmentsRescheduling) {
            appointments = state.appointments;
            appointmentIdInProgress = state.appointmentIdInProgress;
          } else if (state is AppointmentsCancelled) {
            appointments = state.appointments;
          } else if (state is AppointmentsCancelError) {
            appointments = state.appointments;
          } else if (state is AppointmentsRescheduled) {
            appointments = state.appointments;
          } else if (state is AppointmentsRescheduleError) {
            appointments = state.appointments;
          }
          
          if (appointments.isEmpty) {
            return AppEmptyWidget(
              message: 'No appointments found',
              actionLabel: 'Book New Appointment',
              onAction: () {
                context.pushNamedAndRemoveUntil(
                  Routes.specialists,
                  predicate: (route) => false,
                );
              },
            );
          }

          // Get upcoming and past appointments
          final upcomingAppointments = appointments
              .where((appointment) => appointment.isUpcoming)
              .toList();
          
          final pastAppointments = appointments
              .where((appointment) => 
                  appointment.isPast || 
                  appointment.isCancelled || 
                  appointment.isCompleted)
              .toList();

          return TabBarView(
            controller: _tabController,
            children: [
              // Upcoming appointments tab
              _buildAppointmentsList(
                context,
                upcomingAppointments,
                'No upcoming appointments',
                state,
                appointmentIdInProgress,
              ),
              
              // Past appointments tab
              _buildAppointmentsList(
                context,
                pastAppointments,
                'No past appointments',
                state,
                appointmentIdInProgress,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppointmentsList(
    BuildContext context,
    List<AppointmentEntity> appointments,
    String emptyMessage,
    AppointmentsState state,
    String appointmentIdInProgress,
  ) {
    if (appointments.isEmpty) {
      return AppEmptyWidget(
        message: emptyMessage,
        actionLabel: 'Book New Appointment',
        onAction: () {
          context.pushNamedAndRemoveUntil(
            Routes.specialists,
            predicate: (route) => false,
          );
        },
      );
    }

    return ListView.builder(
      padding: AppResponsive.padding(all: 16),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        final isCancelling = state is AppointmentsCancelling && 
                            appointmentIdInProgress == appointment.id;
        
        return AppointmentCard(
          appointment: appointment,
          onTap: () => _navigateToAppointmentDetails(appointment),
          onCancel: _tabController.index == 0 && !appointment.isPast
              ? () => _confirmCancelAppointment(context, appointment)
              : null,
          isLoading: isCancelling,
        );
      },
    );
  }

  void _confirmCancelAppointment(BuildContext context, AppointmentEntity appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Cancel Appointment',
          style: TextStyle(
            fontSize: AppResponsive.sp(AppTheme.heading3),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to cancel this appointment?',
          style: TextStyle(
            fontSize: AppResponsive.sp(AppTheme.bodyMedium),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'No',
              style: TextStyle(
                fontSize: AppResponsive.sp(AppTheme.bodyMedium),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AppointmentsCubit>().cancelAppointment(appointment.id);
            },
            child: Text(
              'Yes',
              style: TextStyle(
                fontSize: AppResponsive.sp(AppTheme.bodyMedium),
              ),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppResponsive.r(12)),
        ),
        contentPadding: AppResponsive.padding(horizontal: 24, vertical: 20),
        actionsPadding: AppResponsive.padding(all: 16),
      ),
    );
  }
}
