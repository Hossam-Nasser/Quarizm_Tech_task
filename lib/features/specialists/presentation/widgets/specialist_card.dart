import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/util/responsive/app_responsive.dart';
import '../../../../core/util/theme/app_theme.dart';
import '../../domain/entities/specialist_entity.dart';

class SpecialistCard extends StatelessWidget {
  final SpecialistEntity specialist;
  final VoidCallback onTap;

  const SpecialistCard({
    Key? key,
    required this.specialist,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: AppResponsive.margin(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppResponsive.r(16)),
      ),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: AppResponsive.padding(all: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Specialist image
              ClipRRect(
                borderRadius: BorderRadius.circular(AppResponsive.r(12)),
                child: specialist.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: specialist.imageUrl!,
                        width: AppResponsive.w(80),
                        height: AppResponsive.h(80),
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: AppResponsive.w(80),
                          height: AppResponsive.h(80),
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.person,
                            size: AppResponsive.r(40),
                            color: Colors.grey,
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: AppResponsive.w(80),
                          height: AppResponsive.h(80),
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.error,
                            size: AppResponsive.r(40),
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : Container(
                        width: AppResponsive.w(80),
                        height: AppResponsive.h(80),
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.person,
                          size: AppResponsive.r(40),
                          color: Colors.grey,
                        ),
                      ),
              ),
              AppResponsive.horizontalSpace(16),
              
              // Specialist info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and rating
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            specialist.name,
                            style: TextStyle(
                              fontSize: AppResponsive.sp(AppTheme.heading3),
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: AppResponsive.r(16),
                            ),
                            AppResponsive.horizontalSpace(4),
                            Text(
                              specialist.rating.toString(),
                              style: TextStyle(
                                fontSize: AppResponsive.sp(AppTheme.bodySmall),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    AppResponsive.verticalSpace(4),
                    
                    // Specialization
                    Text(
                      specialist.specialization,
                      style: TextStyle(
                        fontSize: AppResponsive.sp(AppTheme.bodyMedium),
                        color: AppTheme.subtitleColor,
                      ),
                    ),
                    AppResponsive.verticalSpace(8),
                    
                    // Bio (if available)
                    if (specialist.bio != null && specialist.bio!.isNotEmpty)
                      Text(
                        specialist.bio!,
                        style: TextStyle(
                          fontSize: AppResponsive.sp(AppTheme.bodySmall),
                          color: AppTheme.textColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    AppResponsive.verticalSpace(8),
                    
                    // Working days
                    Text(
                      'Available: ${_formatWorkingDays(specialist.workingHours)}',
                      style: TextStyle(
                        fontSize: AppResponsive.sp(AppTheme.bodySmall),
                        color: AppTheme.subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatWorkingDays(List<WorkingHour> workingHours) {
    if (workingHours.isEmpty) {
      return 'Not available';
    }

    // Get list of days
    final days = workingHours.map((wh) => wh.dayOfWeek).toList()..sort();
    
    // Convert day numbers to abbreviated day names
    final dayNames = days.map((day) {
      switch (day) {
        case 1:
          return 'Mon';
        case 2:
          return 'Tue';
        case 3:
          return 'Wed';
        case 4:
          return 'Thu';
        case 5:
          return 'Fri';
        case 6:
          return 'Sat';
        case 7:
          return 'Sun';
        default:
          return '';
      }
    }).toList();
    
    // Group consecutive days
    final List<String> result = [];
    int start = 0;
    
    for (int i = 1; i <= dayNames.length; i++) {
      if (i == dayNames.length || dayNames[i] != dayNames[i - 1]) {
        if (start == i - 1) {
          result.add(dayNames[start]);
        } else {
          result.add('${dayNames[start]}-${dayNames[i - 1]}');
        }
        if (i < dayNames.length) {
          start = i;
        }
      }
    }
    
    return result.join(', ');
  }
}
