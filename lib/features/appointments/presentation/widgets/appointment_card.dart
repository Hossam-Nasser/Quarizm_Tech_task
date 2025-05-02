import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quarizmtask/core/util/responsive/app_responsive.dart';

import '../../../../core/util/theme/app_theme.dart';
import '../../../../core/util/widget/date_time_utils.dart';
import '../../domain/entities/appointment_entity.dart';

class AppointmentCard extends StatelessWidget {
  final AppointmentEntity appointment;
  final VoidCallback onTap;
  final VoidCallback? onCancel;
  final bool isLoading;

  const AppointmentCard({
    Key? key,
    required this.appointment,
    required this.onTap,
    this.onCancel,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isPast = appointment.isPast;
    final bool isCancelled = appointment.isCancelled;
    
    return Card(
      margin: AppResponsive.margin(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppResponsive.r(16)),
      ),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppResponsive.r(16)),
        child: Padding(
          padding: AppResponsive.padding(all: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date and time
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Calendar icon with date
                  Container(
                    width: AppResponsive.w(50),
                    height: AppResponsive.h(60),
                    decoration: BoxDecoration(
                      color: isCancelled
                          ? Colors.grey[300]
                          : isPast
                              ? AppTheme.dividerColor
                              : AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppResponsive.r(8)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          appointment.appointmentDateTime.day.toString(),
                          style: TextStyle(
                            fontSize: AppResponsive.sp(20),
                            fontWeight: FontWeight.bold,
                            color: isCancelled
                                ? Colors.grey
                                : isPast
                                    ? AppTheme.subtitleColor
                                    : AppTheme.primaryColor,
                          ),
                        ),
                        Text(
                          _getMonthAbbreviation(appointment.appointmentDateTime.month),
                          style: TextStyle(
                            fontSize: AppResponsive.sp(14),
                            color: isCancelled
                                ? Colors.grey
                                : isPast
                                    ? AppTheme.subtitleColor
                                    : AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppResponsive.horizontalSpace(16),
                  
                  // Appointment details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Specialist name and status indicator
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                appointment.specialistName,
                                style: TextStyle(
                                  fontSize: AppResponsive.sp(AppTheme.heading3),
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            _buildStatusIndicator(),
                          ],
                        ),
                        AppResponsive.verticalSpace(4),
                        
                        // Specialization
                        Text(
                          appointment.specialization,
                          style: TextStyle(
                            fontSize: AppResponsive.sp(AppTheme.bodyMedium),
                            color: AppTheme.subtitleColor,
                          ),
                        ),
                        AppResponsive.verticalSpace(8),
                        
                        // Date and time
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: AppResponsive.r(16),
                              color: AppTheme.subtitleColor,
                            ),
                            AppResponsive.horizontalSpace(4),
                            Expanded(
                              child: Text(
                                '${DateTimeUtils.formatFullDate(appointment.appointmentDateTime)} • ${DateTimeUtils.formatTimeRange(
                                  appointment.appointmentDateTime,
                                  appointment.endDateTime,
                                )}',
                                style: TextStyle(
                                  fontSize: AppResponsive.sp(AppTheme.bodyMedium),
                                  color: AppTheme.subtitleColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              // Cancel button (shown only for upcoming appointments)
              if (onCancel != null) ...[
                AppResponsive.verticalSpace(16),
                const Divider(),
                AppResponsive.verticalSpace(8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: isLoading ? null : onCancel,
                    icon: isLoading
                        ? SizedBox(
                            width: AppResponsive.w(16),
                            height: AppResponsive.h(16),
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.errorColor),
                            ),
                          )
                        : Icon(
                            Icons.cancel,
                            color: AppTheme.errorColor,
                            size: AppResponsive.r(18),
                          ),
                    label: Text(
                      isLoading ? 'Cancelling...' : 'Cancel Appointment',
                      style: TextStyle(
                        color: AppTheme.errorColor,
                        fontSize: AppResponsive.sp(AppTheme.bodyMedium),
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: AppResponsive.padding(vertical: 8),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatusIndicator() {
    if (appointment.isCancelled) {
      return _buildStatusBadge('Cancelled', Colors.grey);
    } else if (appointment.isRescheduled) {
      return _buildStatusBadge('Rescheduled', Colors.orange);
    } else if (appointment.isCompleted) {
      return _buildStatusBadge('Completed', Colors.green);
    } else if (appointment.isPast) {
      return _buildStatusBadge('Missed', Colors.red);
    } else {
      return _buildStatusBadge('Upcoming', AppTheme.primaryColor);
    }
  }
  
  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: AppResponsive.padding(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppResponsive.r(12)),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: AppResponsive.sp(AppTheme.bodySmall),
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  String _getMonthAbbreviation(int month) {
    const List<String> months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}
