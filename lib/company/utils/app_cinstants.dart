import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Constants',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const AppConstantsScreen(),
    );
  }
}

// ============================================================================
// APP CONSTANTS - All constants defined in one place
// ============================================================================

class AppConstants {
  // App Info
  static const String appName = 'My Awesome App';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  static const String companyName = 'Tech Solutions Inc.';

  // API Configuration
  static const String baseUrl = 'https://api.example.com';
  static const String apiVersion = '/v1';
  static const int connectionTimeout = 30000; // milliseconds
  static const int receiveTimeout = 30000; // milliseconds

  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String logoutEndpoint = '/auth/logout';
  static const String usersEndpoint = '/users';
  static const String productsEndpoint = '/products';
  static const String ordersEndpoint = '/orders';

  // Feature Flags
  static const bool enableNotifications = true;
  static const bool enableOfflineMode = true;
  static const bool enableBiometric = true;
  static const bool enableDarkMode = true;

  // Cache Configuration
  static const int cacheDurationMinutes = 30;
  static const int maxCacheSize = 100; // MB
  static const bool enableImageCache = true;

  // Pagination
  static const int itemsPerPage = 20;
  static const int maxPages = 100;

  // Validation Rules
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int minEmailLength = 5;
  static const int maxEmailLength = 100;

  // Retry Configuration
  static const int maxRetries = 3;
  static const int retryDelaySeconds = 2;

  // Database
  static const String databaseName = 'app_database.db';
  static const int databaseVersion = 1;

  // Shared Preferences Keys
  static const String prefUserToken = 'user_token';
  static const String prefUserId = 'user_id';
  static const String prefUserEmail = 'user_email';
  static const String prefThemeMode = 'theme_mode';
  static const String prefLanguage = 'language';
  static const String prefFontSize = 'font_size';
  static const String prefNotifications = 'notifications_enabled';
  static const String prefBiometric = 'biometric_enabled';

  // Device Limits
  static const int maxFileSizeMB = 50;
  static const int maxImageCount = 10;
  static const int maxVideoLength = 300; // seconds

  // Time Intervals
  static const Duration syncInterval = Duration(minutes: 15);
  static const Duration refreshInterval = Duration(seconds: 5);
  static const Duration debounceInterval = Duration(milliseconds: 500);
  static const Duration animationDuration = Duration(milliseconds: 300);

  // Firebase Configuration
  static const String firebaseProjectId = 'my-project-id';
  static const String firebaseSenderId = 'sender-id';
  static const String firebaseApiKey = 'api-key';

  // Third-party APIs
  static const String googleMapsApiKey = 'your-google-maps-api-key';
  static const String stripeApiKey = 'your-stripe-api-key';

  // Support
  static const String supportEmail = 'support@example.com';
  static const String supportPhoneNumber = '+1-800-123-4567';
  static const String privacyPolicyUrl = 'https://example.com/privacy';
  static const String termsOfServiceUrl = 'https://example.com/terms';

  // Default Values
  static const String defaultLanguage = 'en';
  static const String defaultCurrency = 'USD';
  static const String defaultTimeZone = 'UTC';
}

// ============================================================================
// APP COLORS - All colors defined in one place
// ============================================================================

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFFE3F2FD);

  // Secondary Colors
  static const Color secondary = Color(0xFF03DAC6);
  static const Color secondaryDark = Color(0xFF018786);
  static const Color secondaryLight = Color(0xFFB2EBF2);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color greyDark = Color(0xFF616161);
  static const Color greyLight = Color(0xFFF5F5F5);
  static const Color greySuperLight = Color(0xFFFAFAFA);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFC8E6C9);
  static const Color warning = Color(0xFFFFC107);
  static const Color warningLight = Color(0xFFFFECB3);
  static const Color error = Color(0xFFF44336);
  static const Color errorLight = Color(0xFFEFCDD5);
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFFBBDEFB);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textLight = Color(0xFFEEEEEE);

  // Background Colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);

  // Brand Colors
  static const Color facebook = Color(0xFF1877F2);
  static const Color google = Color(0xFF4285F4);
  static const Color twitter = Color(0xFF1DA1F2);
  static const Color whatsapp = Color(0xFF25D366);
}

// ============================================================================
// APP DIMENSIONS - All sizes and spacing defined
// ============================================================================

class AppDimensions {
  // Padding & Margins
  static const double paddingXXSmall = 4.0;
  static const double paddingXSmall = 8.0;
  static const double paddingSmall = 12.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 20.0;
  static const double paddingXLarge = 24.0;
  static const double paddingXXLarge = 32.0;

  // Border Radius
  static const double radiusXSmall = 4.0;
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  static const double radiusCircle = 50.0;

  // Icon Sizes
  static const double iconXSmall = 16.0;
  static const double iconSmall = 20.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconXLarge = 48.0;

  // Button Sizes
  static const double buttonHeightSmall = 36.0;
  static const double buttonHeightMedium = 44.0;
  static const double buttonHeightLarge = 52.0;
  static const double buttonWidthMin = 100.0;

  // Card Sizes
  static const double cardElevation = 2.0;
  static const double cardElevationHigh = 8.0;

  // Image Sizes
  static const double imageThumbSize = 80.0;
  static const double imageSmallSize = 120.0;
  static const double imageMediumSize = 200.0;
  static const double imageLargeSize = 300.0;

  // Avatar Sizes
  static const double avatarXSmall = 24.0;
  static const double avatarSmall = 32.0;
  static const double avatarMedium = 48.0;
  static const double avatarLarge = 64.0;
  static const double avatarXLarge = 80.0;

  // Input Field
  static const double inputFieldHeight = 48.0;
  static const double inputBorderWidth = 1.0;

  // App Bar
  static const double appBarHeight = 56.0;

  // Bottom Navigation
  static const double bottomNavHeight = 60.0;

  // Divider
  static const double dividerHeight = 1.0;

  // Shadow
  static const double shadowBlur = 8.0;
  static const double shadowSpread = 2.0;
  static const double shadowOpacity = 0.1;

  // Screen Max Width
  static const double screenMaxWidth = 480.0;
}

// ============================================================================
// APP TEXT STYLES - All text styles defined
// ============================================================================

class AppTextStyles {
  // Display Styles
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );

  // Headline Styles
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  // Title Styles
  static const TextStyle titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  // Body Styles
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );
  static const TextStyle buttonText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );
  static const TextStyle caption = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
  );
}

class AppStrings {
  static const String appName = 'My App';
  static const String ok = 'OK';
  static const String cancel = 'Cancel';
  static const String save = 'Save';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String close = 'Close';
  static const String back = 'Back';
  static const String next = 'Next';
  static const String skip = 'Skip';
  static const String submit = 'Submit';
  static const String confirm = 'Confirm';

  static const String login = 'Login';
  static const String logout = 'Logout';
  static const String signup = 'Sign Up';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String rememberMe = 'Remember Me';
  static const String forgotPassword = 'Forgot Password?';
  static const String resetPassword = 'Reset Password';
  static const String newPassword = 'New Password';
  static const String confirmPassword = 'Confirm Password';

  static const String emailRequired = 'Email is required';
  static const String emailInvalid = 'Please enter a valid email';
  static const String passwordRequired = 'Password is required';
  static const String passwordTooShort =
      'Password must be at least 8 characters';
  static const String passwordMismatch = 'Passwords do not match';
  static const String nameRequired = 'Name is required';
  static const String fieldRequired = 'This field is required';

  static const String errorOccurred = 'An error occurred';
  static const String errorConnection = 'Connection error';
  static const String errorTimeout = 'Request timeout';
  static const String errorNotFound = 'Not found';
  static const String errorUnauthorized = 'Unauthorized';
  static const String errorForbidden = 'Forbidden';
  static const String errorServerError = 'Server error';
  static const String errorUnknown = 'Unknown error';
  static const String tryAgain = 'Try Again';
  static const String noInternet = 'No internet connection';

  static const String successSave = 'Saved successfully';
  static const String successDelete = 'Deleted successfully';
  static const String successUpdate = 'Updated successfully';
  static const String successLogout = 'Logged out successfully';

  static const String home = 'Home';
  static const String profile = 'Profile';
  static const String settings = 'Settings';
  static const String help = 'Help';
  static const String about = 'About';
  static const String privacy = 'Privacy Policy';
  static const String terms = 'Terms of Service';

  static const String loading = 'Loading...';
  static const String noData = 'No data available';
  static const String empty = 'Empty';
  static const String search = 'Search';
  static const String filter = 'Filter';
  static const String sort = 'Sort';
}
class AppConstantsScreen extends StatefulWidget {
  const AppConstantsScreen({super.key});

  @override
  State<AppConstantsScreen> createState() => _AppConstantsScreenState();
}

class _AppConstantsScreenState extends State<AppConstantsScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'App Constants',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildTabNavigation(),
            const SizedBox(height: 16),
            _selectedTab == 0
                ? _buildAppConstantsTab()
                : _selectedTab == 1
                ? _buildColorsTab()
                : _selectedTab == 2
                ? _buildDimensionsTab()
                : _buildStringsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabNavigation() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildTabButton(0, 'Constants'),
            _buildTabButton(1, 'Colors'),
            _buildTabButton(2, 'Dimensions'),
            _buildTabButton(3, 'Strings'),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(int index, String label) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.blue,
          ),
        ),
      ),
    );
  }

  Widget _buildAppConstantsTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection('App Information'),
          _buildConstantItem('App Name', AppConstants.appName),
          _buildConstantItem('Version', AppConstants.appVersion),
          _buildConstantItem('Build Number', AppConstants.appBuildNumber),
          _buildConstantItem('Company', AppConstants.companyName),
          const SizedBox(height: 20),
          _buildSection('API Configuration'),
          _buildConstantItem('Base URL', AppConstants.baseUrl),
          _buildConstantItem('API Version', AppConstants.apiVersion),
          _buildConstantItem(
            'Connection Timeout',
            '${AppConstants.connectionTimeout}ms',
          ),
          _buildConstantItem(
            'Receive Timeout',
            '${AppConstants.receiveTimeout}ms',
          ),
          const SizedBox(height: 20),
          _buildSection('Feature Flags'),
          _buildConstantItem(
            'Notifications',
            AppConstants.enableNotifications.toString(),
          ),
          _buildConstantItem(
            'Offline Mode',
            AppConstants.enableOfflineMode.toString(),
          ),
          _buildConstantItem(
            'Biometric',
            AppConstants.enableBiometric.toString(),
          ),
          _buildConstantItem(
            'Dark Mode',
            AppConstants.enableDarkMode.toString(),
          ),
          const SizedBox(height: 20),
          _buildSection('Validation Rules'),
          _buildConstantItem(
            'Min Password Length',
            '${AppConstants.minPasswordLength}',
          ),
          _buildConstantItem(
            'Max Password Length',
            '${AppConstants.maxPasswordLength}',
          ),
          _buildConstantItem(
            'Min Name Length',
            '${AppConstants.minNameLength}',
          ),
          _buildConstantItem(
            'Max Name Length',
            '${AppConstants.maxNameLength}',
          ),
          const SizedBox(height: 20),
          _buildSection('Support'),
          _buildConstantItem('Support Email', AppConstants.supportEmail),
          _buildConstantItem('Support Phone', AppConstants.supportPhoneNumber),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildColorsTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection('Primary Colors'),
          _buildColorItem('Primary', AppColors.primary),
          _buildColorItem('Primary Dark', AppColors.primaryDark),
          _buildColorItem('Primary Light', AppColors.primaryLight),
          const SizedBox(height: 20),
          _buildSection('Secondary Colors'),
          _buildColorItem('Secondary', AppColors.secondary),
          _buildColorItem('Secondary Dark', AppColors.secondaryDark),
          _buildColorItem('Secondary Light', AppColors.secondaryLight),
          const SizedBox(height: 20),
          _buildSection('Status Colors'),
          _buildColorItem('Success', AppColors.success),
          _buildColorItem('Warning', AppColors.warning),
          _buildColorItem('Error', AppColors.error),
          _buildColorItem('Info', AppColors.info),
          const SizedBox(height: 20),
          _buildSection('Neutral Colors'),
          _buildColorItem('Grey', AppColors.grey),
          _buildColorItem('Grey Dark', AppColors.greyDark),
          _buildColorItem('Grey Light', AppColors.greyLight),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDimensionsTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection('Padding & Spacing'),
          _buildDimensionItem('XSmall', '${AppDimensions.paddingXSmall}dp'),
          _buildDimensionItem('Small', '${AppDimensions.paddingSmall}dp'),
          _buildDimensionItem('Medium', '${AppDimensions.paddingMedium}dp'),
          _buildDimensionItem('Large', '${AppDimensions.paddingLarge}dp'),
          _buildDimensionItem('XLarge', '${AppDimensions.paddingXLarge}dp'),
          const SizedBox(height: 20),
          _buildSection('Border Radius'),
          _buildDimensionItem('Small', '${AppDimensions.radiusSmall}dp'),
          _buildDimensionItem('Medium', '${AppDimensions.radiusMedium}dp'),
          _buildDimensionItem('Large', '${AppDimensions.radiusLarge}dp'),
          const SizedBox(height: 20),
          _buildSection('Icon Sizes'),
          _buildDimensionItem('Small', '${AppDimensions.iconSmall}dp'),
          _buildDimensionItem('Medium', '${AppDimensions.iconMedium}dp'),
          _buildDimensionItem('Large', '${AppDimensions.iconLarge}dp'),
          const SizedBox(height: 20),
          _buildSection('Component Heights'),
          _buildDimensionItem(
            'Button Small',
            '${AppDimensions.buttonHeightSmall}dp',
          ),
          _buildDimensionItem(
            'Button Medium',
            '${AppDimensions.buttonHeightMedium}dp',
          ),
          _buildDimensionItem(
            'Button Large',
            '${AppDimensions.buttonHeightLarge}dp',
          ),
          _buildDimensionItem('App Bar', '${AppDimensions.appBarHeight}dp'),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStringsTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection('Common Strings'),
          _buildStringItem('OK', AppStrings.ok),
          _buildStringItem('Cancel', AppStrings.cancel),
          _buildStringItem('Save', AppStrings.save),
          _buildStringItem('Delete', AppStrings.delete),
          const SizedBox(height: 20),
          _buildSection('Authentication'),
          _buildStringItem('Login', AppStrings.login),
          _buildStringItem('Signup', AppStrings.signup),
          _buildStringItem('Email', AppStrings.email),
          _buildStringItem('Password', AppStrings.password),
          const SizedBox(height: 20),
          _buildSection('Validation Messages'),
          _buildStringItem('Email Required', AppStrings.emailRequired),
          _buildStringItem('Email Invalid', AppStrings.emailInvalid),
          _buildStringItem('Password Required', AppStrings.passwordRequired),
          _buildStringItem('Password Too Short', AppStrings.passwordTooShort),
          const SizedBox(height: 20),
          _buildSection('Error Messages'),
          _buildStringItem('Error Occurred', AppStrings.errorOccurred),
          _buildStringItem('Connection Error', AppStrings.errorConnection),
          _buildStringItem('No Internet', AppStrings.noInternet),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSection(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildConstantItem(String name, String value) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorItem(String name, Color color) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey[300]!),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            name,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          Text(
            '#${color.value.toRadixString(16).toUpperCase().padLeft(8, '0')}',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontFamily: 'Courier',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDimensionItem(String name, String value) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          Text(value, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildStringItem(String name, String value) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
