class AppConstants {
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String specialistsCollection = 'specialists';
  static const String appointmentsCollection = 'appointments';
  static const String specialtiesCollection = 'specialties';
  
  // Error Messages
  static const String defaultErrorMessage = 'Something went wrong. Please try again later.';
  static const String networkErrorMessage = 'Network error. Please check your internet connection.';
  static const String authErrorMessage = 'Authentication failed. Please try again.';
  static const String userNotFoundErrorMessage = 'User not found. Please check your credentials.';
  static const String userAlreadyExistsErrorMessage = 'User already exists. Please login instead.';
  static const String appointmentAlreadyBookedErrorMessage = 'This time slot is already booked. Please select another time.';
  static const String appointmentCancellationErrorMessage = 'Failed to cancel appointment. Please try again.';
  static const String appointmentReschedulingErrorMessage = 'Failed to reschedule appointment. Please try again.';
  
  // Success Messages
  static const String registrationSuccessMessage = 'Registration successful! You can now login.';
  static const String loginSuccessMessage = 'Login successful!';
  static const String appointmentBookedSuccessMessage = 'Appointment booked successfully!';
  static const String appointmentCancelledSuccessMessage = 'Appointment cancelled successfully!';
  static const String appointmentRescheduledSuccessMessage = 'Appointment rescheduled successfully!';
  
  // Time Constants
  static const int cancellationThresholdHours = 24; // Hours before appointment when cancellation is allowed
  
  // Animations
  static const Duration animationDuration = Duration(milliseconds: 300);
}
