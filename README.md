# Budget App

A simple budgeting application for Android built with Flutter.

## Features
- Add income and expense transactions
- View transaction history
- Delete transactions
- Persistent storage using Shared Preferences
- Simple chart view showing net balance over time

## Architecture
- **State Management**: Provider package
- **Persistence**: Shared Preferences
- **UI**: Material Design components

## File Structure
```
lib/
├── main.dart          # Main application code
```

## How to Run
1. Ensure you have Flutter installed and configured
2. Navigate to the project directory
3. Run `flutter pub get` to install dependencies
4. Connect an Android device or start an emulator
5. Run `flutter run` to launch the app

## Dependencies Used
- `provider: ^6.0.5` - State management
- `shared_preferences: ^2.0.15` - Local data storage
- `fl_chart: ^0.40.0` - Simple charting (used in chart view)
- `intl: ^0.18.0` - Internationalization (for date formatting)

## Notes
This is a basic implementation demonstrating core Flutter concepts:
- Stateful widgets for form handling
- Provider for state management
- Persistent data storage
- Navigation between screens
- Material Design components

For production use, consider:
- Adding validation and error handling
- Implementing proper date grouping for charts
- Adding transaction categories
- Using a more robust state management solution (Riverpod, Bloc) for complex apps
- Adding unit and widget tests