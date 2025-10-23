class AppConstants {
  static const String appName = 'EventMate';
  static const String appVersion = '1.0.0';

  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;

  static const double iconSizeSmall = 20.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;

  static const Duration animationDurationShort = Duration(milliseconds: 200);
  static const Duration animationDurationMedium = Duration(milliseconds: 300);
  static const Duration animationDurationLong = Duration(milliseconds: 500);

  static const int minPasswordLength = 3;
  static const int minNameLength = 2;

  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNetwork = 'Network error. Please check your connection.';
  static const String errorInvalidEmail = 'Please enter a valid email address.';
  static const String errorPasswordTooShort = 'Password must be at least 6 characters.';
  static const String errorNameTooShort = 'Name must be at least 2 characters.';
  static const String errorFieldRequired = 'This field is required.';
}
