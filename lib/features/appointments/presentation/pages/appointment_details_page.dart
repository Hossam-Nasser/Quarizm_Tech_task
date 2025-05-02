import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' as picker;
import 'package:intl/intl.dart';
import 'package:quarizmtask/core/util/responsive/app_responsive.dart';
import 'package:quarizmtask/core/util/routing/extensions.dart';
import 'package:quarizmtask/core/util/routing/routes.dart';

import '../../../../core/util/constants/app_constants.dart';
import '../../../../core/util/theme/app_theme.dart';
import '../../../../core/util/widget/common_widgets.dart';
import '../../../../core/util/widget/date_time_utils.dart';
import '../../../specialists/domain/usecases/get_available_time_slots_usecase.dart';
import '../../domain/entities/appointment_entity.dart';
import '../cubit/appointments_cubit.dart';
import '../cubit/appointments_state.dart';

class AppointmentDetailsPage extends StatefulWidget {
  final AppointmentEntity appointment;

  const AppointmentDetailsPage({
    Key? key,
    required this.appointment,
  }) : super(key: key);

  @override
  State<AppointmentDetailsPage> createState() => _AppointmentDetailsPageState();
}

class _AppointmentDetailsPageState extends State<AppointmentDetailsPage> {
  DateTime? _newDate;
  DateTime? _newTimeSlot;
  List<DateTime> _availableTimeSlots = [];
  bool _isLoadingTimeSlots = false;
  String? _timeSlotError;
  
  void _confirmCancelAppointment() {
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
              _cancelAppointment();
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
      ),
    );
  }
  
  void _cancelAppointment() {
    context.read<AppointmentsCubit>().cancelAppointment(widget.appointment.id);
  }
  
  void _showRescheduleDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppResponsive.r(20))),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: AppResponsive.w(16),
              right: AppResponsive.w(16),
              top: AppResponsive.h(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reschedule Appointment',
                  style: TextStyle(
                    fontSize: AppResponsive.sp(AppTheme.heading2),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AppResponsive.verticalSpace(16),
                
                // Date selection
                Text(
                  'Select new date:',
                  style: TextStyle(
                    fontSize: AppResponsive.sp(AppTheme.bodyLarge),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AppResponsive.verticalSpace(8),
                AppButton(
                  text: _newDate != null
                      ? DateFormat('EEEE, MMMM d, yyyy').format(_newDate!)
                      : 'Select a Date',
                  isOutlined: true,
                  onPressed: () => _selectNewDate(context, setState),
                ),
                AppResponsive.verticalSpace(16),
                
                // Time slots selection (if date is selected)
                if (_newDate != null) ...[
                  Text(
                    'Select new time:',
                    style: TextStyle(
                      fontSize: AppResponsive.sp(AppTheme.bodyLarge),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AppResponsive.verticalSpace(8),
                  
                  _isLoadingTimeSlots
                      ? const Center(child: CircularProgressIndicator())
                      : _timeSlotError != null
                          ? Text(
                              _timeSlotError!,
                              style: TextStyle(
                                color: AppTheme.errorColor,
                                fontSize: AppResponsive.sp(AppTheme.bodyMedium),
                              ),
                            )
                          : _availableTimeSlots.isEmpty
                              ? Text(
                                  'No available time slots for the selected date',
                                  style: TextStyle(
                                    color: AppTheme.subtitleColor,
                                    fontSize: AppResponsive.sp(AppTheme.bodyMedium),
                                  ),
                                )
                              : SizedBox(
                                  height: AppResponsive.h(50),
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _availableTimeSlots.length,
                                    itemBuilder: (context, index) {
                                      final timeSlot = _availableTimeSlots[index];
                                      final isSelected = _newTimeSlot == timeSlot;
                                      
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _newTimeSlot = timeSlot;
                                          });
                                        },
                                        child: Container(
                                          margin: AppResponsive.margin(right: 8),
                                          padding: AppResponsive.padding(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? AppTheme.primaryColor
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(AppResponsive.r(8)),
                                            border: Border.all(
                                              color: isSelected
                                                  ? AppTheme.primaryColor
                                                  : AppTheme.dividerColor,
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            DateTimeUtils.formatTime(timeSlot),
                                            style: TextStyle(
                                              fontSize: AppResponsive.sp(AppTheme.bodyMedium),
                                              fontWeight: isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                              color: isSelected
                                                  ? Colors.white
                                                  : AppTheme.textColor,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                ],
                
                AppResponsive.verticalSpace(24),
                
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: 'Cancel',
                        isOutlined: true,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    AppResponsive.horizontalSpace(16),
                    Expanded(
                      child: AppButton(
                        text: 'Confirm',
                        onPressed: () {
                          if (_newTimeSlot != null) {
                            Navigator.pop(context);
                            _rescheduleAppointment();
                          }
                        },
                        isLoading: _isLoadingTimeSlots,
                        color: _newTimeSlot == null ? Colors.grey : AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
                AppResponsive.verticalSpace(16),
              ],
            ),
          );
        },
      ),
    );
  }
  
  void _selectNewDate(BuildContext context, StateSetter setState) {
    picker.DatePicker.showDatePicker(
      context,
      showTitleActions: true,
      minTime: DateTime.now(),
      maxTime: DateTime.now().add(const Duration(days: 30)),
      onConfirm: (date) {
        setState(() {
          _newDate = date;
          _newTimeSlot = null;
          _isLoadingTimeSlots = true;
        });
        
        // TODO: Replace with actual implementation that uses a cubit
        // This is a simplified implementation for the mockup
        Future.delayed(const Duration(milliseconds: 800), () {
          final Random random = Random();
          final List<DateTime> slots = [];
          
          final DateTime baseTime = DateTime(
            date.year,
            date.month,
            date.day,
            9, // Start at 9 AM
            0,
          );
          
          // Generate random time slots
          for (int i = 0; i < 8; i++) {
            if (random.nextBool()) { // Randomly skip some slots
              final DateTime slotTime = baseTime.add(Duration(minutes: i * 30));
              slots.add(slotTime);
            }
          }
          
          setState(() {
            _availableTimeSlots = slots;
            _isLoadingTimeSlots = false;
            _timeSlotError = slots.isEmpty ? 'No available time slots' : null;
          });
        });
      },
      currentTime: DateTime.now(),
      locale: picker.LocaleType.en,
      theme: picker.DatePickerTheme(
        headerColor: AppTheme.primaryColor,
        backgroundColor: Colors.white,
        itemStyle: TextStyle(
          color: AppTheme.textColor,
          fontWeight: FontWeight.bold,
          fontSize: AppResponsive.sp(18),
        ),
        doneStyle: TextStyle(
          color: Colors.white,
          fontSize: AppResponsive.sp(16),
        ),
        cancelStyle: TextStyle(
          color: Colors.white,
          fontSize: AppResponsive.sp(16),
        ),
      ),
    );
  }
  
  void _rescheduleAppointment() {
    if (_newTimeSlot != null) {
      context.read<AppointmentsCubit>().rescheduleAppointment(
            appointmentId: widget.appointment.id,
            newDateTime: _newTimeSlot!,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Appointment Details',
          style: TextStyle(
            fontSize: AppResponsive.sp(AppTheme.heading3),
          ),
        ),
      ),
      body: BlocConsumer<AppointmentsCubit, AppointmentsState>(
        listener: (context, state) {
          if (state is AppointmentsCancelled) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(AppConstants.appointmentCancelledSuccessMessage),
                backgroundColor: AppTheme.successColor,
              ),
            );
            
            // Navigate back to appointments page
            Future.delayed(const Duration(seconds: 1), () {
              context.pushReplacementNamed(
                Routes.appointments,
              );
            });
          } else if (state is AppointmentsCancelError) {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          } else if (state is AppointmentsRescheduled) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(AppConstants.appointmentRescheduledSuccessMessage),
                backgroundColor: AppTheme.successColor,
              ),
            );
            
            // Navigate back to appointments page
            Future.delayed(const Duration(seconds: 1), () {
              context.pushReplacementNamed(
                Routes.appointments,
              );
            });
          } else if (state is AppointmentsRescheduleError) {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        },
        builder: (context, state) {
          // Determine if currently in a loading state
          final bool isCancelling = state is AppointmentsCancelling && 
              state.appointmentIdInProgress == widget.appointment.id;
          
          final bool isRescheduling = state is AppointmentsRescheduling && 
              state.appointmentIdInProgress == widget.appointment.id;
          
          return SingleChildScrollView(
            padding: AppResponsive.padding(all: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Appointment status card
                _buildStatusCard(isCancelling, isRescheduling),
                
                AppResponsive.verticalSpace(24),
                
                // Specialist info
                _buildSpecialistInfo(),
                
                AppResponsive.verticalSpace(24),
                
                // Appointment info
                _buildAppointmentInfo(),
                
                AppResponsive.verticalSpace(24),
                
                // Cancel/Reschedule buttons for upcoming appointments
                if (!widget.appointment.isPast && !widget.appointment.isCancelled) ...[
                  Column(
                    children: [
                      // Rescheduling button (only for upcoming appointments)
                      AppButton(
                        text: 'Reschedule Appointment',
                        icon: Icons.calendar_month,
                        isOutlined: true,
                        onPressed: _showRescheduleDialog,
                        isLoading: isRescheduling,
                      ),
                      
                      // Cancellation button (only for upcoming appointments)
                      AppButton(
                        text: 'Cancel Appointment',
                        icon: Icons.cancel,
                        color: Colors.red,
                        isOutlined: true,
                        onPressed: _confirmCancelAppointment,
                        isLoading: isCancelling,
                      ),
                      
                      // Back button
                      AppButton(
                        text: 'Back to My Appointments',
                        icon: Icons.arrow_back,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  
                  if (!DateTimeUtils.canCancelAppointment(
                      widget.appointment.appointmentDateTime,
                      AppConstants.cancellationThresholdHours)) ...[
                    AppResponsive.verticalSpace(8),
                    Text(
                      'Appointments can only be modified at least 24 hours in advance',
                      style: TextStyle(
                        color: AppTheme.errorColor,
                        fontSize: AppResponsive.sp(AppTheme.bodySmall),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ] else ...[
                  // Just show back button for past appointments
                  AppButton(
                    text: 'Back to My Appointments',
                    icon: Icons.arrow_back,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildStatusCard(bool isCancelling, bool isRescheduling) {
    final status = widget.appointment.status;
    Color statusColor = AppTheme.primaryColor;
    String statusText = 'Scheduled';
    IconData statusIcon = Icons.event_available;
    
    if (isCancelling) {
      statusColor = Colors.orange;
      statusText = 'Cancelling...';
      statusIcon = Icons.hourglass_top;
    } else if (isRescheduling) {
      statusColor = Colors.orange;
      statusText = 'Rescheduling...';
      statusIcon = Icons.hourglass_top;
    } else {
      switch (status) {
        case AppointmentStatus.scheduled:
          statusColor = AppTheme.primaryColor;
          statusText = 'Scheduled';
          statusIcon = Icons.event_available;
          break;
        case AppointmentStatus.completed:
          statusColor = AppTheme.successColor;
          statusText = 'Completed';
          statusIcon = Icons.check_circle;
          break;
        case AppointmentStatus.cancelled:
          statusColor = AppTheme.errorColor;
          statusText = 'Cancelled';
          statusIcon = Icons.cancel;
          break;
        case AppointmentStatus.rescheduled:
          statusColor = Colors.amber;
          statusText = 'Rescheduled';
          statusIcon = Icons.update;
          break;
      }
    }
    
    return Container(
      padding: AppResponsive.padding(all: 16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppResponsive.r(12)),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: AppResponsive.r(36)),
          AppResponsive.horizontalSpace(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: AppResponsive.sp(AppTheme.bodyLarge),
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                AppResponsive.verticalSpace(4),
                Text(
                  DateFormat('EEEE, MMMM d, yyyy').format(widget.appointment.appointmentDateTime),
                  style: TextStyle(
                    fontSize: AppResponsive.sp(AppTheme.bodyMedium),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AppResponsive.verticalSpace(2),
                Text(
                  DateFormat('h:mm a').format(widget.appointment.appointmentDateTime),
                  style: TextStyle(
                    fontSize: AppResponsive.sp(AppTheme.bodyMedium),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSpecialistInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Doctor Information',
          style: TextStyle(
            fontSize: AppResponsive.sp(AppTheme.heading2),
            fontWeight: FontWeight.bold,
          ),
        ),
        AppResponsive.verticalSpace(16),
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppResponsive.r(8)),
              child: widget.appointment.specialistImageUrl != null 
                ? CachedNetworkImage(
                    imageUrl: widget.appointment.specialistImageUrl!,
                    width: AppResponsive.w(80),
                    height: AppResponsive.h(80),
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  )
                : Container(
                    width: AppResponsive.w(80),
                    height: AppResponsive.h(80),
                    color: Colors.grey[300],
                    child: Icon(Icons.person, size: AppResponsive.r(40), color: Colors.grey),
                  ),
            ),
            AppResponsive.horizontalSpace(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.appointment.specialistName,
                    style: TextStyle(
                      fontSize: AppResponsive.sp(AppTheme.heading3),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AppResponsive.verticalSpace(4),
                  Text(
                    widget.appointment.specialization,
                    style: TextStyle(
                      fontSize: AppResponsive.sp(AppTheme.bodyMedium),
                      color: AppTheme.subtitleColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildAppointmentInfo() {
    // Calculate duration in minutes
    final durationInMinutes = widget.appointment.endDateTime
        .difference(widget.appointment.appointmentDateTime)
        .inMinutes;
        
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Appointment Details',
          style: TextStyle(
            fontSize: AppResponsive.sp(AppTheme.heading2),
            fontWeight: FontWeight.bold,
          ),
        ),
        AppResponsive.verticalSpace(16),
        _buildInfoItem(
          'Date',
          DateFormat('EEEE, MMMM d, yyyy').format(widget.appointment.appointmentDateTime),
          Icons.calendar_today,
        ),
        _buildInfoItem(
          'Time',
          '${DateFormat('h:mm a').format(widget.appointment.appointmentDateTime)} - ${DateFormat('h:mm a').format(widget.appointment.endDateTime)}',
          Icons.access_time,
        ),
        _buildInfoItem(
          'Duration',
          '$durationInMinutes minutes',
          Icons.timer,
        ),
        _buildInfoItem(
          'Status',
          _getStatusText(widget.appointment.status),
          Icons.info_outline,
        ),
        _buildInfoItem(
          'Booked on',
          DateFormat('MMM d, yyyy').format(widget.appointment.createdAt),
          Icons.event_note,
        ),
      ],
    );
  }
  
  String _getStatusText(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return 'Scheduled';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
      case AppointmentStatus.rescheduled:
        return 'Rescheduled';
      default:
        return 'Unknown';
    }
  }
  
  Widget _buildInfoItem(String title, String value, IconData icon) {
    return Padding(
      padding: AppResponsive.padding(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppTheme.subtitleColor,
            size: AppResponsive.r(20),
          ),
          AppResponsive.horizontalSpace(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: AppResponsive.sp(AppTheme.bodyMedium),
                    color: AppTheme.subtitleColor,
                  ),
                ),
                AppResponsive.verticalSpace(2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: AppResponsive.sp(AppTheme.bodyLarge),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
