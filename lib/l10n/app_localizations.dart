import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get appTitle;

  /// No description provided for @settingsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load app settings'**
  String get settingsLoadError;

  /// No description provided for @placesLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load places'**
  String get placesLoadError;

  /// No description provided for @unableToStartApp.
  ///
  /// In en, this message translates to:
  /// **'Unable to start app'**
  String get unableToStartApp;

  /// No description provided for @emDash.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get emDash;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonViewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get commonViewAll;

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// No description provided for @commonFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get commonFailed;

  /// No description provided for @commonNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get commonNext;

  /// No description provided for @commonSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get commonSkip;

  /// No description provided for @commonAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get commonAll;

  /// No description provided for @commonNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get commonNone;

  /// No description provided for @commonNotFound.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get commonNotFound;

  /// No description provided for @commonChooseImage.
  ///
  /// In en, this message translates to:
  /// **'Choose image'**
  String get commonChooseImage;

  /// No description provided for @commonCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get commonCreate;

  /// No description provided for @commonSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get commonSaved;

  /// No description provided for @commonDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get commonDeleted;

  /// No description provided for @commonCreated.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get commonCreated;

  /// No description provided for @commonUser.
  ///
  /// In en, this message translates to:
  /// **'user'**
  String get commonUser;

  /// No description provided for @chooseLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get chooseLanguageTitle;

  /// No description provided for @chooseLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can change this anytime from settings.'**
  String get chooseLanguageSubtitle;

  /// No description provided for @languageFooterAgreement.
  ///
  /// In en, this message translates to:
  /// **'By continuing you agree to a better food decision-making.'**
  String get languageFooterAgreement;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @authDiscoverExplore.
  ///
  /// In en, this message translates to:
  /// **'Discover & Explore'**
  String get authDiscoverExplore;

  /// No description provided for @loginWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get loginWelcomeBack;

  /// No description provided for @loginAdminTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin Login'**
  String get loginAdminTitle;

  /// No description provided for @loginLoggingIn.
  ///
  /// In en, this message translates to:
  /// **'Logging In...'**
  String get loginLoggingIn;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login successful'**
  String get loginSuccess;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Check credentials.'**
  String get loginFailed;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign Up'**
  String get dontHaveAccount;

  /// No description provided for @userLogin.
  ///
  /// In en, this message translates to:
  /// **'User login'**
  String get userLogin;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get continueAsGuest;

  /// No description provided for @adminLoginButton.
  ///
  /// In en, this message translates to:
  /// **'Admin login'**
  String get adminLoginButton;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerTitle;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get registerButton;

  /// No description provided for @registerHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Login'**
  String get registerHaveAccount;

  /// No description provided for @forgotTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get forgotTitle;

  /// No description provided for @forgotSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to reset your password'**
  String get forgotSubtitle;

  /// No description provided for @forgotSubmit.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get forgotSubmit;

  /// No description provided for @forgotBackToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to login'**
  String get forgotBackToLogin;

  /// No description provided for @onboardingDiscoverTitle.
  ///
  /// In en, this message translates to:
  /// **'Discover Restaurants'**
  String get onboardingDiscoverTitle;

  /// No description provided for @onboardingDiscoverBody.
  ///
  /// In en, this message translates to:
  /// **'Find the best restaurants around you with personalized recommendations.'**
  String get onboardingDiscoverBody;

  /// No description provided for @onboardingBranchesTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore Branches'**
  String get onboardingBranchesTitle;

  /// No description provided for @onboardingBranchesBody.
  ///
  /// In en, this message translates to:
  /// **'Locate nearby branches with directions and facilities.'**
  String get onboardingBranchesBody;

  /// No description provided for @onboardingSpinTitle.
  ///
  /// In en, this message translates to:
  /// **'Spin the Wheel'**
  String get onboardingSpinTitle;

  /// No description provided for @onboardingSpinBody.
  ///
  /// In en, this message translates to:
  /// **'Can\'t decide? Let the wheel pick your next dining adventure!'**
  String get onboardingSpinBody;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingSkipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get onboardingSkipForNow;

  /// No description provided for @shellHotDealsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Hot Deals'**
  String get shellHotDealsTooltip;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get navCategories;

  /// No description provided for @navMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get navMap;

  /// No description provided for @navSpin.
  ///
  /// In en, this message translates to:
  /// **'Spin'**
  String get navSpin;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @profileLoggedInUser.
  ///
  /// In en, this message translates to:
  /// **'Logged in user'**
  String get profileLoggedInUser;

  /// No description provided for @profileGuestUser.
  ///
  /// In en, this message translates to:
  /// **'Guest User'**
  String get profileGuestUser;

  /// No description provided for @profileTapSettings.
  ///
  /// In en, this message translates to:
  /// **'Tap settings to manage your account'**
  String get profileTapSettings;

  /// No description provided for @profileSignInSync.
  ///
  /// In en, this message translates to:
  /// **'Sign in to sync your favorites'**
  String get profileSignInSync;

  /// No description provided for @profileVisited.
  ///
  /// In en, this message translates to:
  /// **'Visited'**
  String get profileVisited;

  /// No description provided for @profileFavoritesStat.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get profileFavoritesStat;

  /// No description provided for @profileReviewsStat.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get profileReviewsStat;

  /// No description provided for @profileMyActivity.
  ///
  /// In en, this message translates to:
  /// **'My Activity'**
  String get profileMyActivity;

  /// No description provided for @profileMyFavorites.
  ///
  /// In en, this message translates to:
  /// **'My Favorites'**
  String get profileMyFavorites;

  /// No description provided for @profileMyFavoritesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View saved restaurants'**
  String get profileMyFavoritesSubtitle;

  /// No description provided for @profileNearbyPlaces.
  ///
  /// In en, this message translates to:
  /// **'Nearby Places'**
  String get profileNearbyPlaces;

  /// No description provided for @profileNearbySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Explore on map'**
  String get profileNearbySubtitle;

  /// No description provided for @profileAdminDashboard.
  ///
  /// In en, this message translates to:
  /// **'Admin dashboard'**
  String get profileAdminDashboard;

  /// No description provided for @profileAdminSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage categories and content'**
  String get profileAdminSubtitle;

  /// No description provided for @profileSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileSettings;

  /// No description provided for @profileLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguage;

  /// No description provided for @profileLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get profileLanguageSubtitle;

  /// No description provided for @profileLegal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get profileLegal;

  /// No description provided for @profilePrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get profilePrivacy;

  /// No description provided for @profilePrivacySubtitle.
  ///
  /// In en, this message translates to:
  /// **'How we handle your data'**
  String get profilePrivacySubtitle;

  /// No description provided for @profileTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of service'**
  String get profileTerms;

  /// No description provided for @profileTermsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Rules for using the app'**
  String get profileTermsSubtitle;

  /// No description provided for @profileEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profileEditProfile;

  /// No description provided for @profileEditSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update your information'**
  String get profileEditSubtitle;

  /// No description provided for @profileLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get profileLogout;

  /// No description provided for @profileSignInCreate.
  ///
  /// In en, this message translates to:
  /// **'Sign in or create account'**
  String get profileSignInCreate;

  /// No description provided for @profileCouldNotOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Could not open link'**
  String get profileCouldNotOpenLink;

  /// No description provided for @profileDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get profileDarkMode;

  /// No description provided for @profileDarkModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Toggle dark theme'**
  String get profileDarkModeSubtitle;

  /// No description provided for @adminTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get adminTitle;

  /// No description provided for @adminOpenApp.
  ///
  /// In en, this message translates to:
  /// **'Open app'**
  String get adminOpenApp;

  /// No description provided for @adminMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'Menu admin'**
  String get adminMenuTitle;

  /// No description provided for @adminDrawerCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get adminDrawerCategories;

  /// No description provided for @adminDrawerFacilities.
  ///
  /// In en, this message translates to:
  /// **'Facilities'**
  String get adminDrawerFacilities;

  /// No description provided for @adminDrawerAreas.
  ///
  /// In en, this message translates to:
  /// **'Areas'**
  String get adminDrawerAreas;

  /// No description provided for @adminDrawerRestaurants.
  ///
  /// In en, this message translates to:
  /// **'Restaurants'**
  String get adminDrawerRestaurants;

  /// No description provided for @adminDrawerBranches.
  ///
  /// In en, this message translates to:
  /// **'Branches'**
  String get adminDrawerBranches;

  /// No description provided for @adminDrawerUsers.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get adminDrawerUsers;

  /// No description provided for @adminSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get adminSignOut;

  /// No description provided for @adminDashboardHeadline.
  ///
  /// In en, this message translates to:
  /// **'Admin dashboard'**
  String get adminDashboardHeadline;

  /// No description provided for @adminDashboardHint.
  ///
  /// In en, this message translates to:
  /// **'Use the drawer to open each section.'**
  String get adminDashboardHint;

  /// No description provided for @adminCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get adminCategoriesTitle;

  /// No description provided for @adminNewCategory.
  ///
  /// In en, this message translates to:
  /// **'New category'**
  String get adminNewCategory;

  /// No description provided for @adminEditCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get adminEditCategory;

  /// No description provided for @adminNameEnglish.
  ///
  /// In en, this message translates to:
  /// **'Name (English)'**
  String get adminNameEnglish;

  /// No description provided for @adminNameArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic name'**
  String get adminNameArabic;

  /// No description provided for @adminNameArabicLabel.
  ///
  /// In en, this message translates to:
  /// **'Name (Arabic)'**
  String get adminNameArabicLabel;

  /// No description provided for @adminCategoryImageTitle.
  ///
  /// In en, this message translates to:
  /// **'Category image'**
  String get adminCategoryImageTitle;

  /// No description provided for @adminCategoryImageBody.
  ///
  /// In en, this message translates to:
  /// **'Add an image now? (Required for image-based categories.)'**
  String get adminCategoryImageBody;

  /// No description provided for @adminCategoryDisplayOrderHint.
  ///
  /// In en, this message translates to:
  /// **'Display order'**
  String get adminCategoryDisplayOrderHint;

  /// No description provided for @adminCategoryActiveLabel.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get adminCategoryActiveLabel;

  /// No description provided for @adminCategoryActiveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Inactive categories are hidden in the customer app.'**
  String get adminCategoryActiveSubtitle;

  /// No description provided for @adminCategoryCoverSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Cover image'**
  String get adminCategoryCoverSectionTitle;

  /// No description provided for @adminCategoryIconHint.
  ///
  /// In en, this message translates to:
  /// **'Emoji or icon identifier'**
  String get adminCategoryIconHint;

  /// No description provided for @adminCategoryValidationNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get adminCategoryValidationNameRequired;

  /// No description provided for @adminCategoryValidationNameMax.
  ///
  /// In en, this message translates to:
  /// **'Max 255 characters'**
  String get adminCategoryValidationNameMax;

  /// No description provided for @adminCategoryValidationDisplayOrder.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get adminCategoryValidationDisplayOrder;

  /// No description provided for @adminReorderTooltip.
  ///
  /// In en, this message translates to:
  /// **'Reorder'**
  String get adminReorderTooltip;

  /// No description provided for @adminReorderDoneTooltip.
  ///
  /// In en, this message translates to:
  /// **'Save order'**
  String get adminReorderDoneTooltip;

  /// No description provided for @adminTooltipRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get adminTooltipRefresh;

  /// No description provided for @adminValidationPhoneMax.
  ///
  /// In en, this message translates to:
  /// **'Phone must be at most 20 characters'**
  String get adminValidationPhoneMax;

  /// No description provided for @adminValidationAddressMax.
  ///
  /// In en, this message translates to:
  /// **'Address must be at most 500 characters'**
  String get adminValidationAddressMax;

  /// No description provided for @adminValidationNumberInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get adminValidationNumberInvalid;

  /// No description provided for @adminValidationCostLevelRange.
  ///
  /// In en, this message translates to:
  /// **'Use a number from 1 to 5'**
  String get adminValidationCostLevelRange;

  /// No description provided for @adminValidationTimeMax.
  ///
  /// In en, this message translates to:
  /// **'At most 16 characters'**
  String get adminValidationTimeMax;

  /// No description provided for @adminValidationSelectRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Select a restaurant'**
  String get adminValidationSelectRestaurant;

  /// No description provided for @adminValidationUrlMax.
  ///
  /// In en, this message translates to:
  /// **'URL is too long'**
  String get adminValidationUrlMax;

  /// No description provided for @adminBranchSectionDetails.
  ///
  /// In en, this message translates to:
  /// **'Branch details'**
  String get adminBranchSectionDetails;

  /// No description provided for @adminBranchSectionLocation.
  ///
  /// In en, this message translates to:
  /// **'Location & hours'**
  String get adminBranchSectionLocation;

  /// No description provided for @adminBranchFacilitiesHint.
  ///
  /// In en, this message translates to:
  /// **'Optional — assign now or edit later'**
  String get adminBranchFacilitiesHint;

  /// No description provided for @adminBranchIsOpenLabel.
  ///
  /// In en, this message translates to:
  /// **'Shown as open to customers'**
  String get adminBranchIsOpenLabel;

  /// No description provided for @adminLabelOpenTime.
  ///
  /// In en, this message translates to:
  /// **'Open time'**
  String get adminLabelOpenTime;

  /// No description provided for @adminLabelCloseTime.
  ///
  /// In en, this message translates to:
  /// **'Close time'**
  String get adminLabelCloseTime;

  /// No description provided for @adminWeeklyHoursSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly opening hours'**
  String get adminWeeklyHoursSectionTitle;

  /// No description provided for @adminWeeklyHoursHint.
  ///
  /// In en, this message translates to:
  /// **'Use 24-hour times (HH:mm). Turn on overnight for hours past midnight (e.g. 22:00–02:00).'**
  String get adminWeeklyHoursHint;

  /// No description provided for @adminWeeklyHoursCopyMonday.
  ///
  /// In en, this message translates to:
  /// **'Copy Monday to all days'**
  String get adminWeeklyHoursCopyMonday;

  /// No description provided for @adminWeeklyHoursClosedThisDay.
  ///
  /// In en, this message translates to:
  /// **'Closed this day'**
  String get adminWeeklyHoursClosedThisDay;

  /// No description provided for @adminWeeklyHoursOvernight.
  ///
  /// In en, this message translates to:
  /// **'Overnight (closes after midnight)'**
  String get adminWeeklyHoursOvernight;

  /// No description provided for @adminWeeklyHoursTimeRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter open and close times for each day that is not closed'**
  String get adminWeeklyHoursTimeRequired;

  /// No description provided for @adminWeeklyHoursTimeFormat.
  ///
  /// In en, this message translates to:
  /// **'Use HH:mm in 24-hour format (e.g. 09:30, 22:00)'**
  String get adminWeeklyHoursTimeFormat;

  /// No description provided for @adminSaveOpeningHours.
  ///
  /// In en, this message translates to:
  /// **'Save opening hours'**
  String get adminSaveOpeningHours;

  /// No description provided for @adminNoRestaurants.
  ///
  /// In en, this message translates to:
  /// **'No restaurants'**
  String get adminNoRestaurants;

  /// No description provided for @adminNoBranches.
  ///
  /// In en, this message translates to:
  /// **'No branches'**
  String get adminNoBranches;

  /// No description provided for @adminInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get adminInactive;

  /// No description provided for @adminChangeImageTooltip.
  ///
  /// In en, this message translates to:
  /// **'Change image'**
  String get adminChangeImageTooltip;

  /// No description provided for @adminDeleteCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete category'**
  String get adminDeleteCategoryTitle;

  /// No description provided for @adminDeleteCategoryMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"? This cannot be undone.'**
  String adminDeleteCategoryMessage(String name);

  /// No description provided for @adminOrderSaved.
  ///
  /// In en, this message translates to:
  /// **'Order saved'**
  String get adminOrderSaved;

  /// No description provided for @adminImageUpdated.
  ///
  /// In en, this message translates to:
  /// **'Image updated'**
  String get adminImageUpdated;

  /// No description provided for @adminNoCategories.
  ///
  /// In en, this message translates to:
  /// **'No categories'**
  String get adminNoCategories;

  /// No description provided for @adminFacilitiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Facilities'**
  String get adminFacilitiesTitle;

  /// No description provided for @adminNewFacility.
  ///
  /// In en, this message translates to:
  /// **'New facility'**
  String get adminNewFacility;

  /// No description provided for @adminEditFacility.
  ///
  /// In en, this message translates to:
  /// **'Edit facility'**
  String get adminEditFacility;

  /// No description provided for @adminNoFacilities.
  ///
  /// In en, this message translates to:
  /// **'No facilities'**
  String get adminNoFacilities;

  /// No description provided for @adminFacilityValidationIconMax.
  ///
  /// In en, this message translates to:
  /// **'Max 255 characters'**
  String get adminFacilityValidationIconMax;

  /// No description provided for @adminAreasTitle.
  ///
  /// In en, this message translates to:
  /// **'Areas'**
  String get adminAreasTitle;

  /// No description provided for @adminNewArea.
  ///
  /// In en, this message translates to:
  /// **'New area'**
  String get adminNewArea;

  /// No description provided for @adminEditArea.
  ///
  /// In en, this message translates to:
  /// **'Edit area'**
  String get adminEditArea;

  /// No description provided for @adminNoAreas.
  ///
  /// In en, this message translates to:
  /// **'No areas'**
  String get adminNoAreas;

  /// No description provided for @adminDeleteFacilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete facility'**
  String get adminDeleteFacilityTitle;

  /// No description provided for @adminDeleteFacilityMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String adminDeleteFacilityMessage(String name);

  /// No description provided for @adminDeleteAreaTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete area'**
  String get adminDeleteAreaTitle;

  /// No description provided for @adminDeleteAreaMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String adminDeleteAreaMessage(String name);

  /// No description provided for @adminRestaurantsTitle.
  ///
  /// In en, this message translates to:
  /// **'Restaurants'**
  String get adminRestaurantsTitle;

  /// No description provided for @adminNewRestaurant.
  ///
  /// In en, this message translates to:
  /// **'New restaurant'**
  String get adminNewRestaurant;

  /// No description provided for @adminNameEnPrompt.
  ///
  /// In en, this message translates to:
  /// **'Name (EN)'**
  String get adminNameEnPrompt;

  /// No description provided for @adminNameArPrompt.
  ///
  /// In en, this message translates to:
  /// **'Name (AR)'**
  String get adminNameArPrompt;

  /// No description provided for @adminRestaurantFallback.
  ///
  /// In en, this message translates to:
  /// **'Restaurant'**
  String get adminRestaurantFallback;

  /// No description provided for @adminDeleteRestaurantTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete restaurant'**
  String get adminDeleteRestaurantTitle;

  /// No description provided for @adminDeleteRestaurantBody.
  ///
  /// In en, this message translates to:
  /// **'This removes the restaurant and related data. Continue?'**
  String get adminDeleteRestaurantBody;

  /// No description provided for @adminTabInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get adminTabInfo;

  /// No description provided for @adminTabCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get adminTabCategories;

  /// No description provided for @adminTabPhotos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get adminTabPhotos;

  /// No description provided for @adminTabOffers.
  ///
  /// In en, this message translates to:
  /// **'Offers'**
  String get adminTabOffers;

  /// No description provided for @adminLabelPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get adminLabelPhone;

  /// No description provided for @adminLabelLogoUrl.
  ///
  /// In en, this message translates to:
  /// **'Logo URL'**
  String get adminLabelLogoUrl;

  /// No description provided for @adminLabelDescEn.
  ///
  /// In en, this message translates to:
  /// **'Description EN'**
  String get adminLabelDescEn;

  /// No description provided for @adminLabelDescAr.
  ///
  /// In en, this message translates to:
  /// **'Description AR'**
  String get adminLabelDescAr;

  /// No description provided for @adminSaveCategories.
  ///
  /// In en, this message translates to:
  /// **'Save categories'**
  String get adminSaveCategories;

  /// No description provided for @adminAddPhotoByUrl.
  ///
  /// In en, this message translates to:
  /// **'Add photo by URL'**
  String get adminAddPhotoByUrl;

  /// No description provided for @adminAddPhotoFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Add photo from gallery'**
  String get adminAddPhotoFromGallery;

  /// No description provided for @adminOfferDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get adminOfferDescriptionLabel;

  /// No description provided for @adminOfferImageUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Offer image URL (optional)'**
  String get adminOfferImageUrlLabel;

  /// No description provided for @adminOfferStartDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get adminOfferStartDate;

  /// No description provided for @adminOfferEndDate.
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get adminOfferEndDate;

  /// No description provided for @adminNoPhotosPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'No photos yet'**
  String get adminNoPhotosPlaceholder;

  /// No description provided for @adminNoOffersPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'No offers yet'**
  String get adminNoOffersPlaceholder;

  /// No description provided for @adminNewOffer.
  ///
  /// In en, this message translates to:
  /// **'New offer'**
  String get adminNewOffer;

  /// No description provided for @adminImageUrlPrompt.
  ///
  /// In en, this message translates to:
  /// **'Image URL'**
  String get adminImageUrlPrompt;

  /// No description provided for @adminOfferTitlePrompt.
  ///
  /// In en, this message translates to:
  /// **'Offer title'**
  String get adminOfferTitlePrompt;

  /// No description provided for @adminCategoriesUpdated.
  ///
  /// In en, this message translates to:
  /// **'Categories updated'**
  String get adminCategoriesUpdated;

  /// No description provided for @adminPhotoAdded.
  ///
  /// In en, this message translates to:
  /// **'Photo added'**
  String get adminPhotoAdded;

  /// No description provided for @adminOfferCreated.
  ///
  /// In en, this message translates to:
  /// **'Offer created'**
  String get adminOfferCreated;

  /// No description provided for @adminUserActionsNote.
  ///
  /// In en, this message translates to:
  /// **'Role changes and bans require new API endpoints.'**
  String get adminUserActionsNote;

  /// No description provided for @adminUsersTitle.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get adminUsersTitle;

  /// No description provided for @adminUserDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get adminUserDetailTitle;

  /// No description provided for @adminLabelName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get adminLabelName;

  /// No description provided for @adminLabelRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get adminLabelRole;

  /// No description provided for @adminLabelPhoneField.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get adminLabelPhoneField;

  /// No description provided for @adminLabelGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get adminLabelGender;

  /// No description provided for @adminLabelBirthDate.
  ///
  /// In en, this message translates to:
  /// **'Birth date'**
  String get adminLabelBirthDate;

  /// No description provided for @adminLabelCreated.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get adminLabelCreated;

  /// No description provided for @adminBranchesTitle.
  ///
  /// In en, this message translates to:
  /// **'Branches'**
  String get adminBranchesTitle;

  /// No description provided for @adminNewBranch.
  ///
  /// In en, this message translates to:
  /// **'New branch'**
  String get adminNewBranch;

  /// No description provided for @adminFilterRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Filter by restaurant'**
  String get adminFilterRestaurant;

  /// No description provided for @adminRestaurantPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Restaurant'**
  String get adminRestaurantPickerTitle;

  /// No description provided for @adminBranchNameEn.
  ///
  /// In en, this message translates to:
  /// **'Branch name (EN)'**
  String get adminBranchNameEn;

  /// No description provided for @adminBranchNameAr.
  ///
  /// In en, this message translates to:
  /// **'Branch name (AR)'**
  String get adminBranchNameAr;

  /// No description provided for @adminCreateRestaurantFirst.
  ///
  /// In en, this message translates to:
  /// **'Create a restaurant first'**
  String get adminCreateRestaurantFirst;

  /// No description provided for @adminBranchTitle.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get adminBranchTitle;

  /// No description provided for @adminDeleteBranchTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete branch'**
  String get adminDeleteBranchTitle;

  /// No description provided for @adminDeleteBranchBody.
  ///
  /// In en, this message translates to:
  /// **'Delete this branch?'**
  String get adminDeleteBranchBody;

  /// No description provided for @adminLabelNameEn.
  ///
  /// In en, this message translates to:
  /// **'Name EN'**
  String get adminLabelNameEn;

  /// No description provided for @adminLabelNameAr.
  ///
  /// In en, this message translates to:
  /// **'Name AR'**
  String get adminLabelNameAr;

  /// No description provided for @adminLabelAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get adminLabelAddress;

  /// No description provided for @adminLabelLatitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get adminLabelLatitude;

  /// No description provided for @adminLabelLongitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get adminLabelLongitude;

  /// No description provided for @adminLabelCostLevel.
  ///
  /// In en, this message translates to:
  /// **'Cost level (1–5)'**
  String get adminLabelCostLevel;

  /// No description provided for @adminLabelArea.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get adminLabelArea;

  /// No description provided for @adminDeleteBranch.
  ///
  /// In en, this message translates to:
  /// **'Delete branch'**
  String get adminDeleteBranch;

  /// No description provided for @adminUploadMenuImage.
  ///
  /// In en, this message translates to:
  /// **'Upload menu image'**
  String get adminUploadMenuImage;

  /// No description provided for @adminUploaded.
  ///
  /// In en, this message translates to:
  /// **'Uploaded'**
  String get adminUploaded;

  /// No description provided for @adminSaveFacilities.
  ///
  /// In en, this message translates to:
  /// **'Save facilities'**
  String get adminSaveFacilities;

  /// No description provided for @adminFacilitiesSaved.
  ///
  /// In en, this message translates to:
  /// **'Facilities saved'**
  String get adminFacilitiesSaved;

  /// No description provided for @adminIconOptional.
  ///
  /// In en, this message translates to:
  /// **'Icon (optional)'**
  String get adminIconOptional;

  /// No description provided for @categoriesPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categoriesPageTitle;

  /// No description provided for @placesPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Places'**
  String get placesPageTitle;

  /// No description provided for @offersPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Offers'**
  String get offersPageTitle;

  /// No description provided for @favoritesPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesPageTitle;

  /// No description provided for @searchResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchResultsTitle;

  /// No description provided for @spinPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Spin'**
  String get spinPageTitle;

  /// No description provided for @mapNearbyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nearby'**
  String get mapNearbyTitle;

  /// No description provided for @homeNearby.
  ///
  /// In en, this message translates to:
  /// **'Nearby'**
  String get homeNearby;

  /// No description provided for @homeMostVoted.
  ///
  /// In en, this message translates to:
  /// **'Most voted'**
  String get homeMostVoted;

  /// No description provided for @homeRecommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get homeRecommended;

  /// No description provided for @homeDiscover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get homeDiscover;

  /// No description provided for @homeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search restaurants or categories'**
  String get homeSearchHint;

  /// No description provided for @homeNearbyPlaces.
  ///
  /// In en, this message translates to:
  /// **'Nearby places'**
  String get homeNearbyPlaces;

  /// No description provided for @homeNearbyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No nearby places match your filters'**
  String get homeNearbyEmpty;

  /// No description provided for @homeMostVotedTitle.
  ///
  /// In en, this message translates to:
  /// **'Most voted'**
  String get homeMostVotedTitle;

  /// No description provided for @homeMostVotedEmpty.
  ///
  /// In en, this message translates to:
  /// **'No places to rank yet'**
  String get homeMostVotedEmpty;

  /// No description provided for @homeRecommendedTitle.
  ///
  /// In en, this message translates to:
  /// **'Recommended for you'**
  String get homeRecommendedTitle;

  /// No description provided for @homeRecommendedEmpty.
  ///
  /// In en, this message translates to:
  /// **'No recommendations available'**
  String get homeRecommendedEmpty;

  /// No description provided for @filtersTitle.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filtersTitle;

  /// No description provided for @filterPriceRange.
  ///
  /// In en, this message translates to:
  /// **'Price Range'**
  String get filterPriceRange;

  /// No description provided for @filterMinRating.
  ///
  /// In en, this message translates to:
  /// **'Minimum Rating'**
  String get filterMinRating;

  /// No description provided for @filterDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get filterDistance;

  /// No description provided for @filterWithinKm.
  ///
  /// In en, this message translates to:
  /// **'Within {km} km'**
  String filterWithinKm(String km);

  /// No description provided for @filterLimitByDistance.
  ///
  /// In en, this message translates to:
  /// **'Limit by distance'**
  String get filterLimitByDistance;

  /// No description provided for @filterAvailability.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get filterAvailability;

  /// No description provided for @filterOpenNowOnly.
  ///
  /// In en, this message translates to:
  /// **'Open now only'**
  String get filterOpenNowOnly;

  /// No description provided for @filterCuisineType.
  ///
  /// In en, this message translates to:
  /// **'Cuisine Type'**
  String get filterCuisineType;

  /// No description provided for @filterCuisineSelected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get filterCuisineSelected;

  /// No description provided for @filterFacilities.
  ///
  /// In en, this message translates to:
  /// **'Facilities'**
  String get filterFacilities;

  /// No description provided for @filterNoFacilities.
  ///
  /// In en, this message translates to:
  /// **'No facilities configured yet'**
  String get filterNoFacilities;

  /// No description provided for @unableToLoad.
  ///
  /// In en, this message translates to:
  /// **'Unable to load'**
  String get unableToLoad;

  /// No description provided for @unableToLoadFacilities.
  ///
  /// In en, this message translates to:
  /// **'Unable to load facilities'**
  String get unableToLoadFacilities;

  /// No description provided for @sortVotes.
  ///
  /// In en, this message translates to:
  /// **'votes'**
  String get sortVotes;

  /// No description provided for @sortNewest.
  ///
  /// In en, this message translates to:
  /// **'newest'**
  String get sortNewest;

  /// No description provided for @filterApply.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters ({count})'**
  String filterApply(int count);

  /// No description provided for @filterResetAll.
  ///
  /// In en, this message translates to:
  /// **'Reset All'**
  String get filterResetAll;

  /// No description provided for @filtersActiveOne.
  ///
  /// In en, this message translates to:
  /// **'1 active filter'**
  String get filtersActiveOne;

  /// No description provided for @filtersActiveMany.
  ///
  /// In en, this message translates to:
  /// **'{count} active filters'**
  String filtersActiveMany(int count);

  /// No description provided for @filterMin.
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get filterMin;

  /// No description provided for @filterMax.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get filterMax;

  /// No description provided for @filterAny.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get filterAny;

  /// No description provided for @filterKmShort.
  ///
  /// In en, this message translates to:
  /// **'{km} km'**
  String filterKmShort(String km);

  /// No description provided for @filterFacilitiesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String filterFacilitiesCount(int count);

  /// No description provided for @homeSpinBanner.
  ///
  /// In en, this message translates to:
  /// **'Spin to Decide Where to Eat'**
  String get homeSpinBanner;

  /// No description provided for @placesSortTitle.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get placesSortTitle;

  /// No description provided for @categoriesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No categories'**
  String get categoriesEmpty;

  /// No description provided for @offersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No offers right now'**
  String get offersEmpty;

  /// No description provided for @favoritesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get favoritesEmpty;

  /// No description provided for @favoritesEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Save restaurants you love from details'**
  String get favoritesEmptyHint;

  /// No description provided for @searchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get searchNoResults;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get commonLoading;

  /// No description provided for @commonError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get commonError;

  /// No description provided for @restaurantDetails.
  ///
  /// In en, this message translates to:
  /// **'Restaurant'**
  String get restaurantDetails;

  /// No description provided for @branchDetails.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get branchDetails;

  /// No description provided for @directions.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get directions;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @openNow.
  ///
  /// In en, this message translates to:
  /// **'Open now'**
  String get openNow;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @distanceKm.
  ///
  /// In en, this message translates to:
  /// **'{km} km away'**
  String distanceKm(String km);

  /// No description provided for @submitReview.
  ///
  /// In en, this message translates to:
  /// **'Submit review'**
  String get submitReview;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @comment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get comment;

  /// No description provided for @voteUp.
  ///
  /// In en, this message translates to:
  /// **'Upvote'**
  String get voteUp;

  /// No description provided for @voteDown.
  ///
  /// In en, this message translates to:
  /// **'Downvote'**
  String get voteDown;

  /// No description provided for @addToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get addToFavorites;

  /// No description provided for @removeFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get removeFromFavorites;

  /// No description provided for @spinTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Spin again'**
  String get spinTryAgain;

  /// No description provided for @spinResult.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get spinResult;

  /// No description provided for @mapUserLocation.
  ///
  /// In en, this message translates to:
  /// **'Your location'**
  String get mapUserLocation;

  /// No description provided for @mapPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied'**
  String get mapPermissionDenied;

  /// No description provided for @mapOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get mapOpenSettings;

  /// No description provided for @registerName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get registerName;

  /// No description provided for @registerBirthDate.
  ///
  /// In en, this message translates to:
  /// **'Birth date'**
  String get registerBirthDate;

  /// No description provided for @registerGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get registerGender;

  /// No description provided for @registerPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get registerPhone;

  /// No description provided for @genderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemale;

  /// No description provided for @genderOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get genderOther;

  /// No description provided for @registerSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account created. You can now log in.'**
  String get registerSuccess;

  /// No description provided for @registerFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign up failed.'**
  String get registerFailed;

  /// No description provided for @registerSigningUp.
  ///
  /// In en, this message translates to:
  /// **'Signing Up...'**
  String get registerSigningUp;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterName;

  /// No description provided for @forgotCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get forgotCardTitle;

  /// No description provided for @forgotSuccessSnack.
  ///
  /// In en, this message translates to:
  /// **'If an account exists, you\'ll receive an email shortly.'**
  String get forgotSuccessSnack;

  /// No description provided for @forgotFailSnack.
  ///
  /// In en, this message translates to:
  /// **'Could not request password reset.'**
  String get forgotFailSnack;

  /// No description provided for @forgotSending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get forgotSending;

  /// No description provided for @registerBirthDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Birth Date'**
  String get registerBirthDateLabel;

  /// No description provided for @registerSelectBirthDate.
  ///
  /// In en, this message translates to:
  /// **'Select your birth date'**
  String get registerSelectBirthDate;

  /// No description provided for @registerSelectGender.
  ///
  /// In en, this message translates to:
  /// **'Select your gender'**
  String get registerSelectGender;

  /// No description provided for @registerPhoneNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get registerPhoneNumberLabel;

  /// No description provided for @registerEnterPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get registerEnterPhone;

  /// No description provided for @registerPasswordMin.
  ///
  /// In en, this message translates to:
  /// **'Min 6 characters'**
  String get registerPasswordMin;

  /// No description provided for @legalUrlsTestPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get legalUrlsTestPlaceholder;

  /// No description provided for @categoriesExploreSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Explore restaurants by category'**
  String get categoriesExploreSubtitle;

  /// No description provided for @categoriesSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search categories...'**
  String get categoriesSearchHint;

  /// No description provided for @categoriesLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load categories'**
  String get categoriesLoadError;

  /// No description provided for @categoriesNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No categories match \"{query}\"'**
  String categoriesNoMatch(String query);

  /// No description provided for @categoriesTryDifferentSearch.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term'**
  String get categoriesTryDifferentSearch;

  /// No description provided for @categoriesEmptyYet.
  ///
  /// In en, this message translates to:
  /// **'No categories yet'**
  String get categoriesEmptyYet;

  /// No description provided for @favoritesSignInPrompt.
  ///
  /// In en, this message translates to:
  /// **'Sign in to view your favorites'**
  String get favoritesSignInPrompt;

  /// No description provided for @favoritesSignInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get favoritesSignInButton;

  /// No description provided for @favoritesSavedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} saved places'**
  String favoritesSavedCount(int count);

  /// No description provided for @offersLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load offers'**
  String get offersLoadError;

  /// No description provided for @offersViewRestaurant.
  ///
  /// In en, this message translates to:
  /// **'View restaurant'**
  String get offersViewRestaurant;

  /// No description provided for @restaurantsNoneFound.
  ///
  /// In en, this message translates to:
  /// **'No restaurants found'**
  String get restaurantsNoneFound;

  /// No description provided for @restaurantsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load restaurants'**
  String get restaurantsLoadError;

  /// No description provided for @searchAllRestaurants.
  ///
  /// In en, this message translates to:
  /// **'All restaurants'**
  String get searchAllRestaurants;

  /// No description provided for @searchResultsFor.
  ///
  /// In en, this message translates to:
  /// **'Results for \"{query}\"'**
  String searchResultsFor(String query);

  /// No description provided for @placesListEmpty.
  ///
  /// In en, this message translates to:
  /// **'No places found'**
  String get placesListEmpty;

  /// No description provided for @restaurantLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load restaurant: {message}'**
  String restaurantLoadError(String message);

  /// No description provided for @restaurantNoBranches.
  ///
  /// In en, this message translates to:
  /// **'No branches for this restaurant'**
  String get restaurantNoBranches;

  /// No description provided for @restaurantBranchesLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load branches'**
  String get restaurantBranchesLoadError;

  /// No description provided for @restaurantNoBranchesReview.
  ///
  /// In en, this message translates to:
  /// **'No branches to review yet'**
  String get restaurantNoBranchesReview;

  /// No description provided for @restaurantNoReviewsYet.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get restaurantNoReviewsYet;

  /// No description provided for @restaurantReviewsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load reviews'**
  String get restaurantReviewsLoadError;

  /// No description provided for @restaurantBranchesForReviewsError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load branches for reviews'**
  String get restaurantBranchesForReviewsError;

  /// No description provided for @restaurantNoBranchesMenu.
  ///
  /// In en, this message translates to:
  /// **'No branches to show menu yet'**
  String get restaurantNoBranchesMenu;

  /// No description provided for @restaurantMenuNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Menu not available yet'**
  String get restaurantMenuNotAvailable;

  /// No description provided for @restaurantMenuImagesLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load menu images'**
  String get restaurantMenuImagesLoadError;

  /// No description provided for @restaurantBranchesForMenuError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load branches for menu'**
  String get restaurantBranchesForMenuError;

  /// No description provided for @restaurantNoPhotosYet.
  ///
  /// In en, this message translates to:
  /// **'No photos yet'**
  String get restaurantNoPhotosYet;

  /// No description provided for @restaurantPhotosLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load photos'**
  String get restaurantPhotosLoadError;

  /// No description provided for @reviewLoginRequired.
  ///
  /// In en, this message translates to:
  /// **'Please log in to write a review.'**
  String get reviewLoginRequired;

  /// No description provided for @restaurantWriteReview.
  ///
  /// In en, this message translates to:
  /// **'Write a review'**
  String get restaurantWriteReview;

  /// No description provided for @restaurantLoginToWriteReview.
  ///
  /// In en, this message translates to:
  /// **'Log in to write a review'**
  String get restaurantLoginToWriteReview;

  /// No description provided for @favoriteUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Could not update favorite. Please try again.'**
  String get favoriteUpdateError;

  /// No description provided for @tabBranches.
  ///
  /// In en, this message translates to:
  /// **'Branches'**
  String get tabBranches;

  /// No description provided for @tabMenu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get tabMenu;

  /// No description provided for @tabPhotos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get tabPhotos;

  /// No description provided for @tabReviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get tabReviews;

  /// No description provided for @labelCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get labelCategory;

  /// No description provided for @labelTotalVotes.
  ///
  /// In en, this message translates to:
  /// **'Total votes'**
  String get labelTotalVotes;

  /// No description provided for @labelBranchesCount.
  ///
  /// In en, this message translates to:
  /// **'Branches'**
  String get labelBranchesCount;

  /// No description provided for @facilitiesSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Facilities'**
  String get facilitiesSectionTitle;

  /// No description provided for @reviewSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Review submitted'**
  String get reviewSubmitted;

  /// No description provided for @reviewSubmitFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit review'**
  String get reviewSubmitFailed;

  /// No description provided for @rateThisBranch.
  ///
  /// In en, this message translates to:
  /// **'Rate this branch'**
  String get rateThisBranch;

  /// No description provided for @reviewCommentOptional.
  ///
  /// In en, this message translates to:
  /// **'Write your review (optional)'**
  String get reviewCommentOptional;

  /// No description provided for @reviewSubmitting.
  ///
  /// In en, this message translates to:
  /// **'Submitting...'**
  String get reviewSubmitting;

  /// No description provided for @branchOpeningHours.
  ///
  /// In en, this message translates to:
  /// **'Opening hours'**
  String get branchOpeningHours;

  /// No description provided for @branchHoursOvernightFootnote.
  ///
  /// In en, this message translates to:
  /// **'* Hours extend past midnight'**
  String get branchHoursOvernightFootnote;

  /// No description provided for @branchNoFacilities.
  ///
  /// In en, this message translates to:
  /// **'No facilities information'**
  String get branchNoFacilities;

  /// No description provided for @branchVotesUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Votes unavailable'**
  String get branchVotesUnavailable;

  /// No description provided for @branchNavigateGoogleMaps.
  ///
  /// In en, this message translates to:
  /// **'Navigate with Google Maps'**
  String get branchNavigateGoogleMaps;

  /// No description provided for @voteLoginRequired.
  ///
  /// In en, this message translates to:
  /// **'Please log in to vote.'**
  String get voteLoginRequired;

  /// No description provided for @spinWhatToEat.
  ///
  /// In en, this message translates to:
  /// **'What to eat?'**
  String get spinWhatToEat;

  /// No description provided for @spinWhereToEat.
  ///
  /// In en, this message translates to:
  /// **'Where to eat?'**
  String get spinWhereToEat;

  /// No description provided for @spinUnableLoadOptions.
  ///
  /// In en, this message translates to:
  /// **'Unable to load options.'**
  String get spinUnableLoadOptions;

  /// No description provided for @mapFilterCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter categories'**
  String get mapFilterCategoriesTitle;

  /// No description provided for @mapApplyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply filters'**
  String get mapApplyFilters;

  /// No description provided for @mapViewDetails.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get mapViewDetails;

  /// No description provided for @branchAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get branchAddressLabel;

  /// No description provided for @branchHoursNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Hours not available'**
  String get branchHoursNotAvailable;

  /// No description provided for @branchClosedToday.
  ///
  /// In en, this message translates to:
  /// **'Closed today'**
  String get branchClosedToday;

  /// No description provided for @branchServicesFacilities.
  ///
  /// In en, this message translates to:
  /// **'Services & facilities'**
  String get branchServicesFacilities;

  /// No description provided for @branchViewMenu.
  ///
  /// In en, this message translates to:
  /// **'View menu'**
  String get branchViewMenu;

  /// No description provided for @branchMenuUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Menu not available'**
  String get branchMenuUnavailable;

  /// No description provided for @voteCountUp.
  ///
  /// In en, this message translates to:
  /// **'{count} upvotes'**
  String voteCountUp(int count);

  /// No description provided for @voteCountDown.
  ///
  /// In en, this message translates to:
  /// **'{count} downvotes'**
  String voteCountDown(int count);

  /// No description provided for @spinHeadline.
  ///
  /// In en, this message translates to:
  /// **'Not sure what to eat?'**
  String get spinHeadline;

  /// No description provided for @spinSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Spin the wheel for a category (What to eat?) or a restaurant (Where to eat?)'**
  String get spinSubtitle;

  /// No description provided for @spinFilterByCategory.
  ///
  /// In en, this message translates to:
  /// **'Filter by category (optional)'**
  String get spinFilterByCategory;

  /// No description provided for @spinSpinning.
  ///
  /// In en, this message translates to:
  /// **'Spinning...'**
  String get spinSpinning;

  /// No description provided for @spinNow.
  ///
  /// In en, this message translates to:
  /// **'Spin now'**
  String get spinNow;

  /// No description provided for @spinEmptyCategories.
  ///
  /// In en, this message translates to:
  /// **'No categories. Try removing filters.'**
  String get spinEmptyCategories;

  /// No description provided for @spinEmptyRestaurants.
  ///
  /// In en, this message translates to:
  /// **'No restaurants. Try different categories.'**
  String get spinEmptyRestaurants;

  /// No description provided for @spinNeedTwoOptions.
  ///
  /// In en, this message translates to:
  /// **'Need at least 2 options to spin.'**
  String get spinNeedTwoOptions;

  /// No description provided for @spinYouShouldEat.
  ///
  /// In en, this message translates to:
  /// **'You should eat...'**
  String get spinYouShouldEat;

  /// No description provided for @spinWhereToEatEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Where to eat...'**
  String get spinWhereToEatEllipsis;

  /// No description provided for @spinExploreCategory.
  ///
  /// In en, this message translates to:
  /// **'Explore this category'**
  String get spinExploreCategory;

  /// No description provided for @mapNoOpenBranches.
  ///
  /// In en, this message translates to:
  /// **'No open branches nearby'**
  String get mapNoOpenBranches;

  /// No description provided for @mapNoBranchesYet.
  ///
  /// In en, this message translates to:
  /// **'No branches nearby yet'**
  String get mapNoBranchesYet;

  /// No description provided for @mapNavigateTooltip.
  ///
  /// In en, this message translates to:
  /// **'Navigate'**
  String get mapNavigateTooltip;

  /// No description provided for @mapLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading map…'**
  String get mapLoading;

  /// No description provided for @mapLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load map data'**
  String get mapLoadError;

  /// No description provided for @mapTitle.
  ///
  /// In en, this message translates to:
  /// **'Restaurants map'**
  String get mapTitle;

  /// No description provided for @mapBranchesAroundYou.
  ///
  /// In en, this message translates to:
  /// **'{count} branches around you'**
  String mapBranchesAroundYou(int count);

  /// No description provided for @mapOpenBranchesAroundYou.
  ///
  /// In en, this message translates to:
  /// **'{count} open branches around you'**
  String mapOpenBranchesAroundYou(int count);

  /// No description provided for @mapFilteredSuffix.
  ///
  /// In en, this message translates to:
  /// **' (filtered)'**
  String get mapFilteredSuffix;

  /// No description provided for @mapSheetRestaurantDetails.
  ///
  /// In en, this message translates to:
  /// **'Restaurant details'**
  String get mapSheetRestaurantDetails;

  /// No description provided for @mapFilterAction.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get mapFilterAction;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
