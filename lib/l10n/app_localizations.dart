import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Emplake'**
  String get appTitle;

  /// No description provided for @loginAppBar.
  ///
  /// In en, this message translates to:
  /// **'Emplake - Sign in'**
  String get loginAppBar;

  /// No description provided for @projectTitle.
  ///
  /// In en, this message translates to:
  /// **'Reverse Engineering Project - Emplake'**
  String get projectTitle;

  /// No description provided for @credits.
  ///
  /// In en, this message translates to:
  /// **'Developed by: {names}'**
  String credits(String names);

  /// No description provided for @gameTitle.
  ///
  /// In en, this message translates to:
  /// **'Emplake Challenge'**
  String get gameTitle;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level:'**
  String get level;

  /// No description provided for @easy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get easy;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get medium;

  /// No description provided for @advanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advanced;

  /// No description provided for @hard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get hard;

  /// No description provided for @challengeLabel.
  ///
  /// In en, this message translates to:
  /// **'Tap a slot and pick the signs that connect the numbers.'**
  String get challengeLabel;

  /// No description provided for @yourFormula.
  ///
  /// In en, this message translates to:
  /// **'Your formula:'**
  String get yourFormula;

  /// No description provided for @formulaHint.
  ///
  /// In en, this message translates to:
  /// **'Pick the signs in the slots...'**
  String get formulaHint;

  /// No description provided for @latexLabel.
  ///
  /// In en, this message translates to:
  /// **'LaTeX rendering:'**
  String get latexLabel;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip this number'**
  String get skip;

  /// No description provided for @nextChallenge.
  ///
  /// In en, this message translates to:
  /// **'Next number'**
  String get nextChallenge;

  /// No description provided for @errUseAllDigits.
  ///
  /// In en, this message translates to:
  /// **'Use all 4 digits, in order.'**
  String get errUseAllDigits;

  /// No description provided for @errNeedEquals.
  ///
  /// In en, this message translates to:
  /// **'The expression must contain an equals sign (=).'**
  String get errNeedEquals;

  /// No description provided for @errBothSides.
  ///
  /// In en, this message translates to:
  /// **'Build an expression on both sides of the equals sign (=).'**
  String get errBothSides;

  /// No description provided for @errInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid expression.'**
  String get errInvalid;

  /// No description provided for @errNonInteger.
  ///
  /// In en, this message translates to:
  /// **'This level does not allow division with a non-integer result!'**
  String get errNonInteger;

  /// No description provided for @errDivZero.
  ///
  /// In en, this message translates to:
  /// **'Division by zero is not allowed.'**
  String get errDivZero;

  /// No description provided for @errDomain.
  ///
  /// In en, this message translates to:
  /// **'Operation out of the allowed domain (negative root, invalid factorial or value too large).'**
  String get errDomain;

  /// No description provided for @errOperatorNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'The operator {op} is not allowed at this level.'**
  String errOperatorNotAllowed(String op);

  /// No description provided for @notEqual.
  ///
  /// In en, this message translates to:
  /// **'The equality is false: {left} ≠ {right}'**
  String notEqual(String left, String right);

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! Challenge solved! 🎉'**
  String get success;

  /// No description provided for @saveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save your progress to the cloud.'**
  String get saveError;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'Solved Challenges'**
  String get history;

  /// No description provided for @historyError.
  ///
  /// In en, this message translates to:
  /// **'Error loading history from Firestore.'**
  String get historyError;

  /// No description provided for @historyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No challenges solved yet.\nStart playing to save your wins!'**
  String get historyEmpty;

  /// No description provided for @historyDigits.
  ///
  /// In en, this message translates to:
  /// **'Digits: {digits}'**
  String historyDigits(String digits);

  /// No description provided for @historyFormula.
  ///
  /// In en, this message translates to:
  /// **'Formula: {formula}'**
  String historyFormula(String formula);

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @typography.
  ///
  /// In en, this message translates to:
  /// **'Typography'**
  String get typography;

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get themeMode;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @seedColor.
  ///
  /// In en, this message translates to:
  /// **'Theme Seed Color'**
  String get seedColor;

  /// No description provided for @fontSize.
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get fontSize;

  /// No description provided for @fontFamily.
  ///
  /// In en, this message translates to:
  /// **'Font Type'**
  String get fontFamily;

  /// No description provided for @soundEnabled.
  ///
  /// In en, this message translates to:
  /// **'Background music'**
  String get soundEnabled;

  /// No description provided for @soundSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Off by default'**
  String get soundSubtitle;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @helpTitle.
  ///
  /// In en, this message translates to:
  /// **'How to Play Emplake'**
  String get helpTitle;

  /// No description provided for @helpDetails.
  ///
  /// In en, this message translates to:
  /// **'1. Choose your level.\n2. You get 4 fixed numbers. Tap a slot (between the numbers) and pick signs on the keyboard; an empty slot joins the numbers (1 and 2 become 12).\n3. Use the = sign exactly once and build a true equality.\n4. Easy allows non-integer division. On the other levels, division must be exact.\n5. Tap a placed sign to remove it. Use Skip to get another number.'**
  String get helpDetails;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @historySolvedOn.
  ///
  /// In en, this message translates to:
  /// **'Solved on: {date}'**
  String historySolvedOn(String date);

  /// No description provided for @authFailed.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed. Please try again.'**
  String get authFailed;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get logout;

  /// No description provided for @unknownDate.
  ///
  /// In en, this message translates to:
  /// **'unknown date'**
  String get unknownDate;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'pt': return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
