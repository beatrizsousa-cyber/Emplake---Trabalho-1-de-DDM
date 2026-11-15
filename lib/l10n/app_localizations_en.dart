// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Emplake';

  @override
  String get loginAppBar => 'Emplake - Sign in';

  @override
  String get projectTitle => 'Reverse Engineering Project - Emplake';

  @override
  String credits(String names) {
    return 'Developed by: $names';
  }

  @override
  String get gameTitle => 'Emplake Challenge';

  @override
  String get level => 'Level:';

  @override
  String get easy => 'Easy';

  @override
  String get medium => 'Intermediate';

  @override
  String get advanced => 'Advanced';

  @override
  String get hard => 'Hard';

  @override
  String get challengeLabel => 'Tap a slot and pick the signs that connect the numbers.';

  @override
  String get yourFormula => 'Your formula:';

  @override
  String get formulaHint => 'Pick the signs in the slots...';

  @override
  String get latexLabel => 'LaTeX rendering:';

  @override
  String get undo => 'Undo';

  @override
  String get clear => 'Clear';

  @override
  String get verify => 'Verify';

  @override
  String get skip => 'Skip this number';

  @override
  String get nextChallenge => 'Next number';

  @override
  String get errUseAllDigits => 'Use all 4 digits, in order.';

  @override
  String get errNeedEquals => 'The expression must contain an equals sign (=).';

  @override
  String get errBothSides => 'Build an expression on both sides of the equals sign (=).';

  @override
  String get errInvalid => 'Invalid expression.';

  @override
  String get errNonInteger => 'This level does not allow division with a non-integer result!';

  @override
  String get errDivZero => 'Division by zero is not allowed.';

  @override
  String get errDomain => 'Operation out of the allowed domain (negative root, invalid factorial or value too large).';

  @override
  String errOperatorNotAllowed(String op) {
    return 'The operator $op is not allowed at this level.';
  }

  @override
  String notEqual(String left, String right) {
    return 'The equality is false: $left ≠ $right';
  }

  @override
  String get success => 'Congratulations! Challenge solved! 🎉';

  @override
  String get saveError => 'Could not save your progress to the cloud.';

  @override
  String get history => 'Solved Challenges';

  @override
  String get historyError => 'Error loading history from Firestore.';

  @override
  String get historyEmpty => 'No challenges solved yet.\nStart playing to save your wins!';

  @override
  String historyDigits(String digits) {
    return 'Digits: $digits';
  }

  @override
  String historyFormula(String formula) {
    return 'Formula: $formula';
  }

  @override
  String get settings => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get typography => 'Typography';

  @override
  String get themeMode => 'Theme Mode';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get seedColor => 'Theme Seed Color';

  @override
  String get fontSize => 'Font Size';

  @override
  String get fontFamily => 'Font Type';

  @override
  String get soundEnabled => 'Background music';

  @override
  String get soundSubtitle => 'Off by default';

  @override
  String get help => 'Help';

  @override
  String get helpTitle => 'How to Play Emplake';

  @override
  String get helpDetails => '1. Choose your level.\n2. You get 4 fixed numbers. Tap a slot (between the numbers) and pick signs on the keyboard; an empty slot joins the numbers (1 and 2 become 12).\n3. Use the = sign exactly once and build a true equality.\n4. Easy allows non-integer division. On the other levels, division must be exact.\n5. Tap a placed sign to remove it. Use Skip to get another number.';

  @override
  String get gotIt => 'Got it';

  @override
  String historySolvedOn(String date) {
    return 'Solved on: $date';
  }

  @override
  String get authFailed => 'Authentication failed. Please try again.';

  @override
  String get logout => 'Sign out';

  @override
  String get unknownDate => 'unknown date';
}
