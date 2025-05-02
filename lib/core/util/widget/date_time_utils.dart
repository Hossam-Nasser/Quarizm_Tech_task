import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeUtils {
  // Format date as "Monday, January 1, 2025"
  static String formatFullDate(DateTime date) {
    return DateFormat('EEEE, MMMM d, yyyy').format(date);
  }

  // Format date as "Jan 1, 2025"
  static String formatShortDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  // Format time as "10:30 AM"
  static String formatTime(DateTime time) {
    return DateFormat('h:mm a').format(time);
  }

  // Format date and time as "Jan 1, 2025 at 10:30 AM"
  static String formatDateTime(DateTime dateTime) {
    return '${formatShortDate(dateTime)} at ${formatTime(dateTime)}';
  }

  // Format a time range, e.g. "10:30 AM - 11:30 AM"
  static String formatTimeRange(DateTime start, DateTime end) {
    return '${formatTime(start)} - ${formatTime(end)}';
  }

  // Get a list of time slots for a given date, start time, end time, and duration in minutes
  static List<DateTime> getTimeSlots({
    required DateTime date,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required int durationMinutes,
  }) {
    final List<DateTime> timeSlots = [];
    
    // Create DateTime objects for start and end times on the given date
    final DateTime startDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      startTime.hour,
      startTime.minute,
    );
    
    final DateTime endDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      endTime.hour,
      endTime.minute,
    );
    
    // Calculate the number of time slots that fit within the time range
    DateTime currentSlot = startDateTime;
    
    while (currentSlot.isBefore(endDateTime)) {
      timeSlots.add(currentSlot);
      currentSlot = currentSlot.add(Duration(minutes: durationMinutes));
    }
    
    return timeSlots;
  }

  // Check if two date times are on the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Check if a date is in the past
  static bool isPast(DateTime date) {
    final now = DateTime.now();
    return date.isBefore(now);
  }

  // Check if a date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return isSameDay(date, now);
  }

  // Check if a date is within the next X days
  static bool isWithinNextDays(DateTime date, int days) {
    final now = DateTime.now();
    final future = now.add(Duration(days: days));
    return date.isAfter(now) && date.isBefore(future);
  }

  // Get the time difference in hours between two datetime objects
  static int hoursDifference(DateTime date1, DateTime date2) {
    return date1.difference(date2).inHours;
  }

  // Check if an appointment can be cancelled (e.g., if it's more than 24 hours away)
  static bool canCancelAppointment(DateTime appointmentTime, int thresholdHours) {
    final now = DateTime.now();
    final difference = appointmentTime.difference(now).inHours;
    return difference >= thresholdHours;
  }
}
