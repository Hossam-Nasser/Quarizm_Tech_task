# Specialist Reservation App - Quarizm Tech Task

## Video Walkthrough

A video walkthrough of the application is available at: https://drive.google.com/file/d/1AqH8jh9vqH-TMscFpr_kQa-Mt07gdAgV/view?usp=sharing

## About the Developer
A brief introduction about myself: My name is Hossam, and I'm a mobile developer with two and a half years of experience. I've developed around eleven applications for both Android and iOS using Flutter. Currently, I'm working at a company called HNE Futures.

## Project Overview
A comprehensive Flutter application that allows users to browse specialists (doctors, consultants, trainers) and book appointments with them. Built with clean architecture, Cubit state management, and dependency injection using injectable. The app currently runs using mock data, but Firestore has been implemented as an alternative data store.

## Features

- **User Authentication**: Registration, login, and logout functionality with proper state management
- **Specialists Browsing**: Browse specialists by category or search for specialists by name or specialization
- **Specialist Details**: View specialist information including ratings, reviews, specialization, and biography
- **Appointment Booking**: Select date and time slots to book appointments with specialists
- **Appointment Management**: View, cancel, and reschedule booked appointments
- **Responsive UI**: Beautiful and responsive UI compatible with both Android and iOS


### Installation

1. Clone this repository:
```bash
git clone https://github.com/Hossam-Nasser/Quarizm_Tech_task.git
cd specialist-reservation-app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the code generator for dependency injection:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. Run the app:
```bash
flutter run
```

## Data Storage

The app currently runs using mock data sources by default, providing a ready-to-use experience without any external dependencies. However, Firebase Firestore implementations have been created for all data services:

- **Mock Data**: In-memory storage that simulates network requests and provides consistent test data
- **Firestore**: Complete implementation of all services using Firebase Authentication and Firestore

To switch to Firestore:
Ensure you have set up a Firebase project and added the configuration files to the app

## Firebase Schema

### Database Structure
![Firestore Root Structure](images/firestore_root_structure.png)

### Collection Schemas

#### users/{user_id}:
```json
{
    "id": "string",
    "email": "string",
    "name": "string",
    "profileImage": "string?",
    "createdAt": "timestamp",
    "updatedAt": "timestamp"
}
```

#### appointments/{appointment_id}:
```json
{
    "id": "string",
    "userId": "string",
    "specialistId": "string",
    "appointmentDateTime": "timestamp",
    "endDateTime": "timestamp",
    "status": "string", // ["scheduled", "completed", "cancelled", "rescheduled"]
    "createdAt": "timestamp",
    "updatedAt": "timestamp",
    "specialistName": "string",
    "specialization": "string",
    "specialistImageUrl": "string?"
}
```

#### specialists/{specialist_id}:
```json
{
    "id": "string",
    "name": "string",
    "specialization": "string",
    "workingHours": [
        {
            "dayOfWeek": number,     // 1 = Monday, 2 = Tuesday, etc.
            "from": "timestamp",      // Start time of the working day
            "to": "timestamp",        // End time of the working day
            "isWorkingDay": boolean   // If false, specialist doesn't work this day
        },
        // ... One entry for each day of the week
    ],
    "bio": "string?",                // Optional
    "imageUrl": "string?",           // Optional
    "rating": number,                // Default: 0.0
    "appointmentDurationMinutes": number,  // Default: 30
    "appointmentFee": number,        // Default: 0.0
    "isAvailable": boolean          // Default: true
}
```

### Document References and Queries
- Appointments link to users via userId
- Appointments link to specialists via specialistId

![Appointments Query Example](images/appointments_query.png)

## App Architecture

This application follows Clean Architecture principles with a feature-first approach, organized into three main layers:

### 1. Presentation Layer
- Contains UI components (pages, widgets) 
- Implements state management using Flutter Bloc/Cubit
- Each feature has its own set of cubit/state classes that follow a consistent pattern

### 2. Domain Layer
- Contains business logic (use cases)
- Defines entities that represent core business objects
- Declares repository interfaces that define how data should be accessed

### 3. Data Layer
- Contains repository implementations
- Implements data sources (remote, local)
- Provides models that extend domain entities for data transfer


### Project Structure

```
lib/
├── core/                  # Shared code across features
│   ├── di/                # Dependency injection
│   ├── error/             # Error handling (failures, exceptions)
│   └── util/              # Utilities (constants, widgets, theme, routing)
└── features/              # Feature modules
    ├── auth/              # Authentication feature
    ├── specialists/       # Specialists browsing feature
    └── appointments/      # Appointment booking and management feature
```

Each feature follows the same structure:

```
feature/
├── data/                # Data layer
│   ├── models/           # Data models
│   ├── repositories/     # Repository implementations
│   └── services/         # Data sources
├── domain/              # Domain layer
│   ├── entities/         # Business objects
│   ├── repositories/     # Repository interfaces
│   └── usecases/         # Business logic
└── presentation/        # Presentation layer
    ├── cubit/             # State management
    ├── pages/             # Screens
    └── widgets/           # UI components
```

## Packages Used

The application uses the following packages:

### Firebase
- **firebase_core (^2.27.1)**: Core functionality for all Firebase services
- **firebase_auth (^4.17.9)**: Authentication services
- **cloud_firestore (^4.15.9)**: Cloud-hosted NoSQL database

### State Management
- **flutter_bloc (^8.1.3)**: Implementation of the BLoC pattern
- **equatable (^2.0.5)**: Simplifies equality comparisons

### Dependency Injection
- **get_it (^7.6.7)**: Service locator for dependency injection
- **injectable (^2.3.2)**: Code generation for dependency injection

### UI & Responsiveness
- **google_fonts (^6.2.1)**: Access to Google Fonts
- **cached_network_image (^3.3.1)**: Caching for network images
- **flutter_datetime_picker_plus (^2.1.0)**: Date and time picker
- **flutter_screenutil (^5.9.0)**: Responsive UI utilities

### Utilities
- **dartz (^0.10.1)**: Functional programming features
- **intl (^0.19.0)**: Internationalization and date formatting
- **uuid (^4.3.3)**: UUID generation
- **logger (^2.0.2+1)**: Logging utilities

### Development
- **build_runner (^2.4.8)**: Code generation
- **injectable_generator (^2.4.1)**: Code generation for injectable

## Future Improvements

- Complete Firebase backend integration
- Add push notifications for appointment reminders
- Implement payment integration
- Add ratings and reviews system
- Add multi-language support
- Improve offline support
