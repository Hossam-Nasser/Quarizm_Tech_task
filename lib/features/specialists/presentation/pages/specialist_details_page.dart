import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' as picker;
import 'package:intl/intl.dart';
import 'package:quarizmtask/core/util/responsive/app_responsive.dart';
import 'package:quarizmtask/core/util/routing/extensions.dart';

import '../../../../core/util/constants/app_constants.dart';
import '../../../../core/util/routing/routes.dart';
import '../../../../core/util/theme/app_theme.dart';
import '../../../../core/util/widget/common_widgets.dart';
import '../../../../core/util/widget/date_time_utils.dart';
import '../../domain/entities/specialist_entity.dart';
import '../cubit/specialist_details_cubit.dart';
import '../cubit/specialist_details_state.dart';

class SpecialistDetailsPage extends StatefulWidget {
  final SpecialistEntity specialist;

  const SpecialistDetailsPage({
    Key? key,
    required this.specialist,
  }) : super(key: key);

  @override
  State<SpecialistDetailsPage> createState() => _SpecialistDetailsPageState();
}

class _SpecialistDetailsPageState extends State<SpecialistDetailsPage> {
  @override
  void initState() {
    super.initState();
    // Set specialist directly from navigation arguments
    context.read<SpecialistDetailsCubit>().setSpecialist(widget.specialist);
  }

  void _selectDate(BuildContext context) {
    picker.DatePicker.showDatePicker(
      context,
      showTitleActions: true,
      minTime: DateTime.now(),
      maxTime: DateTime.now().add(const Duration(days: 60)),
      onChanged: (date) {},
      onConfirm: (date) {
        context.read<SpecialistDetailsCubit>().selectDate(date);
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

  void _selectTimeSlot(DateTime timeSlot) {
    context.read<SpecialistDetailsCubit>().selectTimeSlot(timeSlot);
  }

  void _bookAppointment() {
    context.read<SpecialistDetailsCubit>().bookAppointment();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.specialist.name),
      ),
      body: BlocConsumer<SpecialistDetailsCubit, SpecialistDetailsState>(
        listener: (context, state) {
          if (state is SpecialistDetailsBookingSuccess) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(AppConstants.appointmentBookedSuccessMessage),
                backgroundColor: AppTheme.successColor,
              ),
            );

            // Navigate to appointments page
            Future.delayed(const Duration(seconds: 1), () {
              context.pushNamed(
                Routes.appointments,
              );
            });
          } else if (state is SpecialistDetailsBookingError) {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
              ),
            );

            // Reset booking state
            context.read<SpecialistDetailsCubit>().resetBookingState();
          }
        },
        builder: (context, state) {
          // Show loading indicator
          if (state is SpecialistDetailsLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Show error
          if (state is SpecialistDetailsError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () {
                context.read<SpecialistDetailsCubit>().setSpecialist(widget.specialist);
              },
            );
          }

          // Show booking in progress
          if (state is SpecialistDetailsBooking) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  AppResponsive.verticalSpace(16),
                  const Text('Booking your appointment...'),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: AppResponsive.padding(all: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSpecialistHeader(context, state),
                AppResponsive.verticalSpace(24),
                _buildDateSelection(context, state),
                AppResponsive.verticalSpace(24),

                // Only show time slots section if we have a selected date
                if (state is SpecialistDetailsTimeSlotsLoaded ||
                    state is SpecialistDetailsLoadingTimeSlots ||
                    state is SpecialistDetailsTimeSlotsError)
                  _buildTimeSlots(context, state),

                // Show book button if time slot is selected
                if (state is SpecialistDetailsTimeSlotsLoaded && state.selectedTimeSlot != null)
                  Padding(
                    padding: AppResponsive.padding(top: 24),
                    child: AppButton(
                      text: 'Book Appointment',
                      onPressed: _bookAppointment,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSpecialistHeader(BuildContext context, SpecialistDetailsState state) {
    SpecialistEntity? specialist;

    // Extract specialist from various states
    if (state is SpecialistDetailsLoaded) {
      specialist = state.specialist;
    } else if (state is SpecialistDetailsLoadingTimeSlots) {
      specialist = state.specialist;
    } else if (state is SpecialistDetailsTimeSlotsLoaded) {
      specialist = state.specialist;
    } else if (state is SpecialistDetailsTimeSlotsError) {
      specialist = state.specialist;
    } else if (state is SpecialistDetailsBooking) {
      specialist = state.specialist;
    } else if (state is SpecialistDetailsBookingSuccess) {
      specialist = state.specialist;
    } else if (state is SpecialistDetailsBookingError) {
      specialist = state.specialist;
    }

    if (specialist == null) {
      specialist = widget.specialist;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile image and basic info
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile image
            ClipRRect(
              borderRadius: BorderRadius.circular(AppResponsive.r(12)),
              child: specialist.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: specialist.imageUrl!,
                      width: AppResponsive.w(100),
                      height: AppResponsive.h(100),
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: AppResponsive.w(100),
                        height: AppResponsive.h(100),
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.person,
                          size: AppResponsive.r(50),
                          color: Colors.grey[500],
                        ),
                      ),
                    )
                  : Container(
                      width: AppResponsive.w(100),
                      height: AppResponsive.h(100),
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.person,
                        size: AppResponsive.r(50),
                        color: Colors.grey[500],
                      ),
                    ),
            ),

            AppResponsive.horizontalSpace(16),

            // Basic info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    specialist.name,
                    style: TextStyle(
                      fontSize: AppResponsive.sp(AppTheme.heading2),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AppResponsive.verticalSpace(4),
                  Text(
                    specialist.specialization,
                    style: TextStyle(
                      fontSize: AppResponsive.sp(AppTheme.bodyLarge),
                      color: AppTheme.secondaryColor,
                    ),
                  ),
                  AppResponsive.verticalSpace(8),
                  // Rating
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: AppResponsive.r(18),
                        color: Colors.amber,
                      ),
                      AppResponsive.horizontalSpace(4),
                      Text(
                        '${specialist.rating}',
                        style: TextStyle(
                          fontSize: AppResponsive.sp(AppTheme.bodyMedium),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AppResponsive.horizontalSpace(4),
                      Text(
                        '(0 reviews)',
                        style: TextStyle(
                          fontSize: AppResponsive.sp(AppTheme.bodySmall),
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),

        AppResponsive.verticalSpace(16),

        // Bio
        Text(
          'About',
          style: TextStyle(
            fontSize: AppResponsive.sp(AppTheme.heading3),
            fontWeight: FontWeight.bold,
          ),
        ),
        AppResponsive.verticalSpace(8),
        Text(
          specialist.bio ?? "",
          style: TextStyle(
            fontSize: AppResponsive.sp(AppTheme.bodyMedium),
            color: Colors.grey[600],
          ),
        ),

        // Working days
        AppResponsive.verticalSpace(16),
        Text(
          'Working Hours',
          style: TextStyle(
            fontSize: AppResponsive.sp(AppTheme.heading3),
            fontWeight: FontWeight.bold,
          ),
        ),
        AppResponsive.verticalSpace(8),
        _buildWorkingDaysList(specialist.workingHours),
      ],
    );
  }

  Widget _buildWorkingDaysList(List<WorkingHour> workingHours) {
    final List<Widget> dayWidgets = [];

    for (var workingHour in workingHours) {
      dayWidgets.add(
        Padding(
          padding: AppResponsive.padding(bottom: 8),
          child: Row(
            children: [
              SizedBox(
                width: AppResponsive.w(100),
                child: Text(
                  _getDayName(workingHour.dayOfWeek),
                  style: TextStyle(
                    fontSize: AppResponsive.sp(AppTheme.bodyMedium),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${DateTimeUtils.formatTime(workingHour.from)} - ${DateTimeUtils.formatTime(workingHour.to)}',
                style: TextStyle(
                  fontSize: AppResponsive.sp(AppTheme.bodyMedium),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (dayWidgets.isEmpty) {
      return Text(
        'No working days available',
        style: TextStyle(
          fontSize: AppResponsive.sp(AppTheme.bodyMedium),
        ),
      );
    }

    return Column(children: dayWidgets);
  }

  String _getDayName(int dayOfWeek) {
    switch (dayOfWeek) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }

  Widget _buildDateSelection(BuildContext context, SpecialistDetailsState state) {
    // Extract selected date from various states
    DateTime? selectedDate;

    if (state is SpecialistDetailsLoadingTimeSlots) {
      selectedDate = state.selectedDate;
    } else if (state is SpecialistDetailsTimeSlotsLoaded) {
      selectedDate = state.selectedDate;
    } else if (state is SpecialistDetailsTimeSlotsError) {
      selectedDate = state.selectedDate;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select a Date',
          style: TextStyle(
            fontSize: AppResponsive.sp(AppTheme.heading3),
            fontWeight: FontWeight.bold,
          ),
        ),
        AppResponsive.verticalSpace(16),
        AppButton(
          text: selectedDate != null
              ? DateFormat('EEEE, MMMM d, yyyy').format(selectedDate)
              : 'Select a Date',
          isOutlined: true,
          onPressed: () => _selectDate(context),
        ),
      ],
    );
  }

  Widget _buildTimeSlots(BuildContext context, SpecialistDetailsState state) {
    if (state is SpecialistDetailsLoadingTimeSlots) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state is SpecialistDetailsTimeSlotsError) {
      return AppErrorWidget(
        message: state.message,
        onRetry: () {
          context.read<SpecialistDetailsCubit>().selectDate(state.selectedDate);
        },
      );
    }

    if (state is SpecialistDetailsTimeSlotsLoaded) {
      if (state.timeSlots.isEmpty) {
        return const AppEmptyWidget(
          message: 'No available time slots for the selected date',
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select a Time',
            style: TextStyle(
              fontSize: AppResponsive.sp(AppTheme.heading3),
              fontWeight: FontWeight.bold,
            ),
          ),
          AppResponsive.verticalSpace(16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: AppResponsive.w(10),
              mainAxisSpacing: AppResponsive.h(10),
              childAspectRatio: 2.5,
            ),
            itemCount: state.timeSlots.length,
            itemBuilder: (context, index) {
              final timeSlot = state.timeSlots[index];
              final isSelected = state.selectedTimeSlot == timeSlot;

              return GestureDetector(
                onTap: () => _selectTimeSlot(timeSlot),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppResponsive.r(8)),
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryColor : AppTheme.dividerColor,
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    DateTimeUtils.formatTime(timeSlot),
                    style: TextStyle(
                      fontSize: AppResponsive.sp(AppTheme.bodyMedium),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : AppTheme.textColor,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}
