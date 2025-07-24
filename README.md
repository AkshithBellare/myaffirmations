# Daily Affirmations App

A beautiful Flutter app for creating and managing personal affirmations with smart notification reminders.

## Features

✨ **Core Features:**
- Create and manage custom affirmations
- Beautiful, modern Material Design 3 UI
- Local storage with SQLite database
- Smart notification system with customizable reminder times
- Activate/deactivate individual affirmations
- Random or sequential affirmation delivery

🔔 **Notification Features:**
- Schedule multiple daily reminders
- Customizable notification times
- Random affirmation selection
- Instant affirmation notifications
- Persistent notification scheduling

📱 **User Experience:**
- Intuitive add/edit interface with helpful tips
- Swipe-to-refresh affirmations list
- Confirmation dialogs for destructive actions
- Loading states and error handling
- Responsive design for all screen sizes

## Getting Started

### Prerequisites
- Flutter SDK (3.8.0 or higher)
- Dart SDK
- For iOS: Xcode and CocoaPods
- For Android: Android Studio and SDK

### Installation

1. Clone or download this project
2. Navigate to the project directory:
   ```bash
   cd affirmations_app
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. For iOS (if running on iOS):
   ```bash
   cd ios && pod install && cd ..
   ```

5. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   ├── affirmation.dart      # Affirmation data model
│   └── notification_settings.dart # Notification settings model
├── services/
│   ├── database_helper.dart  # SQLite database operations
│   └── notification_service.dart # Local notification management
└── screens/
    ├── home_screen.dart      # Main affirmations list
    ├── add_affirmation_screen.dart # Add new affirmations
    └── settings_screen.dart  # Notification settings
```

## Dependencies

- **flutter_local_notifications**: Local push notifications
- **sqflite**: SQLite database for local storage
- **shared_preferences**: Simple key-value storage
- **timezone**: Timezone handling for notifications
- **uuid**: Unique identifier generation
- **intl**: Internationalization and date formatting

## Usage

### Adding Affirmations
1. Tap the "+" button on the home screen
2. Write your positive affirmation
3. Follow the helpful tips for creating effective affirmations
4. Tap "Save" to store your affirmation

### Managing Notifications
1. Tap the settings icon in the app bar
2. Toggle notifications on/off
3. Add custom reminder times by tapping the "+" button
4. Choose between random or sequential affirmation delivery

### Instant Affirmations
- Tap the notification bell icon for an instant affirmation
- Perfect for moments when you need immediate motivation

## Permissions

The app requires notification permissions to send reminder notifications. These are requested automatically when the app starts.

## Platform Support

- ✅ iOS (10.0+)
- ✅ Android (API 21+)
- ✅ macOS
- ✅ Web (limited notification support)

## Contributing

Feel free to contribute to this project by:
- Reporting bugs
- Suggesting new features
- Submitting pull requests
- Improving documentation

## License

This project is open source and available under the MIT License.
